grammar edu:umn:cs:melt:ableC:abstractsyntax:overloadable;

imports core:monad;

imports silver:langutil;
imports silver:langutil:pp with implode as ppImplode, concat as ppConcat;

imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;

imports edu:umn:cs:melt:ableC:abstractsyntax:host as host;
imports edu:umn:cs:melt:ableC:abstractsyntax:injectable as inj;

-- Useful defs to make signatures more managable
type UnaryProd = (host:Expr ::= host:Expr Location);
type BinaryProd = (host:Expr ::= host:Expr host:Expr Location);

synthesized attribute arraySubscriptProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype arraySubscriptProd {} on host:Type, host:ExtType;

synthesized attribute callProd<a>::Maybe<a>;
attribute callProd<(host:Expr ::= host:Exprs Location)> occurs on host:Expr;
attribute callProd<(host:Expr ::= host:Expr host:Exprs Location)> occurs on host:Type, host:ExtType;
flowtype callProd {decorate} on host:Expr, host:Type, host:ExtType;

inherited attribute isDeref::Boolean occurs on host:Type;
synthesized attribute callMemberProd<a>::Maybe<a>;
attribute callMemberProd<(host:Expr ::= host:Expr host:Name host:Exprs Location)> occurs on host:Type;
attribute callMemberProd<(host:Expr ::= host:Expr Boolean host:Name host:Exprs Location)> occurs on host:ExtType;
flowtype callMemberProd {isDeref} on host:Type;
flowtype callMemberProd {} on host:ExtType;

synthesized attribute memberProd<a>::Maybe<a>;
attribute memberProd<(host:Expr ::= host:Expr host:Name Location)> occurs on host:Type;
attribute memberProd<(host:Expr ::= host:Expr Boolean host:Name Location)> occurs on host:ExtType;
flowtype memberProd {isDeref} on host:Type;
flowtype memberProd {} on host:ExtType;

synthesized attribute preIncProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype preIncProd {} on host:Type, host:ExtType;

synthesized attribute preDecProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype preDecProd {} on host:Type, host:ExtType;

synthesized attribute postIncProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype postIncProd {} on host:Type, host:ExtType;

synthesized attribute postDecProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype postDecProd {} on host:Type, host:ExtType;

synthesized attribute addressOfProd<a>::Maybe<a>;
attribute addressOfProd<(host:Expr ::= Location)> occurs on host:Expr;
attribute addressOfProd<UnaryProd> occurs on host:Type, host:ExtType;
flowtype addressOfProd {decorate} on host:Expr, host:Type, host:ExtType;

synthesized attribute addressOfArraySubscriptProd::Maybe<(host:Expr ::= host:Expr host:Expr Location)> occurs on host:Type, host:ExtType;
flowtype addressOfArraySubscriptProd {} on host:Type, host:ExtType;

synthesized attribute addressOfCallProd::Maybe<(host:Expr ::= host:Expr host:Exprs Location)> occurs on host:Type, host:ExtType;
flowtype addressOfCallProd {} on host:Type, host:ExtType;

synthesized attribute addressOfMemberProd<a>::Maybe<a>;
attribute addressOfMemberProd<(host:Expr ::= host:Expr host:Name Location)> occurs on host:Type;
attribute addressOfMemberProd<(host:Expr ::= host:Expr Boolean host:Name Location)> occurs on host:ExtType;
flowtype addressOfMemberProd {isDeref} on host:Type;
flowtype addressOfMemberProd {} on host:ExtType;

synthesized attribute dereferenceProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype dereferenceProd {} on host:Type, host:ExtType;

synthesized attribute positiveProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype positiveProd {} on host:Type, host:ExtType;

synthesized attribute negativeProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype negativeProd {} on host:Type, host:ExtType;

synthesized attribute bitNegateProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype bitNegateProd {} on host:Type, host:ExtType;

synthesized attribute notProd::Maybe<UnaryProd> occurs on host:Type, host:ExtType;
flowtype notProd {} on host:Type, host:ExtType;

inherited attribute otherType::host:Type occurs on host:Type, host:ExtType;

synthesized attribute lEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lMulEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lMulEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rMulEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rMulEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lDivEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lDivEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rDivEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rDivEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lModEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lModEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rModEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rModEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lAddEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lAddEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rAddEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rAddEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lSubEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lSubEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rSubEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rSubEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lLshEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lLshEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rLshEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rLshEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lRshEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lRshEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rRshEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rRshEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lAndEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lAndEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rAndEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rAndEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lXorEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lXorEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rXorEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rXorEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lOrEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lOrEqProd {otherType} on host:Type, host:ExtType;
synthesized attribute rOrEqProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rOrEqProd {otherType} on host:Type, host:ExtType;

synthesized attribute lAndProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lAndProd {otherType} on host:Type, host:ExtType;
synthesized attribute rAndProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rAndProd {otherType} on host:Type, host:ExtType;

synthesized attribute lOrProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lOrProd {otherType} on host:Type, host:ExtType;
synthesized attribute rOrProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rOrProd {otherType} on host:Type, host:ExtType;

synthesized attribute lAndBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lAndBitProd {otherType} on host:Type, host:ExtType;
synthesized attribute rAndBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rAndBitProd {otherType} on host:Type, host:ExtType;

synthesized attribute lOrBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lOrBitProd {otherType} on host:Type, host:ExtType;
synthesized attribute rOrBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rOrBitProd {otherType} on host:Type, host:ExtType;

synthesized attribute lXorProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lXorProd {otherType} on host:Type, host:ExtType;
synthesized attribute rXorProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rXorProd {otherType} on host:Type, host:ExtType;

synthesized attribute lLshBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lLshBitProd {otherType} on host:Type, host:ExtType;
synthesized attribute rLshBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rLshBitProd {otherType} on host:Type, host:ExtType;

synthesized attribute lRshBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lRshBitProd {otherType} on host:Type, host:ExtType;
synthesized attribute rRshBitProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rRshBitProd {otherType} on host:Type, host:ExtType;

synthesized attribute lEqualsProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lEqualsProd {otherType} on host:Type, host:ExtType;
synthesized attribute rEqualsProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rEqualsProd {otherType} on host:Type, host:ExtType;

synthesized attribute lNotEqualsProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lNotEqualsProd {otherType} on host:Type, host:ExtType;
synthesized attribute rNotEqualsProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rNotEqualsProd {otherType} on host:Type, host:ExtType;

synthesized attribute lLtProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lLtProd {otherType} on host:Type, host:ExtType;
synthesized attribute rLtProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rLtProd {otherType} on host:Type, host:ExtType;

synthesized attribute lGtProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lGtProd {otherType} on host:Type, host:ExtType;
synthesized attribute rGtProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rGtProd {otherType} on host:Type, host:ExtType;

synthesized attribute lLteProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lLteProd {otherType} on host:Type, host:ExtType;
synthesized attribute rLteProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rLteProd {otherType} on host:Type, host:ExtType;

synthesized attribute lGteProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lGteProd {otherType} on host:Type, host:ExtType;
synthesized attribute rGteProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rGteProd {otherType} on host:Type, host:ExtType;

synthesized attribute lAddProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lAddProd {otherType} on host:Type, host:ExtType;
synthesized attribute rAddProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rAddProd {otherType} on host:Type, host:ExtType;

synthesized attribute lSubProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lSubProd {otherType} on host:Type, host:ExtType;
synthesized attribute rSubProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rSubProd {otherType} on host:Type, host:ExtType;

synthesized attribute lMulProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lMulProd {otherType} on host:Type, host:ExtType;
synthesized attribute rMulProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rMulProd {otherType} on host:Type, host:ExtType;

synthesized attribute lDivProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lDivProd {otherType} on host:Type, host:ExtType;
synthesized attribute rDivProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rDivProd {otherType} on host:Type, host:ExtType;

synthesized attribute lModProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype lModProd {otherType} on host:Type, host:ExtType;
synthesized attribute rModProd::Maybe<BinaryProd> occurs on host:Type, host:ExtType;
flowtype rModProd {otherType} on host:Type, host:ExtType;

aspect default production
top::host:Expr ::=
{
  top.callProd =
    case top.host:typerep.callProd of
      just(prod) -> just(prod(top, _, _))
    | nothing() -> nothing()
    end;
  top.addressOfProd = 
    case top.host:typerep.addressOfProd of
      just(prod) -> just(prod(top, _))
    | nothing() -> nothing()
    end;
}

aspect production host:arraySubscriptExpr
top::host:Expr ::= lhs::host:Expr  rhs::host:Expr
{
  top.addressOfProd =
    orElse(
      case top.host:typerep.addressOfArraySubscriptProd of
        just(prod) -> just(prod(lhs, rhs, _))
      | nothing() -> nothing()
      end,
      case top.host:typerep.addressOfProd of
        just(prod) -> just(prod(top, _))
      | nothing() -> nothing()
      end);
}

aspect production host:callExpr
top::host:Expr ::= f::host:Expr  a::host:Exprs
{
  top.addressOfProd =
    orElse(
      case top.host:typerep.addressOfCallProd of
        just(prod) -> just(prod(f, a, _))
      | nothing() -> nothing()
      end,
      case top.host:typerep.addressOfProd of
        just(prod) -> just(prod(top, _))
      | nothing() -> nothing()
      end);
}

aspect production host:memberExpr
top::host:Expr ::= lhs::host:Expr  deref::Boolean  rhs::host:Name
{
  local t::host:Type = lhs.host:typerep;
  t.isDeref = deref;
  top.callProd =
    orElse(
      case t.callMemberProd of
        just(prod) -> just(prod(lhs, rhs, _, _))
      | nothing() -> nothing()
      end,
      case top.host:typerep.callProd of
        just(prod) -> just(prod(top, _, _))
      | nothing() -> nothing()
      end);
  top.addressOfProd =
    orElse(
      case t.addressOfMemberProd of
        just(prod) -> just(prod(lhs, rhs, _))
      | nothing() -> nothing()
      end,
      case top.host:typerep.addressOfProd of
        just(prod) -> just(prod(top, _))
      | nothing() -> nothing()
      end);
}

aspect production host:parenExpr
top::host:Expr ::= e::host:Expr
{
  top.callProd = e.callProd;
  top.addressOfProd = e.addressOfProd;
}

aspect default production
top::host:Type ::=
{
  top.arraySubscriptProd = nothing();
  top.callProd = nothing();
  top.callMemberProd = nothing();
  top.memberProd = nothing();
  top.preIncProd = nothing();
  top.preDecProd = nothing();
  top.postIncProd = nothing();
  top.postDecProd = nothing();
  top.addressOfProd = nothing();
  top.addressOfArraySubscriptProd = nothing();
  top.addressOfCallProd = nothing();
  top.addressOfMemberProd = nothing();
  top.dereferenceProd = nothing();
  top.positiveProd = nothing();
  top.negativeProd = nothing();
  top.bitNegateProd = nothing();
  top.notProd = nothing();
  top.lEqProd = nothing();
  top.rEqProd = nothing();
  top.lMulEqProd = nothing();
  top.rMulEqProd = nothing();
  top.lDivEqProd = nothing();
  top.rDivEqProd = nothing();
  top.lModEqProd = nothing();
  top.rModEqProd = nothing();
  top.lAddEqProd = nothing();
  top.rAddEqProd = nothing();
  top.lSubEqProd = nothing();
  top.rSubEqProd = nothing();
  top.lLshEqProd = nothing();
  top.rLshEqProd = nothing();
  top.lRshEqProd = nothing();
  top.rRshEqProd = nothing();
  top.lAndEqProd = nothing();
  top.rAndEqProd = nothing();
  top.lXorEqProd = nothing();
  top.rXorEqProd = nothing();
  top.lOrEqProd = nothing();
  top.rOrEqProd = nothing();
  top.lAndProd = nothing();
  top.rAndProd = nothing();
  top.lOrProd = nothing();
  top.rOrProd = nothing();
  top.lAndBitProd = nothing();
  top.rAndBitProd = nothing();
  top.lOrBitProd = nothing();
  top.rOrBitProd = nothing();
  top.lXorProd = nothing();
  top.rXorProd = nothing();
  top.lLshBitProd = nothing();
  top.rLshBitProd = nothing();
  top.lRshBitProd = nothing();
  top.rRshBitProd = nothing();
  top.lEqualsProd = nothing();
  top.rEqualsProd = nothing();
  top.lNotEqualsProd = nothing();
  top.rNotEqualsProd = nothing();
  top.lLtProd = nothing();
  top.rLtProd = nothing();
  top.lGtProd = nothing();
  top.rGtProd = nothing();
  top.lLteProd = nothing();
  top.rLteProd = nothing();
  top.lGteProd = nothing();
  top.rGteProd = nothing();
  top.lAddProd = nothing();
  top.rAddProd = nothing();
  top.lSubProd = nothing();
  top.rSubProd = nothing();
  top.lMulProd = nothing();
  top.rMulProd = nothing();
  top.lDivProd = nothing();
  top.rDivProd = nothing();
  top.lModProd = nothing();
  top.rModProd = nothing();
}

aspect production host:pointerType
top::host:Type ::= q::host:Qualifiers target::host:Type
{
  top.callMemberProd = if top.isDeref then target.callMemberProd else nothing();
  top.memberProd = if top.isDeref then target.memberProd else nothing();
  top.addressOfMemberProd = if top.isDeref then target.addressOfMemberProd else nothing();
  
  target.isDeref = false;
}

aspect production host:extType
top::host:Type ::= q::host:Qualifiers  sub::host:ExtType
{
  top.arraySubscriptProd = sub.arraySubscriptProd;
  top.callProd = sub.callProd;
  top.callMemberProd =
    case sub.callMemberProd of
      just(prod) -> just(prod(_, top.isDeref, _, _, _))
    | nothing() -> nothing()
    end;
  top.memberProd =
    case sub.memberProd of
      just(prod) -> just(prod(_, top.isDeref, _, _))
    | nothing() -> nothing()
    end;
  
  top.preIncProd = sub.preIncProd;
  top.preDecProd = sub.preDecProd;
  top.postIncProd = sub.postIncProd;
  top.postDecProd = sub.postDecProd;
  top.addressOfProd = sub.addressOfProd;
  top.addressOfArraySubscriptProd = sub.addressOfArraySubscriptProd;
  top.addressOfCallProd = sub.addressOfCallProd;
  top.addressOfMemberProd =
    case sub.addressOfMemberProd of
      just(prod) -> just(prod(_, top.isDeref, _, _))
    | nothing() -> nothing()
    end;
  top.dereferenceProd = sub.dereferenceProd;
  top.positiveProd = sub.positiveProd;
  top.negativeProd = sub.negativeProd;
  top.bitNegateProd = sub.bitNegateProd;
  top.notProd = sub.notProd;
  
  sub.otherType = top.otherType;
  top.lEqProd = sub.lEqProd;
  top.rEqProd = sub.lEqProd;
  top.lMulEqProd = sub.lMulEqProd;
  top.rMulEqProd = sub.lMulEqProd;
  top.lDivEqProd = sub.lDivEqProd;
  top.rDivEqProd = sub.rDivEqProd;
  top.lModEqProd = sub.lModEqProd;
  top.rModEqProd = sub.rModEqProd;
  top.lAddEqProd = sub.lAddEqProd;
  top.rAddEqProd = sub.rAddEqProd;
  top.lSubEqProd = sub.lSubEqProd;
  top.rSubEqProd = sub.rSubEqProd;
  top.lLshEqProd = sub.lLshEqProd;
  top.rLshEqProd = sub.rLshEqProd;
  top.lRshEqProd = sub.lRshEqProd;
  top.rRshEqProd = sub.rRshEqProd;
  top.lAndEqProd = sub.lAndEqProd;
  top.rAndEqProd = sub.rAndEqProd;
  top.lXorEqProd = sub.lXorEqProd;
  top.rXorEqProd = sub.rXorEqProd;
  top.lOrEqProd = sub.lOrEqProd;
  top.rOrEqProd = sub.rOrEqProd;
  top.lAndProd = sub.lAndProd;
  top.rAndProd = sub.rAndProd;
  top.lOrProd = sub.lOrProd;
  top.rOrProd = sub.rOrProd;
  top.lAndBitProd = sub.lAndBitProd;
  top.rAndBitProd = sub.rAndBitProd;
  top.lOrBitProd = sub.lOrBitProd;
  top.rOrBitProd = sub.rOrBitProd;
  top.lXorProd = sub.lXorProd;
  top.rXorProd = sub.rXorProd;
  top.lLshBitProd = sub.lLshBitProd;
  top.rLshBitProd = sub.rLshBitProd;
  top.lRshBitProd = sub.lRshBitProd;
  top.rRshBitProd = sub.rRshBitProd;
  top.lEqualsProd = sub.lEqualsProd;
  top.rEqualsProd = sub.rEqualsProd;
  top.lNotEqualsProd = sub.lNotEqualsProd;
  top.rNotEqualsProd = sub.rNotEqualsProd;
  top.lLtProd = sub.lLtProd;
  top.rLtProd = sub.rLtProd;
  top.lGtProd = sub.lGtProd;
  top.rGtProd = sub.rGtProd;
  top.lLteProd = sub.lLteProd;
  top.rLteProd = sub.rLteProd;
  top.lGteProd = sub.lGteProd;
  top.rGteProd = sub.rGteProd;
  top.lAddProd = sub.lAddProd;
  top.rAddProd = sub.rAddProd;
  top.lSubProd = sub.lSubProd;
  top.rSubProd = sub.rSubProd;
  top.lMulProd = sub.lMulProd;
  top.rMulProd = sub.rMulProd;
  top.lDivProd = sub.lDivProd;
  top.rDivProd = sub.rDivProd;
  top.lModProd = sub.lModProd;
  top.rModProd = sub.rModProd;
}

aspect default production
top::host:ExtType ::=
{
  top.arraySubscriptProd = nothing();
  top.callProd = nothing();
  top.callMemberProd = nothing();
  top.memberProd = nothing();
  top.preIncProd = nothing();
  top.preDecProd = nothing();
  top.postIncProd = nothing();
  top.postDecProd = nothing();
  top.addressOfProd = nothing();
  top.addressOfArraySubscriptProd = nothing();
  top.addressOfCallProd = nothing();
  top.addressOfMemberProd = nothing();
  top.dereferenceProd = nothing();
  top.positiveProd = nothing();
  top.negativeProd = nothing();
  top.bitNegateProd = nothing();
  top.notProd = nothing();
  top.lEqProd = nothing();
  top.rEqProd = nothing();
  top.lMulEqProd = nothing();
  top.rMulEqProd = nothing();
  top.lDivEqProd = nothing();
  top.rDivEqProd = nothing();
  top.lModEqProd = nothing();
  top.rModEqProd = nothing();
  top.lAddEqProd = nothing();
  top.rAddEqProd = nothing();
  top.lSubEqProd = nothing();
  top.rSubEqProd = nothing();
  top.lLshEqProd = nothing();
  top.rLshEqProd = nothing();
  top.lRshEqProd = nothing();
  top.rRshEqProd = nothing();
  top.lAndEqProd = nothing();
  top.rAndEqProd = nothing();
  top.lXorEqProd = nothing();
  top.rXorEqProd = nothing();
  top.lOrEqProd = nothing();
  top.rOrEqProd = nothing();
  top.lAndProd = nothing();
  top.rAndProd = nothing();
  top.lOrProd = nothing();
  top.rOrProd = nothing();
  top.lAndBitProd = nothing();
  top.rAndBitProd = nothing();
  top.lOrBitProd = nothing();
  top.rOrBitProd = nothing();
  top.lXorProd = nothing();
  top.rXorProd = nothing();
  top.lLshBitProd = nothing();
  top.rLshBitProd = nothing();
  top.lRshBitProd = nothing();
  top.rRshBitProd = nothing();
  top.lEqualsProd = nothing();
  top.rEqualsProd = nothing();
  top.lNotEqualsProd = nothing();
  top.rNotEqualsProd = nothing();
  top.lLtProd = nothing();
  top.rLtProd = nothing();
  top.lGtProd = nothing();
  top.rGtProd = nothing();
  top.lLteProd = nothing();
  top.rLteProd = nothing();
  top.lGteProd = nothing();
  top.rGteProd = nothing();
  top.lAddProd = nothing();
  top.rAddProd = nothing();
  top.lSubProd = nothing();
  top.rSubProd = nothing();
  top.lMulProd = nothing();
  top.rMulProd = nothing();
  top.lDivProd = nothing();
  top.rDivProd = nothing();
  top.lModProd = nothing();
  top.rModProd = nothing();
}

