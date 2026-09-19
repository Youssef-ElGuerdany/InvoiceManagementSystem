program ExtraTest;


{$ifdef OSWINDOWS}
  {$apptype console}
  {$R ..\src\mormot.win.default.manifest.res}
{$endif OSWINDOWS}

uses
  {$ifdef UNIX}
  cwstring,
  {$endif UNIX}
  sysutils,
  mormot.core.base,
  mormot.core.os,
  mormot.core.text,
  mormot.core.unicode,
  mormot.core.log,
  mormot.core.test,
  mormot.db.raw.sqlite3,
  {$ifdef USEZEOS}
  mormot.db.sql.zeos,
  {$endif USEZEOS}
  {$ifdef FPC}
  {$else}
  {$endif FPC}
  mormot.lib.openssl11,
  mormot.crypt.openssl,
  ExtraTestUnit in '..\test\ExtraTestUnit.pas',
  extInterface in '..\src\extInterface.pas',
  server in '..\src\server.pas',
  variables in '..\src\variables.pas',
  ExtraBase in '..\src\ExtraBase.pas';

{ TIntegrationTests }

type
   TIntegrationTests = class(TSynTestsLogged)
  private
    procedure test;
  protected
    class procedure DescribeCommandLine; override;
  public
    function Run: boolean; override;
  published
    procedure CoreUnits;

  end;

procedure TIntegrationTests.CoreUnits;
begin
 AddCase([
 TTestCoreBase
 ]);

end;

class procedure TIntegrationTests.DescribeCommandLine;
begin
  with Executable.Command do
  begin
    ExeDescription := 'mORMot '+ SYNOPSE_FRAMEWORK_VERSION + ' Regression Tests';
    Param('dns', 'a DNS #server name/IP for LDAP tests via Kerberos ' +
      {$ifdef OSWINDOWS}
      'with current logged user');
      {$else}
      'after kinit');
      {$endif OSWINDOWS}
    Param('ldapusr', 'the LDAP #user for --dns, e.g. name@ad.company.com');
    Param('ldappwd', 'the LDAP #password for --dns');
    Param('ntp', 'a NTP/SNTP #server name/IP to use instead of time.google.com');
    {$ifdef USE_OPENSSL}
    // refine the OpenSSL library path - RegisterOpenSsl is done in Run method
    OpenSslDefaultCrypto := Utf8ToString(
      Param('libcrypto', 'the OpenSSL libcrypto #filename'));
    OpenSslDefaultSsl := Utf8ToString(
      Param('libssl', 'the OpenSSL libssl #filename'));
    {$endif USE_OPENSSL}
  end;
end;

function TIntegrationTests.Run: boolean;
var
  cp, ssl: shortstring;
  mem: TMemoryInfo;
begin
  ssl[0] := #0;
  {$ifdef USE_OPENSSL}
  // warning: OpenSSL on Windows requires to download the right libraries
  RegisterOpenSsl;
  if OpenSslIsAvailable then
    FormatShort(' and OpenSSL %', [OpenSslVersionHexa], ssl);
  {$endif USE_OPENSSL}
  case Unicode_CodePage of
    CP_UTF8:
      cp := 'utf8';
    CODEPAGE_US:
      cp := 'WinAnsi';
  else
    FormatShort('cp%', [Unicode_CodePage], cp);
  end;
  GetMemoryInfo(mem, false);
  CustomVersions := Format(#13#10#13#10'%s [%s %s %x]'#13#10 +
    '    %s'#13#10'    on %s'#13#10'Using mORMot %s%s'#13#10'    %s',
    [OSVersionText, cp, KBNoSpace(mem.memtotal), OSVersionInt32, CpuInfoText,
     BiosInfoText, SYNOPSE_FRAMEWORK_FULLVERSION, ssl, sqlite3.Version]);
  result := inherited Run;
end;



procedure TIntegrationTests.test;
begin
  AddCase([
  ]);
end;

begin
  SetExecutableVersion(SYNOPSE_FRAMEWORK_VERSION);
  TIntegrationTests.RunAsConsole('mORMot2 Regression Tests',
    //LOG_VERBOSE +
    LOG_FILTER[lfExceptions] // + [sllErrors, sllWarning]
    ,[], Executable.ProgramFilePath + 'data');
  {$ifdef FPC_X64MM}
  WriteHeapStatus(' ', 16, 8, {compileflags=}true);
  {$endif FPC_X64MM}
end.

