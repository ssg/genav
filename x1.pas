{
X1 operator... This virus has been discovered by me... I didn't find a
name to it but maybe "Yandan Carkli" ??.. or its variant... but I am sure
about that: whatever this virus is, it's another one from coder of Mumcu
virus.. They use same tech: 4343 -> 3434... or a little different variants
of this tech... This operator is coded by me (Sedat Kapanoglu, if still
you don't know)... Works perfectly with this virus...
}

unit X1;

interface

uses

  XTypes,Objects,XVir;

type

  PX1 = ^TX1;
  TX1 = object(TVirus)
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

 X1_SIGN : String[11] = #$5d#$b8#$43#$43#$cd#$21#$3d#$34#$34#$75#$02;

 X1_COMSIZE : Word = 570;
 X1_EXESIZE : Word = 580;

function TX1.GetFlags;
begin
  GetFlags := Vir_COM+Vir_EXE;
end;

function TX1.ScanEXE;
var
  SG : String[11];
begin
  if T.GetSize > X1_COMSIZE then begin
     T.Seek(T.GetSize-564);
     T.Read(SG[1],11);
     SG[0] := #11;
     ScanEXE := SG=X1_SIGN;
  end;
end;

function TX1.ScanCOM;
var
  SG : String[11];
begin
  if T.GetSize > X1_COMSIZE then begin
     T.Seek(T.GetSize-564);
     T.Read(SG[1],11);
     SG[0] := #11;
     ScanCOM := SG=X1_SIGN;
  end;
end;

function TX1.CleanCOM;
var
  buf:array[1..3] of byte;
begin
  T.Seek(T.GetSize-4);
  T.Read(buf,3);
  T.Seek(0);
  T.Write(buf,3);
  T.Seek(T.GetSize - X1_COMSIZE);
  T.Truncate;
  CleanCOM := T.Status = stOK;
end;

function TX1.CleanEXE;
var
  a:longint;
begin
  T.Seek(T.GetSize-15);
  T.Read(h.IPInit,4);
  T.Read(h.SSInit,4);
  A := T.GetSize-X1_EXESIZE;
  AlignEXEHeader(h,A);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(A);
  T.Truncate;
  CleanEXE := T.Status = stOK;
end;

function TX1.InMem;assembler;
asm
  mov  ax,4343h
  int  21h
  cmp  ax,3434h
  je   @Yes
@No:
  mov   al,false
  jmp   @Exit
@Yes:
  mov   al,true
@Exit:
end;

function TX1.GetName;
begin
  GetName := 'X1';
end;

end.