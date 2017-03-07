/*
 * MIT License
 * 
 * Copyright (c) 2017 Marco Silipo aka X39
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

grammar sqf;
options
{
    language = cs;
}
@header
{
	using System.Collections.Generic;
    using System.Linq;
}
@lexer::members
{
	private IEnumerable<SqfDefinition> BinaryDefinitions;
	private IEnumerable<SqfDefinition> UnaryDefinitions;
	private IEnumerable<SqfDefinition> NullarDefinitions;

	public sqfLexer(ICharStream input, IEnumerable<SqfDefinition> definitions) : this(input)
	{
		this.BinaryDefinitions = from def in definitions where def.Kind == SqfDefinition.EKind.Binary select def;
		this.UnaryDefinitions = from def in definitions where def.Kind == SqfDefinition.EKind.Unary select def;
		this.NullarDefinitions = from def in definitions where def.Kind == SqfDefinition.EKind.Nullar select def;
	}
}

sqf: code;

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment DIGIT: [0-9];
fragment LETTER: (LOWERCASE | UPPERCASE);
fragment HEXADIGIT: (DIGIT | [a-f] | [A-F]);
fragment ANY: .;
PUNCTUATION: '||' | '&&' | '==' | '>=' | '<=' | '!=' | '*' | '/' | '>>' | '+' | '-';
WS: [ \t\r\n]+ -> skip;
INSTRUCTION: '//@' .*? '\n';
INLINECOMMENT: '//' .*? '\n' -> skip;
BLOCKCOMMENT: '/*' .*? '*/' -> skip;
PREPROCESSOR: '#' .*? '\n' -> skip;
STRING: '"' ( ANY | '""' )*? '"' | '\'' ( ANY | '\'\'' )*? '\'';
NUMBER: ('0x' | '$') HEXADIGIT+ |  '-'? DIGIT+ ( '.' DIGIT+ )?;
IDENTIFIER: (LETTER | '_') (LETTER | DIGIT | '_')*;
CURLYOPEN: '{';
CURLYCLOSE: '}';
ROUNDOPEN: '(';
ROUNDCLOSE: ')';
EDGYOPEN: '[';
EDGYCLOSE: ']';
BINARY: { this.BinaryDefinitions.ContainsName(_input.GetTextTillWhitespace()) }?;
UNARY: { this.UnaryDefinitions.ContainsName(_input.GetTextTillWhitespace()) }?;
NULL: { this.NullarDefinitions.ContainsName(_input.GetTextTillWhitespace()) }?;


code:
        statement (';' statement?)*
    ;
statement:
             assignment
         |   binaryexpression
         ;
assignment:
			IDENTIFIER '=' binaryexpression
          |	IDENTIFIER IDENTIFIER '=' binaryexpression
          ;
binaryexpression:
                    primaryexpression
                |	binaryexpression BINARY binaryexpression 
                ;
primaryexpression: 
                     NUMBER
                 |   unaryexpression
                 |   nularexpression
                 |   variable
                 |   STRING
                 |   CURLYOPEN code CURLYCLOSE
                 |   ROUNDOPEN binaryexpression ROUNDCLOSE
                 |   EDGYOPEN ( binaryexpression ( ',' binaryexpression )* )? EDGYCLOSE
                 ;
nularexpression:
                   operator
			   |   NULL
               ;
unaryexpression:
                   UNARY primaryexpression
               ;
variable:
            IDENTIFIER
        ;
operator:
            IDENTIFIER
        |   PUNCTUATION
        |   PUNCTUATION PUNCTUATION
        ;