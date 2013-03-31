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
	string isVarExist(string var); //переименовать
	int varQuantity(string var);
	int expression(string operation); //generates code for expressions
	string typeDataClass(string data, string className);
	struct variable
	{
		string name;
		int value;
	};
	
    vector<string> myVariables, myVarTypes, myClasses;    
    stack<string> myStack, myPar, myParType; //myStack is for expression calculation
	vector<bool> importantVar; //importantVar shows if variable is temporary expression result
	vector<string>  myLabels;
    //int result = 0;
    bool isStrTemp = false; // for expressions
	int currentAlpha = 97; //for generating unique variables.
	int myIfCounter = 0, myIfInc = 0, myIfLevel = 0, myRepeatCounter = 0, myRepeat2Counter = 0, myCycleInc = 0, myRetCounter = 0; 
	string dataClassTemp = "", currentFunc = "";
%}

%start progr

%token BEG END IF THEN OTHERWISE REPEAT WHILE WRITE READ RETURN
%token ASSIGN SEMICOLON COMMA LBR RBR COLON DOT
%token PLUS MINUS MULT DIVIDE GOTO LABEL CLASS EX
%token AND OR NOT LT GT EQ NE LE GE
%token INTNUM
%token STRLIT
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

listofoperators : operator SEMICOLON listofoperators
	| operator
	| class SEMICOLON listofoperators
	| class SEMICOLON
	;

class : CLASS ID 
	{
		myClasses.push_back((string)"~" + $2);
	}
	BEG classmembers END
	;

classmembers : data SEMICOLON classmembers
	| data
	| method SEMICOLON classmembers
	| method
	;

data : ID COMMA data
	{
		$$ = $3;
		myClasses.push_back($1);
		myClasses.push_back($3);
	}
	| ID COLON ID
	{
		$$ = $3;
		myClasses.push_back($1);
		myClasses.push_back($3);		
	}
	; 

method : ID COLON ID LBR parameters_declaration RBR 
	{
		cout << "STRING " << $1 << " " << $1 << "\n";
		/*if($3 == "string")
			cout << "STRING " << $1 << "result 0\n";
		else
			cout << "INTEGER " << $1 << "result 0\n";
		myFuncRes.push($1 + (string)"result");*/
		myCode << "LABEL " << $1 << "\n";
		myVariables.push_back($1);
		myVarTypes.push_back($3);
		for(int i = myPar.size() - 1; i = 0; i--)
		{
			if(myParType.top() == "string")
			{
				myCode << "IND indexName strIndex strStack\n";
				myCode << "SUB strIndex one strIndex\n";
				myCode << "MOVE strPointerHelper strTemp\n";
				myCode << "INDIR indexName strTemp\n";
				myCode << "MOVE strPointer " << myPar.top() << "\n";								
			}
			else
			{
				myCode << "IND indexName intIndex intStack\n";
				myCode << "SUB intIndex one intIndex\n";
				myCode << "MOVE intPointerHelper strTemp\n";
				myCode << "INDIR indexName strTemp\n";
				myCode << "MOVE intPointer " << myPar.top() << "\n";
			}
			myPar.pop();
			myParType.pop();
		}
			
	}
	BEG listofoperators END//второе ID - simpletype
	{
		myCode << "SUB strIndex one strIndex\n";
		myCode << "IND indexName strIndex strStack\n";
		myCode << "MOVE strPointerHelper strTemp\n";
		myCode << "INDIR indexName strTemp\n";
		myCode << "ADD strIndex one strIndex\n";
		myCode << "GOTO strPointer\n";
	}
	;

parameters_declaration : 
	|parameters SEMICOLON parameters
	|parameters
	;

parameters : ID COMMA parameters
	{
		$$ = $3;
		if($3 == "string")
		{
			myVariables.push_back($1);
			cout << "STRING " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("string");	
			myParType.push("string");
		}
		else
		{
			myVariables.push_back($1);
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("integer");
			myParType.push("integer");
		}
		myPar.push($1);
	}
	| ID COLON ID
	{
		$$ = $3;
		if($3 == "string")
		{
			myVariables.push_back($1);			
			cout << "STRING " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("string");		
		}
		else
		{
			myVariables.push_back($1);
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("integer");
		}
		myPar.push($1);		
	}
	;

operator: id ASSIGN expr
	{
		$$ = $1;
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				myCode << "MOVE " << (char)currentAlpha << (char)(myStack.size()+96-i) << " " << $1 << varQuantity($1) << dataClassTemp << "\n";
				dataClassTemp = "";
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

	| READ LBR id RBR //read
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
	| RETURN expr
	{
		for(int i = 0; i < myStack.size(); i++)
			if(importantVar.at(myStack.size()-i-1))
			{
				if(isStrTemp)
				{
					myCode << "ADD strIndex one strIndex\n";
					myCode << "IND indexName strIndex strStack\n";
					myCode << "MOVE strPointerHelper strTemp\n";
					myCode << "MOVE " << (char)currentAlpha << (char)(myStack.size()+96-i) << " strPointer\n";
					myCode << "INDIR strTemp indexName\n";
				}
				else
				{
					myCode << "ADD intIndex one intIndex\n";
					myCode << "IND indexName intIndex intStack\n";
					myCode << "MOVE intPointerHelper strTemp\n";
					myCode << "MOVE " << (char)currentAlpha << (char)(myStack.size()+96-i) << " intPointer\n";
					myCode << "INDIR strTemp indexName\n";
				}
				break;
			}
		while(myStack.size() != 0)
			myStack.pop();
		importantVar.clear();
		currentAlpha++;
	}
	| expr
        ;

declaration : ID COMMA declaration
	{
		$$ = $3;
		if($3 == "string")
		{
			myVariables.push_back($1);
			cout << "STRING " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("string");	
		}
		else if($3 == "integer")
		{
			myVariables.push_back($1);
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("integer");
		}
		else 
			for(int i = 0; i < myClasses.size(); i++)
			{
				if(((string)"~" + $3) == myClasses[i])
				{
					myVariables.push_back($1);
					myVarTypes.push_back(myClasses[i]);
					int j = i + 1; 
					while(j < myClasses.size() && myClasses[j][0] != '~')
					{
						if(myClasses[j+1] == "string")
							cout << "STRING";
						else
							cout << "INTEGER";
						cout << " " << $1 << varQuantity($1) << "." << myClasses[j] << " 0\n";
						j += 2;
					}
					break;
				}
			}
	}
	| ID COLON ID
	{
		$$ = $3;
		if($3 == "string")
		{
			myVariables.push_back($1);			
			cout << "STRING " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("string");		
		}
		else if($3 == "integer")
		{
			myVariables.push_back($1);
			cout << "INTEGER " << $1 << varQuantity($1) << " 0\n";
			myVarTypes.push_back("integer");
		}
		else 
			for(int i = 0; i < myClasses.size(); i++)
			{
				if(((string)"~" + $3) == myClasses[i])
				{
					myVariables.push_back($1);
					myVarTypes.push_back(myClasses[i]);
					int j = i + 1; 
					while(j < myClasses.size() && myClasses[j][0] != '~')
					{
						if(myClasses[j+1] == "string")
							cout << "STRING";
						else
							cout << "INTEGER";
						cout << " " << $1 << varQuantity($1) << "." << myClasses[j] << " 0\n";
						j += 2;
					}
					break;
				}
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

	| id //добавить распознавание типа
	{
		myStack.push($1);
	 	importantVar.push_back(true);
		string temp = "string";
		if(isVarExist($1) == temp || typeDataClass(dataClassTemp, isVarExist($1)) == temp)
		{
			isStrTemp = true; 
			cout << "STRING " << (char)currentAlpha << (char)(myStack.size()+96) << " 0\n";
		}
		temp = "integer";
		if(isVarExist($1) == temp || typeDataClass(dataClassTemp, isVarExist($1)) == temp)
		{
			isStrTemp = false;
			cout << "INTEGER " << (char)currentAlpha << (char)(myStack.size()+96) << " 0\n";
		}
		myCode << "MOVE " << $1 << varQuantity($1) << dataClassTemp << " " << (char)currentAlpha << (char)(myStack.size()+96) << "\n";
		dataClassTemp = "";
	}

	| INTNUM EX string //take symbol from string
	{
		myStack.push($1); 
		importantVar.push_back(false);
		cout << "INTEGER " << (char)currentAlpha << (char)(myStack.size()+96) << " " << myStack.top() << "\n";
		myCode << "IND " << (char)currentAlpha << (char)(myStack.size()+95) << " " << (char)currentAlpha << (char)(myStack.size()+96) << " " << (char)currentAlpha << (char)(myStack.size()+95) << "\n";
	}
	| ID DOT ID LBR 
	{
		cout << "STRING goBack" << myRetCounter << " goBack" << myRetCounter << "\n";
		myCode << "MOVE goBack" << myRetCounter << " strPointer\n";
		myCode << "MOVE strPointerHelper strTemp\n";
		myCode << "IND indexName strIndex strStack\n";
		myCode << "INDIR strTemp indexName\n";
		myCode << "ADD strIndex one StrIndex\n";
		currentFunc = $3;
	}
	listOfParameters RBR //call class method
	{
		myCode << "GOTO " << currentFunc << "\n";
		myCode << "LABEL goBack" << myRetCounter << "\n";
		myRetCounter++;
		myStack.push("nothing"); 
		importantVar.push_back(true);		
		if(isStrTemp)
		{
			cout << "STRING " << (char)currentAlpha << (char)(myStack.size()+96) << " " << "0\n";
			myCode << "IND indexName strIndex strStack\n";
			myCode << "MOVE strPointerHelper strTemp\n";
			myCode << "INDIR indexName strTemp\n";
			myCode << "MOVE strPointer " << (char)currentAlpha << (char)(myStack.size()+96) << "\n";			
		}
		else
		{			
			cout << "INTEGER " << (char)currentAlpha << (char)(myStack.size()+96) << " " << "0\n";
			myCode << "IND indexName intIndex intStack\n";
			myCode << "MOVE intPointerHelper strTemp\n";
			myCode << "INDIR indexName strTemp\n";
			myCode << "MOVE intPointer " << (char)currentAlpha << (char)(myStack.size()+96) << "\n";	
		}
		myCode << "SUB strIndex one strIndex\n";		
	}
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
	| id
	{
		myStack.push($1);
	 	importantVar.push_back(true); 
		isStrTemp = true;
		cout << "STRING " << (char)currentAlpha << (char)(myStack.size()+96) << " " << 0 << "\n";
		myCode << "MOVE " << myStack.top() << varQuantity($1) << dataClassTemp << " " << (char)currentAlpha << (char)(myStack.size()+96) << "\n";
		dataClassTemp = "";
	}
	;

id :	ID
	{
		$$ = $1;
	}
	| ID DOT ID
	{
		$$ = $1;
		dataClassTemp = (string)"." + $3;		
	}
listOfParameters: 
	|id COMMA listOfParameters
	{
		string temp = "string";
		if(isVarExist($1) == temp || typeDataClass(dataClassTemp, isVarExist($1)) == temp)
		{
			myCode << "IND indexName strIndex strStack\n";
			myCode << "ADD strIndex one\n";
			myCode << "MOVE " << $1 << varQuantity($1) << dataClassTemp << " strPointer\n";
			myCode << "MOVE strPointerHelper strTemp\n";
			myCode << "INDIR strTemp indexName\n";
		}
		temp = "integer";
		if(isVarExist($1) == temp || typeDataClass(dataClassTemp, isVarExist($1)) == temp)
		{
			myCode << "IND indexName intIndex intStack\n";
			myCode << "ADD intIndex one\n";
			myCode << "MOVE " << $1 << varQuantity($1) << dataClassTemp << " intPointer\n";
			myCode << "MOVE intPointerHelper intTemp\n";
			myCode << "INDIR intTemp indexName\n";
		}
		dataClassTemp = "";
	}
	| id
	{
		string temp = "string";
		if(isVarExist($1) == temp || typeDataClass(dataClassTemp, isVarExist($1)) == temp)
		{
			myCode << "IND indexName strIndex strStack\n";
			myCode << "ADD strIndex one\n";
			myCode << "MOVE " << $1 << varQuantity($1) << dataClassTemp << " strPointer\n";
			myCode << "MOVE strPointerHelper strTemp\n";
			myCode << "INDIR strTemp indexName\n";
		}
		temp = "integer";
		if(isVarExist($1) == temp || typeDataClass(dataClassTemp, isVarExist($1)) == temp)
		{
			myCode << "IND indexName intIndex intStack\n";
			myCode << "ADD intIndex one\n";
			myCode << "MOVE " << $1 << varQuantity($1) << dataClassTemp << " intPointer\n";
			myCode << "MOVE intPointerHelper intTemp\n";
			myCode << "INDIR intTemp indexName\n";
		}
		dataClassTemp = "";
	}
%%

int main()
{
	//stack initialization
	myCode << "STRING strStack ABCDEFGHIJKLMNOPQRSTUVWXYZ\n";
	myCode << "STRING intStack abcdefghijklmnopqrstuvwxyz\n";
	for(int i = 97; i < 123; i++)
	{
		myCode << "INTEGER " << (char)i << " 0\n";
		myCode << "STRING " << (char)(i-32) << " 0\n";
	}
	myCode << "INTEGER intIndex 0\n"; //maybe 1
	myCode << "INTEGER strIndex 0\n"; //maybe 1
	myCode << "STRING indexName 0\n";
	myCode << "INTEGER one 1\n";
	myCode << "INTEGER zero 0\n";
	myCode << "STRING strTemp 0\n";
	myCode << "INTEGER temp 0\n";
	myCode << "INTEGER intPointer 0\n";
	myCode << "STRING intPointerHelper intPointer\n";
	myCode << "STRING strPointer 0\n";
	myCode << "STRING strPointerHelper strPointer\n";
	
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

string typeDataClass(string data, string className)
{
	data.erase(0,1);
	for(int i = 0; i < myClasses.size(); i++)
	{
		if(className == myClasses[i])
		{	
			int j = i + 1; 
			while(j < myClasses.size() && myClasses[j][0] != '~')
			{
				if(myClasses[j] == data)
					return myClasses[j+1];
				j += 2;
			}
			break;
		}
	}
	return "error";
}
