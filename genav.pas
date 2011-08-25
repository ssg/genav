{
Name            : GENAV 1.02f
Purpose         : Generic Anti-Virus
Coder           : SSG

Update info:
------------
              Version 1.01
 6th Aug 94 - 20:35 - La conversione de la Englissione texte due tue
                      Turkisce goode...
 6th Aug 94 - 21:06 - Added critical error handler...
 7th Aug 94 - 18:32 - Added X1 support...
 7th Aug 94 - 19:34 - Added BarGraph to show percentage...
 7th Aug 94 - 20:05 - Added command line parameters...
 7th Aug 94 - 20:10 - Added Cascade-1661 support...
              Version 1.02
 8th Aug 94 - 22:19 - Added TVision support...
22nd Aug 94 - 00:01 - Added Mumcu support...
                      (Damn this xvhc! I've overwritten genav.pas!)
                      (Fortunately, my backups were new)
22nd Aug 94 - 00:15 - When cleaning Mumcu, first three bytes of COM
                      are not recovered... Fixed this bug..
16th Nov 94 - 00:51 - Recompiled with new FatalVision...
13th Dec 94 - 21:37 - Recompiled with newer FatalVision...
21nd May 96 - 16:02 - Removing TV support...
}

uses

ATB,Mirage,X1,X2,X3,C1661,Mumcu,TaiPan,

Dos,Drivers,XProtect,XVir;

const

  gVersion  = '1.03e';

  cmScan     = 56905;
  cmClean    = 56906;
  cmAbout    = 56907;
  cmScanFile = 56908;

  gmDestroyed : string[20] = 'VirÅs yok edildi';
  gmNA        : string[20] = 'VirÅs yok edilemedi';

  Ctx_Help    = hcNoContext;

type

  PInfoWindow = ^TInfoWindow;
  TInfoWindow = object(Tools.TDialog)
    Topic     : PTopic;
    constructor Init;
    procedure   ChangeBounds(var R:TRect);virtual;
  end;

  PVirusCollection = ^TVirusCollection;
  TVirusCollection = object(TCollection)
    procedure FreeItem(Item:Pointer);virtual;
  end;

  TMain = object(TSystem)
    HL          : PInfoWindow;
    constructor Init;
    destructor  Done;virtual;
    function    CheckMem:boolean;
    function    GetScanFileName:FNameStr;
    procedure   HandleEvent(var Event:TEvent);virtual;
  end;

  PInfo = ^TInfo;
  TInfo = record
    Scanning  : string[40];
    Scanned,
    Infected,
    Repaired : longint;
  end;

  PStatWindow = ^TStatWindow;
  TStatWindow = object(GView.TWindow)
    Graph : PBarGraph;
    constructor Init(Ahdr:string);
  end;

var

  VirusList   : PVirusCollection;
  ParamScan   : boolean;
  DriveScan   : boolean;

constructor TInfoWindow.Init;
var
  R:TRect;
  R1:TRect;
begin
  R.Assign(0,0,400,250);
  inherited Init(R,'Bilgi Bankasi');
  Options := Options or Ocf_Centered or Ocf_ReSize;
  GetVisibleBounds(R);
  R.Move(-r.a.x,-r.a.y);
  New(Topic,Init(R,0));
  Insert(Topic);
end;

procedure TInfoWindow.ChangeBounds;
begin
  Lock;
  inherited ChangeBounds(R);
  GetVisibleBounds(R);
  Topic^.ChangeBounds(R);
  UnLock;
end;

constructor TStatWindow.Init(AHdr:string);
var
  R:TRect;
begin
  R.Assign(0,0,0,0);
  inherited Init(R,AHdr);
  Options := Options and not Ocf_ReSize;
  InsertBlock(GetBlock(5,5,mnfVertical+mnfNoSelect,
    NewInputItem ('Dosya adç         ',40,Idc_StrDefault,
    NewNInputItem('Kontrol edilenler ',12,Stf_Longint,12,0,0,
    NewNInputItem('VirÅslÅ dosyalar  ',12,Stf_Longint,12,0,0,
    NewNInputItem('Onarçlan dosyalar ',12,Stf_Longint,12,0,0,
  NIL))))));
  FitBounds;
  GetVisibleBounds(R);
  R.Grow(-5,-5);
  R.Move(-r.a.x,-r.a.y);
  R.A.X := 253;
  R.A.Y := 21;
  New(Graph,Init(R,0,0));
  Insert(Graph);
end;

procedure TVirusCollection.FreeItem;
begin
  Dispose(PVirus(Item),Done);
end;

function TMain.CheckMem;
var
  n:integer;
  P:PWindow;
  Graph:PBarGraph;
  R:TRect;
  PV:PVirus;
begin
  CheckMem := false;
  R.Assign(0,0,0,0);
  New(P,Init(R,'Hafçza Tarançyor'));
  R.Assign(0,0,320,60);
  R.Move(5,5);
  Graph := New(PBarGraph,Init(R,VirusList^.Count-1,0));
  P^.Insert(Graph);
  P^.Options := P^.Options or Ocf_Centered and not (Ocf_Close+Ocf_ReSize);
  P^.FitBounds;
  Insert(P);
  for n := 0 to VirusList^.Count - 1 do begin
    PV := PVirus(VirusList^.At(n));
    if PV^.InMem then begin
      MessageBox(^C+PV^.GetName+' virÅsÅ hafçzada bulundu'#13+
                 ^C'Programdan áçktçßçnçzda tekrar bulaüabilir'#13+
                 ^C'Programç temiz bir sistem disketinden áalçütçrçn',0,mfWarning);
      exit;
    end;
    Graph^.Update(VirusList^.Count-1,n);
  end;
  Dispose(P,Done);
  CheckMem := True;
end;

procedure InitViruses;
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
  Install(New(PTaiPan,Init));
end;

constructor TMain.Init;
var
  P:PMenuBar;
  R:TRect;
begin
  asm
    mov ax,3
    int 10h
  end;
  writeln('GenAv '+gVersion+' - (c) 1994..1996 SSG'#13#10);
  InitCRH;
  InitHelpSystem('GENAV');
  inherited Init;
  SetSysPalette;
  if XIsParam('NOMEM') = 0 then begin
    if not CheckMem then begin
      Done;
      writeln('Temiz bir sistem disketinden aámayç unutmayçn...');
      halt(1);
    end;
  end;
  GetExtent(R);
  New(P,Init(R,NewMenu(
    NewSubMenu('~GenAv',
     NewMenu(
      NewItem('~Sadece virÅs ara',cmScan,
      NewItem('~VirÅs ara ve buldußunda yoket',cmClean,
      NewItem('Tek ~dosyayç ara',cmScanFile,
      NewLine(
      NewItem('~Program hakkçnda',cmAbout,
      NewLine(
      NewItem('~Äçkçü',XTypes.cmQuit,NIL)
      ))))))),
    NIL))));
  Insert(P);
  if ParamScan then Message(@Self,evCommand,cmScanFile,nil) else if
     DriveScan then Message(@Self,evCommand,cmScan,nil);
end;

destructor TMain.Done;
begin
  DoneCRH;
  Dispose(VirusList,Done);
  inherited Done;
end;

function TMain.GetScanFileName:FNameStr;
begin
  if not XFileExists(ParamStr(1)) then GetScanFileName := ExecuteFileDialog('*.EXE','Dosya Seáimi','Dosya adç')
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

type

  TProc = procedure(S:FNameStr);

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
          MessageBox(^C+PV^.GetName+' virÅsÅ'+#13#3+
                       S+dirinfo.name+' isimli dosyada bulundu',0,mfWarning);
          inc(Info.Infected);
          if Clean then case PV^.Clean(T) of
            True  : begin
                      MessageBox(^C+gmDestroyed,0,mfInfo);
                      inc(Info.Repaired);
                    end;
            False : MessageBox(^C+gmNA,0,mfWarning);
          end;
        end;
      end;
      if keypressed then if readkey = #27 then
        if MessageBox(^C'òülemi iptal etmek istiyor musunuz?',0,mfYesNo+mfConfirm) = cmYes then
          Cancelled := true;
      inc(Info.Scanned);
      iw^.SetData(Info);
      T.Done;
      SetFAttr(F,Attr);
    end;
  begin
    if Cancelled then exit;
    FindFirst(S+'*.COM',Archive+ReadOnly+Hidden+SysFile,dirinfo);
    while DosError = 0 do begin
      SubOfSub;
      FindNext(dirinfo);
    end;
    FindFirst(S+'*.EXE',Archive+ReadOnly+Hidden+SysFile,dirinfo);
    while DosError = 0 do begin
      SubOfSub;
      FindNext(dirinfo);
    end;
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
  P:PDialog;
  View:PView;
  R:TRect;
  b:byte;
  code:word;
  procedure PutDrive(c:char);
  begin
    View := New(PButton,Init(R.A.x,r.a.y,'~'+c+':',cmOK));
    View^.GetBounds(R);
    R.A.X := R.B.X + 5;
    P^.Insert(View);
  end;
begin
  GetDrive := 255;
  R.Assign(0,0,0,0);
  New(P,Init(R,'SÅrÅcÅ Seáimi'));
  P^.Options := P^.Options or Ocf_Centered;
  r.a.y := 5;
  r.a.x := 5;
  for b:=0 to GetDDC-1 do PutDrive(char(b+65));
  P^.Insert(New(PButton,Init(R.A.x,r.a.y,'Vazgeá',cmCancel)));
  P^.FitBounds;
  P^.SelectNext(True);
  code := ExecView(P);
  if code = cmOK then GetDrive := byte(PButton(P^.Current)^.Text^[1])-65;
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
               else drive := char(GetDrive+65);
  if drive = #255 then exit;
  StartJob('Directory''ler okunuyor');
  totaldirs := 0;
  SubScan(drive+':\');
  EndJob;
  New(iw,Init(AHdr));
  iw^.Options := (iw^.Options and not (Ocf_ReSize+Ocf_Close)) or Ocf_Centered;;
  Insert(iw);
  FillChar(Info,SizeOf(Info),0);
  Cancelled := false;
  ForEachDir(drive+':\');
  MessageBox(^C'òülem tamamlandç',0,mfInfo);
  Dispose(iw,Done);
  if DriveScan then begin
    Done;
    Halt;
  end;
end;

procedure DamnedScan;
begin
  AHdr := 'Tarançyor';
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
begin
  MessageBox(^C'GenAv'#13+
             ^C'Version '+gVersion+#13#32#13+
             ^C'Program'#13+
             ^C'Sedat Kapanoßlu'#13#32#13+
             ^C'FatalVision'#13+
             ^C'Sedat Kapanoßlu'#13+
             ^C'Meriá ûentunalç'#13#32#13+
             ^C'(c) 1994 K.I.S.S.',0,mfInfo);
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
      if MessageBox(^C+'Dosyada '+PV^.GetName+' virÅsÅ bulundu'#13+
                                        ^C'VirÅsÅ yok etmek istiyor musunuz?',0,mfConfirm+mfYesNo) = cmYes then
      begin
         if PV^.Clean(T) then MessageBox(^C+gmDestroyed,0,mfInfo)
                         else MessageBox(^C+gmNA,0,mfWarning);
      end;
    end;
  end;
  if not found then MessageBox(^C'Dosyada herhangi bir virÅse rastlanmadç',0,mfInfo);
  T.Done;
  if ParamScan then begin
    Done;
    Halt;
  end;
end;

begin
  if Event.What = evCommand then if
    Event.Command = cmHelp then if HelpOK then begin
      if HL = NIL then begin
         New(HL,Init);
         HL^.HelpContext := Ctx_Help;
         ExecView(HL);
         if HL <> NIL then Dispose(HL,Done);
         HL := NIL;
      end else
        if Current <> PView(HL) then HL^.Select;
    end;
  inherited HandleEvent(Event);
  case Event.What of
    evCommand : case Event.Command of
                  cmScan  : DamnedScan;
                  cmScanFile : ScanFile;
                  cmClean : DamnedClean;
                  cmAbout : About;
                end;
    evKeyDown : case Event.KeyCode of
                  kbF1 : Message(@Self,evCommand,cmHelp,NIL);
                  kbF2 : DamnedScan;
                  kbF3 : DamnedClean;
                end;
  end;
end;

var
  T:TMain;
  s:string[1];
begin
  if (not EXEOK) and (XIsParam('DEVPARM') = 0) then begin
    writeln('GenAv bozuk...');
    halt(1);
  end;
  if XIsParam('?') > 0 then XAbort('Usage: GENAV [drive|filename] [/NOMEM]');
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
