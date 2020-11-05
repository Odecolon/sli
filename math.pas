unit math;

interface

uses types;

function math_DoMath(iline: string): integer;
function math_BinaryToInt(iline: string): integer;
function math_IntToBinary(n: integer): string;

implementation

const

  S_PL = '+';
  S_MN = '-';
  S_ML = '*';
  S_DV = '/';

  S_BO = '(';
  S_BC = ')';

var

  Line: tList;

function Power(a, n: integer): integer;
begin

  Power:= 1;

  while (n <> 0) do begin

    Power:= Power * a;
    n    := n - 1;

  end;

end;

function CheckAll(s: string): boolean;
begin

  CheckAll:= false;

  if (s = S_PL) then CheckAll:= true;
  if (s = S_MN) then CheckAll:= true;
  if (s = S_ML) then CheckAll:= true;
  if (s = S_DV) then CheckAll:= true;
  if (s = S_BO) then CheckAll:= true;
  if (s = S_BC) then CheckAll:= true;

end;

function CheckUpper(s: string): boolean;
begin

  CheckUpper:= false;

  if (s = S_ML) then CheckUpper:= true;
  if (s = S_DV) then CheckUpper:= true;

end;

function CheckLower(s: string): boolean;
begin

  CheckLower:= false;

  if (s = S_PL) then CheckLower:= true;

end;

function CheckUnary(s: string): boolean;
begin

  CheckUnary:= false;

  if (s = S_MN) then CheckUnary:= true;

end;

procedure Parsing(iline: string);
var

   i: integer;
   s: string;

begin

  i:= 1;
  s:= '';

  Line.Append(S_BO);

  while (i <= length(iline)) do begin

    if (CheckAll(iline[i]) = false) then begin

       s:= s + iline[i];

    end else begin

      if (s <> '') then Line.Append(s);
      Line.Append(iline[i]);

      s:= '';

    end;

    i:= i + 1;

  end;

  if (s <> '') then Line.Append(s);
  Line.Append(S_BC);

end;

function DoBinary(a: integer; b: integer; op: string): integer;
begin

  DoBinary:= 0;

  case op of

       S_PL: DoBinary:= a + b;
       S_ML: DoBinary:= a * b;
       S_DV: DoBinary:= a div b;

  end;

end;

function DoUnary(a: integer; op: string): integer;
begin

  DoUnary:= 0;

  case op of

       S_MN: DoUnary:= 0 - a;

  end;

end;

function math_DoMath(iline: string): integer;
var

  i: integer;
  b: integer;
  e: integer;

  arg_a: integer;
  arg_b: integer;
  ic   : integer;

begin

  math_DoMath:= 0;

  i:= 0;
  b:= 0;
  e:= 0;

  arg_a:= 0;
  arg_b:= 0;

  Line.Init();

  for i:= 1 to length(iline) do begin

    if (iline[i] = ' ') then delete(iline, i, 1);

  end;

  Parsing(iline);

  if (Line.Size = 2) then exit;

  while (true) do begin

    b:= Line.Search(S_BO, 1, true);
    e:= Line.Search(S_BC, b, false);
    i:= e;

    if (b = 0) or (e = 0) then begin

       Val(Line.List[1], math_DoMath, ic);
       break;

    end;

    while (i >= b) do begin

      if (CheckUnary(Line.List[i]) = true) then begin

         if (CheckAll(Line.List[i + 1]) = true) then exit;

         Val(Line.List[i + 1], arg_a, ic);
         Str(DoUnary(arg_a, Line.List[i]), Line.List[i + 1]);

         if (CheckAll(Line.List[i - 1]) = true) then begin

            Line.Delete(i);

            arg_a:= 0;

            e:= e - 1;
            i:= e;
            continue;

         end else begin

           if (Line.List[i] = S_MN) then Line.List[i]:= S_PL;

         end;

      end;

      i:= i - 1;

    end;

    b:= Line.Search(S_BO, 1, true);
    e:= Line.Search(S_BC, b, false);
    i:= b;

    while (i <= e) do begin

      if (CheckUpper(Line.List[i]) = true) then begin

         if (CheckUpper(Line.List[i - 1]) = true) then exit;
         if (CheckLower(Line.List[i - 1]) = true) then exit;
         if (CheckUpper(Line.List[i + 1]) = true) then exit;
         if (CheckLower(Line.List[i + 1]) = true) then exit;

         Val(Line.List[i - 1], arg_a, ic);
         Val(Line.List[i + 1], arg_b, ic);
         Str(DoBinary(arg_a, arg_b, Line.List[i]), Line.List[i]);

         Line.Delete(i - 1);
         Line.Delete(i);

         arg_a:= 0;
         arg_b:= 0;

         e:= e - 2;
         i:= b;
         continue;

      end;

      i:= i + 1;

    end;

    b:= Line.Search(S_BO, 1, true);
    e:= Line.Search(S_BC, b, false);
    i:= b;

    while (i <= e) do begin

      if (CheckLower(Line.List[i]) = true) then begin

         if (CheckUpper(Line.List[i - 1]) = true) then exit;
         if (CheckLower(Line.List[i - 1]) = true) then exit;
         if (CheckUpper(Line.List[i + 1]) = true) then exit;
         if (CheckLower(Line.List[i + 1]) = true) then exit;

         Val(Line.List[i - 1], arg_a, ic);
         Val(Line.List[i + 1], arg_b, ic);
         Str(DoBinary(arg_a, arg_b, Line.List[i]), Line.List[i]);

         Line.Delete(i - 1);
         Line.Delete(i);

         e:= e - 2;
         i:= b;
         continue;

         arg_a:= 0;
         arg_b:= 0;

      end;

      i:= i + 1;

    end;

    b:= Line.Search(S_BO, 1, true);
    e:= Line.Search(S_BC, b, false);
    Line.Delete(e);
    Line.Delete(b);

  end;

end;

function math_BinaryToInt(iline: string): integer;
var

  i: integer;

begin

  math_BinaryToInt:= 0;

  for i:= length(iline) downto 1 do begin

    if (iline[i] = '1') then math_BinaryToInt:= math_BinaryToInt + Power(2, length(iline) - i);

  end;

end;

function math_IntToBinary(n: integer): string;
var

  i: integer;
  a: integer;

  s: string;
  o: string;

begin

  math_IntToBinary:= '';
  s               := '';
  o               := '';

  if (n = 0) then begin

     math_IntToBinary:= '';
     exit;

  end;

  a:= 0;
  i:= 0;

  for i:= 0 to n do begin

    if (Power(2, i) > n) then begin

       a:= i - 1;
       break;

    end;

  end;

  while (a >= 0) do begin

    if (n - Power(2, a) >= 0) then begin

       n:= n - Power(2, a);
       insert('1', s, 0);

    end else begin

      insert('0', s, 0);

    end;

    a:= a - 1;

  end;

  o:= s;

  for i:= 1 to length(s) do begin

    o[i]:= s[length(s) - i + 1];

  end;

  math_IntToBinary:= o;

end;

begin

  Line.Init();

end.

