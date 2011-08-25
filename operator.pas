{
project  : Operator / AD94
module   : main application
revision : 1.00a
start    : 6th Aug 94
finish   : ???

Update info:
------------
16th Nov 94 - 00:55 - stripped FatalVision parts...
16th Nov 94 - 01:48 - made working...
16th Nov 94 - 02:42 - i must sleep...
}

uses

{ virus operator units }
ATB,Mirage,X1,X2,X3,C1661,Mumcu,

{ TurboVision units }
App,Menus,Views,Dialogs,MsgBox,StdDlg,

{ misc units }
Crt,Dos,Drivers,Objects,XVir;

const

  gVersion  = '1.00a';

  cmScan     = 56905;   {menu commands}
  cmClean    = 56906;
  cmAbout    = 56907;
  cmScanFile = 56908;
  cmDosShell = 56909;

  gmDestroyed : string[16] = 'VirÅs yok edildi';
  gmNA        : string[19] = 'VirÅs yok edilemedi';

type

  PVirusCollection = ^TVirusCollection;
  TVirusCollection = object(TCollection)
    procedure FreeItem(Item:Pointer);virtual;
  end;

  PBargraph = ^TBargraph;
  TBarGraph = object(TView)
    Max,Current : longint;
    constructor Init(var R:TRect; amax,acurrent:longint);
    procedure   Draw;virtual;
    procedure   Update(amax,acurrent:longint);virtual;
  end;

  TMain = object(TApplication)
    constructor Init;
    destructor  Done;virtual;
    function    CheckMem:boolean;
    function    GetScanFileName:FNameStr;
    procedure   HandleEvent(var Event:TEvent);virtual;
    procedure   InitStatusLine;virtual;
    procedure   InitMenuBar;virtual;
    procedure   WriteShellMsg;virtual;
  end;

  PInfo = ^TInfo;
  TInfo = record
    Scanning  : string[40];
    Scanned,
    Infected,
    Repaired : longint;
  end;

  PStatWindow = ^TStatWindow;
  TStatWindow = object(TDialog)
    Graph : PBarGraph;
    constructor Init(Ahdr:string);
    procedure   SetData(var rec);virtual;
  end;

  PDrvDialog = ^TDrvDialog;
  TDrvDialog = object(TDialog)
    procedure HandleEvent(var Event:TEvent);virtual;
  end;

var  {global variables}

  VirusList   : PVirusCollection;
  ParamScan   : boolean;
  DriveScan   : boolean;

{ generic procedures begin here }

function LInt2Str(l:longint):string;
var
  s:string[10];
begin
  Str(l,s);
  LInt2Str := s;
end;

function GetDDC:byte;assembler; {finds disk drive count (all dos drives)}
asm
  push  ds
  mov   bl,1
@Loop:
  push  bx
  mov   ax,4408h
  int   21h
  pop   bx
  cmp   al,1
  ja    @Exit
  inc   bl
  cmp   bl,25
  jb    @Loop
@Exit:
  pop   ds
  dec   bl
  mov   al,bl
end;

function XFileExists(s:FNameStr):boolean; {using borland's method}
var
  F: file;
  Attr: Word;
begin
  Assign(F, s);
  GetFAttr(F, Attr);
  XFileExists := DosError = 0;
end;

procedure FastUpper(var s:string); {makes string upper}
var
  b:byte;
begin
  for b:=1 to length(s) do s[b] := UpCase(s[b]);
end;

function XIsParam(AParam:string):integer; {Returns param no of param}
var
  n:integer;
  s:string;
  i:byte;
begin
  XIsParam := 0;
  FastUpper(AParam);
  for n:=1 to ParamCount do begin
    s := ParamStr(n);
    if (s[1] = '/') or (s[1] = '-') then begin
      Delete(s,1,1);
      i := Pos(':',s);
      if i > 0 then Delete(s,i,255);
      FastUpper(s);
      if s = AParam then XIsParam := n;
    end;
  end;
end;

function TMain.CheckMem;
var
  n:integer;
  P:Dialogs.PDialog;
  Graph:PBarGraph;
  R:TRect;
  PV:PVirus;
begin
  CheckMem := false;
  R.Assign(0,0,30,10);
  New(P,Init(R,'Hafçza Tarançyor'));
  R.Grow(-2,-2);
  New(Graph,Init(R,VirusList^.Count-1,0));
  P^.Insert(Graph);
  P^.Options := P^.Options or ofCentered;
  Insert(P);
  for n := 0 to VirusList^.Count - 1 do begin
    PV := PVirus(VirusList^.At(n));
    if PV^.InMem then begin
      MessageBox(^C+PV^.GetName+' virusu hafizada bulundu'#13+
                 ^C'Programdan ciktiginizda tekrar bulasabilir'#13+
                 ^C'Programi temiz bir sistem disketinden calistirin',NIL,MsgBox.mfWarning+mfOkButton);
      exit;
    end;
    Graph^.Update(VirusList^.Count-1,n);
  end;
  Dispose(P,Done);
  CheckMem := True;
end;

procedure TMain.InitStatusLine;
var
  R:TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y-1;
  New(StatusLine,Init(R,NewStatusDef(0,65535,
    NewStatusKey('~F2~ Ara',kbF2,cmScan,
    NewStatusKey('~F3~ Yoket!',kbF3,cmClean,
    NewStatusKey('~F4~ Dosya',kbF4,cmScanFile,
    NewStatusKey('~Alt-D~ Dos',kbAltD,cmDosShell,
    NewStatusKey('~Alt-X~ Cikis',kbAltX,cmQuit,
    NewStatusKey('(c) 1994 Sedat Kapanoglu',kbAltH,cmAbout,
    NIL)))))),NIL)));
end;

constructor TMain.Init;
begin
  inherited Init;
  if XIsParam('NOMEM') = 0 then begin
    if not CheckMem then begin
      Done;
      writeln('Temiz bir sistem disketinden acmayi unutmayin...');
      halt(1);
    end;
  end;
  if ParamScan then Views.Message(@Self,evCommand,cmScanFile,nil) else if
     DriveScan then Views.Message(@Self,evCommand,cmScan,nil);
end;

procedure TMain.InitMenuBar;
var
  R:TRect;
begin
  GetExtent(R);
  r.b.y := r.a.y + 1;
  MenuBar := New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('~O~perator',0,
     NewMenu(
      NewItem('~S~adece virus ara','F2',kbF2,cmScan,hcNoContext,
      NewItem('~V~irus ara ve buldugunda yoket','F3',kbF3,cmClean,hcNoContext,
      NewItem('Tek ~d~osyayi ara','F4',kbF4,cmScanFile,hcNoContext,
      NewLine(
      NewItem('D~O~S Shell','Alt-D',kbAltD,cmDosShell,hcNoContext,
      NewLine(
      NewItem('~P~rogram hakkinda','Alt-H',kbAltH,cmAbout,hcNoContext,
      NewLine(
      NewItem('~C~ikis','Alt-X',kbAltX,Views.cmQuit,hcNoContext,NIL)
      ))))))))),
    NIL))));
end;

destructor TMain.Done;
begin
  Dispose(VirusList,Done);
  inherited Done;
end;

function TMain.GetScanFileName:FNameStr;
  function ExecuteFileDialog:FNameStr;
  var
    P:StdDlg.PFileDialog;
    F:PathStr;
    code:word;
  begin
    New(P,Init('*.EXE','Dosya Secimi','Dosya adi',fdOkButton,0));
    code := ExecView(P);
    F := '';
    if code <> Views.cmCancel then P^.GetData(F);
    Dispose(P,Done);
    ExecuteFileDialog := F;
  end;
begin
  if not XFileExists(ParamStr(1)) then GetScanFileName := ExecuteFileDialog
                                  else GetScanFileName := ParamStr(1);
end;

procedure TMain.HandleEvent;
var
  Info:TInfo;
  iw:PStatWindow;
  Graph:PBarGraph;
  AHdr:String;
  Clean:boolean;
  Cancelled:boolean;
  totaldirs:longint;
  currentdir:longint;

  function Mess(msg:string;ptr:pointer;flags:word):word;
  begin
    Delete(iw);
    Mess := MsgBox.MessageBox(msg,ptr,flags);
    Insert(iw);
  end;

  procedure ScanDisk(S:FNameStr);
  var
    dirinfo:SearchRec;
    Attr:word;
    F:File;
    T:TDosStream;
    procedure SubOfSub;
    var
      n:integer;
      PV:PVirus;
      Event:TEvent;
    begin
      if Cancelled then exit;
      Assign(F,S+dirinfo.name);
      GetFAttr(F,Attr);
      SetFAttr(F,Archive);
      T.Init(S+dirinfo.name,stOpen);
      Info.Scanning := S+dirinfo.name;
      iw^.SetData(Info);
      for n:=0 to VirusList^.Count-1 do begin
        PV := VirusList^.At(n);
        if PV^.Scan(T) then begin
          Mess(^C+PV^.GetName+' virusu'+#13#3+
                       S+dirinfo.name+' isimli dosyada bulundu',NIL,mfWarning+mfOkButton);
          inc(Info.Infected);
          if Clean then case PV^.Clean(T) of
            True  : begin
                      Mess(^C+gmDestroyed,NIL,mfInformation+mfOkButton);
                      inc(Info.Repaired);
                    end;
            False : Mess(^C+gmNA,NIL,mfWarning+mfOkButton);
          end;
        end;
      end;
      GetEvent(Event);
      if Event.What = evKeyDown then if Event.KeyCode = kbEsc then begin
        if Mess(^C'Islemi iptal etmek istiyor musunuz?',NIL,MsgBox.mfYesButton+MsgBox.mfNoButton+mfConfirmation)
        = Views.cmYes then
          Cancelled := true;
      end;
      inc(Info.Scanned);
      iw^.SetData(Info);
      T.Done;
      SetFAttr(F,Attr);
    end;
    procedure DoIt(awild:FnameStr);
    begin
      FindFirst(S+awild,Archive+ReadOnly+Hidden+SysFile,dirinfo);
      while DosError = 0 do begin
        SubOfSub;
        FindNext(dirinfo);
      end;
    end;
  begin
    if Cancelled then exit;
    DoIt('*.COM');
    DoIt('*.EXE');
  end;

  procedure ForEachDir(S:FNameStr);
  var
    dirinfo:SearchRec;
  begin
    if Cancelled then exit;
    inc(currentdir);
    iw^.Graph^.Update(totaldirs,currentdir);
    ScanDisk(S);
    FindFirst(S+'*.*',Directory+Hidden,dirinfo);
    while DosError = 0 do begin
      if (dirinfo.name[1] <> '.') and (dirinfo.attr and directory > 0)
        then ForEachDir(S+dirinfo.name+'\');
      FindNext(dirinfo);
    end;
  end;

  function GetDrive:byte;
  var
    P:PDrvDialog;
    View:Views.PView;
    R:TRect;
    b:byte;
    code:word;
    procedure PutDrive(c:char);
    begin
      r.b.x := r.a.x + 6;
      r.b.y := r.a.y + 2;
      View := New(Dialogs.PButton,Init(R,'~'+c+'~'+':',65000+byte(c),0));
      R.A.X := R.B.X + 2;
      P^.Insert(View);
    end;
  begin
    GetDrive := 255;
    R.Assign(0,0,0,0);
    New(P,Init(R,'Hangi SÅrÅcÅde?'));
    P^.Options := P^.Options or ofCentered;
    r.a.y := 2;
    r.a.x := 2;
    for b:=0 to GetDDC-1 do PutDrive(char(b+65));
    r.b.x := r.a.x + 10;
    P^.Insert(New(Dialogs.PButton,Init(R,'Vazgec',Views.cmCancel,0)));
    r.a.x := 0;
    r.a.y := 0;
    inc(r.b.x,2);
    r.b.y := 6;
    P^.ChangeBounds(R);
    P^.SelectNext(False);
    code := ExecView(P);
    if code > 65000 then GetDrive := code-65000;
    Dispose(P,Done);
  end;

  procedure SubScan(path:FNameStr);
  var
    dirinfo:SearchRec;
  begin
    inc(totaldirs);
    FindFirst(path+'*.*',Directory+Hidden,dirinfo);
    while DosError = 0 do begin
      if (dirinfo.name[1] <> '.') and (dirinfo.attr and directory > 0) then SubScan(path+dirinfo.name+'\');
      FindNext(dirinfo);
    end;
  end;

  procedure Off;
  var
    drive:char;
    s:string[1];
  begin
    currentdir := 0;
    s          := ParamStr(1);
    if DriveScan then drive := upcase(s[1])
                 else drive := char(GetDrive);
    if drive = #255 then exit;
    totaldirs := 0;
    SubScan(drive+':\');
    New(iw,Init(AHdr));
    Insert(iw);
    FillChar(Info,SizeOf(Info),0);
    Cancelled := false;
    ForEachDir(drive+':\');
    Mess(^C'Islem tamamlandi',NIL,MsgBox.mfInformation+MsgBox.mfOkButton);
    Dispose(iw,Done);
    if DriveScan then begin
      Done;
      Halt;
    end;
  end;

  procedure DamnedScan;
  begin
    AHdr := 'Taraniyor';
    Clean := false;
    Off;
  end;

  procedure DamnedClean;
  begin
    AHdr := 'Temizleniyor';
    Clean := true;
    Off;
  end;

  procedure About;
  var
    R:TRect;
  begin
    R.Assign(0,0,30,16);
    R.Move(25,2);
    MessageBoxRect(R,^C'Operator'#13+
               ^C'Version '+gVersion+#13#13+
               ^C'Program'#13+
               ^C'Sedat Kapanoglu'#13#13+
               ^C'Turbo Vision'#13+
               ^C'(c) Borland International',NIL,mfInformation+mfOkButton);
  end;

  procedure ScanFile;
  var
    f:FNameStr;
    T:TDosStream;
    PV:PVirus;
    n:integer;
    found:boolean;
  begin
    f := GetScanFileName;
    if f = '' then exit;
    T.Init(f,stOpen);
    found := false;
    for n:=0 to VirusList^.Count-1 do begin
      PV := VirusList^.At(n);
      if PV^.Scan(T) then begin
        found := true;
        if MsgBox.MessageBox(^C+'Dosyada '+PV^.GetName+' virusu bulundu'#13+
                                          ^C'Virusu yok etmek istiyor musunuz?',NIL,
        mfConfirmation+MsgBox.mfYesButton+MsgBox.mfNoButton) = Views.cmYes then
        begin
           if PV^.Clean(T) then MsgBox.MessageBox(^C+gmDestroyed,NIL,mfInformation+mfOkButton)
                           else MsgBox.MessageBox(^C+gmNA,NIL,mfWarning+mfOkButton);
        end;
      end;
    end;
    if not found then MsgBox.MessageBox(^C'Dosyada herhangi bir viruse rastlanmadi',NIL,mfInformation+mfOkButton);
    T.Done;
    if ParamScan then begin
      Done;
      Halt;
    end;
  end;

begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand : case Event.Command of
                  cmScan  : DamnedScan;
                  cmScanFile : ScanFile;
                  cmClean : DamnedClean;
                  cmAbout : About;
                  cmDosShell : DosShell;
                end;
  end;
end;

procedure TMain.WriteShellMsg;
begin
  PrintStr('Operator''e donmek icin EXIT yaziniz...'#13#10);
end;

constructor TBarGraph.Init;
begin
  inherited Init(R);
  EventMask := 0;
  Update(amax,acurrent);
end;

procedure TBarGraph.Update;
begin
  if (AMax = Max) and (ACurrent = Current) then exit;
  Max     := AMax;
  Current := ACurrent;
  if Current > Max then Current := Max;
  DrawView;
end;

procedure TBarGraph.Draw;
var
  T:TDrawBuffer;
  visix:integer;
  color:byte;
begin
  if Mem[Seg0040:$49] = 7 then color := 15 else color := 12;
  FillChar(T,SizeOf(T),0);
  if Max = 0 then begin
    MoveChar(T,#32,0,Size.X);
  end else begin
    visix := (Size.X*Current) div Max;
    MoveChar(T,#219,color,visix);
    MoveChar(T[visix],#32,0,Size.X-visix);
  end;
  WriteLine(0,0,Size.X,Size.Y,T);
end;

constructor TStatWindow.Init(AHdr:string);
var
  R:TRect;
  y:integer;
  procedure PutInput(caption:FNameStr;len:byte);
  var
    P:Views.PView;
  begin
    R.Assign(1,y,1+length(caption),y+1);
    P := New(Dialogs.PLabel,Init(R,caption,nil));
    P^.Options := P^.Options and not ofSelectable;
    P^.SetState(sfCursorVis,False);
    Insert(P);
    R.Assign(2+length(caption),y,2+length(caption)+len,y+1);
    P := New(PInputLine,Init(R,len));
    Insert(P);
    P^.Options := P^.Options and not ofSelectable;
    inc(y,2);
  end;
begin
  R.Assign(0,0,62,11);
  inherited Init(R,AHdr);
  Options := Options or ofCentered;
  y := 2;
  PutInput('Dosya adi         ',40);
  PutInput('Kontrol edilenler ',12);
  PutInput('Viruslu dosyalar  ',12);
  PutInput('Onarilan dosyalar ',12);
  GetExtent(R);
  r.a.x := 33;
  r.a.y := 4;
  dec(r.b.x,2);
  dec(r.b.y,2);
  New(Graph,Init(R,0,0));
  Insert(Graph);
end;

procedure TStatWindow.SetData;
type
  TScr = record
    fname : string[40];
    scanned,infected,repaired:string[12];
  end;
var
  T:TScr;
begin
  with TInfo(rec) do begin
    T.fname := Scanning;
    T.Scanned := LInt2Str(Scanned);
    T.Infected := LInt2Str(Infected);
    T.Repaired := LInt2Str(Repaired);
  end;
  inherited SetData(T);
end;

procedure TVirusCollection.FreeItem;
begin
  Dispose(PVirus(Item),Done);
end;

procedure TDrvDialog.HandleEvent;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then if Event.Command > 65000 then EndModal(Event.Command);
end;

procedure InitViruses;  {initializes virus info}
  procedure Install(P:PVirus);
  begin
    VirusList^.Insert(P);
  end;
begin
  New(VirusList,Init(10,10));
  Install(New(PMirage,Init));
  Install(New(PATB,Init));
  Install(New(PMumcu,Init));
  Install(New(PX1,Init));
  Install(New(PX2,Init));
  Install(New(PX3,Init));
  Install(New(PC1661,Init));
end;

var
  T:TMain;
  s:string[1];
begin
  if XIsParam('?') > 0 then begin
    writeln('Kullanim: OPERATOR [surucu|dosyaadi] [/NOMEM]');
    halt(1);
  end;
  ParamScan := XFileExists(ParamStr(1));
  if (not ParamScan) and (ParamCount > 0) then begin
    s := ParamStr(1);
    DriveScan := (s <> '-') and (s <> '/');
  end else DriveScan := false;
  InitViruses;
  T.Init;
  T.Run;
  T.Done;
end.
