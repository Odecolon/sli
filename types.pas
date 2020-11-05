unit types;

interface

const

TYPES_SIZE_LIST  = 64;
TYPES_SIZE_STACK = 128;

type

  tList = object

    List: array [1..TYPES_SIZE_LIST] of string;
    Size: integer;

    procedure Init();
    procedure Append(s: string);
    procedure Delete(n: integer);
    function  Search(s: string; p: integer; r: boolean): integer;
    procedure Print();

  end;

  tStack = object

    Stack: array [1..TYPES_SIZE_STACK] of integer;
    Size : integer;

    procedure Init();
    procedure Push(n: integer);
    function  Pull(): integer;
    procedure PullOut();

  end;

implementation

{tList}

procedure tList.Init();
var

   i: integer;

begin

  for i:= 1 to TYPES_SIZE_LIST do begin

    List[i]:= '';

  end;

  Size:= 0;

end;

procedure tList.Append(s: string);
begin

  if (Size + 1 >  TYPES_SIZE_LIST) then exit;

  Size      := Size + 1;
  List[Size]:= s;

end;

procedure tList.Delete(n: integer);
var

   i: integer;

begin

  if (n <= 0) or (n > Size) then exit;

  List[n]:= '';

  if (n = Size) then begin

     Size:= Size - 1;
     exit;

  end;

  for i:= n + 1 to Size do begin

    List[i - 1]:= List[i];
    List[i]    := '';

  end;

  Size:= Size - 1;

end;

function  tList.Search(s: string; p: integer; r: boolean): integer;
var

   i: integer;

begin

   Search:= 0;

   if (p <= 0) or (p > TYPES_SIZE_LIST) then exit;

   if (r = false) then begin

      for i:= p to TYPES_SIZE_LIST do begin

        if (List[i] = s) then begin

           Search:= i;
           exit;

        end;

      end;

   end else begin

      for i:= TYPES_SIZE_LIST downto p do begin

        if (List[i] = s) then begin

           Search:= i;
           exit;

        end;

      end;

   end;

end;

procedure tList.Print();
var

   i: integer;

begin

  if (Size = 0) then begin

     writeln('[ ]');
     exit;

  end;

  write('[');

  for i:= 1 to Size - 1 do begin

    write('"' + List[i] + '", ');

  end;

  writeln('"' + List[Size] + '"]');

end;

{tStack}

procedure tStack.Init();
var

   i: integer;

begin

  for i:= 1 to TYPES_SIZE_STACK do begin

    Stack[i]:= 0;

  end;

  Size:= 0;

end;

procedure tStack.Push(n: integer);
begin

  if (Size + 1 > TYPES_SIZE_STACK) then exit;

  Size       := Size + 1;
  Stack[Size]:= n;

end;

procedure tStack.PullOut();
begin

  if (Size - 1 < 0) then exit;

  Stack[Size]:= 0;
  Size       := Size - 1;

end;

function tStack.Pull(): integer;
begin

  Pull:= 0;

  if (Size - 1 < 0) then exit;

  Pull:= Stack[Size];
  Size:= Size - 1;

end;

begin

end.

