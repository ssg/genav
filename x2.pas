{
X2 operator... Another virus from creator of Mumcu... This virus uses
techniques similar to Mumcu,X1 & X2... Discovered by me and operator code
has been coded by me too... works perfectly...
}

unit X2;

interface

uses

  XTypes,Objects,XVir;

type

  PX2 = ^TX2;
  TX2 = object(TVirus)
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

 X2_SIGN : String[12] = #$B8#$88#$42#$CD#$21#$3D#$88#$42#$74#$03#$E8#$5A;

 X2_COMSIZE : Word = 1070;
 X2_EXESIZE : Word = 1080;

function TX2.GetFlags;
begin
  GetFlags := Vir_COM+Vir_EXE;
end;

function TX2.ScanEXE;
var
  sg:string[12];
begin
  if T.GetSize > X2_COMSIZE then begin
     T.Seek(T.GetSize-1067);
     T.Read(SG[1],12);
     SG[0] := #12;
     ScanEXE := SG=X2_SIGN;
  end;
end;

function TX2.ScanCOM;
var
  sg:string[12];
begin
  if T.GetSize > X2_COMSIZE then begin
     T.Seek(T.GetSize-1067);
     T.Read(SG[1],12);
     SG[0] := #12;
     ScanCOM := SG=X2_SIGN;
  end;
end;

function TX2.CleanCOM;
var
  buf:array[1..3] of char;
begin
  T.Seek(T.GetSize-4);
  T.Read(buf,3);
  T.Seek(0);
  T.Write(buf,3);
  T.Seek(T.GetSize - X2_COMSIZE);
  T.Truncate;
  CleanCOM := T.Status = stOK;
end;

function TX2.CleanEXE;
var
  a:longint;
begin
  T.Seek(T.GetSize-15);
  T.Read(h.IPInit,4);
  T.Read(h.SSInit,4);
  A := T.GetSize-x2_EXESIZE;
  AlignEXEHeader(h,A);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(a);
  T.Truncate;
  CleanEXE := T.Status = stOK;
end;

function TX2.InMem;assembler;
asm
  mov  ax,4288h
  int  21h
  cmp  ax,4288h
  je   @Yes
@No:
  mov   al,false
  jmp   @Exit
@Yes:
  mov   al,true
@Exit:
end;

function TX2.GetName;
begin
  GetName := 'X2';
end;

end.