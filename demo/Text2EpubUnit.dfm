object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Text2Epub'
  ClientHeight = 145
  ClientWidth = 573
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Meiryo UI'
  Font.Style = []
  OldCreateOrder = False
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
    Left = 340
    Top = 116
    Width = 36
    Height = 15
    Caption = #29366#24907#65306
  end
  object Status: TLabel
    Left = 380
    Top = 116
    Width = 36
    Height = 15
    Caption = #24453#27231#20013
  end
  object Label4: TLabel
    Left = 8
    Top = 70
    Width = 75
    Height = 15
    Caption = 'zip.exe'#12398#22580#25152
  end
  object Button1: TButton
    Left = 472
    Top = 109
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
  object ZipExe: TEdit
    Left = 89
    Top = 67
    Width = 421
    Height = 23
    TabOrder = 5
    OnExit = ZipExeExit
  end
  object Button4: TButton
    Left = 512
    Top = 67
    Width = 53
    Height = 25
    Caption = #21442#29031'...'
    TabOrder = 6
    OnClick = Button4Click
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'txt'
    Filter = #12486#12461#12473#12488#12501#12449#12452#12523'(*.txt)|*.txt|'#12377#12409#12390#12398#12501#12449#12452#12523'(*.*)|*.*'
    Title = #12486#12461#12473#12488#12501#12449#12452#12523#12434#25351#23450#12377#12427
    Left = 28
    Top = 92
  end
end
