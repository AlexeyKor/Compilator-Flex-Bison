%{
	#include <iostream>
%}

%start progr

%token BEGIN END IF THEN OTHERWISE REPEAT WHILE WRITE READ
%token ASSIGN SEMICOLON COMMA LBR RBR COLON DOT SPACE 
%token PLUS MINUS MULT DIVIDE GOTO LABEL CLASS
%token AND OR NOT LT GT EQ NE LE GE
%token INTNUM INTEGER
%token STRLIT STRING
%token ID //it can be either parameter or data of class

%left LT GT LE GE EQ NE
%left MINUS PLUS OR
%left MULT DIVIDE AND DIV MOD
%left NOT

%%

progr : class listofoperators
	| listofoperators class
	| listofoperators
	;

class : CLASS ID BEGIN classmembers END
	;

classmembers : data SEMICOLON classmembers
	| method SEMICOLON classmembers
	;

data : ID COMMA data
	| ID COLON simpletype
	;

simpletype : INTEGER
	| STRING
	;

method : ID COLON SIMPLETYPE LBR parameters_declaration RBR BEGIN listofoperators END
	;

parameters_declaration : data COMMA parametrs
	| data
	;

listofoperators : operator SEMICOLON listofoperators
	| operator
	| class SEMICOLON listofoperators
	| class
	;

operator: {}
	| ID ASSIGN expr 

	| INTEGER SPACE EX SPACE string //take symbol from string

	| REPEAT SPACE operator SPACE WHILE SPACE expr //cycles
	
	| IF SPACE expr SPACE THEN SPACE operator SPACE otherwise //if
	
	| BEGIN listoperator END //block
	{
		$$ = $2;
	}
	| WRITE LBR expr RBR //write
	
	| READ LBR ID RBR //read
	
	| data //declarations

	| LABEL SPACE ID //make label

	| GOTO SPACE ID //go to label
        ;

otherwise: 
	{
		$$ = null;
	}
	| OTHERWISE operator {
		$$ = $2;
	}
	;

string : STRLIT	
	| ID
	;

expr: INTNUM 
	| STRLIT
	{
		// Íåò ó íàñ òàêèõ!!!
	}
	| ID
	| ID DOT ID LBR parameters RBR //call class method
	| expr PLUS expr 
	{
		$$ = new BinExpression($1, $3, Op.Plus, @$);
	}
	| expr MINUS expr 
	{
		$$ = new BinExpression($1, $3, Op.Minus, @$);
	}
	| expr MULT expr 
	{
		$$ = new BinExpression($1, $3, Op.Mult, @$);
	}
	| expr DIVIDE expr 
	{
		$$ = new BinExpression($1, $3, Op.Divide, @$);
	}
	| expr DIV expr 
	{
		// Íå ïîääåðæèâàåòñÿ!
	}
	| expr MOD expr 
	{
		// Íå ïîääåðæèâàåòñÿ!
	}
	| expr AND expr 
	{
		if ($1.getType() != TipType.BoolType || $2.getType() != TipType.BoolType)
		{
			// Error: only for bool types
		}
		$$ = new BinExpression($1, $3, Op.And, @$);
	}
	| expr OR expr 
	{
		if ($1.getType() != TipType.BoolType || $2.getType() != TipType.BoolType)
		{
		    // Error: only for bool types
		}
		$$ = new BinExpression($1, $3, Op.Or, @$);
	}
	| expr LT expr 
	{
		$$ = new BinExpression($1, $3, Op.Less, @$);
	}
	| expr GT expr 
	{
		$$ = new BinExpression($1, $3, Op.More, @$);
	}
	| expr LE expr	
	{
		$$ = new BinExpression($1, $3, Op.LessEqual, @$);
	}
	| expr GE expr 
	{
		$$ = new BinExpression($1, $3, Op.MoreEqual, @$);       
	}
	| expr EQ expr
	{
		$$ = new BinExpression($1, $3, Op.Equal, @$);       
	}
	| expr NE expr 
	{
		$$ = new BinExpression($1, $3, Op.NotEqual, @$);        
	}
	| NOT expr 
	{
		if ($2.getType() != TipType.BoolType)
		{
		// Error: type is wrong.
		}
		$$ = new UnarExpression($2, Op.Not, @2);
	}
	| LBR expr RBR
	{
		$$ = $2;
	}
	;

parameters : ID
	| ID COMMA parameters
	;
%%
