object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Text2Epub'
  ClientHeight = 111
  ClientWidth = 573
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Meiryo UI'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 58
    Height = 15
    Caption = #20837#21147#12501#12449#12452#12523
  end
  object Label2: TLabel
    Left = 8
    Top = 41
    Width = 62
    Height = 15
    Caption = 'Epub'#12398#22580#25152
  end
  object Label3: TLabel
    Left = 344
    Top = 84
    Width = 36
    Height = 15
    Caption = #29366#24907#65306
  end
  object Status: TLabel
    Left = 384
    Top = 84
    Width = 36
    Height = 15
    Caption = #24453#27231#20013
  end
  object Button1: TButton
    Left = 476
    Top = 77
    Width = 89
    Height = 25
    Caption = 'Epub'#20316#25104'(&E)'
    TabOrder = 0
    OnClick = Button1Click
  end
  object TxtFile: TEdit
    Left = 89
    Top = 9
    Width = 421
    Height = 23
    TabOrder = 1
  end
  object Button2: TButton
    Left = 512
    Top = 8
    Width = 53
    Height = 25
    Caption = #21442#29031'...'
    TabOrder = 2
    OnClick = Button2Click
  end
  object EpubDir: TEdit
    Left = 89
    Top = 38
    Width = 421
    Height = 23
    TabOrder = 3
  end
  object Button3: TButton
    Left = 512
    Top = 36
    Width = 53
    Height = 25
    Caption = #21442#29031'...'
    TabOrder = 4
    OnClick = Button3Click
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'txt'
    Filter = #12486#12461#12473#12488#12501#12449#12452#12523'(*.txt)|*.txt|'#12377#12409#12390#12398#12501#12449#12452#12523'(*.*)|*.*'
    Title = #12486#12461#12473#12488#12501#12449#12452#12523#12434#25351#23450#12377#12427
    Left = 32
    Top = 56
  end
end
