object FormMain: TFormMain
  Left = 848
  Top = 217
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
  OnCloseQuery = FormCloseQuery
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
    ScrollBars = ssVertical
    TabOrder = 1
    OnChange = MemoChange
  end
  object ActionList: TActionList
    Left = 194
    Top = 244
    object ActionFileExit: TAction
      Caption = 'E&xit'
      OnExecute = ActionFileExitExecute
    end
    object ActionHelpAbout: TAction
      Caption = '&About'
      OnExecute = ActionHelpAboutExecute
    end
    object ActionFileNew: TAction
      Caption = '&New'
      OnExecute = ActionFileNewExecute
    end
    object ActionFileSave: TAction
      Caption = '&Save'
      OnExecute = ActionFileSaveExecute
      OnUpdate = ActionFileSaveUpdate
    end
    object ActionFileOpen: TAction
      Caption = '&Open'
      OnExecute = ActionFileOpenExecute
    end
    object ActionFileSaveAs: TAction
      Caption = 'Save &As'
      OnExecute = ActionFileSaveAsExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 136
    Top = 244
    object MenuFile: TMenuItem
      Caption = '&File'
      object MenuFileNew: TMenuItem
        Action = ActionFileNew
      end
      object MenuFileOpen: TMenuItem
        Action = ActionFileOpen
      end
      object MenuFileSave: TMenuItem
        Action = ActionFileSave
      end
      object MenuFileSaveAs: TMenuItem
        Action = ActionFileSaveAs
      end
      object MenuFileDividerAfterSaveAs: TMenuItem
        Caption = '-'
      end
      object MenuExit: TMenuItem
        Action = ActionFileExit
      end
    end
    object MenuHelp: TMenuItem
      Caption = '&Help'
      object MenuHelpAbout: TMenuItem
        Action = ActionHelpAbout
      end
    end
  end
  object XPManifest: TXPManifest
    Left = 79
    Top = 245
  end
  object FileOpenDialog: TOpenDialog
    Left = 168
    Top = 192
  end
  object FileSaveDialog: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 80
    Top = 192
  end
end
