%{    
    #include <cstdio>
    #include <string>
    #include <iostream>
    #include <stack>
    #include <vector>
    
    using namespace std;
    #define YYSTYPE string
    #define YYERROR_VERBOSE 1
    #define DEBUG
    
    int yylex(void);
    
    void yyerror(const char *str) {
        #ifdef DEBUG
          //cout << "Parser: " << str << endl;
        #endif
    }
 
    int main();
	bool isVarExist(string var);

	struct variable
	{
		string name;
		int value;
	};

    vector<string> myVariables;    
    stack<int> myStack, retAdr;
    //int result = 0;
    bool isTempExist = false;
 
%}

%start progr

%token BEG END IF THEN OTHERWISE REPEAT WHILE WRITE READ
%token ASSIGN SEMICOLON COMMA LBR RBR COLON DOT
%token PLUS MINUS MULT DIVIDE GOTO LABEL CLASS EX
%token AND OR NOT LT GT EQ NE LE GE
%token INTNUM INTEGER
%token STRLIT STRING
%token ID //it can be either parameter or data of class

%left LT GT LE GE EQ NE
%left MINUS PLUS OR
%left MULT DIVIDE AND DIV MOD
%left NOT

%%

progr : 
	| listofoperators
	;

/*class : CLASS ID BEG classmembers END
	;

classmembers : 
	|data SEMICOLON classmembers
	| method SEMICOLON classmembers
	;*/

data : ID COMMA data
	{
		myVariables.push_back($1);
		if($3 == "string")		
			printf("STRING %s nothing\n", $1.c_str());
		else
			printf("INTEGER %s 0\n", $1.c_str()); 
	}
	| ID COLON simpletype
	{
		$$ = $3;
		myVariables.push_back($1);
		if($3 == "string")		
			printf("STRING %s nothing\n", $1.c_str());
		else
			printf("INTEGER %s 0\n", $1.c_str()); 
	}
	;

simpletype : INTEGER
	{
		$$ = $1;
	}
	| STRING	
	{
		$$ = $1;
	}
	;

/*method : ID COLON simpletype LBR parameters_declaration RBR BEG listofoperators END
	;

parameters_declaration : 
	|data COMMA parameters
	| data
	;
*/
listofoperators : operator SEMICOLON listofoperators
	| operator SEMICOLON
	/*| class SEMICOLON listofoperators
	| class SEMICOLON*/
	;

operator: {}
	| ID ASSIGN expr
	{
		//if(!isVarExist($1))
			myVariables.push_back($1);
		printf("MOVE aa %s\n", myVariables.back().c_str());
		myStack.pop();
	} 

	| INTEGER EX string //take symbol from string

	| REPEAT operator WHILE expr //cycles
	
	| IF expr THEN operator otherwise //if
	
	| BEG listofoperators END //block
	{
		//$$ = $2;
	}
	| WRITE LBR expr RBR //write
	
	| READ LBR ID RBR //read
	
	| data //declarations

	| LABEL ID //make label

	| GOTO ID //go to label
        ;

otherwise: OTHERWISE operator 
	{
		//$$ = $1;
	}
	;

string : STRLIT	
	| ID
	;

expr: INTNUM 
	{
		//$$ = $1; 
		myStack.push(atoi($$.c_str())); printf("INTEGER a%c %d\n", (char)(myStack.size()+96), myStack.top());
	}
	/*| STRLIT
	{
	}
	| ID
	| ID DOT ID LBR parameters RBR //call class method*/
	| expr PLUS expr 
	{
		//$$ = $1 + $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("ADD temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr MINUS expr 
	{
		//$$ = $1 - $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("SUB temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr MULT expr 
	{
		//$$ = $1 * $3; 
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("MUL temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr DIVIDE expr 
	{
		//$$ = $1 / $3; 
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("DIV temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr AND expr 
	{
		//$$ = $1 && $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("AND temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr OR expr 
	{
		//$$ = $1 || $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("OR temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr LT expr 
	{
		//$$ = $1 < $3; 
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("LT temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr GT expr 
	{
		//$$ = $1 > $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("GT temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr LE expr	
	{
		//$$ = $1 <= $3; 
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("LE temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr GE expr 
	{
		//$$ = $1 >= $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("GE temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr EQ expr
	{
		//$$ = $1 == $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("EQ temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));
	}
	| expr NE expr 
	{
		//$$ = $1 != $3;
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("NE temp a%c ", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		printf("a%c\n", (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));    
	}
	| NOT expr 
	{
		//$$ = !$2; 
		if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}
		printf("NOT temp a%c\n", (char)(myStack.size()+96), (char)(myStack.size()+96), (char)(myStack.size()+96));
		myStack.pop();
		myStack.push(1);
		printf("MOVE temp a%c\n", (char)(myStack.size()+96));    
	}
	| LBR expr RBR
	{
		//$$ = $2;
	}
	;

/*parameters : ID
	| ID COMMA parameters
	;*/
%%

int main()
{
    return yyparse();
}

bool isVarExist(string var)
{
	for(int i = 0; i < myVariables.size(); i++)
		if(var == myVariables[i])
			return true;
	return false;
}
