unit login;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  ExtraBase,
  mormot.core.base,
  mormot.core.text;

type
  TForm_Login = class(TForm)
    pnlCard: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    lblUser: TLabel;
    lblPass: TLabel;
    edtUsername: TEdit;
    edtPassword: TEdit;
    lblLoginError: TLabel;
    btnLogin: TButton;
    btnReset: TButton;
    lblFooter: TLabel;
    procedure btnLoginClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure AddDefaultMasterAccount;
    procedure InitializeUserSession(const User: TOrmUser);
  public
  end;

var
  Form_Login: TForm_Login;

implementation

{$R *.dfm}

uses
  home, ExtraDataModule;

procedure TForm_Login.FormCreate(Sender: TObject);
begin
  try
    DataModule1.InitializeClient;
    AddDefaultMasterAccount;
  except
    on E: Exception do
      lblLoginError.Caption := 'Erreur de connexion serveur: ' + E.Message;
  end;
end;

procedure TForm_Login.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    DataModule1.FinalizeClient;
  except
  end;
  Action := caFree;
end;

procedure TForm_Login.btnLoginClick(Sender: TObject);
var
  User: TOrmUser;
  check: RawUtf8;
begin
  if not Assigned(DataModule1.FHttpClient) then
  begin
    lblLoginError.Caption := 'Serveur non connecte. Verifiez ExtraService.';
    Exit;
  end;

  User := TOrmUser.Create;
  try
    check := FormatUtf8('Username=% AND PasswordHash=%', [QuotedStr(edtUsername.Text), QuotedStr(edtPassword.Text)]);
    if DataModule1.FHttpClient.orm.Retrieve(check, User) then
    begin
      InitializeUserSession(User);
      if not Assigned(Form_Home) then
        Application.CreateForm(TForm_Home, Form_Home);
      Form_Home.Show;
      edtPassword.Clear;
      lblLoginError.Caption := '';
      Self.Hide;
    end
    else
    begin
      lblLoginError.Caption := 'Identifiant ou mot de passe incorrect.';
      lblLoginError.Font.Color := clRed;
      edtUsername.SetFocus;
    end;
  finally
    User.Free;
  end;
end;

procedure TForm_Login.btnResetClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm_Login.AddDefaultMasterAccount;
var
  MasterUser: TOrmUser;
begin
  if not Assigned(DataModule1.FHttpClient) then
    Exit;
  MasterUser := TOrmUser.Create;
  try
    if not DataModule1.FHttpClient.Orm.Retrieve('Username=''MASTER''', MasterUser) then
    begin
      MasterUser.Username := 'MASTER';
      MasterUser.PasswordHash := 'MASTER';
      MasterUser.HavePermission := True;
      DataModule1.FHttpClient.Add(MasterUser, True);
    end;
  finally
    MasterUser.Free;
  end;
end;

procedure TForm_Login.InitializeUserSession(const User: TOrmUser);
begin
  DataModule1.CurrentUser := UTF8ToString(User.Username);
  DataModule1.CurrentUserPermissions := User.HavePermission;
end;

end.


