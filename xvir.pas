unit XVir;

interface

uses

  XTypes,Objects;

const

  Vir_COM      = 1;
  Vir_EXE      = 2;

type

  PVirus = ^TVirus;
  TVirus = object(TObject)
    Next     : PVirus;
    function ScanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function CleanEXE(var h:TEXEHeader; var T:TStream):boolean;virtual;
    function ScanCOM(var T:TStream):boolean;virtual;
    function CleanCOM(var T:TStream):boolean;virtual;
    function InMem:boolean;virtual;
    function GetName:string;virtual;
    function GetFlags:byte;virtual;
    procedure AlignEXEHeader(var h:TEXEHeader; length:longint);
  end;

implementation

procedure TVirus.AlignEXEHeader;
var
  l1,l2:longint;
begin
  l1 := length div 512;
  l2 := length mod 512;
  if l2 > 0 then inc(l1);
  h.FileSize := l1;
  h.LastPageSize := l2;
end;

function TVirus.ScanCOM;
begin
  ScanCOM := false;
end;

function TVirus.CleanCOM;
begin
  CleanCOM := false;
end;

function TVirus.ScanEXE;
begin
  ScanEXE := false;
end;

function TVirus.CleanEXE;
begin
  CleanEXE := false;
end;

function TVirus.InMem;
begin
  InMem := false;
end;

function TVirus.GetFlags;
begin
  GetFlags := 0;
end;

function TVirus.GetName;
begin
  GetName := 'Unnamed virus';
end;

end.