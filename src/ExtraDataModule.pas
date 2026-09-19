unit ExtraDataModule;

interface

uses
  System.SysUtils, System.Classes,
  mormot.rest.http.client,
  mormot.orm.core,
  mormot.soa.core,
  mormot.core.variants,
  server,

  config,
  ExtInterface;  // Add any other interface units as needed

type
  TDataModule1 = class(TDataModule)
  private

    FModel: TOrmModel;
    FService: IExtraInterface;

  public
    CurrentUser: string;
    CurrentUserPermissions: Boolean;
    FHttpClient: TRestHttpClient;
    procedure InitializeClient;
    procedure FinalizeClient;
    property Service: IExtraInterface  read FService;

  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

procedure TDataModule1.InitializeClient;
var HttpPort : String;
begin
  HttpPort:=  VariantToString(RemoteConfig.HttpPort);
  FModel := CreateModel;
  FHttpClient := TRestHttpClient.Create('localhost',HttpPort , FModel);
  FHttpClient.ServiceDefine([IExtraInterface], sicShared);// i forget to do this modification
  FHttpClient.Services['ExtraInterface'].Get(FService);

end;

procedure TDataModule1.FinalizeClient;
begin
  FHttpClient.Free;
  FModel.Free;
end;

end.

