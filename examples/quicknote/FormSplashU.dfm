object FormSplash: TFormSplash
  Left = 584
  Top = 496
  Width = 261
  Height = 181
  Caption = 'FormSplash'
  Color = clGrayText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LabelLoading: TLabel
    Left = 102
    Top = 67
    Width = 49
    Height = 13
    Caption = 'Loading...'
  end
  object Timer: TTimer
    Enabled = False
    Interval = 750
    OnTimer = TimerTimer
    Left = 184
    Top = 32
  end
end
