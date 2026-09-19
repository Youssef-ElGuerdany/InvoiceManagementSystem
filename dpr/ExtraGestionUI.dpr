program ExtraGestionUI;

uses
  Vcl.Forms,
  ExtraDataModule in '..\src\ExtraDataModule.pas' {DataModule1: TDataModule},
  extInterface in '..\src\extInterface.pas',
  variables in '..\src\variables.pas',
  server in '..\src\server.pas',
  config in '..\src\config.pas',
  ExtraBase in '..\src\ExtraBase.pas',
  login in '..\ui\login.pas' {Form_Login},
  home in '..\ui\home.pas' {Form_Home};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Extra Gestion';
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TForm_Login, Form_Login);
  Application.Run;
end.
