grammar edu:umn:cs:melt:exts:ableC:closure:concretesyntax:typeExpr;

imports edu:umn:cs:melt:ableC:concretesyntax;
imports silver:langutil only ast;

imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
--imports edu:umn:cs:melt:ableC:abstractsyntax:debug;

import edu:umn:cs:melt:exts:ableC:closure;

-- Spurious import, to trigger the tests on build.
import edu:umn:cs:melt:exts:ableC:closure:mda_test;

marking terminal Closure_t 'closure' lexer classes {Ckeyword};

concrete productions top::TypeSpecifier_c
| 'closure' '(' te::ClosureTypeExpr_c ')'
    { top.realTypeSpecifiers = [te.ast];
      top.preTypeSpecifiers = [];
      te.givenQualifiers = top.givenQualifiers; }
{-| 'closure' '(' res::TypeName_c '(' params::TypeNames_c ')' ')'
    { top.realTypeSpecifiers = [closureTypeExpr(params.ast, res.ast)];
      top.preTypeSpecifiers = []; } -}

nonterminal ClosureTypeExpr_c with ast<BaseTypeExpr>, givenQualifiers;

concrete productions top::ClosureTypeExpr_c
| '(' param::ClosureTypeExpr_c ')' '->' ret::TypeName_c
    { top.ast = closureTypeExpr(top.givenQualifiers, consParameters(parameterDecl([], param.ast, baseTypeExpr(), nothingName(), []), nilParameters()), ret.ast); }
| '(' param::ClosureTypeExpr_c ')' '->' rest::ClosureTypeExpr_c
    { top.ast = closureTypeExpr(top.givenQualifiers, consParameters(parameterDecl([], param.ast, baseTypeExpr(), nothingName(), []), nilParameters()), typeName(rest.ast, baseTypeExpr())); }
| '(' params::ParameterList_c ')' '->' rest::ClosureTypeExpr_c
    { top.ast = closureTypeExpr(top.givenQualifiers, foldParameterDecl(params.ast), typeName(rest.ast, baseTypeExpr())); }
| '(' params::ParameterList_c ')' '->' ret::TypeName_c
    { top.ast = closureTypeExpr(top.givenQualifiers, foldParameterDecl(params.ast), ret.ast); }
| '(' ')' '->' rest::ClosureTypeExpr_c
    { top.ast = closureTypeExpr(top.givenQualifiers, nilParameters(), typeName(rest.ast, baseTypeExpr())); }
| '(' ')' '->' ret::TypeName_c
    { top.ast = closureTypeExpr(top.givenQualifiers, nilParameters(), ret.ast); }