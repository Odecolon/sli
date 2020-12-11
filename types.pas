unit types;

{Odecolon's types library v4}

{$mode objfpc}{$H+}

interface

const

{Sizes}

TYPES_SIZE_LIST     = 128;
TYPES_SIZE_STACK    = 128;
TYPES_SIZE_GLOSSARY = 128;

type

  tList = object

    List: array of string;
    Size: integer;

    procedure Init();
    function Get(n: integer): string;
    procedure Put(n: integer; s: string);
    procedure Append(s: string);
    procedure Delete(n: integer);
    function  Search(s: string; p: integer; up: boolean; r: boolean): integer;
    procedure Insert(n: integer; s: string);
    procedure Print();

  end;

  tStack = object

    Stack: array of integer;
    Size : integer;

    procedure Init();
    procedure Push(n: integer);
    function  Pull(): integer;
    procedure PullOut();
    function  InStack(n: integer): boolean;
    function  Top(): integer;
    procedure Print();

  end;

  tGlossary = object

    Keys  : array of string;
    Values: array of string;

    Size: integer;

    procedure Init();

    procedure Create(k: string; v: string);

    procedure DeleteByKey(k: string);
    procedure DeleteByKeyAndValue(k: string; v: string);

    function ExistsByKey(k: string): boolean;
    function ExistsByValue(v: string): boolean;
    function ExistsByKeyAndValue(k: string; v: string): boolean;

    procedure SetValue(k: string; v: string);

    function GetValue(k: string): string;
    function GetKey  (v: string): string;

    procedure Print();

  end;

  tStream = object

    Stream: tList;
    StandartIO: boolean;

    procedure Init();
    procedure SetStandartIO(mode: boolean);
    procedure Clear();
    procedure Put(s: string);
    function  Get(): string;
    function  IsEmpty(): boolean;
    procedure Print();

  end;

implementation

{tList}

procedure tList.Init();
begin

  Size:= 0;

  setLength(List, Size);

end;

function tList.Get(n: integer): string;
begin

  Get:= '';

  if (n <= 0) or (n > Size) then exit;

  Get:= List[n];

end;

procedure tList.Put(n: integer; s: string);
begin

  if (n <= 0) or (n > Size) then exit;

  List[n]:= s;

end;

procedure tList.Append(s: string);
begin

  if (Size + 1 >  TYPES_SIZE_LIST) then exit;

  Size:= Size + 1;

  setLength(List, Size + 1);

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

  setLength(List, Size + 1);

end;

function  tList.Search(s: string; p: integer; up: boolean; r: boolean): integer;
var

   i: integer;

begin

   Search:= 0;

   if (p <= 0) or (p > TYPES_SIZE_LIST) then exit;

   if (r = false) then begin

      for i:= p to Size do begin

        if (up = false) then begin

           if (List[i] = s) then begin

              Search:= i;
              exit;

           end;

        end else begin

          if (UpCase(List[i]) = UpCase(s)) then begin

              Search:= i;
              exit;

          end;

        end;

      end;

   end else begin

      for i:= Size downto p do begin

        if (up = false) then begin

           if (List[i] = s) then begin

              Search:= i;
              exit;

           end;

        end else begin

          if (UpCase(List[i]) = UpCase(s)) then begin

              Search:= i;
              exit;

          end;

        end;

      end;

   end;

end;

procedure tList.Insert(n: integer; s: string);
var

   i: integer;

begin

  if (n <= 0) or (n > Size) then exit;

  Size:= Size + 1;
  setLength(List, Size);

  for i:= (Size - 1) downto n do begin

    List[i + 1]:= List[i];

  end;

  List[n]:= s;

end;

procedure tList.Print();
var

   i: integer;

begin

  if (Size = 0) then begin

     writeln('0: [ ]');
     exit;

  end;

  write(Size, ': [');

  for i:= 1 to Size - 1 do begin

    write('"' + List[i] + '", ');

  end;

  writeln('"' + List[Size] + '"]');

end;

{tStack}

procedure tStack.Init();
begin

  Size:= 0;

  setLength(Stack, Size);

end;

procedure tStack.Push(n: integer);
begin

  if (Size + 1 > TYPES_SIZE_STACK) then exit;

  Size:= Size + 1;

  setLength(Stack, Size + 1);

  Stack[Size]:= n;

end;

procedure tStack.PullOut();
begin

  if (Size - 1 < 0) then exit;

  Stack[Size]:= 0;
  Size       := Size - 1;
  setLength(Stack, Size + 1);

end;

function tStack.Pull(): integer;
begin

  Pull:= 0;

  if (Size - 1 < 0) then exit;

  Pull:= Stack[Size];
  Size:= Size - 1;
  setLength(Stack, Size + 1);

end;

function tStack.InStack(n: integer): boolean;
var

   i: integer;

begin

  InStack:= false;

  for i:= 1 to Size do begin

    if (Stack[i] = n) then begin

       InStack:= true;
       exit;

    end;

  end;

end;

function tStack.Top(): integer;
begin

  Top:= 0;

  if (Size <> 0) then Top:= Stack[Size];

end;

procedure tStack.Print();
var

   i: integer;

begin

  if (Size = 0) then begin

     writeln('(LtU) 0: [ ]');
     exit;

  end;

  write('(LtU) ', Size, ': [');

  for i:= 1 to Size - 1 do begin

    write('"', Stack[i], '", ');

  end;

  writeln('"', Stack[Size], '"]');

end;

{tGlossary}

procedure tGlossary.Init();
begin

  Size:= 0;

  setLength(Keys, Size);
  setLength(Values, Size);

end;

procedure tGlossary.Create(k: string; v: string);
var

   i: integer;

begin

  if (Size = TYPES_SIZE_GLOSSARY) then exit;

  for i:= 1 to Size do begin

    if (Keys[i] = k) and (Values[i] = v) then exit;

  end;

  Size:= Size + 1;

  setLength(Keys, Size + 1);
  setLength(Values, Size + 1);

  Keys[Size]  := k;
  Values[Size]:= v;

end;

procedure tGlossary.DeleteByKey(k: string);
var

   i: integer;
   n: integer;

begin

  if (Size = 0) then exit;

  n:= 1;

  for i:= 1 to Size do begin

    if (Keys[i] = k) then begin

       Keys[i]  := '';
       Values[i]:= '';

       for n:= i to Size - 1 do begin

         Keys[n]  := '';
         Values[n]:= '';
         Keys[n]  := Keys[n + 1];
         Values[n]:= Values[n + 1];

       end;

       Keys[Size]  := '';
       Values[Size]:= '';

       Size:= Size - 1;

       setLength(Keys, Size + 1);
       setLength(Values, Size + 1);

    end;

  end;

end;

procedure tGlossary.DeleteByKeyAndValue(k: string; v: string);
var

   i: integer;
   n: integer;

begin

  if (Size = 0) then exit;

  n:= 1;

  for i:= 1 to Size do begin

    if (Keys[i] = k) and (Values[i] = v) then begin

       Keys[i]  := '';
       Values[i]:= '';

       for n:= i to Size - 1 do begin

         Keys[n]  := Keys[n + 1];
         Values[n]:= Keys[n + 1];

       end;

       Size:= Size - 1;

       setLength(Keys, Size + 1);
       setLength(Values, Size + 1);

    end;

  end;

end;

function tGlossary.ExistsByKey(k: string): boolean;
var

   i: integer;

begin

  ExistsByKey:= false;

  if (Size = 0) then exit;

  for i:= 1 to Size do begin

    if (Keys[i] = k) then begin

       ExistsByKey:= true;
       exit;

    end;

  end;

end;

function tGlossary.ExistsByValue(v: string): boolean;
var

   i: integer;

begin

  ExistsByValue:= false;

  if (Size = 0) then exit;

  for i:=1 to Size do begin

    if (Values[i] = v) then begin

       ExistsByValue:= true;
       exit;

    end;

  end;

end;

function tGlossary.ExistsByKeyAndValue(k: string; v: string): boolean;
var

   i: integer;

begin

  ExistsByKeyAndValue:= false;

  if (Size = 0) then exit;

  for i:=1 to Size do begin

    if (Keys[i] = k) and (Values[i] = v) then begin

       ExistsByKeyAndValue:= true;
       exit;

    end;

  end;

end;

procedure tGlossary.SetValue(k: string; v: string);
var

   i: integer;

begin

  if (Size = 0) then exit;

  for i:= 1 to Size do begin

    if (Keys[i] = k) then Values[i]:= v;

  end;

end;

function tGlossary.GetValue(k: string): string;
var

   i: integer;

begin

  GetValue:= '';

  if (Size = 0) then exit;

  for i:=1 to Size do begin

    if (Keys[i] = k) then begin

       GetValue:= Values[i];
       exit;

    end;

  end;

end;

function tGlossary.GetKey(v: string): string;
var

   i: integer;

begin

  GetKey:= '';

  if (Size = 0) then exit;

  for i:=1 to Size do begin

    if (Values[i] = v) then begin

       GetKey:= Keys[i];
       exit;

    end;

  end;

end;

procedure tGlossary.Print();
var

   i: integer;

begin

  if (Size = 0) then begin

     writeln('[ ]');
     exit;

  end;

  write('[');

  for i:= 1 to Size - 1 do begin

    writeln(Keys[i], ' : ', Values[i], ' ,');

  end;

  writeln(Keys[Size], ' : ', Values[Size], ']');

end;

{tStream}

procedure tStream.Init();
begin

  Stream.Init();
  StandartIO:= false;

end;

procedure tStream.Clear();
begin

  Stream.Init();

end;

procedure tStream.SetStandartIO(mode: boolean);
begin

  StandartIO:= mode;

end;

procedure tStream.Put(s: string);
begin

  Stream.Append(s);

  if (StandartIO = true) then begin

     write(s);

  end;

end;

function  tStream.Get(): string;
begin

   if (StandartIO = true) then begin

      readln(Get);

   end else begin

     Get:= Stream.Get(1);
     Stream.Delete(1);

   end;

end;

function tStream.IsEmpty(): boolean;
begin

  IsEmpty:= true;

  if (Stream.Size <> 0) then IsEmpty:= false;

end;

procedure tStream.Print();
begin

  Stream.Print();

end;

begin

end.
