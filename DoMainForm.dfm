object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 119
  ClientWidth = 126
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnStart: TButton
    Left = 24
    Top = 39
    Width = 75
    Height = 25
    Caption = #24320#22987
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 24
    Top = 70
    Width = 75
    Height = 25
    Caption = #20572#27490
    TabOrder = 1
    OnClick = btnStopClick
  end
  object btnConfig: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Caption = #35774#32622
    TabOrder = 2
    OnClick = btnConfigClick
  end
end
