program sli;

uses l_interpreter, math, types;

const

  SLI_VERSION = '0.2';

  MAIN_PROC = 'main';

  CMD_EXIT = 'EXIT';

procedure Init();
begin

  writeln('sli v' + SLI_VERSION + ' - simple L interpreter by Odecolon');
  writeln('L language version is ' + L_VERSION);
  writeln(L_MAX_VARS, ' vars, ', TYPES_SIZE_STACK, ' proc calls or loops are available');
  writeln();

  l_SetConsoleIO();

  if (ParamCount <> 0) then begin

    l_GetScript(ParamStr(1));

    if (ParamCount = 2) then begin

       l_GetLog(ParamStr(2));

    end;

    l_RunProc(MAIN_PROC);
    writeln();

  end;

end;

procedure Console();
var

  iline: string;

begin

  while (true) do begin

    write('>');
    readln(iline);
    writeln();

    if (UpCase(iline) = CMD_EXIT) then break;

    l_RunLine(iline);

  end;

  l_Clear();

end;

begin

  Init();
  Console();

end.
