unit uGame.OutMap;

interface

uses uGame.Interf, CodeSiteLogging;

type
  TOutMap = class(TGameBase, IOutMap)
  public
    procedure Handle;
  end;

implementation

{ TOutMap }

procedure TOutMap.Handle;
  procedure WeakHandle();
  var
    x, y: OleVariant;
    iRet: Integer;
  begin
    iRet := Obj.FindPic(242, 488, 800, 569, 'ĞéÈõ.bmp', clPicOffsetZero,
      0.9, 0, x, y);
    if iRet > -1 then
    begin
      CodeSite.Send('½øÈëĞéÈõ×´Ì¬²Ù×÷');
      warnning;
    end;
  end;

begin
  WeakHandle;
end;

end.
