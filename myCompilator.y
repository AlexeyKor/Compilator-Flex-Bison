%start progr

%token BEGIN END IF THEN OTHERWISE REPEAT WHILE WRITE READ
%token ASSIGN SEMICOLON COMMA COLON LBR RBR COLON DOT  
%token PLUS MINUS MULT DIVIDE 
%token AND OR NOT LT GT EQ NE LE GE
%token INTNUM INTEGER
%token STRLIT STRING
%token ID

%type expr
%type class
%type operator elsepart
%type listoperator progr 
%type ident 
%type type simpletype

%left LT GT LE GE EQ NE
%left MINUS PLUS OR
%left MULT DIVIDE AND DIV MOD
%left NOT

%%

progr : class listofoperators
	| listofoperators class
	;

class : STRLIT BEGIN classmembers END
	;

classmembers : data SEMICOLON classmembers
	| method SEMICOLON classmembers
	;

data : STRLIT COMMA data
	| STRLIT COLON simpletype
	;

simpletype : INTEGER
	| STRING
	;

method : STRINGLIT COLON SIMPLETYPE LBR parameters RBR BEGIN listofoperators END
	;

parameters : data COMMA parametrs
	| data
	;

listofoperators : operator SEMICOLON listofoperators
	| operator
	;

%%
