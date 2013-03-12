%{
#include "myCompilator.tab.h"
%}
%option noyywrap
Alpha 	[a-zA-Z_]
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
  return STRLIT;
}

"integer" { return INTEGER; }
"begin" { return BEG; }
"end" { return END; }
"if" { return IF; }
"then" { return THEN; }
"otherwise" { return OTHERWISE; }
"repeat" { return REPEAT; }
"while" { return WHILE; }
"read" { return READ; }
"and" { return AND; }
"or" { return OR; }
"not" { return NOT; }
"ex" { return EX; }
"class" { return CLASS; }
"label" { return LABEL; }
"goto" { return GOTO; }

{ID}  { return ID; }

{INTNUM} { yylval = atoi(yytext); return INTNUM; }

"#" { return STOP; }

%%    				
