{
X3 operator... As I remember, this virus contains the text 'Written in
city of Istanbul' and name of X3 can be changed to 'Istanbul' virus...
Not a 'Walker' variant but does a shitty job: it contains an executable
file list ("X.EXE","WOLF3D.EXE" etc)... when you try to execute the file
which its name is in list, the virus deletes it immediately... I think
the coder hates computer games like "F29 Retaliator" and "Wolfenstein"..
So, this operator works perfectly...
}

unit X3;

interface

uses

  XTypes,Objects,XVir;

type

  PX3 = ^TX3;
  TX3 = object(TVirus)
    function ScanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function CleanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function ScanCOM(var T:TStream):boolean;virtual;
    function CleanCOM(var T:TStream):boolean;virtual;
    function InMem:boolean;virtual;
    function GetName:string;virtual;
    function GetFlags:byte;virtual;
  end;

implementation

CONST

 X3_SIGN : String[11] = #$24#$4b#$cd#$21#$3d#$34#$34#$74#$57#$e8#$a9;

 X3_COMSIZE : Word = 1372;
 X3_EXESIZE : Word = 1377;

function TX3.GetFlags;
begin
  GetFlags := Vir_COM+Vir_EXE;
end;

function TX3.ScanEXE;
var
  SG : String[11];
begin
  if T.GetSize > X3_COMSIZE then begin
    T.Seek(T.GetSize-1277);
    T.Read(SG[1],11);
    SG[0] := #11;
    ScanEXE := SG = X3_SIGN;
  end;
end;

function TX3.ScanCOM;
var
  SG : String[11];
begin
  if T.GetSize > X3_COMSIZE then begin
    T.Seek(T.GetSize-1277);
    T.Read(SG[1],11);
    SG[0] := #11;
    ScanCOM := SG = X3_SIGN;
  end;
end;

function TX3.CleanCOM;
var
  buf:array[1..3] of byte;
begin
  T.Seek(T.GetSize-257);
  T.Read(buf,3);
  T.Seek(0);
  T.Write(buf,3);
  T.Seek(T.GetSize-X3_COMSIZE);
  T.Truncate;
  CleanCOM := T.Status = stOK;
end;

function TX3.CleanEXE;
var
  a:longint;
begin
  T.Seek(0);
  T.Read(h,SizeOf(h));
  T.Seek(T.GetSize-257);
  T.Read(h.IPInit,2);
  T.Read(h.CSInit,2);
  T.Read(h.SSInit,2);
  T.Read(h.SPInit,2);
  A := T.GetSize-X3_EXESize;
  AlignEXEHeader(h,a);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(a);
  T.Truncate;
  CleanEXE := T.Status = stOK;
end;

function TX3.InMem;assembler;
asm
  mov  ax,4B24h
  int  21h
  cmp  ax,3434h
  je   @Yes
  mov  al,False
  jmp  @Exit
@Yes:
  mov  al,true
@Exit:
end;

function TX3.GetName;
begin
  GetName := 'X3';
end;

end.