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
	int expression(string operation); //generates code for expressions

	struct variable
	{
		string name;
		int value;
	};
	
    vector<string> myVariables;    
    stack<string> myStack, retAdr; //myStack is for expression calculation
	vector<bool> importantVar; //importantVar shows if variable is temporary expression result
	vector<string>  myLabels;
    //int result = 0;
    bool isTempExist = false, isStrTempExist = false, isStrTemp = false; // for expressions
	int currentAlpha = 97; //for generating unique variables.
	int myIfCounter = 0, myIfInc = 0, myIfLevel = 0, myRepeatCounter = 0, myRepeat2Counter = 0, myCycleInc = 0; 
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
%left MULT DIVIDE AND
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
	| operator
	/*| class SEMICOLON listofoperators
	| class SEMICOLON*/
	;

operator: ID ASSIGN expr
	{
		$$ = $1;		
		//if(!isVarExist($1))
			myVariables.push_back($1);
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				printf("MOVE %c%c %s\n", (char)currentAlpha, (char)(myStack.size()+96-i), myVariables.back().c_str());
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	} 

	| REPEAT 
	{
		printf("STRING repeat%d repeat%d\n LABEL repeat%d\n", myRepeatCounter, myRepeatCounter, myRepeatCounter);
		myRepeatCounter++;		
	}
	
	operator WHILE expr
	{
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				printf("BRANCH %c%c repeat%d\n", (char)currentAlpha, (char)(myStack.size()+96-i), myRepeat2Counter);
				break;
			}
		myRepeat2Counter++;
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	}	
	| IF expr
	{
		myIfLevel++;
		myIfInc++;
		printf("STRING else%d else%d\n", myIfCounter + myIfLevel, myIfCounter + myIfLevel);
		printf("STRING if%dend if%dend\n", myIfCounter + myIfLevel, myIfCounter + myIfLevel);
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				printf("NOT %c%c %c%c\n", (char)currentAlpha, (char)(myStack.size()+96-i), (char)currentAlpha, (char)(myStack.size()+96-i));				
				printf("BRANCH %c%c else%d\n", (char)currentAlpha, (char)(myStack.size()+96-i), myIfCounter + myIfLevel);
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	}

	THEN operator
	{
		printf("GOTO if%dend\n", myIfCounter + myIfLevel);
	}
	
	OTHERWISE
	{
		printf("LABEL else%d\n", myIfCounter + myIfLevel);
	}	
  	
	operator
	{
		printf("label if%dend\n", myIfCounter + myIfLevel);
		
		if(myIfLevel == 1)
		{
			myIfCounter = myIfCounter + myIfInc; 
			myIfInc = 0;
		}		
		myIfLevel--;		
	}
	
	| BEG listofoperators END //block
	{
		//$$ = $2;
	}

	| WRITE LBR expr RBR //write
	{
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				printf("WRITE %c%c\n", (char)currentAlpha, (char)(myStack.size()+96-i));
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	}

	| READ LBR ID RBR //read
	{
		printf("READ %s\n", $3.c_str());
	}

	| data //declarations

	| LABEL ID //make label
	{
		printf("LABEL %s\n STRING label%d %s\n", $2.c_str(), myLabels.size(), $2.c_str());
		myLabels.push_back($2);
	}

	| GOTO ID //go to label
	{
		for(int i = 0; i < myLabels.size(); i++)
			if($2 == myLabels.at(i))
			{
				printf("GOTO label%d\n", i);
				break;
			} 
	}
        ;

expr: INTNUM 
	{
		//$$ = $1;
		myStack.push($1); 
		importantVar.push_back(true); 
		isStrTemp = false; 
		printf("INTEGER %c%c %s\n", (char)currentAlpha, (char)(myStack.size()+96), myStack.top().c_str());
	}

	| STRLIT
	{
		$1.erase($1.begin()-1); 
		$1.erase($1.end()-1); 
		myStack.push($1); 
		importantVar.push_back(true); 
		isStrTemp = true; 
		printf("STRING %c%c %s\n", (char)currentAlpha, (char)(myStack.size()+96), myStack.top().c_str());
	}

	| ID //добавить распознавание типа
	{
		myStack.push($1);
	 	importantVar.push_back(true); 
		printf("MOVE %s %c%c\n", myStack.top().c_str(), (char)currentAlpha, (char)(myStack.size()+96));
	}

	| INTNUM EX string //take symbol from string
	{
		myStack.push($1); 
		importantVar.push_back(false);
		printf("INTEGER %c%c %s\n", (char)currentAlpha, (char)(myStack.size()+96), myStack.top().c_str());
		printf("IND %c%c %c%c %c%c\n", (char)currentAlpha, (char)(myStack.size()+95), (char)currentAlpha, (char)(myStack.size()+96), (char)currentAlpha, (char)(myStack.size()+95));
	}
	//| ID DOT ID LBR parameters RBR //call class method
	| expr PLUS expr 
	{
		//$$ = $1 + $3;
		expression("ADD");
	}
	| expr MINUS expr 
	{
		//$$ = $1 - $3;
		expression("SUB");
	}
	| expr MULT expr 
	{
		//$$ = $1 * $3; 
		expression("MUL");
	}
	| expr DIVIDE expr 
	{
		//$$ = $1 / $3; 
		expression("DIV");
	}
	| expr AND expr 
	{
		//$$ = $1 && $3;
		expression("AND");
	}
	| expr OR expr 
	{
		//$$ = $1 || $3;
		expression("OR");
	}
	| expr LT expr 
	{
		//$$ = $1 < $3; 
		expression("LT");
	}
	| expr GT expr 
	{
		//$$ = $1 > $3;
		expression("GT");
	}
	| expr LE expr	
	{
		//$$ = $1 <= $3; 
		expression("LE");
	}
	| expr GE expr 
	{
		//$$ = $1 >= $3;
		expression("GE");
	}
	| expr EQ expr
	{
		//$$ = $1 == $3;
		expression("EQ");
	}
	| expr NE expr 
	{
		//$$ = $1 != $3;
		expression("NE");   
	}
	| NOT expr 
	{
		//$$ = !$2; 
		expression("NOT");
	}
	| LBR expr RBR
	{
		//$$ = $2;
	}
	;

string : STRLIT
	{
		$1.erase($1.begin()-1); 
		$1.erase($1.end()-1);
		myStack.push($1); 
		importantVar.push_back(true); 
		isStrTemp = true; 
		printf("STRING %c%c %s\n", (char)currentAlpha, (char)(myStack.size()+96), myStack.top().c_str());
	}
	| ID
	{
		myStack.push($1);
	 	importantVar.push_back(true); 
		isStrTemp = true;
		printf("MOVE %s %c%c\n", myStack.top().c_str(), (char)currentAlpha, (char)(myStack.size()+96));
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

int expression(string operation)
{
	if(!isTempExist)
		{
			puts("INTEGER temp 0\n");
			isTempExist = !isTempExist;
		}

	if(!isStrTempExist)
		{
			puts("STRING strTemp nothing\n");
			isStrTempExist = !isStrTempExist;
		}


	for(int i = 0; i < myStack.size(); i++)
		if(importantVar.at(myStack.size()-i-1))
		{
			if(isStrTemp)
				printf("%s strTemp %c%c ", operation.c_str(), (char)currentAlpha, (char)(myStack.size()+96-i));
			else
				printf("%s temp %c%c ", operation.c_str(), (char)currentAlpha, (char)(myStack.size()+96-i));
			if(operation != "NOT")
				importantVar.at(myStack.size()-i-1) = false;
			break;
		}


	if(operation != "NOT")	
	{
		for(int i = 0; i < myStack.size(); i++)		
			if(importantVar.at(myStack.size()-i-1))
			{
				printf("%c%c\n", (char)currentAlpha, (char)(myStack.size()+96-i));
				break;
			}
	}
	else
		puts("\n");


	for(int i = 0; i < myStack.size(); i++)
		if(importantVar.at(myStack.size()-i-1))
		{
			if(isStrTemp)
				printf("MOVE strTemp %c%c\n", (char)currentAlpha, (char)(myStack.size()+96-i));
			else
				printf("MOVE temp %c%c\n", (char)currentAlpha, (char)(myStack.size()+96-i));
			break;
		}

	return 0;
}
