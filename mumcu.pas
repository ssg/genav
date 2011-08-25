{
Mumcu operator... First of all I must say something about this virus:
"Whatever good ideologies it was written for, a virus can never be good... If
Ugur Mumcu would know about this virus, I'am sure that he wouldn't support it"
The operator has been coded by me..  Thanx to Omur from DimSoft for samples
again... works perfect...
}

unit Mumcu;

interface

uses

  XTypes,Objects,XVir;

type

  PMumcu = ^TMumcu;
  TMumcu = object(TVirus)
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

 Mumcu_SIGN : String[8] = #$c0#$74#$2e#$3c#$2e#$75#$f7#$ad;
 Mumcu_EXESize = 1301;

function TMumcu.GetFlags;
begin
  GetFlags := Vir_COM+Vir_EXE;
end;

function TMumcu.ScanCOM;
var
  sg:string[11];
begin
  if T.GetSize > 200 then begin
     T.Seek(T.GetSize-168);
     SG[0] := char(length(Mumcu_SIGN));
     T.Read(SG[1],length(sg));
     ScanCOM := SG=Mumcu_SIGN;
  end;
end;

function TMumcu.ScanEXE;
var
  sg:string[11];
begin
  if T.GetSize > 200 then begin
     T.Seek(T.GetSize-168);
     SG[0] := char(length(Mumcu_SIGN));
     T.Read(SG[1],length(sg));
     ScanEXE := SG=Mumcu_SIGN;
  end;
end;

function TMumcu.CleanCOM;
var
  buf:array[1..3] of byte;
  w:word;
begin
  T.Seek(1);
  T.Read(w,2);
  inc(w,3);
  T.Seek(T.GetSize-99);
  T.Read(buf,3);
  T.Seek(0);
  T.Write(buf,3);
  T.Seek(w);
  T.Truncate;
  CleanCOM := T.Status=stOK;
end;

function TMumcu.CleanEXE;
var
  a:longint;
begin
  with h do a := longint(CSInit)*16+longint(IPInit)+longint(hdrSize)*16;
  T.Seek(T.GetSize-59);
  T.Read(h.IPInit,2);
  T.Read(h.CSInit,2);
  T.Read(h.SSInit,2);
  T.Read(h.SPInit,2);
  AlignEXEHeader(h,A);
  T.Seek(0);
  T.Write(h,SizeOf(h));
  T.Seek(a);
  T.Truncate;
  CleanEXE := T.Status=stOK;
end;

function TMumcu.InMem;assembler;
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

function TMumcu.GetName;
begin
  GetName := 'Mumcu';
end;

end.