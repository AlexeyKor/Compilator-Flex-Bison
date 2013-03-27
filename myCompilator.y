%{    
    #include <string>
    #include <iostream>
	#include <sstream>
    #include <stack>
    #include <vector>
    
    using namespace std;
    #define YYSTYPE string
    #define YYERROR_VERBOSE 1
    #define DEBUG

	ostringstream myCode;
    
    int yylex(void);
    
    void yyerror(const char *str) {
        #ifdef DEBUG
          //cout << "Parser: " << str << endl;
        #endif
    }
 
	int main();
	string isVarExist(string var);
	int varQuantity(string var);
	int expression(string operation); //generates code for expressions

	struct variable
	{
		string name;
		int value;
	};
	
    vector<string> myVariables, myVarTypes;    
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
	{
	}
	;

/*class : CLASS ID BEG classmembers END
	;

classmembers : 
	|data SEMICOLON classmembers
	| method SEMICOLON classmembers
	;

data : ID COMMA data
	{
		$$ = $3;
		if($3 == "string")
		{
			cout << "STRING " << $1 << varQuantity($1) << " nothing\n";
			myVariables.push_back($1);
			myVarTypes.push_back("string");	
		}
		else
		{
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVariables.push_back($1);
			myVarTypes.push_back("integer");	
		} 
	}
	| ID COLON simpletype
	{
		$$ = $3;
		if($3 == "string")
		{
			cout << "STRING " << $1 << varQuantity($1) << " nothing\n";
			myVariables.push_back($1);
			myVarTypes.push_back("string");		
		}
		else
		{
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVariables.push_back($1);
			myVarTypes.push_back("integer");
		}
	}
	; */

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
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				myCode << "MOVE " << (char)currentAlpha << (char)(myStack.size()+96-i) << " " << $1 << varQuantity($1) << "\n";
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	} 

	| REPEAT 
	{
		cout << "STRING repeat" << myRepeatCounter << " repeat" << myRepeatCounter << "\n";
		myCode << "LABEL repeat" << myRepeatCounter << "\n";
		myRepeatCounter++;		
	}
	
	operator WHILE expr
	{
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				myCode << "BRANCH " << (char)currentAlpha << (char)(myStack.size()+96-i) << " repeat" << myRepeat2Counter << "\n";
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
		cout << "STRING else" << myIfCounter + myIfLevel << " else" << myIfCounter + myIfLevel << "\n";
		cout << "STRING if" << myIfCounter + myIfLevel << "end if" << myIfCounter + myIfLevel << "end\n";
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				myCode << "NOT " << (char)currentAlpha << (char)(myStack.size()+96-i) << " " << (char)currentAlpha << (char)(myStack.size()+96-i) << "\n";
				myCode << "BRANCH " << (char)currentAlpha << (char)(myStack.size()+96-i) << " else" << myIfCounter + myIfLevel << "\n";
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	}

	THEN operator
	{
		myCode << "GOTO if" << myIfCounter + myIfLevel << "end\n";
	}
	
	OTHERWISE
	{
		myCode << "LABEL else" << myIfCounter + myIfLevel << "\n";
	}	
  	
	operator
	{
		myCode << "label if" << myIfCounter + myIfLevel << "end\n";
		
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
				myCode << "WRITE " << (char)currentAlpha << (char)(myStack.size()+96-i) << "\n";
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	}

	| READ LBR ID RBR //read
	{
		myCode << "READ " << $3 << varQuantity($3) << "\n";
	}

	| declaration

	| LABEL ID //make label
	{
		cout << "STRING label" << myLabels.size() << " " << $2 << "\n";
		myCode << "LABEL " << $2 << "\n";
		myLabels.push_back($2);
	}

	| GOTO ID //go to label
	{
		for(int i = 0; i < myLabels.size(); i++)
			if($2 == myLabels.at(i))
			{
				myCode << "GOTO label" << i << "\n";
				break;
			} 
	}
	| expr
        ;

declaration : ID COMMA declaration
	{
		$$ = $3;
		if($3 == "string")
		{
			myVariables.push_back($1);
			cout << "STRING " << $1 << varQuantity($1) << " nothing\n";
			myVarTypes.push_back("string");	
		}
		else
		{
			myVariables.push_back($1);
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("integer");	
		} 
	}
	| ID COLON simpletype
	{
		$$ = $3;
		if($3 == "string")
		{
			myVariables.push_back($1);			
			cout << "STRING " << $1 << varQuantity($1) << " nothing\n";
			myVarTypes.push_back("string");		
		}
		else
		{
			myVariables.push_back($1);
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("integer");
		}
	}
	;

expr: INTNUM 
	{
		//$$ = $1;
		myStack.push($1); 
		importantVar.push_back(true); 
		isStrTemp = false; 
		cout << "INTEGER " << (char)currentAlpha << (char)(myStack.size()+96) << " " << myStack.top() << "\n";
	}

	| STRLIT
	{
		$1.erase($1.begin()-1); 
		$1.erase($1.end()-1); 
		myStack.push($1); 
		importantVar.push_back(true); 
		isStrTemp = true; 
		cout << "STRING " << (char)currentAlpha << (char)(myStack.size()+96) << " " << myStack.top() << "\n";
	}

	| ID //добавить распознавание типа
	{
		myStack.push($1);
	 	importantVar.push_back(true);
		string temp = "string";
		if(isVarExist($1) == temp)
		{
			isStrTemp = true; 
			cout << "STRING " << (char)currentAlpha << (char)(myStack.size()+96) << " nothing\n";
		}
		temp = "integer";
		if(isVarExist($1) == temp)
		{
			isStrTemp = false;
			cout << "INTEGER " << (char)currentAlpha << (char)(myStack.size()+96) << " 0\n";
		}
		myCode << "MOVE " << $1 << varQuantity($1) << " " << (char)currentAlpha << (char)(myStack.size()+96) << "\n";
	}

	| INTNUM EX string //take symbol from string
	{
		myStack.push($1); 
		importantVar.push_back(false);
		cout << "INTEGER " << (char)currentAlpha << (char)(myStack.size()+96) << " " << myStack.top() << "\n";
		myCode << "IND " << (char)currentAlpha << (char)(myStack.size()+95) << " " << (char)currentAlpha << (char)(myStack.size()+96) << " " << (char)currentAlpha << (char)(myStack.size()+95) << "\n";
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
		cout << "STRING " << (char)currentAlpha << (char)(myStack.size()+96) << " " << myStack.top() << "\n";
	}
	| ID
	{
		myStack.push($1);
	 	importantVar.push_back(true); 
		isStrTemp = true;
		myCode << "MOVE " << myStack.top() << varQuantity($1) << " " << (char)currentAlpha << (char)(myStack.size()+96) << "\n";
	}
	;

/*parameters : ID
	| ID COMMA parameters
	;*/
%%

int main()
{
	/*//stack initialization
	printf("STRING strStack ABCDEFGHIJKLMNOPQRSTUVWXYZ\n");
	printf("STRING intStack abcdefghijklmnopqrstuvwxyz\n");
	for(int i = 97; i < 123; i++)
	{
		printf("INTEGER %c 0\n", (char)i);
		printf("STRING %c nothing\n", (char)i-32);
	}
	printf("INTEGER intIndex 0\n"); //maybe 1
	printf("INTEGER strIndex 0\n"); //maybe 1
	printf("STRING indexName nothing\n");
	printf("INTEGER one 1\n");
	printf("INTEGER zero 0\n");*/
	
	yyparse();
	cout << myCode.str();
	return 0;
}

int varQuantity(string var)
{
	int counter = 0;	
	for(int i = 0; i < myVariables.size(); i++)
		if(var == myVariables[i])
			counter++;
	return counter;
}

string isVarExist(string var)
{	
	for(int i = myVariables.size() - 1; i >= 0 ; i--)
		if(var == myVariables[i])
			return myVarTypes[i];	
	return "not";
}

int expression(string operation)
{
	if(!isTempExist)
		{
			cout << "INTEGER temp 0\n" ;
			isTempExist = !isTempExist;
		}

	if(!isStrTempExist)
		{
			cout << "STRING strTemp nothing\n";
			isStrTempExist = !isStrTempExist;
		}


	for(int i = 0; i < myStack.size(); i++)
		if(importantVar.at(myStack.size()-i-1))
		{
			if(isStrTemp)
				myCode << operation << " strTemp " << (char)currentAlpha << (char)(myStack.size()+96-i);
			else
				myCode << operation << " temp " << (char)currentAlpha << (char)(myStack.size()+96-i);
			if(operation != "NOT")
				importantVar.at(myStack.size()-i-1) = false;
			break;
		}


	if(operation != "NOT")	
	{
		for(int i = 0; i < myStack.size(); i++)		
			if(importantVar.at(myStack.size()-i-1))
			{
				myCode << " " << (char)currentAlpha << (char)(myStack.size()+96-i) << "\n";
				break;
			}
	}
	else
		myCode << "\n";


	for(int i = 0; i < myStack.size(); i++)
		if(importantVar.at(myStack.size()-i-1))
		{
			if(isStrTemp)
				myCode << "MOVE strTemp " << (char)currentAlpha << (char)(myStack.size()+96-i) << "\n";
			else
				myCode << "MOVE temp " << (char)currentAlpha << (char)(myStack.size()+96-i) << "\n";
			break;
		}

	return 0;
}
