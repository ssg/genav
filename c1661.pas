{
Cascade-1661 operator... I know this one is implemented on PSAV & SCAN but
I've enjoyed to debug this one... It was easy dude... works perfectly and
coded by me... thanks to Omur from DimSoft for getting me samples...
}

unit C1661;

interface

uses Objects,XVir;

type

  PC1661 = ^TC1661;
  TC1661 = object(TVirus)
    function ScanCOM(var T:TStream):boolean;virtual;
    function CleanCOM(var T:TStream):boolean;virtual;
    function InMem:boolean;virtual;
    function GetName:string;virtual;
    function GetFlags:byte;virtual;
  end;

implementation

CONST

 C1661_COMSIZE : Word = 1661;

 C1661_SIGN : string[6] = #$FA#$8B#$EC#$E8#$00#$00;

function TC1661.GetFlags;
begin
  GetFlags := Vir_COM;
end;

function TC1661.ScanCOM;
var
  sg : string[6];
  b  : byte;
  w:word;
begin
  T.Seek(0);
  T.Read(b,1);
  if b <> $E9 then exit;
  T.Read(w,2);
  T.Seek(w+2);
  T.Read(b,1);
  if b <> 1 then exit;
  T.Read(sg[1],6);
  sg[0] := #6;
  ScanCOM := sg = C1661_Sign;
end;

function TC1661.CleanCOM;
var
  di,sp:word;
  n:byte;
  Buf:array[1..15] of byte;
  x:word;
begin
  T.Seek(T.GetSize-1626);
  T.Read(buf,15);
  di := $1AA;
  sp := $65A;
  for n:=1 to 14 do begin
    move(buf[n],x,2);
    x := (x xor di) xor sp;
    Move(x,buf[n],2);
    inc(di);
    dec(sp);
  end;
  T.Seek(0);
  T.Write(buf[7],3);
  T.Seek(T.GetSize-1661);
  T.Truncate;
  CleanCOM := T.Status = stOK;
end;

function TC1661.InMem;assembler;
asm
  mov  ax,4BF1h
  xor  di,di
  xor  si,si
  int  21h
  cmp  di,1990h
  je   @Yes
  mov  al,False
  jmp  @Exit
@Yes:
  mov  al,true
@Exit:
end;

function TC1661.GetName;
begin
  GetName := 'Cascade-1661';
end;

end.