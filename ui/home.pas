unit home;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Data.DB,
  ExtraBase,
  mormot.core.base,
  mormot.core.text,
  mormot.core.variants,
  mormot.core.data,
  mormot.db.rad.ui.orm;

type
  TForm_Home = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblUserBadge: TLabel;
    btnRefresh: TButton;
    btnLogout: TButton;
    pnlTopCards: TPanel;
    pnlCardFactures: TPanel;
    lblFacturesVal: TLabel;
    lblFacturesTitle: TLabel;
    pnlCardBL: TPanel;
    lblBLVal: TLabel;
    lblBLTitle: TLabel;
    pnlCardAvoirs: TPanel;
    lblAvoirsVal: TLabel;
    lblAvoirsTitle: TLabel;
    pnlCardClients: TPanel;
    lblClientsVal: TLabel;
    lblClientsTitle: TLabel;
    pnlCardSuppliers: TPanel;
    lblSuppliersVal: TLabel;
    lblSuppliersTitle: TLabel;
    pnlSidebar: TPanel;
    lblNavDocs: TLabel;
    btnNavFactures: TButton;
    btnNavBL: TButton;
    btnNavAvoirs: TButton;
    btnNavAllDocs: TButton;
    lblNavData: TLabel;
    btnNavClients: TButton;
    btnNavSuppliers: TButton;
    btnNavZones: TButton;
    lblNavAdmin: TLabel;
    btnNavUsers: TButton;
    btnNavAnalyses: TButton;
    pnlCenter: TPanel;
    pnlGridHeader: TPanel;
    lblGridTitle: TLabel;
    gridDocs: TDBGrid;
    pnlFooter: TPanel;
    lblStatus: TLabel;
    dsDocs: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure NavButtonClick(Sender: TObject);
  private
    procedure LoadHome;
    function GetCountFromJson(const AJson: RawUtf8): string;
  public
  end;

var
  Form_Home: TForm_Home;

implementation

{$R *.dfm}

uses
  ExtraDataModule,
  login;

procedure TForm_Home.FormCreate(Sender: TObject);
begin
  Caption := 'Extra Gestion - Tableau de Bord';
end;

procedure TForm_Home.FormShow(Sender: TObject);
begin
  lblUserBadge.Caption := 'Utilisateur : ' + DataModule1.CurrentUser;
  if not DataModule1.CurrentUserPermissions then
  begin
    btnNavUsers.Enabled := False;
    btnNavAnalyses.Enabled := False;
  end
  else
  begin
    btnNavUsers.Enabled := True;
    btnNavAnalyses.Enabled := True;
  end;
  LoadHome;
end;

function TForm_Home.GetCountFromJson(const AJson: RawUtf8): string;
var
  doc: TDocVariantData;
  v: RawUtf8;
begin
  Result := '0';
  if AJson = '' then
    Exit;
  try
    doc.InitJson(AJson);
    if doc.Count > 0 then
    begin
      v := VariantToUtf8(doc.Value[0]);
      Result := UTF8ToString(_Json(v).RowCount);
    end;
  except
    Result := '0';
  end;
end;

procedure TForm_Home.LoadHome;
var
  checkQuery: RawUtf8;
  resJson: RawUtf8;
begin
  if not Assigned(DataModule1.Service) then
  begin
    lblStatus.Caption := 'Service non disponible.';
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    // 1. Documents recents
    try
      checkQuery := DataModule1.Service.GetDocuments('ORDER BY d.ModifDate DESC LIMIT 20');
      if Assigned(dsDocs.DataSet) then
        dsDocs.DataSet.Free;
      dsDocs.DataSet := TOrmTableDataSet.CreateFromJson(Self, checkQuery);
      gridDocs.DataSource := dsDocs;
    except
      on E: Exception do
        lblStatus.Caption := 'Erreur documents: ' + E.Message;
    end;

    // 2. Statistiques KPI
    // Fournisseurs
    resJson := DataModule1.Service.GetRowCountQuery('ThirdParty', FormatUtf8(' And TypeThp=%', [ord(tpSupplier)]));
    lblSuppliersVal.Caption := GetCountFromJson(resJson);

    // Clients
    resJson := DataModule1.Service.GetRowCountQuery('ThirdParty', FormatUtf8(' And TypeThp=%', [ord(tpCustomer)]));
    lblClientsVal.Caption := GetCountFromJson(resJson);

    // BL
    resJson := DataModule1.Service.GetRowCountQuery('doc', FormatUtf8(' And docType=%', [ord(dtBL)]));
    lblBLVal.Caption := GetCountFromJson(resJson);

    // Factures
    resJson := DataModule1.Service.GetRowCountQuery('doc', FormatUtf8(' And docType=%', [ord(dtFact)]));
    lblFacturesVal.Caption := GetCountFromJson(resJson);

    // Avoirs
    resJson := DataModule1.Service.GetRowCountQuery('doc', FormatUtf8(' And docType=%', [ord(dtAv)]));
    lblAvoirsVal.Caption := GetCountFromJson(resJson);

    lblStatus.Caption := 'Pret | Connecte au serveur ExtraService (port 11111) | ' + FormatDateTime('dd/mm/yyyy hh:nn', Now);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm_Home.btnRefreshClick(Sender: TObject);
begin
  LoadHome;
end;

procedure TForm_Home.btnLogoutClick(Sender: TObject);
begin
  Close;
  if Assigned(Form_Login) then
    Form_Login.Show;
end;

procedure TForm_Home.NavButtonClick(Sender: TObject);
var
  btn: TButton;
begin
  if Sender is TButton then
  begin
    btn := TButton(Sender);
    ShowMessage('Module ' + btn.Caption + ' sera integre a la prochaine etape de conversion.');
  end;
end;

end.
