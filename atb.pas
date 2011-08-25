{
ATB operator ... diagnose and disinfection routines written by
Meric Sentunali... source adapted by myself... Works perfect with
old version ATB viruses... Also virus is coded by ATB... -SSG
}

unit ATB;

interface

uses

  XTypes,Objects,XVir;

type

  PATB = ^TATB;
  TATB = object(TVirus)
    function ScanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function CleanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function ScanCOM(var T:TStream):boolean;virtual;
    function CleanCOM(var T:TStream):boolean;virtual;
    function InMem:boolean;virtual;
    function GetName:string;virtual;
    function GetFlags:byte;virtual;
  end;

implementation

const

 ATB_SIGN : String[22]    = #$FC#$B4#$F0#$CD#$21#$3D#$00#$01#$75#$08#$B4+
                            #$FD#$8B#$0E#$DD#$04#$CD#$21#$B8#$55#$0A#$8B;
 ATB_EXESIGN : String[22] = #$FC#$06#$2E#$8C#$06#$09#$04#$2E#$8C#$06#$0D+
                            #$04#$2E#$8C#$06#$11#$04#$2E#$8C#$06#$12#$04;
 ATB_SIZE = $955;

function TATB.GetName;
begin
  GetName := 'ATB';
end;

function TATB.GetFlags;
begin
  GetFlags := Vir_COM+Vir_EXE;
end;

function TATB.ScanEXE;
var
  SG : String[22];
begin
  T.Seek(T.GetSize-ATB_Size);
  T.Read(SG[1],22);
  SG[0] := #22;
  ScanEXE := SG = ATB_EXESIGN;
end;

function TATB.ScanCOM;
var
  SG: string[22];
begin
  T.Seek(T.GetSize-ATB_Size);
  T.Read(SG[1],22);
  SG[0] := #22;
  ScanCOM := SG = ATB_SIGN;
end;

function TATB.CleanCOM;
begin
  CleanCOM := false;
end;

function TATB.CleanEXE;
var
  A:longint;
begin
  A := T.GetSize-ATB_Size;
  with h do begin
    T.Seek(A+$416);
    T.Read(SPInit,2);
    T.Read(SSInit,2);
    T.Seek(A+$440);
    T.Read(IPInit,2);
    T.Read(CSinit,2);
  end;
  AlignEXEHeader(h,A);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(A);
  T.Truncate;
end;

function TATB.InMem;assembler;
asm
  mov ah,$F0
  int 21h
  cmp ax,0100
  jz  @1
  mov al,False
  jmp @Esc
@1:     mov al,true
@Esc:
end;

end.