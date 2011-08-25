{
TaiPan.438 code... This little bullshit infected my drive when I was
getting mad to play Tie Fighter... I think it's origin is from the demos I
got from GnoStiC... TBAV couldn't be able to disinfect it, and the line
was always busy when I was trying to find someone who'd get me a disinfector
from internet.. 25th Apr 97 - 06:42 - SSG
}

unit TaiPan;

interface

uses

  XTypes,Objects,XVir;

type

  PTaiPan = ^TTaiPan;
  TTaiPan = object(TVirus)
    function ScanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function CleanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function InMem:boolean;virtual;
    function GetName:string;virtual;
    function GetFlags:byte;virtual;
  end;

implementation

CONST

 TAIPAN_SIGNSIZE = 9;
 TAIPAN_SIGN : String[TAIPAN_SIGNSIZE] = #$B8#$CE#$7B#$CD#$21#$3D#$CE#$7B#$75;

 TAIPAN_SIGNOFFSET = 431;
 TAIPAN_ORIGOFFSET = 10;

 TAIPAN_EXESIZE = 438;

function TTaiPan.GetFlags;
begin
  GetFlags := Vir_EXE;
end;

function TTaiPan.ScanEXE;
var
  SG : String[TAIPAN_SIGNSIZE];
begin
  ScanEXE := False;
  if T.GetSize > TAIPAN_EXESIZE then begin
     T.Seek(T.GetSize-TAIPAN_SIGNOFFSET);
     T.Read(SG[1],TAIPAN_SIGNSIZE);
     byte(SG[0]) := TAIPAN_SIGNSIZE;
     ScanEXE := SG=TAIPAN_SIGN;
  end;
end;

function TTaiPan.CleanEXE;
Var
  sg   : string[TAIPAN_SIGNSIZE];
  a:longint;
begin
  T.Seek(T.GetSize-TAIPAN_ORIGOFFSET);
  T.Read(h.SSInit,4);
  T.Read(h.CSInit,2);
  T.Read(h.IPInit,2);
  A := T.GetSize-TAIPAN_EXESIZE;
  AlignEXEHeader(h,a);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(a);
  T.Truncate;
  CleanEXE := T.Status = stOK;
end;

function TTaiPan.InMem;assembler;
asm
  mov  ax,7BCEh
  int  21h
  cmp  ax,7BCEh
  je   @Yes
@No:
  mov   al,false
  jmp   @Exit
@Yes:
  mov   al,true
@Exit:
end;

function TTaiPan.GetName;
begin
  GetName := 'TaiPan.438';
end;

end.