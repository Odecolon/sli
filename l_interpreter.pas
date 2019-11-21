unit l_interpreter;

{$mode objfpc}{$H+}

interface

const

  L_VERSION = '0.1';

  L_MAX_VARS   = 64;
  L_MAX_LEXEMS = 64;
  L_STACK_SIZE = 64;

  L_ERR_IO             = 1;
  L_ERR_NE_PROC        = 2;
  L_ERR_STACK_OVERFLOW = 3;
  L_ERR_NE_VAR         = 4;
  L_ERR_TOO_MANY_VARS  = 5;
  L_ERR_SYNTAX_ERROR   = 6;
  L_ERR_INVALID_ARG    = 7;

procedure l_GetScript(iscript: string);
procedure l_GetLog(ilog: string);
procedure l_RunProc(iproc: string);
procedure l_RunLine(iline: string);
procedure l_Exit();

implementation

type

  tVar = record

    vName : string;
    vValue: string;

  end;

var

  ScriptFile: text;
  LogFile   : text;

  ScriptReady: boolean;
  LogReady   : boolean;

  Vars       : array [1..L_MAX_VARS] of tVar;
  Lexems     : array [1..L_MAX_LEXEMS] of string;

  ReturnStack : array [1..L_STACK_SIZE] of integer;
  LoopStack   : array [1..L_STACK_SIZE] of integer;
  ReturnSP    : integer;
  LoopSP      : integer;

  CurrentLine: integer;

procedure Flush();
var

  i: integer;

begin

  for i:= 1 to L_MAX_LEXEMS do begin

    Lexems[i]:= '';

  end;

end;

procedure QuitScript();
begin

   Close(ScriptFile);

end;

procedure ErrExit(ierror: integer);
begin

  case ierror of

       1: writeln('L_ERR_IO');
       2: writeln('L_ERR_NE_PROC');
       3: writeln('L_ERR_STACK_OVERFLOW');
       4: writeln('L_ERR_NE_VAR');
       5: writeln('L_ERR_TOO_MANY_VARS');
       6: writeln('L_ERR_SYNTAX_ERROR');
       7: writeln('L_ERR_INVALID_ARG');

  end;

  if (LogReady = true) then begin

    case ierror of

       1: writeln(LogFile, 'L_ERR_IO');
       2: writeln(LogFile, 'L_ERR_NE_PROC');
       3: writeln(LogFile, 'L_ERR_STACK_OVERFLOW');
       4: writeln(LogFile, 'L_ERR_NE_VAR');
       5: writeln(LogFile, 'L_ERR_TOO_MANY_VARS');
       6: writeln(LogFile, 'L_ERR_SYNTAX_ERROR');
       7: writeln(LogFile, 'L_ERR_INVALID_ARG');

    end;

  end;

  Flush();

  Close(ScriptFile);
  Close(LogFile);

  halt();

end;

procedure ReturnPush(ival: integer);
begin

  if (ReturnSP = L_STACK_SIZE) then ErrExit(L_ERR_STACK_OVERFLOW);

  ReturnSP:= ReturnSP + 1;

  ReturnStack[ReturnSP]:= ival;

end;

function ReturnPull(): integer;
var

  iswap: integer;

begin

  if ReturnSP = 0 then begin

     ReturnPull:= 0;
     exit;

  end;

  iswap:= ReturnStack[ReturnSP];
  ReturnStack[ReturnSP]:= 0;
  ReturnPull:= iswap;
  ReturnSP:= ReturnSP - 1;

end;

procedure LoopPush(ival: integer);
begin

  if (LoopSP = L_STACK_SIZE) then ErrExit(L_ERR_STACK_OVERFLOW);

  LoopSP:= LoopSP + 1;

  LoopStack[LoopSP]:= ival;

end;

function LoopPull(): integer;
begin

  if LoopSP = 0 then begin

     LoopPull:= 0;
     exit;

  end;

  LoopPull:= LoopStack[LoopSP];
  LoopStack[LoopSP]:= 0;
  LoopSP:= LoopSP - 1;

end;

function RemoveCmdSymbols(istr: string): string;
var

  i: integer;

begin

  RemoveCmdSymbols:= '';

  for i:= 1 to length(istr) do begin

    if (ord(istr[i]) >= 32) and (ord(istr[i]) <= 254) then begin

    RemoveCmdSymbols:= RemoveCmdSymbols + istr[i];

    end;

  end;

end;

function SearchVar(ivar: string): integer;
var

  i: integer;

begin

  for i:= 1 to L_MAX_VARS do begin

    if (Vars[i].vName = ivar) then begin

       SearchVar:= i;
       exit;

    end;

  end;

  ErrExit(L_ERR_NE_VAR);

end;

procedure DefineVar(iname: string; ivalue: string);
var

  i: integer;

begin

  for i:= 1 to L_MAX_VARS do begin

    if (Vars[i].vName = '') then begin

       Vars[i].vName := iname;
       Vars[i].vValue:= ivalue;
       exit;

    end;

  end;

  ErrExit(L_ERR_TOO_MANY_VARS);

end;

procedure DeleteVar(ivar: string);
begin

  Vars[SearchVar(ivar)].vValue:= '';
  Vars[SearchVar(ivar)].vName := '';

end;

function LexemPreprocessor(istr: string): string;
var

  rv  : string;
  i   : integer;
  ipos: integer;

  a_v: integer;
  b_v: integer;
  c_v: integer;

  a_s: string;
  b_s: string;
  c_s: string;

  s    : string;
  l    : integer;
  icode: integer;

begin

  if (istr = '') then exit;

  rv:= istr[1];

  LexemPreprocessor:= istr;

  case rv of

       '$': begin

         delete(istr, 1, 1);

         LexemPreprocessor:= Vars[SearchVar(istr)].vValue;

       end;

       '%': begin

         delete(istr, 1, 1);

         for i:= 1 to L_MAX_VARS do begin

           if (Vars[i].vName <> '') and (pos('$' + Vars[i].vName, istr) <> 0) then begin

             ipos:= pos('$' + Vars[i].vName, istr);

             if (istr[ipos + length('$' + Vars[i].vName)] <> ' ') and (istr[ipos + length('$' + Vars[i].vName)] <> ')') and (ipos + length('$' + Vars[i].vName) <= length(istr)) then begin

               continue;

             end;

             delete(istr, ipos, length('$' + Vars[i].vName));
             insert(Vars[i].vValue, istr, ipos);

           end;

         end;

         for i:= 1 to length(istr) do begin

           if (istr[i] = ' ') then delete(istr, i, 1);

         end;

         while (true) do begin

           ipos:= length(istr);

           a_v:= 0;
           b_v:= 0;
           c_v:= 0;

           a_s:= '';
           b_s:= '';
           c_s:= '';
           l  := 1;

           while (istr[ipos] <> '(') do begin

             ipos:= ipos - 1;

             if (ipos = 0) then break;

           end;

           ipos:= ipos + 1;

           if (istr[ipos] = '+') or (istr[ipos] = '-') then begin

               a_s := a_s + istr[ipos];
               ipos:= ipos + 1;
               l   := l + 1;

           end;

           while (true) do begin

             if (istr[ipos] = '+') or (istr[ipos] = '-') or (istr[ipos] = '*') or (istr[ipos] = '/') then break;

             a_s := a_s + istr[ipos];
             ipos:= ipos + 1;
             l   := l + 1;

             if (ipos > length(istr)) then begin

               LexemPreprocessor:= a_s;
               exit;

             end;

           end;

           s   := istr[ipos];
           ipos:= ipos + 1;
           l   := l + 1;

           while (istr[ipos] <> ')') and (ipos <= length(istr)) do begin

             b_s := b_s + istr[ipos];
             ipos:= ipos + 1;
             l   := l + 1;

           end;

           if (istr[ipos] = ')') then begin

             delete(istr, ipos, 1);

           end else begin

             l:= l - 1;

           end;

           val(a_s, a_v, icode);
           val(b_s, b_v, icode);

           case s of

                '+': c_v:= a_v + b_v;
                '-': c_v:= a_v - b_v;
                '*': c_v:= a_v * b_v;
                '/': c_v:= a_v div b_v;

           end;

           str(c_v, c_s);

           delete(istr, ipos - l, l);
           insert(c_s, istr, ipos - l);

         end;

       end;

  end;

end;

procedure ScriptParser(iline: string);
var

  i :  integer;
  c :  integer;

begin

  i:= 1;
  c:= 1;

  Flush();

  for i:= 1 to length(iline) do begin

    if(iline[i] <> ' ') then break;

  end;

  while (c <= L_MAX_LEXEMS) do begin

    Lexems[c]:= '';

    while (i <= length(iline)) do begin

      if (iline[i] = '"') then begin

         i:= i + 1;

         while (i <= length(iline)) do begin

           if (iline[i] = '"') then break;

           Lexems[c]:= Lexems[c] + iline[i];
           i        := i + 1;

         end;

         i:= i + 1;

         break;

      end;

      if (iline[i] <> ' ') then Lexems[c]:= Lexems[c] + iline[i];
      if (iline[i] = ' ') and (iline[i + 1] <> ' ') then break;

      i:= i + 1;

    end;

    Lexems[c]:= LexemPreprocessor(Lexems[c]);

    i:= i + 1;
    c:= c + 1;

  end;

end;

procedure SearchProc(iproc: string);
var

  line: string;

begin

  Reset(ScriptFile);

  CurrentLine:= 0;

  while EOF(ScriptFile) = false do begin

    readln(ScriptFile, line);
    ScriptParser(RemoveCmdSymbols(line));

    CurrentLine:= CurrentLine + 1;

    if (UpCase(Lexems[1]) = 'DEF') and (UpCase(Lexems[2]) = 'PROC') and (Lexems[3] = iproc) then begin

       exit;

    end;

  end;

  ErrExit(L_ERR_NE_PROC);

end;

procedure GotoLine(iline: integer);
var

  line: string;

begin

  CurrentLine:= 0;

  Reset(ScriptFile);

  while EOF(ScriptFile) = false do begin

    readln(ScriptFile, line);
    CurrentLine:= CurrentLine + 1;

    if (CurrentLine = iline) then exit;

  end;

  ErrExit(L_ERR_NE_PROC);

end;

procedure GetLine();
var

  line: string;

begin

  readln(ScriptFile, line);
  ScriptParser(RemoveCmdSymbols(line));
  CurrentLine:= CurrentLine + 1;

end;

procedure Cmd_Out();
begin

  write(Lexems[2]);

  if (LogReady = true) then write(LogFile, Lexems[2]);

end;

procedure Cmd_Outln();
begin

  writeln(Lexems[2]);

  if (LogReady = true) then writeln(LogFile, Lexems[2]);

end;

procedure Cmd_Get();
var

  istr: string;

begin

  read(istr);

  if (LogReady = true) then write(LogFile, istr);

  Vars[SearchVar(Lexems[2])].vValue:= istr;

end;

procedure Cmd_Getln();
var

  istr: string;

begin

  readln(istr);

  if (LogReady = true) then writeln(LogFile, istr);

  Vars[SearchVar(Lexems[2])].vValue:= istr;

end;

procedure Cmd_Do();
begin

  ReturnPush(CurrentLine);
  SearchProc(Lexems[2]);

end;

procedure Cmd_Def();
begin

  if (UpCase(Lexems[2]) = 'VAR') and (Lexems[3] <> '') then begin

     if (Lexems[4] = '=') then begin

       DefineVar(Lexems[3], Lexems[5]);

     end else begin

       DefineVar(Lexems[3], '');

     end;

  end;

end;

procedure Cmd_Del();
begin

  DeleteVar(Lexems[2]);

end;

procedure Cmd_If();
var

  a: integer;
  b: integer;
  c: boolean;

  n : integer;
  ic: integer;

begin

  if (UpCase(Lexems[5]) <> 'THEN') then ErrExit(L_ERR_SYNTAX_ERROR);

  c:= false;

  case Lexems[3] of

       '=': begin

         if (Lexems[2] = Lexems[4]) then c:= true;

       end;

       '>': begin

         Val(Lexems[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a > b) then c:= true;

       end;

       '<': begin

         Val(Lexems[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a < b) then c:= true;

       end;

       '>=': begin

         Val(Lexems[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a >= b) then c:= true;

       end;

       '<=': begin

         Val(Lexems[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a <= b) then c:= true;

       end;

       '!=': begin

         Val(Lexems[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a <> b) then c:= true;

       end;

  end;

  if (c = false) then begin

    n:= 1;

    while (n <> 0) do begin

      GetLine();

      If (UpCase(Lexems[1]) = 'IF') then n:= n + 1;
      If (UpCase(Lexems[1]) = 'END') and (UpCase(Lexems[2]) = 'IF') then n:= n - 1;

    end;

  end;

end;

procedure Cmd_Loop();
begin

  LoopPush(CurrentLine);

end;

procedure Cmd_End();
var

  i: integer;

begin

  if (UpCase(Lexems[2]) = 'LOOP') then begin

    i:= LoopPull();

    GotoLine(i);
    LoopPush(i);

  end;

end;

procedure Cmd_Continue();
var

  i:integer;

begin

  i:= LoopPull();

  if (i <> 0) then begin

    LoopPush(i);
    GotoLine(i);

  end;

end;

procedure Cmd_Break();
var

  i: integer;

begin

  i:= LoopPull();

  while (true) do begin

    GetLine();

    if (UpCase(Lexems[1]) = 'END') and (UpCase(Lexems[2]) = 'LOOP') then break;

  end;

end;

procedure ExecuteLine();
begin

  case UpCase(Lexems[1]) of

       'OUTLN'   : Cmd_Outln();
       'GETLN'   : Cmd_Getln();
       'OUT'     : Cmd_Out();
       'GET'     : Cmd_Get();
       'DO'      : Cmd_Do();
       'DEF'     : Cmd_Def();
       'DEL'     : Cmd_Del();
       'IF'      : Cmd_If();
       'LOOP'    : Cmd_Loop();
       'END'     : Cmd_End();
       'CONTINUE': Cmd_Continue();
       'BREAK'   : Cmd_Break();

  else begin

       if (Lexems[2] = '=') then Vars[SearchVar(Lexems[1])].vValue:= Lexems[3];

       end;

  end;

end;

procedure Execute();
var

  iline: integer;

begin

  iline:= 0;

  Flush();

  while (true) do begin

    if ((UpCase(Lexems[1]) = 'END') and (UpCase(Lexems[2]) = 'DEF')) or (UpCase(Lexems[1]) = 'RETURN') then break;

    GetLine();
    ExecuteLine();

  end;

  iline:= ReturnPull();

  if (iline <> 0) then begin

    GotoLine(iline);
    Execute();

  end;

end;

procedure l_GetScript(iscript: string);
begin

  Assign(ScriptFile, iscript);

  if (IOResult <> 0) then ErrExit(L_ERR_IO);

  Reset(ScriptFile);

  ScriptReady:= true;

end;

procedure l_GetLog(ilog: string);
begin

  Assign(LogFile, ilog);

  if (IOResult <> 0) then ErrExit(L_ERR_IO);

  Rewrite(LogFile);

  LogReady:= true;

end;

procedure l_RunProc(iproc: string);
begin

  if (ScriptReady = true) then begin

    SearchProc(iproc);
    Execute();

  end;

end;

procedure l_RunLine(iline: string);
begin

  ScriptParser(RemoveCmdSymbols(iline));
  ExecuteLine();

end;

procedure l_Exit();
begin

  Flush();

  if (ScriptReady = true) then Close(ScriptFile);
  if (LogReady = true) then Close(LogFile);

end;

procedure Init();
var

  i: integer;

begin

  ScriptReady:= false;
  LogReady   := false;

  for i:= 1 to L_MAX_VARS do begin

    Vars[i].vName := '';
    Vars[i].vValue:= '';

  end;

  for i:= 1 to L_MAX_LEXEMS do begin

    Lexems[i]:= '';

  end;

  for i:= 1 to L_STACK_SIZE do begin

    ReturnStack[i]:= 0;

  end;

  ReturnSP:= 0;

  for i:= 1 to L_STACK_SIZE do begin

    LoopStack[i]:= 0;

  end;

  LoopSP:= 0;

end;

initialization

Init();

end.

