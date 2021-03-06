grammar edu:umn:cs:melt:ableC:abstractsyntax:host;

synthesized attribute name :: String;

synthesized attribute labelRedeclarationCheck :: [Message];

synthesized attribute valueLocalLookup :: [ValueItem];
synthesized attribute valueRedeclarationCheck :: ([Message] ::= Type);
synthesized attribute valueRedeclarationCheckNoCompatible :: [Message];
synthesized attribute valueMergeRedeclExtnQualifiers :: (Type ::= Type);

synthesized attribute tagLocalLookup :: [TagItem];
synthesized attribute tagHasForwardDcl :: Boolean;
synthesized attribute tagRefId :: String;

synthesized attribute valueLookupCheck :: [Message];
synthesized attribute tagLookupCheck :: [Message];
synthesized attribute labelLookupCheck :: [Message];

synthesized attribute valueItem :: Decorated ValueItem;
synthesized attribute tagItem :: Decorated TagItem;
synthesized attribute labelItem :: Decorated LabelItem;

nonterminal Name with location, name, pp, host<Name>, lifted<Name>, env, valueLocalLookup, labelRedeclarationCheck, valueLookupCheck, tagLookupCheck, labelLookupCheck, valueItem, tagItem, labelItem, tagLocalLookup, tagHasForwardDcl, tagRefId, valueRedeclarationCheck, valueRedeclarationCheckNoCompatible, valueMergeRedeclExtnQualifiers;
flowtype Name = decorate {env}, name {}, valueLocalLookup {env}, labelRedeclarationCheck {env}, valueLookupCheck {env}, tagLookupCheck {env}, labelLookupCheck {env}, valueItem {env}, tagItem {env}, labelItem {env}, tagLocalLookup {env}, tagHasForwardDcl {env}, tagRefId {env}, valueRedeclarationCheck {decorate}, valueRedeclarationCheckNoCompatible {decorate}, valueMergeRedeclExtnQualifiers {decorate};

abstract production name
top::Name ::= n::String
{
  propagate host, lifted;
  
  top.name = n;
  top.pp = text(n);
  
  top.valueLocalLookup = lookupValueInLocalScope(n, top.env);
  top.valueRedeclarationCheck = doValueRedeclarationCheck(_, top);
  top.valueRedeclarationCheckNoCompatible = doValueRedeclarationCheckNoCompatible(top);
  top.valueMergeRedeclExtnQualifiers = doValueMergeQualifiers(_, top);
  
  top.tagLocalLookup = lookupTagInLocalScope(n, top.env);
  local refIdIfOld :: Maybe<String> =
    case top.tagLocalLookup of
    | refIdTagItem(_, thisRefID) :: _ -> just(thisRefID)
    | _ -> nothing()
    end;
  top.tagHasForwardDcl = refIdIfOld.isJust;
  top.tagRefId = fromMaybe(toString(genInt()), refIdIfOld);
  
  local labdcls :: [LabelItem] = lookupLabel(n, top.env);
  top.labelRedeclarationCheck =
    case labdcls of
    | [] -> [err(top.location, "INTERNAL compiler error: expected to find label in function scope, was missing.")] -- TODO?
    | [_] -> [] -- We found ourselves. Labels are in function scope, so a-okay!
    | _ :: _ :: _ -> [err(top.location, "Redeclaration of " ++ n)]
    end;
  
  local values :: [ValueItem] = lookupValue(n, top.env);
  local tags :: [TagItem] = lookupTag(n, top.env);
  local labels :: [LabelItem] = lookupLabel(n, top.env);
  top.valueLookupCheck =
    case values of
    | [] -> [err(top.location, "Undeclared value " ++ n)]
    | _ :: _ -> []
    end;
  top.labelLookupCheck =
    case labels of
    | [] -> [err(top.location, "Undeclared label " ++ n)]
    | _ :: _ -> []
    end;
  top.tagLookupCheck =
    case tags of
    | [] -> [err(top.location, "Undeclared tag " ++ n)]
    | _ :: _ -> []
    end;
  
  local value :: ValueItem = if null(values) then errorValueItem() else head(values);
  local tag :: TagItem = if null(tags) then errorTagItem() else head(tags);
  local label :: LabelItem = if null(labels) then errorLabelItem() else head(labels);
  
  top.valueItem = value;
  top.tagItem = tag;
  top.labelItem = label;
}

synthesized attribute maybename :: Maybe<Name>;
synthesized attribute hasName :: Boolean;

nonterminal MaybeName with maybename, pp, host<MaybeName>, lifted<MaybeName>, env, valueLocalLookup, tagLocalLookup, tagHasForwardDcl, tagRefId, hasName, valueRedeclarationCheckNoCompatible, valueRedeclarationCheck, valueMergeRedeclExtnQualifiers;
flowtype MaybeName = decorate {env}, maybename {}, hasName {}, valueLocalLookup {env}, tagLocalLookup {env}, tagHasForwardDcl {env}, tagRefId {env}, valueRedeclarationCheckNoCompatible {decorate}, valueRedeclarationCheck {decorate}, valueMergeRedeclExtnQualifiers {decorate};

abstract production justName
top::MaybeName ::= n::Name
{
  propagate host, lifted;
  top.pp = n.pp;
  top.maybename = just(n);
  top.hasName = true;

  top.valueRedeclarationCheck = n.valueRedeclarationCheck;
  top.valueRedeclarationCheckNoCompatible = n.valueRedeclarationCheckNoCompatible;
  top.valueMergeRedeclExtnQualifiers = n.valueMergeRedeclExtnQualifiers;
  top.valueLocalLookup = n.valueLocalLookup;
  top.tagLocalLookup = n.tagLocalLookup;
  top.tagHasForwardDcl = n.tagHasForwardDcl;
  top.tagRefId = n.tagRefId;
}
abstract production nothingName
top::MaybeName ::=
{
  propagate host, lifted;
  top.pp = notext();
  top.maybename = nothing();
  top.hasName = false;

  top.valueRedeclarationCheck = doNotDoValueRedeclarationCheck;
  top.valueRedeclarationCheckNoCompatible = [];
  top.valueMergeRedeclExtnQualifiers = \t::Type -> errorType();

  top.valueLocalLookup = [];
  top.tagLocalLookup = [];
  top.tagHasForwardDcl = false;
  top.tagRefId = toString(genInt());
}

synthesized attribute names :: [String];

autocopy attribute appendedNames :: Names;
synthesized attribute appendedNamesRes :: Names;

nonterminal Names with env, pps, names, count, appendedNames, appendedNamesRes;
flowtype Names = decorate {env}, pps {}, names {}, count {}, appendedNamesRes {appendedNames};

abstract production consName
top::Names ::= h::Name t::Names
{
  top.pps = h.pp :: t.pps;
  top.names = h.name :: t.names;
  top.count = 1 + t.count;
  top.appendedNamesRes = consName(h, t.appendedNamesRes);
}

abstract production nilName
top::Names ::=
{
  top.pps = [];
  top.names = [];
  top.count = 0;
  top.appendedNamesRes = top.appendedNames;
}

function appendNames
Names ::= e1::Names e2::Names
{
  e1.appendedNames = e2;
  return e1.appendedNamesRes;
}

function doNotDoValueRedeclarationCheck
[Message] ::= t::Type
{
  return [];
}
function doValueRedeclarationCheck
[Message] ::= t::Type  n::Decorated Name
{
  return case n.valueLocalLookup of
  | [] -> []
  | v :: _ -> 
      if compatibleTypes(t.withoutExtensionQualifiers, v.typerep.withoutExtensionQualifiers, false, false)
      then []
      else 
        let originalPP :: String = show(100, cat(v.typerep.lpp, v.typerep.rpp)),
            herePP :: String = show(100, cat(t.lpp, t.rpp))
         in
            [err(n.location, 
              "Redeclaration of " ++ n.name ++ " with incompatible types. Original (from line " ++
              toString(v.sourceLocation.line) ++ ") " ++ originalPP ++ 
              " but here it is " ++ herePP)]
        end
  end;
}

function doValueRedeclarationCheckNoCompatible
[Message] ::= n::Decorated Name
{
  return case n.valueLocalLookup of
  | [] -> []
  | v :: _ -> 
      [err(n.location, 
        "Redeclaration of " ++ n.name ++ ". Original (from line " ++
        toString(v.sourceLocation.line) ++ ")")]
  end;
}

function doValueMergeQualifiers
Type ::= t::Type  n::Decorated Name
{
  return foldr(\t1::Type t2::Type -> t2.mergeQualifiers(t1), t, map((.typerep), n.valueLocalLookup));
}

--  return
--    if null(valueLookup)
--    then t
--    else mergeRedeclarationExtnQuals
--
--  return case n.valueLocalLookup of
--  | [] -> []
--  | v :: _ -> 
--      if compatibleTypes(t.withoutExtensionQualifiers, v.typerep.withoutExtensionQualifiers, false, false)
--      then []
--      else 
--        let originalPP :: String = show(100, cat(v.typerep.lpp, v.typerep.rpp)),
--            herePP :: String = show(100, cat(t.lpp, t.rpp))
--         in
--            [err(n.location, 
--              "Redeclaration of " ++ n.name ++ " with incompatible types. Original (from line " ++
--              toString(v.sourceLocation.line) ++ ") " ++ originalPP ++ 
--              " but here it is " ++ herePP)]
--        end
--  end;
--}

