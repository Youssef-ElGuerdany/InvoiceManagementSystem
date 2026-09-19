object Form_Login: TForm_Login
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Extra Gestion - Authentification'
  ClientHeight = 440
  ClientWidth = 380
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object pnlCard: TPanel
    AlignWithMargins = True
    Left = 20
    Top = 20
    Width = 340
    Height = 400
    Margins.Left = 20
    Margins.Top = 20
    Margins.Right = 20
    Margins.Bottom = 20
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 16
      Top = 16
      Width = 171
      Height = 37
      Caption = 'Extra Gestion'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clPurple
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 18
      Top = 57
      Width = 231
      Height = 15
      Caption = 'Gestion de facturation et pi'#232'ces comptables'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblUser: TLabel
      Left = 18
      Top = 96
      Width = 64
      Height = 15
      Caption = 'Utilisateur :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPass: TLabel
      Left = 18
      Top = 165
      Width = 79
      Height = 15
      Caption = 'Mot de passe :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblLoginError: TLabel
      Left = 18
      Top = 230
      Width = 300
      Height = 30
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object lblFooter: TLabel
      Left = 18
      Top = 368
      Width = 218
      Height = 13
      Caption = #169' 2025 ExtraSolution. Tous droits r'#233'serv'#233's.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object edtUsername: TEdit
      Left = 18
      Top = 117
      Width = 300
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'master'
    end
    object edtPassword: TEdit
      Left = 18
      Top = 186
      Width = 300
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      PasswordChar = '*'
      TabOrder = 1
      Text = 'master'
    end
    object btnLogin: TButton
      Left = 18
      Top = 265
      Width = 300
      Height = 38
      Caption = 'Se connecter'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnLoginClick
    end
    object btnReset: TButton
      Left = 18
      Top = 312
      Width = 300
      Height = 35
      Cancel = True
      Caption = 'Quitter'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnResetClick
    end
  end
end
