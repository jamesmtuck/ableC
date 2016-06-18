grammar edu:umn:cs:melt:exts:ableC:string:abstractsyntax;

imports silver:langutil;
imports silver:langutil:pp with implode as ppImplode ;

imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
--imports edu:umn:cs:melt:ableC:abstractsyntax:debug;

--imports edu:umn:cs:melt:exts:ableC:gc;

abstract production showExpr
top::Expr ::= e::Expr
{
  top.typerep = stringType();
  forwards to
    case e.typerep.showProd of
      just(p) -> p(e, top.location)
    | nothing() -> errorExpr([err(top.location, s"String representation of ${showType(e.typerep)} not defined")], location=top.location)
    end;
}

abstract production showString
top::Expr ::= e::Expr
{
  top.typerep = stringType();
  forwards to e;
}

abstract production showChar
top::Expr ::= e::Expr
{
  forwards to
    directCallExpr(
      name("showChar", location=builtIn()),
      consExpr(e, nilExpr()),
      location=top.location);
}

abstract production showInt
top::Expr ::= e::Expr
{
  forwards to
    directCallExpr(
      name("showInt", location=builtIn()),
      consExpr(e, nilExpr()),
      location=top.location);
}

abstract production showFloat
top::Expr ::= e::Expr
{
  forwards to
    directCallExpr(
      name("showFloat", location=builtIn()),
      consExpr(e, nilExpr()),
      location=top.location);
}

abstract production showPointer
top::Expr ::= e::Expr
{
  forwards to
    directCallExpr(
      name("_showPointer", location=builtIn()),
      consExpr(
        stringLiteral(s"\"${showType(e.typerep)}\"", location=top.location),
        consExpr(
          e,
          nilExpr())),
      location=top.location);
}

abstract production assignString
top::Expr ::= lhs::Expr rhs::Expr
{
  forwards to
    binaryOpExpr(
      lhs,
      assignOp(eqOp(location=builtIn()), location=builtIn()),
      showExpr(rhs, location=builtIn()),
      location=builtIn());
}

abstract production appendString
top::Expr ::= e1::Expr e2::Expr
{
  forwards to
    directCallExpr(
      name("_append_string", location=builtIn()),
      consExpr(
        showExpr(e1, location=builtIn()),
        consExpr(
          showExpr(e2, location=builtIn()),
          nilExpr())),
      location=top.location);
}

abstract production removeString
top::Expr ::= e1::Expr e2::Expr
{
  forwards to
    directCallExpr(
      name("_remove_string", location=builtIn()),
      consExpr(
        showExpr(e1, location=builtIn()),
        consExpr(
          showExpr(e2, location=builtIn()),
          nilExpr())),
      location=top.location);
}

abstract production repeatString
top::Expr ::= e1::Expr e2::Expr
{
  forwards to
    directCallExpr(
      name("_repeat_string", location=builtIn()),
      consExpr(e1, consExpr(e2, nilExpr())),
      location=top.location);
}

abstract production eqString
top::Expr ::= e1::Expr e2::Expr
{
  forwards to
    directCallExpr(
      name("_eq_string", location=builtIn()),
      consExpr(e1, consExpr(e2, nilExpr())),
      location=top.location);
}

abstract production subscriptString
top::Expr ::= e1::Expr e2::Expr
{
  forwards to
    directCallExpr(
      name("_index_string", location=builtIn()),
      consExpr(e1, consExpr(e2, nilExpr())),
      location=top.location);
}

abstract production subscriptAssignString
top::Expr ::= e1::Expr e2::Expr op::AssignOp e3::Expr
{
  forwards to
    stmtExpr(
      exprStmt(
        directCallExpr(
          name("_check_index_string", location=builtIn()),
          consExpr(e1, consExpr(e2, nilExpr())),
          location=top.location)),
        binaryOpExpr(
          arraySubscriptExpr(
            e1, e2,
            location=builtIn()),
          assignOp(op, location=builtIn()),
          e3,
          location=builtIn()),
      location=top.location);
}

abstract production substringString
top::Expr ::= e1::Expr a::Exprs
{
  -- TODO: check arg types
  top.errors <-
    if a.count != 2
    then [err(top.location, s"Invalid number of arguments to substring: expected 2, got ${toString(a.count)}")]
    else [];
  
  forwards to
    directCallExpr(
      name("_substring", location=builtIn()),
      consExpr(e1, a),
      location=top.location);
}

abstract production lengthString
top::Expr ::= e1::Expr
{
  forwards to
    directCallExpr(
      name("strlen", location=builtIn()),
      consExpr(e1, nilExpr()),
      location=top.location);
}

{-
 - New location for expressions which don't have real locations
 -}
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}