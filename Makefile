parser: lex.yy.o myCompilator.tab.o
	g++ -o parser lex.yy.o myCompilator.tab.o
lex.yy.o myCompilator.tab.o: lex.yy.c myCompilator.tab.c
	g++ -c lex.yy.c myCompilator.tab.c
lex.yy.c: myCompilator.l
	flex myCompilator.l
myCompilator.tab.h myCompilator.tab.c myCompilator.output: myCompilator.y
	bison -d myCompilator.y --verbose
clean:
	rm -f myCompilator.tab.h myCompilator.tab.c myCompilator.output lex.yy.c lex.yy.o myCompilator.tab.o parser

