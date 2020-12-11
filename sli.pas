program sli;

{Odecolon's simple l language interpreter v0.4}

{$mode objfpc}{$H+}

uses l, math, types;

const

  {Versions}

  SLI_VERSION = '0.4';

  {Names}

  SLI_MAIN_PROC = 'main';

  SLI_CMD_EXIT      = 'Q';
  SLI_CMD_OPEN      = 'O';
  SLI_CMD_CLEAR_ALL = 'C';
  SLI_CMD_EXECUTE   = 'X';
  SLI_CMD_RUNPROC   = 'R';
  SLI_CMD_HELP      = 'H';

procedure Init();
var

   i: integer;

begin

  writeln('');
  writeln('sli v' + SLI_VERSION +' - a simple l interpreter by Odecolon');
  writeln('Current l version is v' + L_VERSION + '. Try "h" to get help.');
  writeln('');

  if (ParamCount = 0) then begin

     writeln('Use in command line: sli [file] [keys]');
     writeln('');

     exit;

  end;

  l_SetConsoleIO();

  if (ParamCount >= 1) then l_OpenScript(ParamStr(1));

  l_RunProc(SLI_MAIN_PROC);

  writeln('');
  writeln('Ok.');
  writeln('');

end;

procedure Console();
var

  iline: string;

begin

  l_SetConsoleIO();

  while (true) do begin

    write('>');
    readln(iline);
    writeln('');

    case UpCase(iline) of

         SLI_CMD_EXIT     : begin

           writeln('Ok.');
           writeln();
           break;

         end;

         SLI_CMD_CLEAR_ALL: begin

           l_CloseScript();
           l_Clear();
           l_SetConsoleIO();
           writeln('Ok.');
           writeln();

         end;

         SLI_CMD_OPEN     : begin

           write('file? : ');
           readln(iline);

           l_OpenScript(iline);

           writeln('');
           writeln('Ok.');
           writeln('');

         end;

         SLI_CMD_EXECUTE   : begin

           l_RunProc(SLI_MAIN_PROC);

           writeln('');
           writeln('Ok.');
           writeln('');

         end;

         SLI_CMD_RUNPROC   : begin

           write('proc? : ');
           readln(iline);
           writeln('');

           l_RunProc(iline);

           writeln('');
           writeln('Ok.');
           writeln('');

         end;

         SLI_CMD_HELP      : begin

           writeln('o - [o]pen');
           writeln('x - e[x]ecute');
           writeln('r - [r]un procedure');
           writeln('c - [c]lear');
           writeln('q - [q]uit');

           writeln('');
           writeln('Ok.');
           writeln('');

         end;

    end;

  end;

  l_CloseScript();
  l_Clear();

end;

begin

  Init();
  Console();

end.
