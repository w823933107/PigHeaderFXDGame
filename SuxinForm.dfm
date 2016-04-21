object Form4: TForm4
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 347
  ClientWidth = 393
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
  object pgc1: TPageControl
    Left = 0
    Top = 0
    Width = 393
    Height = 347
    ActivePage = ts1
    Align = alClient
    TabOrder = 0
    object ts1: TTabSheet
      Caption = 'BaseSetting'
      object rgWndState: TRadioGroup
        Left = 203
        Top = 3
        Width = 75
        Height = 110
        Caption = 'WindowState'
        ItemIndex = 0
        Items.Strings = (
          'Active'
          'Top')
        TabOrder = 0
      end
      object grpBaseSetting: TGroupBox
        Left = 0
        Top = 3
        Width = 197
        Height = 110
        Caption = 'BaseSetting'
        TabOrder = 1
        object lbl2: TLabel
          Left = 3
          Top = 46
          Width = 50
          Height = 13
          Caption = 'LoopDelay'
        end
        object chkAutoRunGuard: TCheckBox
          Left = 3
          Top = 23
          Width = 96
          Height = 17
          Caption = 'AutoGuard'
          TabOrder = 0
        end
        object edtLoopDelay: TEdit
          Left = 57
          Top = 46
          Width = 42
          Height = 21
          NumbersOnly = True
          TabOrder = 1
          Text = '20'
        end
        object udLoopDelay: TUpDown
          Left = 99
          Top = 46
          Width = 16
          Height = 21
          Associate = edtLoopDelay
          Position = 20
          TabOrder = 2
        end
        object chkVip: TCheckBox
          Left = 125
          Top = 46
          Width = 44
          Height = 17
          Caption = 'VIP'
          TabOrder = 3
        end
        object btnResetDefaultConfig: TButton
          Left = 69
          Top = 73
          Width = 75
          Height = 25
          Caption = 'ResetDefault'
          TabOrder = 4
          OnClick = btnResetDefaultConfigClick
        end
        object btnSaveConfig: TButton
          Left = 3
          Top = 73
          Width = 60
          Height = 25
          Caption = 'SaveConfig'
          TabOrder = 5
          OnClick = btnSaveConfigClick
        end
        object chkLogView: TCheckBox
          Left = 97
          Top = 23
          Width = 97
          Height = 17
          Caption = 'LogView'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
      end
      object grp1: TGroupBox
        Left = 0
        Top = 119
        Width = 169
        Height = 178
        Caption = 'TimeOutSetting'
        TabOrder = 2
        object lbl3: TLabel
          Left = 3
          Top = 83
          Width = 60
          Height = 13
          Caption = 'PickupGoods'
        end
        object lbl4: TLabel
          Left = 3
          Top = 26
          Width = 40
          Height = 13
          Caption = 'FindMan'
        end
        object lbl5: TLabel
          Left = 3
          Top = 64
          Width = 46
          Height = 13
          Caption = 'ManMove'
        end
        object lbl6: TLabel
          Left = 3
          Top = 45
          Width = 59
          Height = 13
          Caption = 'FindMonster'
        end
        object lbl7: TLabel
          Left = 3
          Top = 102
          Width = 41
          Height = 13
          Caption = 'RoleInfo'
        end
        object lbl8: TLabel
          Left = 3
          Top = 121
          Width = 30
          Height = 13
          Caption = 'InMap'
        end
        object edtPickUpGoodsTimeOut: TEdit
          Left = 81
          Top = 83
          Width = 72
          Height = 21
          NumbersOnly = True
          TabOrder = 0
          Text = '10000'
        end
        object edtFindManTimeOut: TEdit
          Left = 81
          Top = 26
          Width = 72
          Height = 21
          NumbersOnly = True
          TabOrder = 1
          Text = '3000'
        end
        object edtManMoveTimeOut: TEdit
          Left = 81
          Top = 64
          Width = 72
          Height = 21
          NumbersOnly = True
          TabOrder = 2
          Text = '3000'
        end
        object edtFindMonsterTimeOut: TEdit
          Left = 81
          Top = 45
          Width = 72
          Height = 21
          NumbersOnly = True
          TabOrder = 3
          Text = '3000'
        end
        object edtGetInfoTimeOut: TEdit
          Left = 81
          Top = 102
          Width = 72
          Height = 21
          NumbersOnly = True
          TabOrder = 4
          Text = '30000'
        end
        object edtInMapTimeOut: TEdit
          Left = 81
          Top = 121
          Width = 72
          Height = 21
          NumbersOnly = True
          TabOrder = 5
          Text = '180000'
        end
      end
      object grp2: TGroupBox
        Left = 175
        Top = 119
        Width = 203
        Height = 178
        Caption = 'FeatureSetting'
        TabOrder = 3
        object lbl9: TLabel
          Left = 8
          Top = 24
          Width = 71
          Height = 13
          Caption = 'WeightPercent'
        end
        object lbl10: TLabel
          Left = 118
          Top = 24
          Width = 28
          Height = 13
          Caption = 'ToSell'
        end
        object lbl11: TLabel
          Left = 8
          Top = 48
          Width = 102
          Height = 13
          Caption = 'ResetMoveStateTime'
        end
        object lbl15: TLabel
          Left = 90
          Top = 142
          Width = 31
          Height = 13
          Caption = 'MapLv'
        end
        object edtmaxZhuangbeiNum: TEdit
          Left = 81
          Top = 24
          Width = 31
          Height = 21
          Alignment = taCenter
          NumbersOnly = True
          TabOrder = 0
          Text = '70'
        end
        object edtResetMoveStateInterval: TEdit
          Left = 113
          Top = 48
          Width = 53
          Height = 21
          NumbersOnly = True
          TabOrder = 1
          Text = '30000'
        end
        object chkResetMoveState: TCheckBox
          Left = 8
          Top = 72
          Width = 97
          Height = 17
          Caption = 'ResetMoveState'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object chkRepair: TCheckBox
          Left = 8
          Top = 96
          Width = 97
          Height = 17
          Caption = 'AutoRepair'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object chkNearAdjustDirection: TCheckBox
          Left = 8
          Top = 119
          Width = 145
          Height = 17
          Caption = 'ArrivedMonsterSetDir'
          TabOrder = 4
        end
        object chkJiabaliWarning: TCheckBox
          Left = 81
          Top = 96
          Width = 119
          Height = 17
          Caption = 'BusinessmanWarning'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object chkWarning: TCheckBox
          Left = 8
          Top = 139
          Width = 58
          Height = 17
          Caption = 'Warning'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object cbbMapLv: TComboBox
          Left = 126
          Top = 139
          Width = 55
          Height = 21
          ItemIndex = 1
          TabOrder = 7
          Text = 'Risk'
          Items.Strings = (
            'Normal'
            'Risk'
            'Warrior'
            'King')
        end
      end
      object grp3: TGroupBox
        Left = 284
        Top = 3
        Width = 97
        Height = 110
        Caption = 'Offset'
        TabOrder = 4
        object lbl12: TLabel
          Left = 3
          Top = 29
          Width = 49
          Height = 13
          Caption = 'KZOffsetY'
        end
        object lbl13: TLabel
          Left = 3
          Top = 79
          Width = 48
          Height = 13
          Caption = 'SLOffsetY'
        end
        object edtKuangzhanOffsetY: TEdit
          Left = 58
          Top = 29
          Width = 24
          Height = 21
          NumbersOnly = True
          TabOrder = 0
          Text = '172'
        end
        object edtSilingOffsetY: TEdit
          Left = 58
          Top = 73
          Width = 24
          Height = 21
          NumbersOnly = True
          TabOrder = 1
          Text = '178'
        end
      end
      object stat1: TStatusBar
        Left = 0
        Top = 300
        Width = 385
        Height = 19
        Panels = <
          item
            Text = 'Operation'
            Width = 100
          end
          item
            Width = 50
          end>
      end
    end
  end
end
