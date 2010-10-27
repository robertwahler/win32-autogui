object FormAbout: TFormAbout
  Left = 503
  Top = 355
  BorderStyle = bsDialog
  Caption = 'About QuickNote'
  ClientHeight = 197
  ClientWidth = 319
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LabelAbout: TLabel
    Left = 16
    Top = 16
    Width = 259
    Height = 26
    Caption = 
      'QuickNote is an example application for the RubyGem win32-guites' +
      't.'
    WordWrap = True
  end
  object LabelCopyright: TLabel
    Left = 52
    Top = 80
    Width = 214
    Height = 13
    Caption = 'Copyright 2010, GearheadForHire.com, LLC.'
  end
  object ButtonOk: TButton
    Left = 122
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = ButtonOkClick
  end
end
