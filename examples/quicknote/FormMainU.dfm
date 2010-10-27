object FormMain: TFormMain
  Left = 543
  Top = 302
  Width = 248
  Height = 366
  Caption = 'QuickNote'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 293
    Width = 240
    Height = 19
    Panels = <>
  end
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 240
    Height = 293
    Align = alClient
    TabOrder = 1
  end
  object ActionList: TActionList
    Left = 194
    Top = 244
    object ActionFileExit: TAction
      Caption = 'E&xit'
      OnExecute = ActionFileExitExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 136
    Top = 244
    object MenuFile: TMenuItem
      Caption = '&File'
      object MenuExit: TMenuItem
        Action = ActionFileExit
      end
    end
  end
  object XPManifest: TXPManifest
    Left = 79
    Top = 245
  end
end
