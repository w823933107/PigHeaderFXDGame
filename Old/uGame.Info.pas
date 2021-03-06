{
  2016/3/31
  =====================
  *修正RoleNameWithDec中不包含Lv导致人物坐标获取不准确的错误

}
unit uGame.Info;

interface

// {$DEFINE USE_CODESITE}

uses uGame.Interf, System.SysUtils, uObj, System.RegularExpressions,
  CodeSiteLogging, System.Diagnostics;

type

  TRoleInfoHandle = class(TGameBase, IRoleInfoHandle)
  private
    FName: string; // 角色名
    FNameWithLv: string; // 带Lv的角色名
    FFullName: string; // 带等级的完整角色名
    FOcrStrArr: TArray<TOcrStr>;
    FLv: Cardinal;
    FBaseX, FBaseY: Integer; // "个"的坐标
    FMainJobName: string;
    FExpertJobLv: Cardinal;
    FExpertJobCurExp: Cardinal;
    FExpertJobMaxExp: Cardinal;
    function OpenOrCloseRoleInfo(const aDoOpen: Boolean): Boolean; // 打开或者关闭角色信息
    function OpenRoleInfo: Boolean; // 打开角色信息
    function CloseRoleInfo: Boolean; // 关闭角色信息
    // 以下函数必须打开角色信息后进行操作
    function GetRoleName: string; // 获取角色名称
    function GetRoleNameWithDec: string; // 获取带"|"的角色名,移除了数字
    function GetMainJob: string; // 获取主职业
    function GetExpertJob: string; // 获取副职业
    function GetExpertJobLv: Cardinal;
    function GetExpertJobCurExp: Cardinal;
    function GetExpertJobMaxExp: Cardinal;
    function GetLv: Integer;
    function GetCenterXOffset: TArray<TStrOffset>; // 获取中心点X偏移
    function GetCenterYOffset: Integer; // 获取中心点Y偏移
  public
    // 获取角色信息数据
    function GetRoleInfo: TRoleInfo;


  end;

implementation

// uses JclAnsiStrings;  //移除,改用使用自带的TryStrToInt功能
{ TRoleInfo }

function TRoleInfoHandle.CloseRoleInfo: Boolean;
begin
  Result := OpenOrCloseRoleInfo(False);
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
  // 公式:
  // centerX=first+(last+10-first)/2 其中包含最后一个字像素10
  // offsetX=centerX-currentX
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetCenterXOffset'); {$ENDIF}
  count := Length(FOcrStrArr);
  FirstX := FOcrStrArr[0].X;
  LastX := FOcrStrArr[count - 1].X;
  CenterX := FirstX + (LastX - FirstX + 10) div 2;
  Result := [];
  for I := Low(FOcrStrArr) to High(FOcrStrArr) do
  begin
    if not TryStrToInt(FOcrStrArr[I].Str, iTemp) then // 如果不是数字,自带功能
    // if not StrIsDigit(AnsiString(FOcrStrArr[I].Str)) then // 如果不是数字JCL库实现
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
  { TODO -oPigheader -c未添加 : 需要添加其他角色职业种类的Y偏移 }
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
  pattern = '副职业Lv(\d)\((\d+)/(\d+)\)\|(.+)'; // 总的
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'GetExpertJob'); {$ENDIF}
  // 副职业偏移范围(-102,318,99,332)
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
  // 主职业偏移范围(-38,137,104,155)
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
        FMainJobName := Result;
      end;
    end;
  end;

end;

function TRoleInfoHandle.GetRoleInfo: TRoleInfo;
var
  StrOffset: TStrOffset;
  sCenterX: string;
  bSuccesed: Boolean;
begin
  bSuccesed := False;
  if OpenRoleInfo then
  begin
    Result.Name := GetRoleName;
    Result.NameWithDec := GetRoleNameWithDec;
    Result.MainJob := GetMainJob;
    Result.ExpertJob := GetExpertJob;
    Result.ExpertJobLv := GetExpertJobLv;
    Result.ExpertJobCurExp := GetExpertJobCurExp;
    Result.ExpertJobMaxExp := GetExpertJobMaxExp;
    Result.Lv := GetLv;
    Result.CenterXOffset := GetCenterXOffset;
    Result.CenterYOffset := GetCenterYOffset;
    bSuccesed := CloseRoleInfo;

    // -------- 以下为调试代码--------------------------
    CodeSite.Send('Name', Result.Name);
    CodeSite.Send('NameWithDec', Result.NameWithDec);
    CodeSite.Send('MainJob', Result.MainJob);
    CodeSite.Send('ExpertJob', Result.ExpertJob);
    CodeSite.Send('ExpertJobLv', Result.ExpertJobLv);
    CodeSite.Send('ExpertJobCurExp', Result.ExpertJobCurExp);
    CodeSite.Send('ExpertJobMaxExp', Result.ExpertJobMaxExp);
    CodeSite.Send('Lv', Result.Lv);
    for StrOffset in Result.CenterXOffset do
    begin
      sCenterX := sCenterX + Format('(%s,%d)',
        [StrOffset.Str, StrOffset.OffsetX]);
    end;
    CodeSite.Send('CenterXOffset', sCenterX);
    CodeSite.Send('CenterYOffset', Result.CenterYOffset);
    // --------------------------------------------------
  end;
  if not bSuccesed then
    raise ERoleInfoFailed.Create('角色获取失败!');
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
    // 获取第一个匹配结果即可
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
  // 名字偏移范围(-24,120,82,140)
  x1 := FBaseX - 50;
  y1 := FBaseY + 120;
  x2 := FBaseX + 82;
  y2 := FBaseY + 140;
  {
    //该部分为以前的方法,解析比较繁琐
    // 不能识别一些字库没有的特殊字符
    Result := FObj.Ocr(x1, y1, x2, y2, clStrWhite, 1.0);
    FName := Result; // 保存下提供给获取带"|"的名字使用
  }
  // 不能使用Getwords识别词组,因为人物名称存在无法识别的字串
  // 获取完整角色名和对应坐标
  FOcrStrArr := MyObj.OcrEx(x1, y1, x2, y2, clStrWhite, 1.0, FFullName);
  // 获取角色名和等级
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
      if not TryStrToInt(FNameWithLv[I], iTemp) then // 如果不是数字
      // if not StrIsDigit(AnsiString(FName[I])) then // 如果不是数字,JCL单元功能
      begin
        if I = FNameWithLv.Length then
          Result := Result + FNameWithLv[I] // 最后一位不用加分隔符
        else
          Result := Result + FNameWithLv[I] + '|';
      end;
    end;
  end;
end;

function TRoleInfoHandle.OpenOrCloseRoleInfo(const aDoOpen: Boolean): Boolean;
var
  X, Y: OleVariant;
  iRet: Integer;
  StopWatch: TStopwatch;
begin
{$IFDEF USE_CODESITE} CodeSite.TraceMethod(Self, 'OpenOrCloseRoleInfo');
{$ENDIF}
  StopWatch := TStopwatch.Create; // 创建并计算

  StopWatch.Start;
  Result := False;
  while not Terminated do // 检测线程
  begin
    if StopWatch.ElapsedMilliseconds >= GameData.GameConfig.iGetInfoTimeOut then
      // 检测是否超时
      Break;
    iRet := Obj.FindStr(95, 80, 414, 165, '个人信息(M)', clWndOpen,
      1.0, X, Y);
    if aDoOpen then
    begin
      Result := iRet <> -1;
      // 设置基础坐标,"个"的坐标
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

function TRoleInfoHandle.OpenRoleInfo: Boolean;
begin
  Result := OpenOrCloseRoleInfo(True);
end;

end.
