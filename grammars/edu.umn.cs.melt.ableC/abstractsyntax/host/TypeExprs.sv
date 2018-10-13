grammar edu:umn:cs:melt:ableC:abstractsyntax:host;

{-- In order to accomodate C's odd-ball syntax when it comes to type declarations
 - (with specifiers separate from declarators) we have a divided Type Expressions
 - abstract syntax.
 -
 - BaseTypeExpr represents specifiers: structs, typedefs, ints, etc
 - TypeModifierExpr represents declarators: pointers, arrays, functions, etc.
 -
 - We can't merge these into one TypeExpr because a BaseTypeExpr might be
 - used as part of several declarators.
 - For example, "struct { ... } bar, *baz;"
 - Here, we declare two variables: bar and baz. one of the anonymous struct
 - type, the other a pointer to it. However, we must NOT duplicate the
 - declaration of the struct!
 - That is, we cannot represent it as "struct { ... } bar; struct { ... } *baz;"
 - because that redeclares the type.
 -
 - Our solution is to have a BaseTypeExpr for a declarations, followed by
 - several identifiers each with their own TypeModifierExpr.
 - This way, the struct appears once in the abstract syntax.
 -
 - TypeModifierExpr are terminated by "baseTypeExpr" which provides a typerep
 - value that is equal to the Type obtained from the corresponding BaseTypeExpr.
 - 
 - Invariant: a BaseTypeExpr and its corresponding TypeModifierExpr should have
 - the same environment
 -
 - Since BaseTypeExpr may contain new declarations, another invariant is that
 - extension productions containing a BaseTypeExpr must forward to a tree
 - containing that BaseTypeExpr exactly once.  However, they are free to use
 - directTypeExpr(ty.typerep) as many times as needed.    
 -}

autocopy attribute baseType :: Type;

{-- The TypeExpr is upside down, so build pp from outside-in -}
synthesized attribute lpp :: Document;
synthesized attribute rpp :: Document;

{-- Resolve the TypeExpr into a Type -}
synthesized attribute typerep :: Type;
synthesized attribute typereps :: [Type];

{-- Used to transform away typeModifierTypeExpr -}
synthesized attribute typeModifiers :: [TypeModifierExpr];
autocopy attribute typeModifiersIn :: [TypeModifierExpr];

{-- Used to set the refId for a declaration via __attribute__ -}
autocopy attribute givenRefId :: Maybe<String>;

{-- The declarations contained in this TypeExpr, corresponding to defs -}
-- TODO: Missing defs/decls contained inside Parameters?
synthesized attribute decls :: [Decl];

{-- Util attributes -}
synthesized attribute bty :: BaseTypeExpr;
synthesized attribute mty :: TypeModifierExpr;

nonterminal TypeName with env, typerep, bty, mty, pp, host<TypeName>, lifted<TypeName>, errors, globalDecls, decls, defs, returnType, freeVariables;
flowtype TypeName = decorate {env, returnType}, bty {}, mty {}, decls {decorate};

abstract production typeName
top::TypeName ::= bty::BaseTypeExpr  mty::TypeModifierExpr
{
  propagate host, lifted;
  top.pp = ppConcat([bty.pp, mty.lpp, mty.rpp]);
  top.typerep = mty.typerep;
  top.bty = bty;
  top.mty = mty;
  bty.givenRefId = nothing();
  mty.baseType = bty.typerep;
  mty.typeModifiersIn = bty.typeModifiers;
  top.errors := bty.errors ++ mty.errors;
  top.globalDecls := bty.globalDecls ++ mty.globalDecls;
  top.decls = bty.decls;
  top.defs := bty.defs;
  top.freeVariables = bty.freeVariables ++ mty.freeVariables;
}


{--
 - Corresponds to types obtainable from a TypeSpecifiers.
 -}
nonterminal BaseTypeExpr with env, typerep, pp, host<BaseTypeExpr>, lifted<BaseTypeExpr>, errors, globalDecls, typeModifiers, decls, defs, givenRefId, returnType, freeVariables;
flowtype BaseTypeExpr = decorate {env, givenRefId, returnType}, typeModifiers {decorate}, decls {decorate};

abstract production errorTypeExpr
top::BaseTypeExpr ::= msg::[Message]
{
  propagate host, lifted;
  top.pp = pp"/*err*/";
  top.typerep = errorType();
  top.errors := msg;
  top.globalDecls := [];
  top.typeModifiers = [];
  top.decls = [];
  top.defs := [];
  top.freeVariables = [];
}

{-- Raise messages about something syntactic but return ty as the reported type. -}
abstract production warnTypeExpr
top::BaseTypeExpr ::= msg::[Message]  ty::BaseTypeExpr
{
  propagate host, lifted;
  top.pp = ty.pp;
  top.typerep = ty.typerep;
  top.errors := msg ++ ty.errors;
  top.globalDecls := ty.globalDecls;
  top.typeModifiers = ty.typeModifiers;
  top.decls = ty.decls;
  top.defs := ty.defs;
  top.freeVariables = ty.freeVariables;
}

{-- A TypeExpr that converts a Type back into a TypeExpr
 - This production is NOT considered part of the host, since Type should not occur in the host tree.
 - Instead we transform the parameter type into a TypeExpr and forward to that.
 - Note that directTypeExpr(te.typerep) is not necessarily equivalent to te, since TypeNames can
 - contain extra information relevant only to the declaration, not to the meaning of the type.  
 - However, directTypeExpr(ty).typerep should be the same as ty, and
 - directTypeExpr(te.typerep).host.pp should be the same as te.typerep.pp
 -}
abstract production directTypeExpr
top::BaseTypeExpr ::= result::Type
{
  top.pp = parens(cat(result.lpp, result.rpp));
  forwards to typeModifierTypeExpr(result.baseTypeExpr, result.typeModifierExpr);
}

{-- A TypeExpr that contains extra extension defs to be placed in the environment
 - This production should not occur in the host AST
 -}
abstract production defsTypeExpr
top::BaseTypeExpr ::= d::[Def]  bty::BaseTypeExpr
{
  propagate lifted;
  top.pp = ppConcat([pp"/* defsTypeExpr", showEnv(addEnv(d, emptyEnv())), pp"*/", bty.pp]);
  -- This production goes away when the transformation to host occurs, this is a special case where
  -- host is not simply propagated, because Def is a closed 'collection' nonterminal with special
  -- semantics
  top.host = bty.host;
  top.typerep = bty.typerep;
  top.errors := bty.errors;
  top.globalDecls := bty.globalDecls;
  top.typeModifiers = bty.typeModifiers;
  top.decls = defsDecl(d) :: bty.decls;
  top.defs := d ++ bty.defs;
  top.freeVariables = bty.freeVariables;
  
  bty.env = addEnv(d, top.env);
}

{-- A TypeExpr that contains a type modifier which must be lifted out
 - This production should not occur in the lifted AST
 -}
abstract production typeModifierTypeExpr
top::BaseTypeExpr ::= bty::BaseTypeExpr  mty::TypeModifierExpr
{
  propagate host;
  top.pp = parens(ppConcat([bty.pp, mty.lpp, mty.rpp]));
  top.lifted = bty.lifted;
  top.typerep = mty.typerep;
  mty.baseType = bty.typerep;
  mty.typeModifiersIn = bty.typeModifiers;
  top.errors := bty.errors ++ mty.errors;
  top.globalDecls := bty.globalDecls ++ mty.globalDecls;
  top.typeModifiers = mty :: bty.typeModifiers;
  top.decls = bty.decls;
  top.defs := bty.defs;
  top.freeVariables = bty.freeVariables ++ mty.freeVariables;
}

{-- Builtin C types: void, unsigned int, signed char, float, bool, etc.
 - also includes complex numbers e.g. 'float _Complex' -}
abstract production builtinTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  result::BuiltinType
{
  propagate host, lifted;
  top.pp = ppConcat([terminate(space(), q.pps), result.pp]);
  top.typerep = builtinType(q, result);
  top.errors := q.errors;
  top.globalDecls := [];
  top.typeModifiers = [];
  top.decls = [];
  top.defs := [];
  top.freeVariables = [];
  q.typeToQualify = top.typerep;
}

{-- A reference to a tag type. e.g. 'struct foo' not 'struct foo {...}' -}
abstract production tagReferenceTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  kwd::StructOrEnumOrUnion  name::Name
{
  propagate host, lifted;
  top.pp = ppConcat([terminate(space(), q.pps), kwd.pp, space(), name.pp
    -- DEBUGGING
    --, text("/*" ++ refId ++ "*/")
    -- END DEBUGGING
    ]);

  -- This code is nassssty. TODO. Possibly split enum references to a separate production? This might simplify the logic considerably.

  local tags :: [TagItem] = lookupTag(name.name, top.env);
  
  top.typerep =
    case kwd, tags of
    -- It's an enum and we see the declaration.
    | enumSEU(), enumTagItem(d) :: _ -> extType(q, enumExtType(d))
    -- We don't see the declaration, so we're adding it.
    | _, [] -> extType(q, refIdExtType(kwd, name.name, fromMaybe(name.tagRefId, top.givenRefId)))
    -- It's a struct/union and the tag type agrees.
    | structSEU(), refIdTagItem(structSEU(), rid) :: _ -> extType(q, refIdExtType(kwd, name.name, rid))
    | unionSEU(), refIdTagItem(unionSEU(), rid) :: _ -> extType(q, refIdExtType(kwd, name.name, rid))
    -- Otherwise, error!
    | _, _ -> errorType()
    end;
  
  top.errors :=
    q.errors ++
    case kwd, tags of
    -- It's an enum and we see the declaration.
    | enumSEU(), enumTagItem(d) :: _ -> []
    | enumSEU(), [] -> [err(name.location, "Undeclared enum " ++ name.name)]
    | enumSEU(), _ :: _ -> [err(name.location, "Tag " ++ name.name ++ " is not an enum")]
    -- We don't see the declaration, so we're adding it.
    | _, [] -> []
    -- It's a struct/union and the tag type agrees.
    | structSEU(), refIdTagItem(structSEU(), rid) :: _ -> []
    | structSEU(), _ :: _ -> [err(name.location, "Tag " ++ name.name ++ " is not a struct")]
    | unionSEU(), refIdTagItem(unionSEU(), rid) :: _ -> []
    | unionSEU(), _ :: _ -> [err(name.location, "Tag " ++ name.name ++ " is not a union")]
    end;
  
  top.globalDecls := [];
  top.typeModifiers = [];
  top.decls = [];
  
  top.defs :=
    case kwd, tags of
    -- It's an enum and we see the declaration.
    | enumSEU(), enumTagItem(d) :: _ -> []
    -- We don't see the declaration, so we're adding it.
    | _, [] -> [tagDef(name.name, refIdTagItem(kwd, fromMaybe(name.tagRefId, top.givenRefId)))]
    -- It's a struct/union and the tag type agrees.
    | structSEU(), refIdTagItem(structSEU(), rid) :: _ -> []
    | unionSEU(), refIdTagItem(unionSEU(), rid) :: _ -> []
    -- Otherwise, error!
    | _, _ -> []
    end;
  
  top.freeVariables = [];
  
  q.typeToQualify = top.typerep;
}

{-- An actual declaration of, not reference to, a struct. -}
abstract production structTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  def::StructDecl
{
  propagate host, lifted;
  top.pp = ppConcat([terminate(space(), q.pps), def.pp ]);
  local name :: String = 
    case def.maybename of
    | just(n) -> n.name
    -- TODO: Figure out how to properly handle anon structs
    | nothing() -> "<anon>"
    end;
  top.typerep = extType(q, refIdExtType(structSEU(), name, def.refId));
  top.errors := q.errors ++ def.errors;
  top.globalDecls := def.globalDecls;
  top.typeModifiers = [];
  top.decls = [typeExprDecl(nilAttribute(), top)];
  top.defs := def.defs;
  top.freeVariables = [];
  q.typeToQualify = top.typerep;
}

{-- An actual declaration of, not reference to, a union. -}
abstract production unionTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  def::UnionDecl
{
  propagate host, lifted;
  top.pp = ppConcat([terminate(space(), q.pps), def.pp ]);
  local name :: String = 
    case def.maybename of
    | just(n) -> n.name
    -- TODO: Figure out how to properly handle anon unions
    | nothing() -> "<anon>"
    end;
  top.typerep = extType(q, refIdExtType(unionSEU(), name, def.refId));
  top.errors := q.errors ++ def.errors;
  top.globalDecls := def.globalDecls;
  top.typeModifiers = [];
  top.decls = [typeExprDecl(nilAttribute(), top)];
  top.defs := def.defs;
  top.freeVariables = [];
  q.typeToQualify = top.typerep;
}

{-- An actual declaration of, not reference to, an enum. -}
abstract production enumTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  def::EnumDecl
{
  propagate host, lifted;
  top.pp = ppConcat([terminate(space(), q.pps), def.pp ]);
  top.typerep = extType(q, enumExtType(def));
  top.errors := q.errors ++ def.errors;
  top.globalDecls := def.globalDecls;
  top.typeModifiers = [];
  top.decls = [typeExprDecl(nilAttribute(), top)];
  top.defs := def.defs;
  top.freeVariables = [];
  q.typeToQualify = top.typerep;
}

{-- Extension "new" types -}
abstract production extTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  sub::ExtType
{
  top.typerep = extType(q, sub);
  propagate lifted;
  top.host = directTypeExpr(sub.host);
  top.pp = sub.pp;
  top.errors := q.errors;
  top.globalDecls := [];
  top.typeModifiers = [];
  top.decls = [];
  top.defs := [];
  top.freeVariables = sub.freeVariables;
  q.typeToQualify = top.typerep;
  sub.givenQualifiers = q;
}

{-- A name, that needs to be looked up. -}
abstract production typedefTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  name::Name
{
  propagate host, lifted;
  top.pp = ppConcat([terminate(space(), q.pps), name.pp ]);
  
  top.typerep = 
    if !null(name.valueLookupCheck) then errorType()
    else noncanonicalType(typedefType(q, name.name, addQualifiers(q.qualifiers, name.valueItem.typerep)));
  top.errors := q.errors;
  top.globalDecls := [];
  top.typeModifiers = [];
  top.decls = [];
  top.defs := [];
  top.freeVariables = [];
  
  top.errors <- name.valueLookupCheck;
  top.errors <-
    if name.valueItem.isItemType then []
    else [err(name.location, "'" ++ name.name ++ "' does not refer to a type.")];
  q.typeToQualify = top.typerep;
}
{--
 - GCC __attribute__ types
 - Note that there is no corresponding type expression in C for an attributed type, as attributes
 - can only be attatched on declarations.  Thus this production is never actually introduced by
 - concrete syntax, but it can be created when translating a transformed attributed type back to a
 - BaseTypeExpr.  To enable this, we must lift a typedef with the appropriate attributes and refer
 - to that.  
 -}
abstract production attributedTypeExpr
top::BaseTypeExpr ::= attrs::Attributes  bt::BaseTypeExpr
{
  top.pp = cat(ppAttributes(attrs), bt.pp);

  local liftedName::Name =
    name(s"_attributedType_${toString(genInt())}", location=builtinLoc("host"));
  forwards to
    -- TODO: We can currently only lift to the global level, but this should be lifted to the closest scope
    injectGlobalDeclsTypeExpr(
      consDecl(
        typedefDecls(
          attrs, bt,
          consDeclarator(
            declarator(liftedName, baseTypeExpr(), nilAttribute(), nothingInitializer()),
            nilDeclarator())),
        nilDecl()),
      typedefTypeExpr(nilQualifier(), liftedName));
}
{-- C11 atomic type -}
abstract production atomicTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  wrapped::TypeName
{
  top.typerep = atomicType(q, wrapped.typerep);
  propagate host, lifted;
  top.pp = ppConcat([ terminate(space(), q.pps),
                     text("_Atomic"), parens(wrapped.pp)]);
  top.errors := q.errors ++ wrapped.errors;
  top.globalDecls := wrapped.globalDecls;
  top.typeModifiers = [];
  top.decls = wrapped.decls;
  top.defs := wrapped.defs;
  top.freeVariables = wrapped.freeVariables;
  q.typeToQualify = top.typerep;
}
{-- GCC builtin type -}
abstract production vaListTypeExpr
top::BaseTypeExpr ::=
{
  top.typerep = pointerType(nilQualifier(),
    builtinType(nilQualifier(), voidType())); -- TODO this should be a special type, not void
  propagate host, lifted;
  top.pp = text("__builtin_va_list");
  top.errors := [];
  top.globalDecls := [];
  top.typeModifiers = [];
  top.decls = [];
  top.defs := [];
  top.freeVariables = [];
  
}
{-- GCC typeof type -}
abstract production typeofTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  e::ExprOrTypeName
{
  top.typerep = noncanonicalType(typeofType(q, e.typerep));
  propagate host, lifted;
  top.pp = ppConcat([text("__typeof__"), parens(e.pp)]);
  top.errors := q.errors ++ e.errors;
  top.globalDecls := e.globalDecls;
  top.typeModifiers = [];
  top.decls = [];
  top.defs := e.defs;
  top.freeVariables = e.freeVariables;
  q.typeToQualify = top.typerep;
}


{--
 - Mirrors Type somewhat, but these depend upon the environment.
 - Typically, these are just anchored somewhere to obtain the env,
 - and then turn into an environment-independent Type.
 -}
nonterminal TypeModifierExpr with env, typerep, lpp, rpp, host<TypeModifierExpr>, lifted<TypeModifierExpr>, isFunctionArrayTypeExpr, baseType, typeModifiersIn, errors, globalDecls, returnType, freeVariables;
flowtype TypeModifierExpr = decorate {env, baseType, typeModifiersIn, returnType}, isFunctionArrayTypeExpr {};

synthesized attribute isFunctionArrayTypeExpr::Boolean;

aspect default production
top::TypeModifierExpr ::=
{
  top.isFunctionArrayTypeExpr = false;
}

{--
 - A TypeModifierExpr that corresponds to whatever the base TypeExpr was.  
 - This gets transformed via lifted to include type modifiers that were included in the base
 - TypeExpr via typeModifierTypeExpr.  
 -}
abstract production baseTypeExpr
top::TypeModifierExpr ::=
{
  propagate host;
  top.lpp = notext();
  top.rpp = notext();
  top.lifted = if !null(top.typeModifiersIn) then mty.lifted else baseTypeExpr();
  
  local mty::TypeModifierExpr = head(top.typeModifiersIn);
  mty.env = top.env;
  mty.baseType = top.typerep;
  mty.typeModifiersIn = tail(top.typeModifiersIn);
  mty.returnType = top.returnType;
  
  top.typerep = top.baseType; 
  top.errors := [];
  top.globalDecls := [];
  top.freeVariables = [];
}

{-- Pointers -}
abstract production pointerTypeExpr
top::TypeModifierExpr ::= q::Qualifiers  target::TypeModifierExpr
{
  propagate host, lifted;
  top.lpp = ppConcat([ target.lpp, space(),
                     if target.isFunctionArrayTypeExpr then text("(*") else text("*"),
                     terminate(space(), q.pps) ]);
  top.rpp = cat(if target.isFunctionArrayTypeExpr then text(")") else notext(), target.rpp);
  top.typerep = pointerType(q, target.typerep);
  top.errors := q.errors ++ target.errors;
  top.globalDecls := target.globalDecls;
  top.freeVariables = target.freeVariables;
  q.typeToQualify = top.typerep;
}

{-- Arrays (constant, variable, etc) -}
abstract production arrayTypeExprWithExpr
top::TypeModifierExpr ::= element::TypeModifierExpr  indexQualifiers::Qualifiers  sizeModifier::ArraySizeModifier  size::Expr
{
  propagate host, lifted;
  top.lpp = element.lpp;
  
  top.rpp = cat(brackets(ppConcat([
    terminate(space(), indexQualifiers.pps ++ sizeModifier.pps),
    size.pp
    ])), element.rpp);
  
  top.isFunctionArrayTypeExpr = true;

  top.typerep =
    arrayType(
      element.typerep, indexQualifiers, sizeModifier,
      case size.integerConstantValue of
        just(v) -> constantArrayType(v)
      | nothing() -> variableArrayType(size)
      end);
  top.errors := element.errors ++ size.errors;
  top.globalDecls := element.globalDecls ++ size.globalDecls;
  top.freeVariables = element.freeVariables ++ size.freeVariables;
}
abstract production arrayTypeExprWithoutExpr
top::TypeModifierExpr ::= element::TypeModifierExpr  indexQualifiers::Qualifiers  sizeModifier::ArraySizeModifier
{
  propagate host, lifted;
  top.lpp = element.lpp;
  
  top.rpp = cat(brackets(
    ppImplode(space(), indexQualifiers.pps ++ sizeModifier.pps)
    ), element.rpp);
  
  top.isFunctionArrayTypeExpr = true;

  top.typerep = arrayType(element.typerep, indexQualifiers, sizeModifier, incompleteArrayType());
  top.errors := element.errors ++ indexQualifiers.errors;
  top.globalDecls := element.globalDecls;
  top.freeVariables = element.freeVariables;
  indexQualifiers.typeToQualify = top.typerep;
}

{-- Functions (with or without args) -}
abstract production functionTypeExprWithArgs
top::TypeModifierExpr ::= result::TypeModifierExpr  args::Parameters  variadic::Boolean  q::Qualifiers
{
  propagate host, lifted;
  top.lpp = ppConcat([ result.lpp ]);

  top.rpp = 
    cat(parens(
      if null(args.pps) 
      then text("void")
      else ppImplode(text(", "), 
            (if variadic then args.pps ++ [text("...")] else args.pps) 
           )
     ), result.rpp);
  
  top.isFunctionArrayTypeExpr = true;
  
  top.typerep = functionType(result.typerep, 
                             protoFunctionType(args.typereps, variadic), q);
  top.errors := result.errors ++ args.errors;
  top.globalDecls := result.globalDecls ++ args.globalDecls;
  top.freeVariables = result.freeVariables;
  
  args.env = openScopeEnv(top.env);
  args.position = 0;
}
abstract production functionTypeExprWithoutArgs
top::TypeModifierExpr ::= result::TypeModifierExpr  ids::[Name]  q::Qualifiers --fnquals::[SpecialSpecifier]
{
  propagate host, lifted;
  top.lpp = result.lpp;
  top.rpp = cat( parens(ppImplode(text(", "), map((.pp), ids))), result.rpp );
  
  top.isFunctionArrayTypeExpr = true;
  
  top.typerep = functionType(result.typerep, noProtoFunctionType(), q);
  top.errors := result.errors;
  top.globalDecls := result.globalDecls;
  top.freeVariables = result.freeVariables;
}
{-- Parens -}
abstract production parenTypeExpr
top::TypeModifierExpr ::= wrapped::TypeModifierExpr
{
  propagate host, lifted;
  --top.pp = parens( wrapped.pp );
  top.lpp = cat( wrapped.lpp, text("(") );
  top.rpp = cat( text(")"), wrapped.rpp );

  top.typerep = noncanonicalType(parenType(wrapped.typerep));
  top.errors := wrapped.errors;
  top.globalDecls := wrapped.globalDecls;
  top.freeVariables = wrapped.freeVariables;
}

autocopy attribute appendedTypeNames :: TypeNames;
synthesized attribute appendedTypeNamesRes :: TypeNames;

nonterminal TypeNames with pps, host<TypeNames>, lifted<TypeNames>, env, typereps, count, errors, globalDecls, decls, defs, returnType, freeVariables, appendedTypeNames, appendedTypeNamesRes;
flowtype TypeNames = decorate {env, returnType}, decls {decorate}, count {}, appendedTypeNamesRes {appendedTypeNames};

abstract production consTypeName
top::TypeNames ::= h::TypeName t::TypeNames
{
  propagate host, lifted;
  top.pps = h.pp :: t.pps;
  top.typereps = h.typerep :: t.typereps;
  top.count = t.count + 1;
  top.errors := h.errors ++ t.errors;
  top.globalDecls := h.globalDecls ++ t.globalDecls;
  top.decls = h.decls ++ t.decls;
  top.defs := h.defs ++ t.defs;
  top.freeVariables = h.freeVariables ++ t.freeVariables;
  top.appendedTypeNamesRes = consTypeName(h, t.appendedTypeNamesRes);
  
  t.env = addEnv(h.defs, h.env);
}

abstract production nilTypeName
top::TypeNames ::= 
{
  propagate host, lifted;
  top.pps = [];
  top.typereps = [];
  top.count = 0;
  top.errors := [];
  top.globalDecls := [];
  top.decls = [];
  top.defs := [];
  top.freeVariables = [];
  top.appendedTypeNamesRes = top.appendedTypeNames;
}

function appendTypeNames
TypeNames ::= e1::TypeNames e2::TypeNames
{
  e1.appendedTypeNames = e2;
  return e1.appendedTypeNamesRes;
}
