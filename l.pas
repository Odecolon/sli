unit l;

{Odecolon's l language v0.4}

{$mode objfpc}{$H+}

interface

uses

  types, math;

const

  {Versions}

  L_VERSION = '0.4';

  {Maxes}

  L_MAX_LEXEMS = 64;

  {Error Codes}

  L_ERR_IO      = 1;
  L_ERR_SYNTAX  = 2;
  L_ERR_NE_OBJ  = 3;
  L_ERR_DBL_DEF = 4;

var

  ScriptFile: text;

  StreamIn : tStream;
  StreamOut: tStream;
  StreamErr: tStream;

  Vars     : tGlossary;
  Lexems   : tList;
  CallStack: tStack;
  LoopStack: tStack;

  CurrentLine: integer;
  CurrentProc: string;

  ScriptReady: boolean;
  ErrorLevel : boolean;
  StayOn     : boolean;

procedure l_SetConsoleIO();
procedure l_RunProc(iproc: string);
procedure l_OpenScript(iscript: string);
procedure l_CloseScript();
procedure l_Clear();
procedure l_Init();

implementation

{Errors and exeptions}

procedure Err(n: integer);
var

  n_s: string;
  currentline_s: string;

begin

  Str(n, n_s);
  Str(CurrentLine, currentline_s);

  case n of

       L_ERR_IO     : StreamErr.Put(currentline_s + ': ERR#' + n_s + ' - I/O ERROR' + chr(13) + chr(10));
       L_ERR_SYNTAX : StreamErr.Put(currentline_s + ': ERR#' + n_s + ' - SYNTAX ERROR' + chr(13) + chr(10));
       L_ERR_NE_OBJ : StreamErr.Put(currentline_s + ': ERR#' + n_s + ' - USING NON-EXIST OBJECT' + chr(13) + chr(10));
       L_ERR_DBL_DEF: StreamErr.Put(currentline_s + ': ERR#' + n_s + ' - DOUBLE DEFINE' + chr(13) + chr(10));

  end;

  ErrorLevel:= true;

end;

function SyntaxChecking(): boolean;
begin

  SyntaxChecking:= true;

  if (Lexems.Size = 0) then exit;

  case UpCase(Lexems.Get(1)) of

       'DEF': begin

         SyntaxChecking:= false;

         if (UpCase(Lexems.Get(2)) = 'PROC') then begin

            if (Lexems.Size = 3) and (Lexems.Get(3) <> '') then SyntaxChecking:= true;

         end;

         if (UpCase(Lexems.Get(2)) = 'VAR') then begin

            if (Lexems.Size = 3) and (Lexems.Get(3) <> '') then SyntaxChecking:= true;
            if (Lexems.Size = 5) and (Lexems.Get(4) = '=') and (Lexems.Get(3) <> '') and (Lexems.Get(5) <> '') then SyntaxChecking:= true;

         end;

       end;

       'END': begin

         SyntaxChecking:= false;

         if (UpCase(Lexems.Get(2)) = 'DEF')  then SyntaxChecking:= true;
         if (UpCase(Lexems.Get(2)) = 'LOOP') then SyntaxChecking:= true;
         if (UpCase(Lexems.Get(2)) = 'IF')   then SyntaxChecking:= true;

       end;

       'OUT': begin

         SyntaxChecking:= false;

         if (Lexems.Size = 2) then SyntaxChecking:= true;
         if (Lexems.Size = 3) and (UpCase(Lexems.Get(3)) = 'LN') then SyntaxChecking:= true;

       end;

       'GET': begin

         SyntaxChecking:= false;

         if (Lexems.Size = 2) and (Lexems.Get(2) <> '') then SyntaxChecking:= true;

       end;

       'BREAK': begin

         SyntaxChecking:= false;

         if (Lexems.Size = 1) then SyntaxChecking:= true;

       end;

       'CONTINUE': begin

         SyntaxChecking:= false;

         if (Lexems.Size = 1) then SyntaxChecking:= true;

       end;

       'RETURN': begin

         SyntaxChecking:= false;

         if (Lexems.Size = 1) then SyntaxChecking:= true;

       end;

       'DO': begin

         SyntaxChecking:= false;

         if (Lexems.Size = 2) and (Lexems.Get(2) <> '') then SyntaxChecking:= true;

       end;

       'IF': begin

         SyntaxChecking:= false;

         if (Lexems.Size >= 3) and (UpCase(Lexems.Get(3)) = 'THEN') then SyntaxChecking:= true;

       end;

  end;

end;

{Parsing and getting data}

function KeywordChecking(s: string): boolean;
begin

  KeywordChecking:= false;

  if (UpCase(s) = 'PROC')     then KeywordChecking:= true;
  if (UpCase(s) = 'VAR')      then KeywordChecking:= true;
  if (UpCase(s) = 'RETURN')   then KeywordChecking:= true;
  if (UpCase(s) = 'IF')       then KeywordChecking:= true;
  if (UpCase(s) = 'THEN')     then KeywordChecking:= true;
  if (UpCase(s) = 'LOOP')     then KeywordChecking:= true;
  if (UpCase(s) = 'DEF')      then KeywordChecking:= true;
  if (UpCase(s) = 'DEL')      then KeywordChecking:= true;
  if (UpCase(s) = 'END')      then KeywordChecking:= true;
  if (UpCase(s) = 'BREAK')    then KeywordChecking:= true;
  if (UpCase(s) = 'CONTINUE') then KeywordChecking:= true;
  if (UpCase(s) = 'OUT')      then KeywordChecking:= true;
  if (UpCase(s) = 'GET')      then KeywordChecking:= true;
  if (UpCase(s) = 'DO')       then KeywordChecking:= true;
  if (UpCase(s) = 'LN')       then KeywordChecking:= true;
  if (UpCase(s) = '=')        then KeywordChecking:= true;

end;

function RemoveCmdSymbols(s: string): string;
var

  i: integer;

begin

  RemoveCmdSymbols:= '';

  for i:= 1 to length(s) do begin

    if (ord(s[i]) = 9) then begin

       RemoveCmdSymbols:= RemoveCmdSymbols + ' ';

    end;

    if (ord(s[i]) >= 32) and (ord(s[i]) <= 254) then begin

       RemoveCmdSymbols:= RemoveCmdSymbols + s[i];

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

  Lexems.Init();

  iline:= RemoveCmdSymbols(iline);

  while (i <= length(iline)) do begin

    if (iline[i] = '"') then begin

       i:= i + 1;

       while (i <= length(iline)) and (iline[i] <> '"') do i:= i + 1;

       if (i >= length(iline)) then break;

    end;

    if (math_isMathOperator(iline[i]) = true) then begin

       if (math_isMathOperator(iline[i + 1]) = true) then begin

          insert(' ', iline, i + 2);
          insert(' ', iline, i);
          i:= i + 4;
          continue;

       end else begin

         insert(' ', iline, i + 1);
         insert(' ', iline, i);
         i:= i + 3;
         continue;

       end;

    end;

    i:= i + 1;

  end;

  i:= 1;

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

         insert('~', s, 1);

         break;

      end;

      if (iline[i] <> ' ') then s:= s + iline[i];
      if (iline[i] = ' ') and (iline[i + 1] <> ' ') then break;

      i:= i + 1;

    end;

    if (s <> '') then Lexems.Append(s);

    if (Lexems.Size = L_MAX_LEXEMS) then exit;

    s:= '';
    i:= i + 1;

    if (i > length(iline)) then break;

  end;

end;

procedure GetData();
var

  i : integer;

  s : string;
  rv: string;


begin

  rv  := '';
  s   := '';
  i   := 0;

  while (i <= Lexems.Size) do begin

    rv:= Copy(Lexems.Get(i), 1, 1);

    case rv of

          '~': begin

           s:= Lexems.Get(i);
           Delete(s, 1, 1);
           Lexems.Put(i, s);

           i:= i + 1;

           continue;

         end;

         '$': begin

           s:= Lexems.Get(i);
           Delete(s, 1, 1);
           Lexems.Put(i, s);

           if (Vars.ExistsByKey(UpCase(Lexems.Get(i))) = false) and (ScriptReady = true) then begin

              Err(L_ERR_NE_OBJ);
              exit;

           end;

           Lexems.Put(i, Vars.GetValue(UpCase(Lexems.Get(i))));

         end;

    end;

    i:= i + 1;

  end;

end;

procedure StringsMath();
var

  i: integer;

  a: string;
  b: string;

begin

  a:= '';
  b:= '';
  i:= 2;

  while (i <= Lexems.Size - 1) do begin

    if (Lexems.Get(i) = '@') then begin

       a:= Lexems.Get(i - 1);
       b:= Lexems.Get(i + 1);

       Lexems.Put(i, a + b);
       Lexems.Delete(i + 1);
       Lexems.Delete(i - 1);

       i:= 2;

    end;

    i:= i + 1;

  end;

end;

procedure Math();
var

  i: integer;

  s : string;
  n : integer;
  k : integer;

begin

  i:= 1;

  if (Lexems.Size = 0) then exit;

  while (i <= Lexems.Size) do begin

    if (KeywordChecking(Lexems.Get(i)) = false) then begin

       s:= '';
       k:= 0;
       n:= 0;

       while (i <= Lexems.Size) and (KeywordChecking(Lexems.Get(i)) = false) do begin

         s:= s + Lexems.Get(i);
         Lexems.Delete(i);

         k:= k + 1;

       end;

       if (k <> 1) then begin

          n:= math_DoMath(s);
          Str(n, s);

       end;

       if (i <> Lexems.Size + 1) then begin

          Lexems.Insert(i, s);

       end else begin

         Lexems.Append(s);

       end;

    end;

    i:= i + 1;

  end;

end;

procedure Preprocessor();
begin

  GetData();
  StringsMath();
  Math();

end;

procedure GetLine();
var

  s: string;

begin

  if (EOF(ScriptFile) = true) then Exit;

  if (EOF(ScriptFile) = false) then begin

     readln(ScriptFile, s);
     ScriptParser(s);
     Preprocessor();
     CurrentLine:= CurrentLine + 1;

     if (SyntaxChecking() = false) then Err(L_ERR_SYNTAX);

  end;

end;

{Moving in script}

procedure GoLine(n: integer);
var

  i: integer;
  s: string;

begin

  i:= 1;

  Reset(ScriptFile);

  while (EOF(ScriptFile) = false) and (i < n) do begin

    readln(ScriptFile, s);
    i:= i + 1;

  end;

  if (i <> n) then begin

     Err(L_ERR_IO);

  end;

  CurrentLine:= i;

end;

procedure GoProc(iproc: string);
begin

  Reset(ScriptFile);

  CurrentLine:= 0;

  while (EOF(ScriptFile) = false) do begin

    GetLine();

    if (UpCase(Lexems.Get(1)) = 'DEF') then begin

       if (UpCase(Lexems.Get(2)) = 'PROC') then begin

          if (UpCase(Lexems.Get(3)) = UpCase(iproc)) then exit;

       end;

    end;

  end;

  Err(L_ERR_NE_OBJ);

end;

{Variables managing}

procedure MemorySetup();
begin

  Reset(ScriptFile);

  while (EOF(ScriptFile) = false) do begin

    GetLine();

    if (UpCase(Lexems.Get(1)) = 'DEF') and (UpCase(Lexems.Get(2)) = 'VAR') then begin

       if (Vars.ExistsByKey(UpCase(Lexems.Get(3))) = true) then begin

          Err(L_ERR_DBL_DEF);
          exit;

       end;

       if (Lexems.Size = 3) then begin

          Vars.Create(UpCase(Lexems.Get(3)), '');

       end else begin

         Vars.Create(UpCase(Lexems.Get(3)), Lexems.Get(5));

       end;

    end;

  end;

end;

{Commands}

procedure Cmd_End();
var

  i: integer;
  v: integer;

begin

  if (UpCase(Lexems.Get(2)) = 'DEF') then begin

     i:= CallStack.Pull();

     if (LoopStack.Size <> 0) then begin

        v:= LoopStack.Pull();

        while (v <> 0) and (LoopStack.Size <> 0) do begin

          v:= LoopStack.Pull();

        end;

     end;

     if (i <> 0) then GoLine(i + 1);

  end;

  if(UpCase(Lexems.Get(2)) = 'LOOP') then begin

     GoLine(LoopStack.Top() + 1);

  end;

end;

procedure Cmd_Out();
begin

  if (UpCase(Lexems.Get(3)) = 'LN') then begin

     StreamOut.Put(Lexems.Get(2) + chr(13) + chr(10));

  end else begin

    StreamOut.Put(Lexems.Get(2));

  end;

end;

procedure Cmd_Get();
var

  s: string;

begin

  if (Vars.ExistsByKey(UpCase(Lexems.Get(2))) = false) then begin

     Err(L_ERR_NE_OBJ);
     exit;

  end;

  Vars.SetValue(UpCase(Lexems.Get(2)), StreamIn.Get());

end;

procedure Cmd_Do();
begin

  CallStack.Push(CurrentLine);
  LoopStack.Push(0);
  GoProc(Lexems.Get(2));

end;

procedure Cmd_If();
var

  i : integer;
  ic: integer;
  v : integer;

begin

  Val(Lexems.Get(2), v, ic);

  if (Lexems.Size = 3) then begin

     if (v = 0) then begin

        while (UpCase(Lexems.Get(1)) <> 'END') or (UpCase(Lexems.Get(2)) <> 'IF') do GetLine();

     end;

  end else begin

    if (v <> 0) then begin

       while (UpCase(Lexems.Get(1)) <> 'THEN') do Lexems.Delete(1);
       Lexems.Delete(1);
       StayOn:= true;

    end;

  end;

end;

procedure Cmd_Loop();
begin

  LoopStack.Push(CurrentLine);

end;

procedure Cmd_Break();
begin

  if (LoopStack.Size = 0) then Err(L_ERR_SYNTAX);

  LoopStack.PullOut();

  while (UpCase(Lexems.Get(1)) <> 'END') or (UpCase(Lexems.Get(2)) <> 'LOOP') do GetLine();

end;

procedure Cmd_Continue();
begin

  GoLine(LoopStack.Top() + 1);

end;

procedure Cmd_Return();
var

  i: integer;
  v: integer;

begin

  i:= CallStack.Pull();

  if (LoopStack.Size <> 0) then begin

     v:= LoopStack.Pull();

     while (v <> 0) and (LoopStack.Size <> 0) do begin

       v:= LoopStack.Pull();

     end;

  end;

  if (i <> 0) then GoLine(i + 1);

end;

{Main structures}

procedure ExecuteLine();
begin

  if (ErrorLevel = true) then exit;

  case UpCase(Lexems.Get(1)) of

       'END'     : Cmd_End();
       'OUT'     : Cmd_Out();
       'GET'     : Cmd_Get();
       'DO'      : Cmd_Do();
       'IF'      : Cmd_If();
       'LOOP'    : Cmd_Loop();
       'BREAK'   : Cmd_Break();
       'CONTINUE': Cmd_Continue();
       'RETURN'  : Cmd_Return();

       else begin

         if (Lexems.Get(2) = '=') then begin

            if (Vars.ExistsByKey(UpCase(Lexems.Get(1))) = true) then begin

                Vars.SetValue(UpCase(Lexems.Get(1)), Lexems.Get(3));

            end else Err(L_ERR_NE_OBJ);

         end;

       end;

  end;

end;

procedure Execute();
begin

  GetLine();

  while (CallStack.Size <> 0) and (ErrorLevel = false) do begin

    ExecuteLine();

    if (StayOn = false) then GetLine();
    if (StayOn = true)  then StayOn:= false;

  end;

end;

procedure Init();
begin

  StreamIn.Init();
  StreamOut.Init();
  StreamErr.Init();
  Vars.Init();
  Lexems.Init();
  CallStack.Init();
  LoopStack.Init();

  CurrentLine:= 0;
  CurrentProc:= '';
  ScriptReady:= false;
  ErrorLevel := false;
  StayOn     := false;

end;

{Interface implementation}

procedure l_SetConsoleIO();
begin

  StreamIn.SetStandartIO(true);
  StreamOut.SetStandartIO(true);
  StreamErr.SetStandartIO(true);

end;

procedure l_RunProc(iproc: string);
begin

  CallStack.Push(0);
  LoopStack.Push(0);
  GoProc(iproc);
  Execute();

end;

procedure l_OpenScript(iscript: string);
begin

  Assign(ScriptFile, iscript);

  {$I-}
  Reset(ScriptFile);
  {$I+}

  if (IOResult <> 0) then begin

     Err(L_ERR_IO);
     exit;

  end;

  MemorySetup();

  ScriptReady:= true;

end;

procedure l_CloseScript();
begin

  if (ScriptReady = true) then begin

     Close(ScriptFile);
     ScriptReady:= false;

  end;

end;

procedure l_Clear();
begin

  Init();

end;

procedure l_Init();
begin

  Init();

end;

begin

  Init();

end.

