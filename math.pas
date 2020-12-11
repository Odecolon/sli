unit math;

{Odecolon's math library v3}

{$mode objfpc}{$H+}

interface

uses types;

function math_DoMath(iline: string): integer;
function math_BinaryToInt(iline: string): integer;
function math_IntToBinary(n: integer): string;
function math_IsMathOperator(iop: string): boolean;

implementation

const

  {Punctuation}

  S_BO = '(';
  S_BC = ')';

  {Calculation}

  S_PL = '+';
  S_MN = '-';
  S_ML = '*';
  S_DV = '/';

  {Logic}

  S_EQ_S = '=';
  S_EQ   = '==';
  S_MR   = '>';
  S_LS   = '<';
  S_MREQ = '>=';
  S_LSEQ = '<=';
  S_NEQ  = '!=';
  S_NOT  = '!';
  S_AND  = '&';
  S_OR   = '|';

  {Logic Values}

  V_FALSE = 0;
  V_TRUE  = 1;

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

function CheckNumeral(s: string): boolean;
begin

  CheckNumeral:= false;

  if (s = '0') then CheckNumeral:= true;
  if (s = '1') then CheckNumeral:= true;
  if (s = '2') then CheckNumeral:= true;
  if (s = '3') then CheckNumeral:= true;
  if (s = '4') then CheckNumeral:= true;
  if (s = '5') then CheckNumeral:= true;
  if (s = '6') then CheckNumeral:= true;
  if (s = '7') then CheckNumeral:= true;
  if (s = '8') then CheckNumeral:= true;
  if (s = '9') then CheckNumeral:= true;

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

  if (s = S_EQ)   then CheckAll:= true;
  if (s = S_MR)   then CheckAll:= true;
  if (s = S_LS)   then CheckAll:= true;
  if (s = S_MREQ) then CheckAll:= true;
  if (s = S_LSEQ) then CheckAll:= true;
  if (s = S_NEQ)  then CheckAll:= true;

  if (s = S_NOT) then CheckAll:= true;
  if (s = S_AND) then CheckAll:= true;
  if (s = S_OR) then CheckAll:= true;

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

  if (s = S_MN)  then CheckUnary:= true;
  if (s = S_NOT) then CheckUnary:= true;

end;

function CheckLogical(s: string): boolean;
begin

  CheckLogical:= false;

  if (s = S_EQ)   then CheckLogical:= true;
  if (s = S_MR)   then CheckLogical:= true;
  if (s = S_LS)   then CheckLogical:= true;
  if (s = S_MREQ) then CheckLogical:= true;
  if (s = S_LSEQ) then CheckLogical:= true;
  if (s = S_NEQ)  then CheckLogical:= true;
  if (s = S_AND)  then CheckLogical:= true;
  if (s = S_OR)   then CheckLogical:= true;

end;

procedure Parsing(iline: string);
var

   i: integer;
   s: string;

begin

  i:= 1;
  s:= '';

  iline:= iline + ' ';

  Line.Append(S_BO);

  while (i <= length(iline) - 1) do begin

    if (CheckAll(iline[i] + iline[i + 1]) = true) then begin

       if (s <> '') then Line.Append(s);
       Line.Append(iline[i] + iline[i + 1]);

       s:= '';
       i:= i + 2;

       continue;

    end;

    if (CheckAll(iline[i]) = true) then begin

       if (s <> '') then Line.Append(s);
       Line.Append(iline[i]);

       s:= '';
       i:= i + 1;

       continue;

    end;

    s:= s + iline[i];
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

       S_NOT: begin

         if (a <> 0) then DoUnary:= 0;
         if (a = 0)  then DoUnary:= V_TRUE;

       end;

  end;

end;

function DoLogical(a: string; b: string; op: string): integer;
var

   a_i: integer;
   b_i: integer;

   ic: integer;

begin

  DoLogical:= V_FALSE;

  case op of

       S_EQ: begin

         if (a = b) then DoLogical:= V_TRUE;

       end;

       S_NEQ: begin

         if (a <> b) then DoLogical:= V_TRUE;

       end;

       S_MR: begin

         Val(a, a_i, ic);
         if (ic <> 0) then exit;
         Val(b, b_i, ic);
         if (ic <> 0) then exit;

         if (a_i > b_i) then DoLogical:= V_TRUE;

       end;

       S_LS: begin

         Val(a, a_i, ic);
         if (ic <> 0) then exit;
         Val(b, b_i, ic);
         if (ic <> 0) then exit;

         if (a_i < b_i) then DoLogical:= V_TRUE;

       end;

       S_MREQ: begin

         Val(a, a_i, ic);
         if (ic <> 0) then exit;
         Val(b, b_i, ic);
         if (ic <> 0) then exit;

         if (a_i >= b_i) then DoLogical:= V_TRUE;

       end;

       S_LSEQ: begin

         Val(a, a_i, ic);
         if (ic <> 0) then exit;
         Val(b, b_i, ic);
         if (ic <> 0) then exit;

         if (a_i <= b_i) then DoLogical:= V_TRUE;

       end;

       S_AND: begin

         Val(a, a_i, ic);
         if (ic <> 0) then exit;
         Val(b, b_i, ic);
         if (ic <> 0) then exit;

         if (a_i <> V_FALSE) and (b_i <> V_FALSE) then DoLogical:= V_TRUE;

       end;

       S_OR: begin

         Val(a, a_i, ic);
         if (ic <> 0) then exit;
         Val(b, b_i, ic);
         if (ic <> 0) then exit;

         if (a_i <> V_FALSE) or (b_i <> V_FALSE) then DoLogical:= V_TRUE;

       end;

  end;

end;

function math_DoMath(iline: string): integer;
var

  i: integer;
  b: integer;
  e: integer;

  istr: string;

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

  while (true) do begin

    b:= Line.Search(S_BO, 1, false, true);
    e:= Line.Search(S_BC, b, false, false);
    i:= e;

    if (b = 0) or (e = 0) then begin

       Val(Line.Get(1), math_DoMath, ic);
       break;

    end;

    while (i >= b) do begin

      if (CheckUnary(Line.Get(i)) = true) then begin

         if (CheckAll(Line.Get(i + 1)) = true) then exit;

         Val(Line.Get(i + 1), arg_a, ic);

         if (ic = 0)  then Str(DoUnary(arg_a, Line.Get(i)), istr);
         if (ic <> 0) then istr:= '0';

         Line.Put(i + 1, istr);

         if (CheckAll(Line.Get(i - 1)) = true) then begin

            Line.Delete(i);

            arg_a:= 0;

            e:= e - 1;
            i:= e;
            continue;

         end else begin

           if (Line.Get(i) = S_MN) then Line.Put(i, S_PL);

         end;

      end;

      i:= i - 1;

    end;

    b:= Line.Search(S_BO, 1, false, true);
    e:= Line.Search(S_BC, b, false, false);
    i:= b;

    while (i <= e) do begin

      if (CheckUpper(Line.Get(i)) = true) then begin

         if (CheckUpper(Line.Get(i - 1))   = true) then exit;
         if (CheckLower(Line.Get(i - 1))   = true) then exit;
         if (CheckUpper(Line.Get(i + 1))   = true) then exit;
         if (CheckLower(Line.Get(i + 1))   = true) then exit;
         if (CheckLogical(Line.Get(i + 1)) = true) then exit;

         Val(Line.Get(i - 1), arg_a, ic);
         if (ic = 0) then Val(Line.Get(i + 1), arg_b, ic);

         if (ic = 0)  then Str(DoBinary(arg_a, arg_b, Line.Get(i)), istr);
         if (ic <> 0) then istr:= '0';

         Line.Put(i, istr);

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

    b:= Line.Search(S_BO, 1, false, true);
    e:= Line.Search(S_BC, b, false, false);
    i:= b;

    while (i <= e) do begin

      if (CheckLower(Line.Get(i)) = true) then begin

         if (CheckUpper(Line.Get(i - 1))   = true) then exit;
         if (CheckLower(Line.Get(i - 1))   = true) then exit;
         if (CheckUpper(Line.Get(i + 1))   = true) then exit;
         if (CheckLower(Line.Get(i + 1))   = true) then exit;
         if (CheckLogical(Line.Get(i + 1)) = true) then exit;

         Val(Line.Get(i - 1), arg_a, ic);
         if (ic = 0) then Val(Line.Get(i + 1), arg_b, ic);

         if (ic = 0)  then Str(DoBinary(arg_a, arg_b, Line.Get(i)), istr);
         if (ic <> 0) then istr:= '0';

         Line.Put(i, istr);

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

    b:= Line.Search(S_BO, 1, false, true);
    e:= Line.Search(S_BC, b, false, false);
    i:= b;

    while (i <= e) do begin

      if (CheckLogical(Line.Get(i)) = true) then begin

         if (CheckUpper(Line.Get(i - 1))   = true) then exit;
         if (CheckLower(Line.Get(i - 1))   = true) then exit;
         if (CheckUpper(Line.Get(i + 1))   = true) then exit;
         if (CheckLower(Line.Get(i + 1))   = true) then exit;
         if (CheckLogical(Line.Get(i + 1)) = true) then exit;

         Str(DoLogical(Line.Get(i - 1), Line.Get(i + 1), Line.Get(i)), istr);

         Line.Put(i, istr);

         Line.Delete(i - 1);
         Line.Delete(i);

         e:= e - 2;
         i:= b;
         continue;

      end;

      i:= i + 1;

    end;

    b:= Line.Search(S_BO, 1, false, true);
    e:= Line.Search(S_BC, b, false, false);
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

function math_IsMathOperator(iop: string): boolean;
begin

  math_IsMathOperator:= false;

  if (iop = S_PL) then math_IsMathOperator:= true;
  if (iop = S_MN) then math_IsMathOperator:= true;
  if (iop = S_ML) then math_IsMathOperator:= true;
  if (iop = S_DV) then math_IsMathOperator:= true;

  if (iop = S_EQ)   then math_IsMathOperator:= true;
  if (iop = S_MR)   then math_IsMathOperator:= true;
  if (iop = S_LS)   then math_IsMathOperator:= true;
  if (iop = S_MREQ) then math_IsMathOperator:= true;
  if (iop = S_LSEQ) then math_IsMathOperator:= true;
  if (iop = S_NEQ)  then math_IsMathOperator:= true;

  if (iop = S_NOT) then math_IsMathOperator:= true;
  if (iop = S_AND) then math_IsMathOperator:= true;
  if (iop = S_OR) then math_IsMathOperator:= true;

  if (iop = S_BO) then math_IsMathOperator:= true;
  if (iop = S_BC) then math_IsMathOperator:= true;

  if (iop = S_EQ_S) then math_IsMathOperator:= true;

end;

begin

  Line.Init();

end.

