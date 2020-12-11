sli v0.4 - simple L interpreter by Odecolon

Sorry, this text was translated using GoogleTranslate :)

1. About the program

sli is an interpreter for a simple scripting language L that I created for embedding in my other projects. Therefore, the interpreter is placed in a separate module written in FreePascal, and sli is a small console around it (oddly enough, it is also written in FreePascal).

The language itself is described in the third section of this readme. In addition, the examples folder of this repository contains example scripts.

2. What's new?

In version 0.4, the parser of mathematical expressions was improved, the preprocessor operator % was removed - now mathematical expressions are determined automatically. Added the ability to concatenate strings, added the cancel operator ~. The interface of the interpreter has been improved. Also removed the ability to generate logs. The error system has been slightly improved, but there are still problems with the definition of some errors.

3. Launch and capabilities

To execute a script from a file:

  sli [script_file]

In the console, you can use the 'h' command to get a list of the available commands.

Tested with lazarus v1.8.0 with fpc 3.0.4 win32 under Win7.

4. About the L language

L is a scripting language designed to be embedded somewhere. Simple, primitive, unwieldy and non-obvious. Procedural but not functional. Has only global variables and only integer arithmetic. The language version is 0.4.

Note - if you made a mistake or did not use the given recommendations, then the interpreter can either crash altogether, or produce a completely unpredictable result.

A program consists of a set of procedure and variable declarations. Variables are only global, they require declaration for their use (they are declared at the same level as procedures, that is, outside procedures) and dereferencing to use their values. Each stand-alone program contains a main routine, returning from which means the end of the program.

The program consists of a set of commands. The program is executed line by line.

The order of line processing is as follows:

1) Reading a line from a file.
2) Removing non-ASCII characters, as well as control characters.
3) Splitting the string into lexemes by spaces (a character set enclosed in quotes (") is read as a token, even if it contains spaces).
4) Getting data by dereferencing variables (see below).
5) Performing actions on strings (see below).
6) Performing mathematical calculations.
7) String execution.

Language alphabet:

Upper and lower case Latin characters are used, numbers from 0 to 9, symbols $, @, +, -, *, /, ",!, =, (,), <,>. Key words and variables are not case sensitive.

List of keywords:

def, proc, var, if, loop, end, out, ln, get, break, continue, return, do

List of preprocessing commands:

1) $ - dereferencing a variable, that is, when processing a string before executing, $variable_name is replaced by its value.
2) @ - string concatenation, that is, string_1 @ string_2 is replaced with a string that is a concatenation of the original two.

List of supported math operations:

1) + - addition
2) - - subtraction
3) * - multiplication
4) / - integer division
5) == - equal
6) > - more
7) < - less
8) <= - less or equal
9) >= - more or equal
10) != - not equal
12) ! - not
12) & - and
13) | - or

One - true and zero - false are used as logical values.

List of commands:

1) def - declaration of an object (procedure / variable).

Structure for a variable: def var [variable_name] or def var [variable_name] = [variable_value]
Structure for the procedure:

def proc [proc_name]

  [procedure_body]

end def

2) = - assignment of a value to a variable.

Structure: [variable_name] = [value]

3) loop - declaration of an unconditional loop.

Structure:

loop

  [loop-body]

end loop

4) if - conditional construction.

Structure: if [boolean_expression] then [command] or

if [boolean_expression] then

  [command_sequence]

end if

5) break - instruction to interrupt the loop.

Structure: break

6) continue - an instruction to move the loop to the next operation.

Structure: continue

7) return - an instruction to return from an executable procedure.

Structure: return

8) out, outln - standard output.

Structure: out [value] ln - with a line break or: out [value] - without a line break.

9) get - standard variable input.

Structure: get [variable] (with a new line).

10) do - procedure call.

Structure: do [sp_name]

5. Code examples

Standard hello-world (examples \ hello.l):

def proc main

  out "Hello, world!" ln

end def

Calculating factorial (examples \ factorial.l):

def var n
def var f

def proc main

  out "n = "
  get n

  do factorial

  out "f = "
  out $f ln

end def

def proc factorial

  f = 1

  loop

    if $n == 0 then break

    f = $f * $n
    n = $n - 1

  end loop

end def
