object Form3: TForm3
  Left = 0
  Top = 0
  ClientHeight = 164
  ClientWidth = 153
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btn1: TButton
    Left = 40
    Top = 8
    Width = 75
    Height = 25
    Caption = #35774#32622
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 40
    Top = 39
    Width = 75
    Height = 25
    Caption = #24320#22987
    TabOrder = 1
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 40
    Top = 70
    Width = 75
    Height = 25
    Caption = #20572#27490
    TabOrder = 2
    OnClick = btn3Click
  end
  object stat1: TStatusBar
    Left = 0
    Top = 145
    Width = 153
    Height = 19
    Panels = <
      item
        Text = 'Guard'
        Width = 50
      end
      item
        Width = 50
      end>
  end
end
