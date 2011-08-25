{
Mirage operator ... diagnose and disinfection routines written by
Meric Sentunali... source optimized and adapted to Operator by
Sedat Kapanoglu... Works perfectly when memory is clean...
}
unit Mirage;

interface

uses

  XTypes,Objects,XVir;

type

  PMirage = ^TMirage;
  TMirage = object(TVirus)
    function ScanEXE(var h:TEXEheader; var T:TStream):boolean;virtual;
    function CleanEXE(var h:TEXEheader; var T:TStream):boolean;virtual;
    function ScanCOM(var T:TStream):boolean;virtual;
    function CleanCOM(var T:TStream):boolean;virtual;
    function InMem:boolean;virtual;
    function GetName:string;virtual;
    function GetFlags:byte;virtual;
  end;

implementation

CONST

 MIRAGE_SIGN : String[12] = #$2E#$A1#$23#$01#$FC#$CD#$21#$BE#$00#$01#$89#$F7;

 MIRAGE_COMSIZE : Word = 1331;
 MIRAGE_EXESIZE : Word = 1341;

function TMirage.GetFlags;
begin
  GetFlags := Vir_COM+Vir_EXE;
end;

function TMirage.ScanEXE;
var
  a:longint;
  sg:string[12];
begin
  with h do A := Longint(CSInit)*16+Longint(IPInit)+Longint(HdrSize)*16;
  T.Seek(A);
  T.Read(sg[1],12);
  byte(sg[0]) := 12;
  ScanEXE := sg = MIRAGE_SIGN;
end;

function TMirage.ScanCOM;
var
  SG : String[12];
begin
  T.Seek(T.GetSize-MIRAGE_COMSIZE);
  T.Read(sg[1],12);
  byte(sg[0]) := 12;
  ScanCOM := SG = MIRAGE_SIGN;
end;

function TMirage.CleanCOM;
begin
  CleanCOM := false;
end;

function TMirage.CleanEXE;
var
  A:longint;
begin
  with h do A := Longint(CSInit)*16+Longint(IPInit)+Longint(HdrSize)*16;
  T.Seek(A+41);
  T.Read(h.SSInit,4);
  T.Read(h.IPInit,4);
  AlignEXEHeader(h,A);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(A);
  T.Truncate;
  CleanEXE := T.Status = stOK;
end;

function TMirage.InMem;assembler;
  asm
    mov   ax,$3521
    int   $21
    cmp   word ptr es:[bx],$809C
    jnz   @MemOK
    cmp   word ptr es:[bx+02],$12FC
    jnz   @MemOK
    cmp   word ptr es:[bx+04],$2B74
    jnz   @MemOK
    cmp   word ptr es:[bx+06],$FC80
    jnz   @MemOK
    cmp   word ptr es:[bx+08],$744F
    jnz   @MemOK
    cmp   word ptr es:[bx+10],$8026
    jnz   @MemOK
    cmp   word ptr es:[bx+12],$11FC
    jnz   @MemOK
    mov   al,True
    jmp   @Exit
@MemOK: mov   al,False
@Exit:
end;

function TMirage.GetName;
begin
  GetName := 'Mirage';
end;

end.