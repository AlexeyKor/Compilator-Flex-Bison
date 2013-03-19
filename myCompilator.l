%{
#include <string>
#include <iostream>
 
using namespace std;
 
#define YYSTYPE string
#include "myCompilator.tab.h"
%}
%option noyywrap
INTNUM  [0-9]+
ID [a-zA-Z_][a-zA-Z0-9_]* 

%%

":=" { return ASSIGN; }
";" { return SEMICOLON; }
"-" { return MINUS; }
"+" { return PLUS; }
"*" { return MULT; }
"/" { return DIVIDE; }
"<" { return LT; }
">" { return GT; }
"<=" { return LE; }
">=" { return GE; }
"=" { return EQ; }
"<>" { return NE; }
"(" { return LBR; }
")" { return RBR; }
"," { return COMMA; }
":" { return COLON; }
"." { return DOT;  }


\"[^"]*\" {
  yylval = yytext;
  return STRLIT;
}

"integer" { yylval = yytext; return INTEGER; }
"string" { yylval = yytext; return STRING; }
"begin" { return BEG; }
"end" { return END; }
"if" { return IF; }
"then" { return THEN; }
"otherwise" { return OTHERWISE; }
"repeat" { return REPEAT; }
"while" { return WHILE; }
"read" { return READ; }
"write" { return WRITE; }
"and" { return AND; }
"or" { return OR; }
"not" { return NOT; }
"ex" { return EX; }
"class" { return CLASS; }
"label" { return LABEL; }
"goto" { return GOTO; }

{ID}  { yylval = yytext; return ID; }

{INTNUM} { yylval = yytext; return INTNUM; }

%%    				
