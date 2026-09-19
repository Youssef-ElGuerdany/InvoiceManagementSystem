program ExtraService;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  mormot.app.daemon,
  mormot.soa.core,
  mormot.core.base,
  mormot.core.os,
  mormot.core.log,
  mormot.db.raw.sqlite3,
  mormot.orm.core,
  mormot.rest.http.server,
  mormot.rest.server,
  mormot.core.variants,
  ExtraBase in '..\src\ExtraBase.PAS',
  implement in '..\src\implement.pas',
  server in '..\src\server.pas',
  variables in '..\src\variables.pas',
  extInterface in '..\src\extInterface.pas',
  config in '..\src\config.pas';

type
  TSampleDaemonSettings = class(TSynDaemonSettings)
  public
    constructor Create; override;
  end;

  TSampleDaemon = class(TSynDaemon)
  protected
    FHttpServer: TRestHttpServer;
    FServer: TServerDb;
  public
    constructor Create(aSettingsClass: TSynDaemonSettingsClass; const
        aWorkFolder, aSettingsFolder, aLogFolder: TFileName; const
        aSettingsExt: TFileName = '.settings'; const aSettingsName: TFileName =
        '');
    procedure Start; override;
    procedure Stop; override;
  end;


var
  LogFamily: TSynLogFamily;
  Model: TOrmModel;
  ExtraServer: TServerDb;
  HttpServer: TRestHttpServer;
  SampleDaemon: TSampleDaemon;

constructor TSampleDaemonSettings.Create;
begin
  inherited Create;
  Log := LOG_VERBOSE;
end;


constructor TSampleDaemon.Create(aSettingsClass: TSynDaemonSettingsClass; const
    aWorkFolder, aSettingsFolder, aLogFolder: TFileName; const aSettingsExt:
    TFileName = '.settings'; const aSettingsName: TFileName = '');
begin
  inherited Create(aSettingsClass, aWorkFolder, aSettingsFolder, aLogFolder, aSettingsExt, aSettingsName);

end;

procedure TSampleDaemon.Start;
var filename:RawUtf8;
begin
  SQLite3Log.Enter(self);
  Model := CreateModel;
  ExtraServer := TServerDb.Create(Model, ChangeFileExt(Executable.ProgramFileName,'.db'));
 // ExtraServer := TServerDb.Create(Model,filename);
  ExtraServer.DB.Synchronous := smOff;
  ExtraServer.DB.LockingMode := lmExclusive;
  ExtraServer.Server.CreateMissingTables;

  HttpServer :=
  TRestHttpServer.Create(HttpPort,[ExtraServer],'+',useHttpApiRegisteringURI,4 );
 // HttpServer.AccessControlAllowOrigin := '*';
//  SQLite3Log.Add.Log(sllInfo, 'HttpServer started at Port: ' + HttpPort);
  ExtraServer.ServiceDefine(TService,[IExtraInterface],sicshared);
end;

procedure TSampleDaemon.Stop;
begin
  SQLite3Log.Enter(self);
  try
    try
      HttpServer.Free;
//      SQLite3Log.Add.Log(sllInfo, 'HttpServer stopped');
    except
//      SQLite3Log.Add.Log(sllWarning, 'Error shutting down HttpServer');
    end;
  finally
    try
      ExtraServer.Free;
//      SQLite3Log.Add.Log(sllInfo, 'Sample Server stopped');
    except
//      SQLite3Log.Add.Log(sllWarning, 'Error shutting down Sample Server');
    end;
  Model.Free;
  end;
end;

begin
  LogFamily := SQLite3Log.Family;
  LogFamily.Level := LOG_VERBOSE;
  LogFamily.PerThreadLog := ptIdentifiedInOnFile;
  LogFamily.EchoToConsole := LOG_VERBOSE;
  SampleDaemon := TSampleDaemon.Create(TSampleDaemonSettings, Executable.ProgramFilePath, '', '');
  SQLite3Log.Add.Log(sllInfo, 'Daemon started, listening on port '  + HttpPort);
  try
    SampleDaemon.CommandLine;
  finally
    SQLite3Log.Add.Log(sllInfo, 'Daemon shut down');
  end;

end.
