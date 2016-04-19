unit uGameEx.Interf;

interface

uses QPlugins, uObj, System.SysUtils;

type
  // ��Ϸ����
  TGameConfig = record
    class function Create: TGameConfig; static;
  end;

  TGameBase = class
  protected
    Obj: IChargeObj;
  protected
    // �ƶ����̶���
    procedure MoveToFixPoint;
  end;

implementation

{ TGameConfig }

class function TGameConfig.Create: TGameConfig;
begin

end;

{ TGameBase }

procedure TGameBase.MoveToFixPoint;
begin
  Obj.MoveTo(5, 592);
  Obj.Delays(100, 120);
  Obj.LeftClick;
  Obj.Delays(150, 180);
end;

end.
