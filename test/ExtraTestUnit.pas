unit ExtraTestUnit;

interface

uses

  System.StrUtils,
  system.DateUtils,
  extrabase,
  variables,
  server,
  extInterface,
  System.SysUtils,

  mormot.core.text,
  mormot.core.variants,
  mormot.orm.core,
  mormot.rest.http.client,
  mormot.soa.core,
  mormot.core.base,
  mormot.core.test;

const
  ExtraClasses: array [0 .. 3] of TOrmClass = (TOrmZone, TormDoc,
    TOrmThirdParty, TormDocDetails);
  MAX_TEST = 100;

type
  TTestCoreBase = class(TSynTestCase)
  protected
  private
    Model: TormModel;
    HttpClient: TRestHttpClient;
    extraInterface: IExtraInterface;
    doc: TDocVariantData;
    remoteResult: RawUtf8;
  public


  published
    procedure start;
    procedure GetRowCountQuery;
    procedure Add;
    procedure Edit;
    procedure Delete;
    /// test the new RecordCopy() using our fast RTTI
    procedure checkExistance;

    procedure finish;

  end;

implementation

{ TTestCoreBase }

procedure TTestCoreBase.start;
begin
  Model := CreateModel;
  HttpClient := TRestHttpClient.Create('localhost', HttpPort, Model);
  HttpClient.ServiceDefine([IExtraInterface], sicShared);
  HttpClient.Services['ExtraInterface'].Get(extraInterface);

  for var I := 0 to High(ExtraClasses) do
  begin
    check(HttpClient.orm.Delete(ExtraClasses[I], 'id>0'));
    check(HttpClient.orm.TableRowCount(ExtraClasses[I]) = 0);
  end;
end;

procedure TTestCoreBase.checkExistance;
var
  zoneID: Tid;
  zone: TOrmZone;
begin

  TOrmZone.AutoFree(zone);
  zone.code := IntToStr(Random(11111));
  doc.init;

  zoneID := HttpClient.orm.Add(zone, True);

  doc.addValue('Field', 'id');
  doc.addValue('value', zoneID);

  // check if this ID is exist in zones
  check(extraInterface.CheckRecExist(ormZone, doc.ToJson));

  // Not exist id
  doc.Clear;
  doc.addValue('Field', 'id');
  doc.addValue('value', zoneID + 1);

  CheckNot(extraInterface.CheckRecExist(ormZone, doc.ToJson));

end;

procedure TTestCoreBase.Add;
var
  VDoc: TDocVariantData;
  RowId, TpID, DocId: Tid;
  TotalAmount: Double;
  docArray: TDocVariantData;
  singleDoc: Variant;
  count, I, j: Integer;
  JsonResult: RawUtf8;
begin
  doc.Clear;
  for I := 1 to MAX_TEST do  // Changed to start from 1 for more intuitive numbering
  begin
    // Zone Creation
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'code', FormatUtf8('ZONE %', [i])  // Now will create ZONE 1, ZONE 2, etc.
    ]);
    docArray.AddItem(singleDoc);
    JsonResult := extraInterface.Add(ormZone,docArray.ToJson);
    VDoc.InitJson(JsonResult);
    for j := 0 to VDoc.count - 1 do
    begin
      RowId := VDoc.Values[j];
      check(RowId > 0);
    end;

    // ThirdParty Creation
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'code', ifThen(I mod 2 = 0,
        FormatUtf8('FOURNISSEUR %', [I]),  // Will create FOURNISSEUR 1, 2, etc.
        FormatUtf8('CLIENT %', [I])),      // Will create CLIENT 1, 2, etc.
      'TypeThp', ifThen(I mod 2 = 0, '1', '2'),
      'zoneID', RowId,
      'plafond', Random(10000)
    ]);
    docArray.AddItem(singleDoc);
    JsonResult := extraInterface.Add(ormThirdParty,docArray.ToJson);
    VDoc.InitJson(JsonResult);
    TpID := VDoc.Values[0];  // Store ThirdParty ID for related documents

    // Invoice Creation
    TotalAmount := 10000 + Random(10000);
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'code', FormatUtf8('FACTURE %', [I]),  // Will create FACTURE 1, 2, etc.
      'DocDate', FormatDateTime('yyyy-mm-dd', Now), //2025-03-03

      'TotalPrice', TotalAmount,
      'DocType', Ord(dtFact),
      'plafond', Random(10000),
      'ThirdPrty', TpID
    ]);
    docArray.AddItem(singleDoc);
    JsonResult := extraInterface.Add(ormDoc,docArray.ToJson);
    VDoc.InitJson(JsonResult);
    DocId := VDoc.Values[0];  // Store Document ID for related payments

    // Payment Records Creation
    docArray.InitArray([]);

    // Payment 1: 40% Settled
    singleDoc := _ObjFast([
      'DocID', DocId,
      'code', FormatUtf8('PAIEMENT_%_1', [I]),  // Will create PAIEMENT_1_1, PAIEMENT_2_1, etc.
      'DocState', 0,
      'PaymentNature', 0,
      'PaymentNumber', FormatUtf8('CHQ%', [10000 + Random(89999)]),
      'PaymentAmount', TotalAmount * 0.4,
      'PaymentStatus', 0,
      'DueDate', FormatDateTime('yyyy-dd-mm', Now),
      'Observation', 'Paiement 1/3'
    ]);
    docArray.AddItem(singleDoc);

    // Payment 2: 30% In Progress
    singleDoc := _ObjFast([
      'DocID', DocId,
      'code', FormatUtf8('PAIEMENT_%_2', [I]),
      'DocState', 0,
      'PaymentNature', 2,
      'PaymentNumber', FormatUtf8('VIR%', [20000 + Random(89999)]),
      'PaymentAmount', TotalAmount * 0.3,
      'PaymentStatus', 5,
      'DueDate', IncDay(Now, 30),
      'Observation', 'Paiement 2/3'
    ]);
    docArray.AddItem(singleDoc);

    // Payment 3: 30% with Discrepancy
    singleDoc := _ObjFast([
      'DocID', DocId,
      'code', FormatUtf8('PAIEMENT_%_3', [I]),
      'DocState', 0,
      'PaymentNature', 2,
      'PaymentNumber', FormatUtf8('VIR%', [30000 + Random(89999)]),
      'PaymentAmount', TotalAmount * 0.3,
      'PaymentStatus', 9,
      'DueDate', IncDay(Now, 60),
      'Observation', 'Paiement 3/3 - Écart constaté'
    ]);
    docArray.AddItem(singleDoc);

    JsonResult := extraInterface.Add(ormDocDetails,docArray.ToJson);
    VDoc.InitJson(JsonResult);

    // Credit Note (Avoir) Creation
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'code', FormatUtf8('AVOIR %', [I]),  // Will create AVOIR 1, 2, etc.
      'DocDate', Now,
      'TotalPrice', TotalAmount * 0.1,
      'DocType', Ord(dtAv),
      'ThirdPrty', TpID
    ]);
    docArray.AddItem(singleDoc);
    JsonResult := extraInterface.Add(ormDoc,docArray.ToJson);
    VDoc.InitJson(JsonResult);
    DocId := VDoc.Values[0];

    // Credit Note Payment
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'DocID', DocId,
      'code', FormatUtf8('AVOIR_PAIEMENT_%', [I]),  // Will create AVOIR_PAIEMENT_1, 2, etc.
      'DocState', 1,
      'PaymentNature', 2,
      'PaymentNumber', FormatUtf8('VIR%', [40000 + Random(89999)]),
      'PaymentAmount', TotalAmount * 0.1,
      'PaymentStatus', 0,
      'DueDate', IncDay(Now, 15),
      'Observation', 'Avoir régularisation'
    ]);
    docArray.AddItem(singleDoc);
    JsonResult := extraInterface.Add(ormDocDetails,docArray.ToJson);
    VDoc.InitJson(JsonResult);

    // Delivery Note (BL) Creation
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'code', FormatUtf8('BL %', [I]),  // Will create BL 1, 2, etc.
      'DocDate', Now,
      'TotalPrice', TotalAmount,
      'DocType', Ord(dtBL),
      'ThirdPrty', TpID
    ]);
    docArray.AddItem(singleDoc);
    JsonResult := extraInterface.Add(ormDoc,docArray.ToJson);
    VDoc.InitJson(JsonResult);
    DocId := VDoc.Values[0];

    // Delivery Note Record
    docArray.InitArray([]);
    singleDoc := _ObjFast([
      'DocID', DocId,
      'code', FormatUtf8('BL_DETAIL_%', [I]),  // Will create BL_DETAIL_1, 2, etc.
      'DocState', 2,
      'PaymentNature', 5,
      'PaymentNumber', '',
      'PaymentAmount', 0,
      'PaymentStatus', 8,
      'DueDate', Now,
      'Observation', 'Bon de livraison sans paiement'
    ]);
    docArray.AddItem(singleDoc);

    JsonResult := extraInterface.Add(ormDocDetails,docArray.ToJson);
    VDoc.InitJson(JsonResult);
  end;
end;

procedure TTestCoreBase.Edit;
var
  zone : TOrmZone;
  DocRes : TDocVariantData;
begin

  ///
  ///   enum of Classes (ormZone , ormDoc, ormDocDetails, ormThirdParty)
  ///

  // TEST UPDATE ZONE 'Exist value'
  doc.Init;
  zone := TOrmZone.Create(HttpClient.Orm,'ID>0');
  zone.code := 'ZONE2';// exiting value in table
  doc.AddValue('id',zone.ID);
  doc.AddValue('code',zone.code);
  doc.AddValue('ormClass',OrmZone);

  RemoteResult := extraInterface.Edit(doc.ToJson);

  DocRes.InitJson(remoteResult);
  // test Update first zone with
  check (Not DocRes.B['status']);
  // status is false because this value already exist 'Zone_2'
  // add other checks

  // case 2 : check if the zone is not exist


end;

procedure TTestCoreBase.Delete;
var
  str : rawutf8;
  MaxID : TID;
  remoteResult : RawUtf8;
  doc,docArray : TdocVariantData;
  rowid : tid;
  singleDoc : Variant ;
begin

  ///
  /// test delete Zones
  ///

  MaxID := HttpClient.Orm.TableMaxID(TormZone);
  doc.Init;
  doc.AddValue('ID',MaxID);
  doc.AddValue('ormClass',ormZone);
  remoteResult :=extraInterface.Delete(doc.ToJson);

  doc := TDocVariantData(_Json(remoteResult));
  CheckNOT( doc.B['status']);
  check(doc.S['message']= SDependencyExistsZone);
  str := HttpClient.Orm.OneFieldValue(TOrmZone,'CODE',FormatUtf8('ID=%',[MaxID]));
  Check(str <> '');

  // CREATE A NEW zone who's never been used before and delete them
  // Zone Creation
  docArray.InitArray([]);

  singleDoc := _ObjFast([
        'code', FormatUtf8('ZONE%', [count + 1]),
        'ormClass',Ord(ormZone)
         ]);
  docArray.AddItem(singleDoc);

  remoteResult := extraInterface.Add(ormZone,docArray.ToJson);
  doc.InitJson(remoteResult);
  RowId := doc.Values[0];
  check(RowId > 0);



  //delete this zone Using RowID
  doc.clear;
  doc.init;
  doc.AddValue('ID',RowId);
  doc.AddValue('ormClass',ormZone);
  remoteResult :=extraInterface.Delete(doc.ToJson);
  doc := TDocVariantData(_Json(remoteResult));
  Check(doc.B['status']);
  Check(doc.s['message']= SDeleteSuccess);



  ///
  /// test delete thirdParties
  ///

  MaxID := HttpClient.Orm.TableMaxID(TOrmThirdParty);
  doc.Init;
  doc.AddValue('ID',MaxID);
  doc.AddValue('ormClass',ormThirdParty);
  remoteResult :=extraInterface.Delete(doc.ToJson);

  doc := TDocVariantData(_Json(remoteResult));
  CheckNOT( doc.B['status']);
  check(doc.S['message']= SDependencyExistsThirdParty);
  str := HttpClient.Orm.OneFieldValue(TOrmThirdParty,'CODE',FormatUtf8('ID=%',[MaxID]));
  Check(str <> '');

  // adding new thirdPartie zho's never been used before

  docArray.InitArray([]);
  singleDoc := _ObjFast([
      'code', 'This One Should deleted',
      'TypeThp', '1',
      'ZoneID', RowId,
      'Plafond', Random(10000)
      ]);
  docArray.AddItem(singleDoc);
  remoteResult := extraInterface.Add(ormThirdparty,docArray.ToJson);
  doc.InitJson(remoteResult);

  check(doc.Values[0] > 0);
  RowId := doc.Values[0];


  //delete this thirdPartiy Using RowID
  doc.Clear;
  doc.init;
  doc.AddValue('ID',RowId);
  doc.AddValue('ormClass',ormZone);

  //delete
  remoteResult :=extraInterface.Delete(doc.ToJson);

  doc := TDocVariantData(_Json(remoteResult));
  Check(doc.B['status']);
  Check(doc.s['message']= SDeleteSuccess);

  ///
  ///  test delete Doc
  ///

  MaxID := HttpClient.Orm.TableMaxID(TOrmDoc);
  doc.Init;
  doc.AddValue('ID',MaxID);
  doc.AddValue('ormClass',ormDoc);
  //delete
  remoteResult :=extraInterface.Delete(doc.ToJson);

  doc := TDocVariantData(_Json(remoteResult));
  Check( doc.B['status']);
  check(doc.S['message']= SDeleteSuccess);
  str := HttpClient.Orm.OneFieldValue(TOrmDoc,'CODE',FormatUtf8('ID=%',[MaxID]));
  Check(str = '');

  // Test give this delete fuction ID 0
  doc.Init;
  doc.AddValue('ID',0);
  doc.AddValue('ormClass',ormDoc);
  //delete
  remoteResult :=extraInterface.Delete(doc.ToJson);
  doc.InitJson(remoteResult);
  CheckNot(doc.B['Status']);
  Check(doc.S['message']= SDeleteFailed);

  ///
  ///  test delete documents Details
  ///

  MaxID := HttpClient.Orm.TableMaxID(TOrmDocDetails);
  doc.Init;
  doc.AddValue('ID',MaxID);
  doc.AddValue('ormClass',ormDocDetails);
   //delete
  remoteResult :=extraInterface.Delete(doc.ToJson);

  doc := TDocVariantData(_Json(remoteResult));
  Check( doc.B['status']);
  check(doc.S['message']= SDeleteSuccess);
  str := HttpClient.Orm.OneFieldValue(TOrmDocDetails,'CODE',FormatUtf8('ID=%',[MaxID]));
  Check(str = '');

   // Test give this delete fuction ID 0
  doc.Init;
  doc.AddValue('ID',0);
  doc.AddValue('ormClass',ormDocDetails);
  //delete
  remoteResult := extraInterface.Delete(doc.ToJson);

  doc.InitJson(remoteResult);

  CheckNot(doc.B['Status']);
  Check(doc.S['message']= SDeleteFailed);

  // test delete Zone where a ThirdPartie use it

 // ThirdParty Creation
  docArray.InitArray([]);
  RowId := HttpClient.TableMaxID(TOrmZone);
  singleDoc := _ObjFast([
      'code',FormatUtf8('SARL DISTR% ', [0000]),
      'TypeThp', '1',
      'zoneID', RowId,
      'plafond', Random(10000)
      ]);
  docArray.AddItem(singleDoc);
  RemoteResult := extraInterface.Add(ormThirdparty,docArray.ToJson);
  doc.InitJson(RemoteResult);
  check(doc.Values[0] > 0);

  // take the ZoneId of this ThirdParty

  doc.Clear;
  doc.init;
  doc.AddValue('id',RowId);
  doc.AddValue('ormClass',ormZone);
  // this zone can't deleted because it's used by the previous thirdParty

  remoteResult := extraInterface.Delete(doc.ToJson);

  doc.InitJson(remoteResult);
  CheckNot(doc.B['status']);
  Check(doc.S['message'] = SDependencyExistsZone);

end;

procedure TTestCoreBase.finish;
begin
  Model.Free;
  extraInterface := nil;
  HttpClient.Free;
end;


procedure TTestCoreBase.GetRowCountQuery;
var s : RawUtf8;
   docArray : TdocVariantData;
   singleDoc :   variant  ;
begin

  docArray.InitArray([]);
    singleDoc := _ObjFast([
      'code', FormatUtf8('ZONE X', [])  // Now will create ZONE 1, ZONE 2, etc.
    ]);
    docArray.AddItem(singleDoc);
    extraInterface.Add(ormZone,docArray.ToJson);
   s := extraInterface.GetRowCountQuery('zone','');
   docArray.Clear;
   docArray.InitJson(s);
   var j : RawUtf8;
   j := docArray.Value[0];
   j := _Json(j).RowCount;
end;

end.
