package Example;

import java_cup.runtime.SymbolFactory;
%%
%cup
%class Scanner
%{
	public Scanner(java.io.InputStream r, SymbolFactory sf){
		this(r);
		this.sf=sf;
	}
	private SymbolFactory sf;
%}

// We define what happens when the lexer reaches the end of the file here.

%eofval{
    return sf.newSymbol("EOF",sym.EOF);
%eofval}

// Here the macros are defined, thiss makes it easier to understand the lexical rules later on in the code. This follows the 'objects' defined in the JSON specification.

//the negative_zero_fraction macro is necessary as the negative sign is not incorporated in the other macros when the first number input token is 0.  

digit1_9 = [1-9]
digit = [0-9]
digits = (0 | {digit1_9}{digit}*)
integer = (0 | [+-]?{digit1_9}{digit}*)
dot = "."
frac = {dot}{digits}+ 
negative_zero_fraction = "-"[0]{frac}
exp = [eE]?[+-]?{digits}+
number = {negative_zero_fraction} |{integer}| {integer}{frac} | {integer}{exp} | {integer}{frac}{exp} | {exp} 

//String can be any unicode character except for the ones listed below. 

string = \"[^(\")(\\)(\/)(\b)(\n)(\r)(\t)(\f)]*\" 

// Here the lexical rules are defined. Each one of these symbols has to refer to a terminal value in the parser. Again, this closely follows the JSON specification. NUMBER, STRING, TRUE and FALSE will create Java object equivalent when detected by the lexer. 

%%
{string} { return sf.newSymbol("String",sym.STRING, new String(yytext())); }

"," { return sf.newSymbol("Comma",sym.COMMA); }
":" { return sf.newSymbol("Colon",sym.COLON); }
"[" { return sf.newSymbol("Left Square Bracket",sym.LSQBRACKET); }
"]" { return sf.newSymbol("Right Square Bracket",sym.RSQBRACKET); }
"{" { return sf.newSymbol("Left Curly Bracket",sym.LCLBRACKET); }
"}" { return sf.newSymbol("Right Curly Bracket",sym.RCLBRACKET); }
"true" { return sf.newSymbol("True",sym.TRUE, new Boolean(true)); }
"false" { return sf.newSymbol("True",sym.FALSE, new Boolean(false)); }
"null" { return sf.newSymbol("Null",sym.NULL); }

//Unlike Java, floats are not explicitely defined in JSON code. The type of number is defined from the use of a decimal point.    

{number} { return sf.newSymbol("Integral Number",sym.NUMBER, new Double(yytext()));}


[ \t\r\n\f] { /* ignore white space. */ }

. { System.err.println("Illegal character: "+yytext()); }
