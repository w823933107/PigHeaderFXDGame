{
  2016/3/31
  =====================
  *����RoleNameWithDec�в�����Lv�������������ȡ��׼ȷ�Ĵ���
}
unit uGameEx.RoleInfo;

interface

// {$DEFINE USE_CODESITE}

uses uGameEx.Interf, System.SysUtils, uObj, System.RegularExpressions,
  CodeSiteLogging, QWorker, System.Types,QPlugins;

type

  TRoleInfoHandle = class(TGameBase,IRoleInfoHandle)
  private
    FName: string; // ��ɫ��
    FNameWithLv: string; // ��Lv�Ľ�ɫ��
    FFullName: string; // ���ȼ���������ɫ��
    FOcrStrArr: TArray<TOcrStr>;
    FLv: Cardinal;
    FBaseX, FBaseY: Integer; // "��"������
    FMainJobName: string;
    FExpertJobLv: Cardinal;
    FExpertJobCurExp: Cardinal;
    FExpertJobMaxExp: Cardinal;
    function OpenOrCloseRoleInfo(AJob: PQJob; const aIsOpen: Boolean): Boolean;
    // �򿪻��߹رս�ɫ��Ϣ
    function OpenRoleInfo(AJob: PQJob): Boolean; // �򿪽�ɫ��Ϣ
    function CloseRoleInfo(AJob: PQJob): Boolean; // �رս�ɫ��Ϣ
    // ���º�������򿪽�ɫ��Ϣ����в���
    function GetRoleName: string; // ��ȡ��ɫ����,�ڲ������˴�Lv�Ľ�ɫ��,���ؽ��������Lv
    function GetRoleNameWithDec: string; // ��ȡ��"|"�Ľ�ɫ��,�Ƴ�������
    function GetMainJob: string; // ��ȡ��ְҵ
    function GetExpertJob: string; // ��ȡ��ְҵ
    function GetExpertJobLv: Cardinal;
    function GetExpertJobCurExp: Cardinal;
    function GetExpertJobMaxExp: Cardinal;
    function GetLv: Integer;
    function GetCenterXOffset: TArray<TStrOffset>; // ��ȡ���ĵ�Xƫ��
    function GetCenterYOffset: Integer; // ��ȡ���ĵ�Yƫ��
  public
    // ��ȡ��ɫ��Ϣ����
    function GetRoleInfo: TRoleInfo;

  end;

implementation

// uses JclAnsiStrings;  //�Ƴ�,����ʹ���Դ���TryStrToInt����
{ TRoleInfo }

function TRoleInfoHandle.CloseRoleInfo(AJob: PQJob): Boolean;
begin
  Result := OpenOrCloseRoleInfo(AJob, False);
end;

function TRoleInfoHandle.GetCenterXOffset: TArray<TStrOffset>;
var
  CenterX, FirstX, LastX: Integer;
  count: Integer;
  OffsetX: Integer;
  I: Integer;
  StrOffset: TStrOffset;
  iTemp: Integer;
begin
  // ��ʽ:
  // centerX=first+(last+10-first)/2 ���а������һ��������10
  // offsetX=centerX-currentX
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetCenterXOffset'); {$ENDIF}
  count := Length(FOcrStrArr);
  FirstX := FOcrStrArr[0].X;
  LastX := FOcrStrArr[count - 1].X;
  CenterX := FirstX + (LastX - FirstX + 10) div 2;
  Result := [];
  for I := Low(FOcrStrArr) to High(FOcrStrArr) do
  begin
    if not TryStrToInt(FOcrStrArr[I].Str, iTemp) then // �����������,�Դ�����
    // if not StrIsDigit(AnsiString(FOcrStrArr[I].Str)) then // �����������JCL��ʵ��
    begin
      OffsetX := CenterX - FOcrStrArr[I].X;
      StrOffset.Str := FOcrStrArr[I].Str;
      StrOffset.OffsetX := OffsetX;
      Result := Result + [StrOffset];
    end;

  end;
end;

function TRoleInfoHandle.GetCenterYOffset: Integer;

begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetCenterYOffset'); {$ENDIF}
  { TODO -oPigheader -cδ��� : ��Ҫ���������ɫְҵ�����Yƫ�� }
  // Result := 0;
  if (FMainJobName = mjKuangzhanshi) or (FMainJobName = mjYuxuemoshen) then
    Result := GameData.GameConfig.iKuangzhanOffsetY
  else
    Result := GameData.GameConfig.iSilingOffsetY;

end;

function TRoleInfoHandle.GetExpertJob: string;
var
  x1, y1, x2, y2: Integer;
  Match: TMatch;
const
  pattern = '��ְҵLv(\d)\((\d+)/(\d+)\)\|(.+)'; // �ܵ�
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetExpertJob'); {$ENDIF}
  // ��ְҵƫ�Ʒ�Χ(-102,318,99,332)
  x1 := FBaseX - 102;
  y1 := FBaseY + 318;
  x2 := FBaseX + 99;
  y2 := FBaseY + 332;
  Result := Obj.Ocr(x1, y1, x2, y2, clStrWhite, 1.0);
  if not Result.IsEmpty then
  begin
    Match := TRegEx.Match(Result, pattern);
    if Match.Success then
    begin
      FExpertJobLv := Match.Groups[1].Value.ToInteger();
      FExpertJobCurExp := Match.Groups[2].Value.ToInteger();
      FExpertJobMaxExp := Match.Groups[3].Value.ToInteger();
      Result := Match.Groups[4].Value;
    end;
  end;
end;

function TRoleInfoHandle.GetExpertJobCurExp: Cardinal;
begin
  Result := FExpertJobCurExp;
end;

function TRoleInfoHandle.GetExpertJobLv: Cardinal;
begin
  Result := FExpertJobLv;
end;

function TRoleInfoHandle.GetExpertJobMaxExp: Cardinal;
begin
  Result := FExpertJobMaxExp;
end;

function TRoleInfoHandle.GetLv: Integer;
begin
  Result := FLv;
end;

function TRoleInfoHandle.GetMainJob: string;
var
  x1, y1, x2, y2: Integer;
  Match: TMatch;
const
  pattern = '\[(.+)\]';
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetMainJob'); {$ENDIF}
  // ��ְҵƫ�Ʒ�Χ(-38,137,104,155)
  x1 := FBaseX - 38;
  y1 := FBaseY + 137;
  x2 := FBaseX + 104;
  y2 := FBaseY + 155;
  Result := Obj.Ocr(x1, y1, x2, y2, clStrWhite, 1.0);
  if not Result.IsEmpty then
  begin
    Match := TRegEx.Match(Result, pattern);
    begin
      if Match.Success then
      begin
        // if Match.Groups.Count = 2 then
        Result := Match.Groups[1].Value;
        FMainJobName := Result; // ���õ��ֶ���,������ȡƫ��
      end;
    end;
  end;

end;

function TRoleInfoHandle.GetRoleInfo: TRoleInfo;
var
  hJob: THandle;
  waitResult: TWaitResult;
begin
  hJob := Workers.Post(
    procedure(AJob: PQJob)
    var
      StrOffset: TStrOffset;
      sCenterX: string;
      RoleInfo: PRoleInfo;
    begin
      RoleInfo := PRoleInfo(AJob.Data);
      if OpenRoleInfo(AJob) then
      begin
        RoleInfo.Name := GetRoleName;
        RoleInfo.NameWithDec := GetRoleNameWithDec;
        RoleInfo.MainJob := GetMainJob;
        RoleInfo.ExpertJob := GetExpertJob;
        RoleInfo.ExpertJobLv := GetExpertJobLv;
        RoleInfo.ExpertJobCurExp := GetExpertJobCurExp;
        RoleInfo.ExpertJobMaxExp := GetExpertJobMaxExp;
        RoleInfo.Lv := GetLv;
        RoleInfo.CenterXOffset := GetCenterXOffset;
        RoleInfo.CenterYOffset := GetCenterYOffset;
        CloseRoleInfo(AJob);
        // -------- ����Ϊ���Դ���--------------------------
        CodeSite.Send('Name', RoleInfo.Name);
        CodeSite.Send('NameWithDec', RoleInfo.NameWithDec);
        CodeSite.Send('MainJob', RoleInfo.MainJob);
        CodeSite.Send('ExpertJob', RoleInfo.ExpertJob);
        CodeSite.Send('ExpertJobLv', RoleInfo.ExpertJobLv);
        CodeSite.Send('ExpertJobCurExp', RoleInfo.ExpertJobCurExp);
        CodeSite.Send('ExpertJobMaxExp', RoleInfo.ExpertJobMaxExp);
        CodeSite.Send('Lv', RoleInfo.Lv);
        for StrOffset in RoleInfo.CenterXOffset do
        begin
          sCenterX := sCenterX + Format('(%s,%d)',
            [StrOffset.Str, StrOffset.OffsetX]);
        end;
        CodeSite.Send('CenterXOffset', sCenterX);
        CodeSite.Send('CenterYOffset', RoleInfo.CenterYOffset);
      end;
    end, @Result);
  waitResult := Workers.WaitJob(hJob, 1000 * 30, False); // �ȴ�30��
  if waitResult = wrTimeout then
    raise Exception.Create('get role info time out');
end;

function TRoleInfoHandle.GetRoleName: string;
  procedure GetNameAndLv(const aFullName: string; var aName: string;
  var aLv: Cardinal);
  var
    Match: TMatch;
  const
    pattern = 'Lv(\d+)(.+)';
  begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetNameAndLv'); {$ENDIF}
    // ��ȡ��һ��ƥ��������
    Match := TRegEx.Match(aFullName, pattern);
    if Match.Success then
    begin
      // if Match.Groups.Count = 3 then
      // begin
      aLv := Match.Groups[1].Value.ToInteger();
      aName := Match.Groups[2].Value;
      // end;
    end;
  end;

var
  x1, y1, x2, y2: Integer;
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetRoleName'); {$ENDIF}
  // ����ƫ�Ʒ�Χ(-24,120,82,140)
  x1 := FBaseX - 50;
  y1 := FBaseY + 120;
  x2 := FBaseX + 82;
  y2 := FBaseY + 140;
  {
    //�ò���Ϊ��ǰ�ķ���,�����ȽϷ���
    // ����ʶ��һЩ�ֿ�û�е������ַ�
    Result := FObj.Ocr(x1, y1, x2, y2, clStrWhite, 1.0);
    FName := Result; // �������ṩ����ȡ��"|"������ʹ��
  }
  // ����ʹ��Getwordsʶ�����,��Ϊ�������ƴ����޷�ʶ����ִ�
  // ��ȡ������ɫ���Ͷ�Ӧ����
  FOcrStrArr := MyObj.OcrEx(x1, y1, x2, y2, clStrWhite, 1.0, FFullName);
  // ��ȡ��ɫ���͵ȼ�
  GetNameAndLv(FFullName, FName, FLv);
  FNameWithLv := 'Lv' + FName;
  Result := FName;
end;

function TRoleInfoHandle.GetRoleNameWithDec: string;
var
  I: Integer;
  iTemp: Integer;
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetRoleNameWithDec'); {$ENDIF}
  if not FNameWithLv.IsEmpty then
  begin
    for I := 1 to FNameWithLv.Length do
    begin
      if not TryStrToInt(FNameWithLv[I], iTemp) then // �����������
      // if not StrIsDigit(AnsiString(FName[I])) then // �����������,JCL��Ԫ����
      begin
        if I = FNameWithLv.Length then
          Result := Result + FNameWithLv[I] // ���һλ���üӷָ���
        else
          Result := Result + FNameWithLv[I] + '|';
      end;
    end;
  end;
end;

function TRoleInfoHandle.OpenOrCloseRoleInfo(AJob: PQJob;
const aIsOpen: Boolean): Boolean;
var
  X, Y: OleVariant;
  iRet: Integer;
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'OpenOrCloseRoleInfo');
{$ENDIF}
  Result := False;
  while not AJob.IsTerminated do // ����߳�
  begin
    iRet := Obj.FindStr(95, 80, 414, 165, '������Ϣ(M)', clWndOpen,
      1.0, X, Y);
    if aIsOpen then
    begin
      Result := iRet <> -1;
      // ���û�������,"��"������
      FBaseX := X;
      FBaseY := Y;
    end
    else
      Result := iRet = -1;
    if Result then
      Break;
    Obj.KeyPressChar('m');
    Sleep(1000);
  end;
end;

function TRoleInfoHandle.OpenRoleInfo(AJob: PQJob): Boolean;
begin
  Result := OpenOrCloseRoleInfo(AJob, True);
end;
initialization
RegisterServices('Services/Game',[TRoleInfoHandle.Create()]);
finalization


end.
