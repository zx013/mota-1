object r: Tr
  Left = 0
  Top = 0
  Caption = 'mota'
  ClientHeight = 500
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Map: TImage
    Left = 206
    Top = 27
    Width = 91
    Height = 89
  end
  object StateMap: TImage
    Left = 100
    Top = 27
    Width = 90
    Height = 89
  end
  object Menu: TImage
    Left = 100
    Top = 136
    Width = 90
    Height = 89
  end
  object Timer: TTimer
    Interval = 25
    OnTimer = TimerTimer
    Left = 688
    Top = 32
  end
  object Sound: TTimer
    OnTimer = SoundTimer
    Left = 688
    Top = 88
  end
end
