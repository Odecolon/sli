unit l_interpreter;

{$mode objfpc}{$H+}

interface

uses math, types;

const

  {Versions}

  L_VERSION = '0.2';

  {Maxes}

  L_MAX_VARS   = 64;

  {Error codes}

  L_ERR_IO             = 1;
  L_ERR_NE_PROC        = 2;
  L_ERR_STACK_OVERFLOW = 3;
  L_ERR_NE_VAR         = 4;
  L_ERR_TOO_MANY_VARS  = 5;
  L_ERR_SYNTAX_ERROR   = 6;
  L_ERR_INVALID_ARG    = 7;

{Interface}

procedure l_GetScript(iscript: string);
procedure l_GetLog(ilog: string);
procedure l_CloseScript();
procedure l_CloseLog();
procedure l_RunProc(iproc: string);
procedure l_RunLine(iline: string);
procedure l_DefVar(ivar: string; ival: string);
function  l_GetVal(ivar: string): string;
procedure l_SetVal(ivar: string; ival: string);
procedure l_SetConsoleIO();
procedure l_Clear();

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

  StandartIO: boolean;

  Vars        : array [1..L_MAX_VARS] of tVar;
  Lexems      : tList;
  ReturnStack : tStack;
  LoopStack   : tStack;

  CurrentLine: integer;
  StayOn     : boolean;

{Instruments}

procedure Flush();
begin

  Lexems.Init();

end;

procedure QuitScript();
begin

   Close(ScriptFile);

end;

procedure ErrExit(ierror: integer);
begin

  if (StandartIO = true) then begin

    case ierror of

         1: writeln('L_ERR_IO');
         2: writeln('L_ERR_NE_PROC');
         3: writeln('L_ERR_STACK_OVERFLOW');
         4: writeln('L_ERR_NE_VAR');
         5: writeln('L_ERR_TOO_MANY_VARS');
         6: writeln('L_ERR_SYNTAX_ERROR');
         7: writeln('L_ERR_INVALID_ARG');

    end;

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

  if (ScriptReady = true) then Close(ScriptFile);
  if (LogReady = true) then Close(LogFile);

  halt();

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

begin

  LexemPreprocessor:= '';

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

         Str(math_DoMath(istr), LexemPreprocessor);

       end;

  end;

end;

procedure ScriptParser(iline: string);
var

  i: integer;
  s: string;

begin

  i:= 1;
  s:= '';

  if (StayOn = true) then exit;

  Flush();

  while (true) do begin

    while (i < length(iline)) and (iline[i] = ' ') do i:= i + 1;

    while (i <= length(iline)) do begin

      if (iline[i] = '"') then begin

         i:= i + 1;

         while (iline[i] <> '"') do begin

           s:= s + iline[i];
           i:= i + 1;

         end;

         i:= i + 1;

         break;

      end;

      if (iline[i] <> ' ') then s:= s + iline[i];
      if (iline[i] = ' ') and (iline[i + 1] <> ' ') then break;

      i:= i + 1;

    end;

    Lexems.Append(LexemPreprocessor(s));

    s:= '';
    i:= i + 1;

    if (i > length(iline)) then break;

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

    if (UpCase(Lexems.List[1]) = 'DEF') and (UpCase(Lexems.List[2]) = 'PROC') and (Lexems.List[3] = iproc) then begin

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

  if (StayOn = true) then exit;

  readln(ScriptFile, line);
  ScriptParser(RemoveCmdSymbols(line));
  CurrentLine:= CurrentLine + 1;

end;

{Commands}

procedure Cmd_Out();
var

  istr: string;

begin

  if (StandartIO = false) then exit;

  istr:= Lexems.List[2];

  write(istr);

  if (LogReady = true) then write(LogFile, istr);

end;

procedure Cmd_Outln();
var

  istr: string;

begin

  if (StandartIO = false) then exit;

  istr:= Lexems.List[2];

  writeln(istr);

  if (LogReady = true) then writeln(LogFile, istr);

end;

procedure Cmd_Get();
var

  istr: string;

begin

  if (StandartIO = false) then exit;

  read(istr);

  if (LogReady = true) then write(LogFile, istr);

  Vars[SearchVar(Lexems.List[2])].vValue:= istr;

end;

procedure Cmd_Getln();
var

  istr: string;

begin

  if (StandartIO = false) then exit;

  readln(istr);

  if (LogReady = true) then writeln(LogFile, istr);

  Vars[SearchVar(Lexems.List[2])].vValue:= istr;

end;

procedure Cmd_Do();
begin

  ReturnStack.Push(CurrentLine);
  SearchProc(Lexems.List[2]);

end;

procedure Cmd_Def();
begin

  if (UpCase(Lexems.List[2]) = 'VAR') and (Lexems.List[3] <> '') then begin

     if (Lexems.List[4] = '=') then begin

       DefineVar(Lexems.List[3], Lexems.List[5]);

     end else begin

       DefineVar(Lexems.List[3], '');

     end;

  end;

end;

procedure Cmd_Del();
begin

  DeleteVar(Lexems.List[2]);

end;

procedure Cmd_If();
var

  a: integer;
  b: integer;
  c: boolean;

  n : integer;
  ic: integer;

begin

  if (UpCase(Lexems.List[5]) <> 'THEN') then ErrExit(L_ERR_SYNTAX_ERROR);

  c:= false;

  case Lexems.List[3] of

       '=': begin

         if (Lexems.List[2] = Lexems.List[4]) then c:= true;

       end;

       '>': begin

         Val(Lexems.List[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems.List[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a > b) then c:= true;

       end;

       '<': begin

         Val(Lexems.List[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems.List[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a < b) then c:= true;

       end;

       '>=': begin

         Val(Lexems.List[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems.List[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a >= b) then c:= true;

       end;

       '<=': begin

         Val(Lexems.List[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems.List[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a <= b) then c:= true;

       end;

       '!=': begin

         Val(Lexems.List[2], a, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         Val(Lexems.List[4], b, ic);
         if (ic <> 0) then ErrExit(L_ERR_INVALID_ARG);

         if (a <> b) then c:= true;

       end;

  end;

  if (Lexems.Size > 5) then begin

     if (c = true) then begin

       while (UpCase(Lexems.List[1]) <> 'THEN') do Lexems.Delete(1);
       Lexems.Delete(1);

       StayOn:= true;

     end;

  end else begin

    if (c = false) then begin

       n:= 1;

       while (n <> 0) do begin

         GetLine();

           if (UpCase(Lexems.List[1]) = 'IF') then n:= n + 1;
           if (UpCase(Lexems.List[1]) = 'END') and (UpCase(Lexems.List[2]) = 'IF') then n:= n - 1;

       end;

    end;

  end;

end;

procedure Cmd_Loop();
begin

  LoopStack.Push(CurrentLine);

end;

procedure Cmd_End();
var

  i: integer;

begin

  if (UpCase(Lexems.List[2]) = 'LOOP') then begin

    i:= LoopStack.Pull();

    GotoLine(i);
    LoopStack.Push(i);

  end;

end;

procedure Cmd_Continue();
var

  i:integer;

begin

  i:= LoopStack.Pull();

  if (i <> 0) then begin

    LoopStack.Push(i);
    GotoLine(i);

  end;

end;

procedure Cmd_Break();
begin

  LoopStack.PullOut();

  while (true) do begin

    GetLine();

    if (UpCase(Lexems.List[1]) = 'END') and (UpCase(Lexems.List[2]) = 'LOOP') then break;

  end;

end;

{Main structures}

procedure ExecuteLine();
begin

  if (StayOn = true) then StayOn:= false;

  case UpCase(Lexems.List[1]) of

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

       if (Lexems.List[2] = '=') then Vars[SearchVar(Lexems.List[1])].vValue:= Lexems.List[3];

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

    if ((UpCase(Lexems.List[1]) = 'END') and (UpCase(Lexems.List[2]) = 'DEF')) or (UpCase(Lexems.List[1]) = 'RETURN') then break;

    GetLine();
    ExecuteLine();

  end;

  iline:= ReturnStack.Pull();

  if (iline <> 0) then begin

    GotoLine(iline);
    Execute();

  end;

end;

procedure Init();
var

  i: integer;

begin

  ScriptReady:= false;
  LogReady   := false;
  StandartIO := false;

  for i:= 1 to L_MAX_VARS do begin

    Vars[i].vName := '';
    Vars[i].vValue:= '';

  end;

  Lexems.Init();
  ReturnStack.Init();
  LoopStack.Init();

  CurrentLine:= 0;
  StayOn     := false;

end;

{Interface implementations}

procedure l_GetScript(iscript: string);
begin

  Assign(ScriptFile, iscript);

  {$I-}
  Reset(ScriptFile);
  {$I+}

  if (IOResult <> 0) then ErrExit(L_ERR_IO);

  ScriptReady:= true;

end;

procedure l_GetLog(ilog: string);
begin

  Assign(LogFile, ilog);

  {$I-}
  Rewrite(LogFile);
  {$I+}

  if (IOResult <> 0) then ErrExit(L_ERR_IO);

  LogReady:= true;

end;

procedure l_CloseScript();
begin

  if (ScriptReady = true) then Close(ScriptFile);

end;

procedure l_CloseLog();
begin

  if (LogReady = true) then Close(LogFile);

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

procedure l_DefVar(ivar: string; ival: string);
begin

  DefineVar(ivar, ival);

end;

procedure l_SetVal(ivar: string; ival: string);
begin

  Vars[SearchVar(ivar)].vValue:= ival;

end;

function  l_GetVal(ivar: string): string;
begin

  l_GetVal:= Vars[SearchVar(ivar)].vValue;

end;

procedure l_SetConsoleIO();
begin

  StandartIO:= true;

end;

procedure l_Clear();
begin

  if (ScriptReady = true) then Close(ScriptFile);
  if (LogReady = true) then Close(LogFile);

  Init();

end;

initialization

Init();

end.

