unit server;

interface

uses
  ExtraBase,


  mormot.rest.server,
  mormot.orm.core,
  mormot.rest.core,
  mormot.rest.sqlite3,
  mormot.db.raw.sqlite3.static,

  mormot.rest.http.server;

type
  TServerDb = class(TRestServerdb)
  published

    // constructor create(aModel : TormModel;const aDbFileName : TFileName);
    HttpServer : TRestHttpServer;
  end;

var
  ormClasses: Array of TormClass;

function CreateModel: TormModel;

implementation


function CreateModel: TormModel;
begin
  ormClasses := [
   TormUSer,
   TOrmZone,
   TOrmThirdParty,
   TOrmDoc,
   TOrmDocDetails,
   TOrmMyHistory];
   result := TormModel.Create(ormClasses);

end;
end.
