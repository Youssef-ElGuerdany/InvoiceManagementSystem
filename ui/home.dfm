object Form_Home: TForm_Home
  Left = 0
  Top = 0
  Caption = 'Extra Gestion - Tableau de Bord'
  ClientHeight = 700
  ClientWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      1100
      60)
    object lblTitle: TLabel
      Left = 20
      Top = 14
      Width = 162
      Height = 30
      Caption = 'EXTRA GESTION'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clPurple
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblUserBadge: TLabel
      Left = 240
      Top = 22
      Width = 114
      Height = 15
      Caption = 'Utilisateur : MASTER'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnRefresh: TButton
      Left = 900
      Top = 14
      Width = 90
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Actualiser'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object btnLogout: TButton
      Left = 1000
      Top = 14
      Width = 90
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'D'#233'connexion'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnLogoutClick
    end
  end
  object pnlTopCards: TPanel
    Left = 0
    Top = 60
    Width = 1100
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    Color = clWhitesmoke
    ParentBackground = False
    TabOrder = 1
    object pnlCardFactures: TPanel
      Left = 15
      Top = 10
      Width = 200
      Height = 70
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblFacturesVal: TLabel
        Left = 15
        Top = 8
        Width = 170
        Height = 30
        AutoSize = False
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11753730
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblFacturesTitle: TLabel
        Left = 15
        Top = 42
        Width = 47
        Height = 15
        Caption = 'Factures'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardBL: TPanel
      Left = 230
      Top = 10
      Width = 200
      Height = 70
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblBLVal: TLabel
        Left = 15
        Top = 8
        Width = 170
        Height = 30
        AutoSize = False
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblBLTitle: TLabel
        Left = 15
        Top = 42
        Width = 93
        Height = 15
        Caption = 'Bons de livraison'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardAvoirs: TPanel
      Left = 445
      Top = 10
      Width = 200
      Height = 70
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object lblAvoirsVal: TLabel
        Left = 15
        Top = 8
        Width = 170
        Height = 30
        AutoSize = False
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAvoirsTitle: TLabel
        Left = 15
        Top = 42
        Width = 35
        Height = 15
        Caption = 'Avoirs'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardClients: TPanel
      Left = 660
      Top = 10
      Width = 200
      Height = 70
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblClientsVal: TLabel
        Left = 15
        Top = 8
        Width = 170
        Height = 30
        AutoSize = False
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16744448
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblClientsTitle: TLabel
        Left = 15
        Top = 42
        Width = 37
        Height = 15
        Caption = 'Clients'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardSuppliers: TPanel
      Left = 875
      Top = 10
      Width = 200
      Height = 70
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 4
      object lblSuppliersVal: TLabel
        Left = 15
        Top = 8
        Width = 170
        Height = 30
        AutoSize = False
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12615680
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSuppliersTitle: TLabel
        Left = 15
        Top = 42
        Width = 69
        Height = 15
        Caption = 'Fournisseurs'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlSidebar: TPanel
    Left = 0
    Top = 150
    Width = 200
    Height = 520
    Align = alLeft
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object lblNavDocs: TLabel
      Left = 16
      Top = 15
      Width = 69
      Height = 13
      Caption = 'DOCUMENTS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNavData: TLabel
      Left = 16
      Top = 195
      Width = 99
      Height = 13
      Caption = 'DONN'#201'ES DE BASE'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNavAdmin: TLabel
      Left = 16
      Top = 338
      Width = 94
      Height = 13
      Caption = 'ADMINISTRATION'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnNavFactures: TButton
      Left = 12
      Top = 35
      Width = 175
      Height = 32
      Caption = 'Factures'
      TabOrder = 0
      OnClick = NavButtonClick
    end
    object btnNavBL: TButton
      Left = 12
      Top = 72
      Width = 175
      Height = 32
      Caption = 'Bons de livraison'
      TabOrder = 1
      OnClick = NavButtonClick
    end
    object btnNavAvoirs: TButton
      Left = 12
      Top = 109
      Width = 175
      Height = 32
      Caption = 'Avoirs'
      TabOrder = 2
      OnClick = NavButtonClick
    end
    object btnNavAllDocs: TButton
      Left = 12
      Top = 146
      Width = 175
      Height = 32
      Caption = 'Tous les documents'
      TabOrder = 3
      OnClick = NavButtonClick
    end
    object btnNavClients: TButton
      Left = 12
      Top = 215
      Width = 175
      Height = 32
      Caption = 'Clients'
      TabOrder = 4
      OnClick = NavButtonClick
    end
    object btnNavSuppliers: TButton
      Left = 12
      Top = 252
      Width = 175
      Height = 32
      Caption = 'Fournisseurs'
      TabOrder = 5
      OnClick = NavButtonClick
    end
    object btnNavZones: TButton
      Left = 12
      Top = 289
      Width = 175
      Height = 32
      Caption = 'Zones'
      TabOrder = 6
      OnClick = NavButtonClick
    end
    object btnNavUsers: TButton
      Left = 12
      Top = 358
      Width = 175
      Height = 32
      Caption = 'Utilisateurs'
      TabOrder = 7
      OnClick = NavButtonClick
    end
    object btnNavAnalyses: TButton
      Left = 12
      Top = 395
      Width = 175
      Height = 32
      Caption = 'Analyses'
      TabOrder = 8
      OnClick = NavButtonClick
    end
  end
  object pnlCenter: TPanel
    Left = 200
    Top = 150
    Width = 900
    Height = 520
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object pnlGridHeader: TPanel
      Left = 0
      Top = 0
      Width = 900
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      Color = clWhitesmoke
      ParentBackground = False
      TabOrder = 0
      object lblGridTitle: TLabel
        Left = 15
        Top = 11
        Width = 232
        Height = 17
        Caption = 'Derniers Documents (20 plus r'#233'cents)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object gridDocs: TDBGrid
      Left = 0
      Top = 40
      Width = 900
      Height = 480
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsDocs
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = [fsBold]
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 670
    Width = 1100
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 4
    object lblStatus: TLabel
      Left = 15
      Top = 8
      Width = 30
      Height = 15
      Caption = 'Pr'#234't...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object dsDocs: TDataSource
    Left = 320
    Top = 260
  end
end
