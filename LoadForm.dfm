object Form2: TForm2
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Form2'
  ClientHeight = 33
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pb1: TProgressBar
    Left = 0
    Top = 0
    Width = 400
    Height = 33
    Align = alClient
    Max = 400
    TabOrder = 0
  end
  object tmr1: TTimer
    Interval = 50
    OnTimer = tmr1Timer
    Left = 56
  end
end
