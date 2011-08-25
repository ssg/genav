{ the holy avenger - anti viral thing - 25th Apr 97 - 06:58 - SSG }

uses

  ATB,Mirage,X1,X2,X3,C1661,Mumcu,TaiPan,

  XTypes,Dos,Objects,XVir,XStr,XIO;

const

  Weapons    : PVirus = NIL;
  viruscount : word = 0;
  KILL       : boolean = false;

procedure InitWeapons;
  procedure install(wha:PVirus);
  begin
    wha^.Next := Weapons;
    Weapons := wha;
    inc(viruscount);
  end;
begin
  Install(New(PATB,Init));
  Install(New(PMirage,Init));
  Install(New(PX1,Init));
  Install(New(PX2,Init));
  Install(New(PX3,Init));
  Install(New(PC1661,Init));
  Install(New(PMumcu,Init));
  Install(New(PTaiPan,Init));
end;

procedure process(fn:string);
var
  T:TDosStream;
  isEXE:boolean;
  h:TEXEHeader;
  wep:PVirus;
  infected:boolean;
  l1,l2:longint;
begin
  T.Init(fn,stOpenRead);
  if T.Status <> stOK then begin
    writeln('WARNING: open failed ('+lower(fn)+')');
    T.Done;
    exit;
  end;
  T.Read(h,SizeOf(h));
  if T.Status <> stOK then begin
    writeln('WARNING: read error ('+lower(fn)+')');
    T.Done;
    exit;
  end;
  isEXE := (h.Id = $5a4d) or (h.Id=$4d5a);
  wep := Weapons;
  while wep <> NIL do begin
    if isEXE then begin
      l1 := h.FileSize;
      l2 := h.LastPageSize;
      if l2 > 0 then dec(l1);
      l1 := (l1*512)+l2;
      if l1 <> T.GetSize then begin
        writeln('WARNING: overlaid exe, skipped.');
        T.Done;
        wep := wep^.Next;
        continue;
      end;
      infected := wep^.ScanEXE(h,T)
    end else infected := wep^.ScanCOM(T);
    if infected then begin
      write('INFECTION: '+lower(fn)+'  ['+wep^.GetName+'] ');
      if KILL then begin
        T.Done;
        XSetFileAttr(fn,0);
        T.Init(fn,stOpen);
        if T.Status <> stOK then begin
          writeln('WARNING: open failed ('+lower(fn)+')');
          T.Done;
          exit;
        end;
        if isEXE then infected := wep^.CleanEXE(h,T) else infected := wep^.CleanCOM(T);
        if infected then writeln('disinfected.') else writeln('failed to disinfect.');
      end else writeln('*** leaved alone ***');
    end;
    wep := wep^.Next;
  end;
  T.Done;
end;

procedure subdirscan(where:string);
var
  dirinfo:SearchRec;
begin
  FindFirst(where+'*.COM',Archive+Hidden+SysFile+ReadOnly,dirinfo);
  while DosError = 0 do begin
    Process(where+dirinfo.name);
    FindNext(dirinfo);
  end;
  FindFirst(where+'*.EXE',Archive+Hidden+SysFile+ReadOnly,dirinfo);
  while DosError = 0 do begin
    Process(where+dirinfo.name);
    FindNext(dirinfo);
  end;
  FindFirst(where+'*.*',Directory+Hidden+SysFile+ReadOnly+Archive,dirinfo);
  while DosError = 0 do begin
    if dirinfo.name[1] <> '.' then if dirinfo.Attr and Directory > 0 then
      subdirscan(where+dirinfo.name+'\');
    FindNext(dirinfo);
  end;
end;

procedure CheckMem;
var
  wep:PVirus;
begin
  wep := Weapons;
  while wep <> NIL do begin
    if wep^.InMem then writeln('WARNING: ['+wep^.GetName+'] found in memory!');
    wep := wep^.Next;
  end;
end;

procedure Usage;
begin
  writeln('usage: avenger <command> [victim]'#13#10);
  writeln('commands are:'#13#10);
  writeln('  scan       scans for viruses');
  writeln('  kill       scans for and kills viruses');
  writeln('  list       lists detected viruses');
  halt;
end;

procedure list;
var
  P:PVirus;
begin
  P := Weapons;
  while P <> NIL do begin
    write(Fix(P^.GetName,30));
    case P^.GetFlags of
      0 : writeln('(n/a)');
      1 : writeln('COM only');
      2 : writeln('EXE only');
      3 : writeln('COM+EXE');
      else writeln('huh?');
    end; {case}
    P := P^.next;
  end;
  halt;
end;

var
  start:string;
  cmd:string;
begin
  InitWeapons;
  writeln('the holy avenger v',viruscount,' - anti viral thing - Apr 97 - SSG'#13#10);
  CheckMem;
  if paramcount < 1 then Usage;
  cmd := lower(paramstr(1));
  if cmd = 'list' then list;
  kill := cmd = 'kill';
  if XFileExists(paramStr(2)) then begin
    process(paramstr(2));
    halt;
  end;
  start := paramstr(2);
  XMakeDirStr(start,true);
  subdirscan(start);
end.