unit implement;

interface

uses
  variables,
  ExtraBase,
  ExtInterface,
  mormot.core.unicode,
  mormot.core.text,
  mormot.core.variants,

  mormot.soa.server,
  mormot.core.base,
  mormot.rest.core,
  mormot.core.rtti,
  mormot.orm.core;


Type

  TGenericResponse = record
    status: boolean;
    message: string;
    data: RawUtf8;
  end;

  TUserManager = class(TInjectableObjectRest,IUserManager)
  public
    function Login(const Username, Password: RawUtf8): Boolean;
    function AddUser(const Username, Password: RawUtf8;HavePermission: Boolean): Boolean;
    function GetUserPermissions(const Username: RawUtf8): TPermissions;
  end;


  TService = class(TInjectableObjectRest, IExtraInterface)
  public

    function Add(domaineType: TORMType;JData: RawUtf8): RawUtf8;
    function Edit(JData:RawUtf8):RawUtf8;
    function Delete(JData: RawUtf8):RawUtf8;
//    function CheckReqFields(aData:RawUtf8):Boolean;

    function GetUsers(aWhere:RawUtf8):RawUtf8;
    function GetZones(aWhere: RawUtf8)     : RawUtf8;
    function GetThirdPartys(aWhere:RawUtf8): RawUtf8;
    function GetDocuments(aWhere: RawUtf8) : RawUtf8;
    function GetDocDetail(aWhere: RawUtf8) : RawUtf8;

    //charts
    function GetTotalSales:RawUtf8;
    function UsersAnaylse:RawUtf8;
    function GetTotales: RawUtf8;

    function CheckRecExist(classType :TORMType ; JData: RawUtf8): Boolean;
    function GetRowCountQuery( TableName, Condition: RawUtf8): RawUtf8;
  end;

  { TService }

implementation

function TService.Add(domaineType: TORMType;JData: RawUtf8): RawUtf8;
var
  orm: TOrm;
  doc, resultArray: TDocVariantData;
  AID: TID;
  I : integer;
begin
  resultArray.InitArray([]);
  doc.InitJson(JData);
  for i := 0 to doc.Count - 1 do
  begin
    orm := CreateOrmInstance(TORMType(domaineType));
    orm.FillFrom(doc.Values[i]);
    AID := Self.server.orm.Add(orm, True);
    if AID > 0 then
      resultArray.AddItem(AID)
    else
      resultArray.AddItem(AId);
  end;
  Result := resultArray.ToJson;
end;

function TService.Edit( JData: RawUtf8): RawUtf8;
var
  Orm, ExistingOrm: TOrm;
  doc, response: TDocVariantData;
  code: RawUtf8;
  id: TID;
begin
  response.Init;
  try
    doc.InitJson(JData);
    if not doc.IsObject then
    begin
      response.AddValue('message', 'Format JSON invalide');
      Exit(response.ToJson());
    end;
    Orm := CreateOrmInstance(TORMType(doc.I['ormClass']));
    if Orm = nil then
    begin
      response.AddValue('message', 'Type d''objet non reconnu');
      Exit(response.ToJson());
    end;

    try
      Orm.FillFrom(JData);
      id := doc.I['ID'];
      code := doc.S['code'];
      ExistingOrm := CreateOrmInstance(TORMType(doc.I['ormClass']));
      try
        if Self.Server.Orm.Retrieve(
           FormatUtf8('code=% and ID<>%', [QuotedStr(code), id]), ExistingOrm) then
        begin
          if (TORMType(doc.I['ormClass']) <> ormDocDetails ) AND (TORMType(doc.I['ormClass']) <> ormUsers )then
          begin
            response.AddValue('status', false);
            response.AddValue('message', 'Code ' + code + ' déjà existant');
            Exit(response.ToJson());
          end;
        end;

        // If the code is unique, proceed to update
        if Self.Server.Orm.Update(Orm) then
        begin
          response.AddValue('status', true);
          response.AddValue('message', 'Mise à jour réussie');
          response.AddValue('data', ObjectToJson(Orm));
        end
        else
        begin
          response.AddValue('message', 'Échec de la mise à jour');
        end;

      finally
        ExistingOrm.Free;
      end;

    finally
      Orm.Free;
    end;

  except
//    on E: Exception do
//    begin
//      response.AddValue('message', 'Erreur: ' + E.Message);
//    end;
  end;

  Result := response.ToJson();
end;

function TService.CheckRecExist(classType :TORMType ; JData: RawUtf8): Boolean;
var
  doc: TDocVariantData;
  aWhereClause: RawUtf8;
  orm :TOrm;
begin

  orm := CreateOrmInstance(classType);
  try
    doc.InitJson(JData);
    if doc.Count = 0 then
    Exit;
    aWhereClause := FormatUtf8('%=%', [doc.U['Field'],  QuotedStr(doc.U['value'])]);
    result:= Self.Server.Orm.Retrieve(aWhereClause,orm);
  finally
    orm.Free;
  end;
end;

function TService.Delete(JData: RawUtf8): RawUtf8;
var
  Orm: TOrm;
  doc: TDocVariantData;
  AType: TORMType;
  AID: TID;
  DeleteResult: Boolean;
begin
  // Parse JSON data
  doc := TDocVariantData(_Json(JData));
  AType := TORMType(doc.I['ormClass']);
  AID := doc.I['ID'];

  // Create the ORM instance based on type
  Orm := CreateOrmInstance(AType);
  try
    if Assigned(Orm) then
    begin
      // Check for dependencies before deletion
      case AType of
        ormZone:
          if Self.Server.Orm.OneFieldValue(TOrmThirdParty, 'code', FormatUtf8('ZoneID=%', [AID])) <> '' then
          begin
            Result := FormatUtf8('{"status": false, "message": "%"}', [SDependencyExistsZone]);
            Exit;
          end;

        ormThirdParty:
          if Self.Server.Orm.OneFieldValue(TOrmDoc, 'ThirdPrty', FormatUtf8('ThirdPrty=%', [AID])) <> '' then
          begin
            Result := FormatUtf8('{"status": false, "message": "%"}', [SDependencyExistsThirdParty]);
            Exit;
          end;
      end;

      // If no dependencies are found, proceed with deletion
      DeleteResult := Self.Server.Orm.Delete(TOrmClass(Orm.ClassType), AID);
      if DeleteResult then
        Result := FormatUtf8('{"status": true, "message": "%"}', [SDeleteSuccess])
      else
        Result := FormatUtf8('{"status": false, "message": "%"}', [SDeleteFailed]);
    end
    else
      Result := FormatUtf8('{"status": false, "message": "%"}', ['Type ORM invalide.']);
  finally
    Orm.Free;
  end;
end;

function CreateOrmInstance(AType: TORMType): TOrm;
begin
  Result := nil;
  case AType of
    ormZone:       Result := TOrmZone.Create;
    ormThirdParty: Result := TOrmThirdParty.Create;
    ormDoc:        Result := TOrmDoc.Create;
    ormDocDetails: Result := TOrmDocDetails.Create;
  end;
end;

function TService.GetDocDetail(aWhere: RawUtf8): RawUtf8;
var
  aSQLQuery: RawUtf8;
begin
  aSQLQuery := FormatUtf8(
    'WITH PaymentSummary AS (' +
    '  SELECT ' +
    '    DocID, ' +
    '    SUM(PaymentAmount) AS TotalPayment ' +
    '  FROM DocDetails ' +
    '  WHERE PaymentStatus IN (0, 9) ' +
    '  GROUP BY DocID ' +
    ') ' +
    'SELECT ' +
    '  dd.*, ' +
    '  d.TotalPrice, ' +
    '  COALESCE(ps.TotalPayment, 0) AS TotalPayment, ' +
    '  (d.TotalPrice - COALESCE(ps.TotalPayment, 0)) AS Reste, ' +
    '  CASE dd.DocState ' +
    '    WHEN 0 THEN ''Partiellement payé'' ' + // psPartiallyPaid
    '    WHEN 1 THEN ''Totalement payé'' ' +    // psFullyPaid
    '    WHEN 2 THEN ''En attente'' ' +         // psPending
    '    WHEN 3 THEN ''Aucune Facture'' ' +     // psNoInvoice
    '    ELSE ''Statut Inconnu'' ' +
    '  END AS DocStateText, ' +
    '  CASE dd.PaymentNature ' +
    '    WHEN 0 THEN ''Chèque'' ' +             // pnCheque
    '    WHEN 1 THEN ''Lettre de Change'' ' +   // pnLNC
    '    WHEN 2 THEN ''Virement'' ' +           // pnBankTransfer
    '    WHEN 3 THEN ''Espèces'' ' +            // pnCash
    '    WHEN 4 THEN ''Autre'' ' +              // pnOther
    '    WHEN 5 THEN ''Aucun Règlement'' ' +    // pnNoPayment
    '    ELSE ''Nature Inconnue'' ' +
    '  END AS PaymentNatureText, ' +
    '  CASE dd.PaymentStatus ' +
    '    WHEN 0 THEN ''Réglé'' ' +              // psSettled
    '    WHEN 1 THEN ''Impayé'' ' +             // psUnpaid
    '    WHEN 2 THEN ''Rejeté'' ' +             // psRejected
    '    WHEN 3 THEN ''Remplacé'' ' +           // psReplaced
    '    WHEN 4 THEN ''Prorogé'' ' +            // psExtended
    '    WHEN 5 THEN ''En cours'' ' +           // psInProgress
    '    WHEN 6 THEN ''Annulé'' ' +             // psCancelled
    '    WHEN 7 THEN ''Annulé et remplacé'' ' + // psCancelledReplaced
    '    WHEN 8 THEN ''Aucun Règlement'' ' +    // psNoPayment
    '    WHEN 9 THEN ''Écart'' ' +              // psDiscrepancy
    '    WHEN 10 THEN ''Représenté'' ' +        // psReprocessed
    '    ELSE ''Situation Inconnue'' ' +
    '  END AS PaymentStatusText ' +
    'FROM DocDetails dd ' +
    'INNER JOIN Doc d ON d.ID = dd.DocID ' +
    'LEFT JOIN PaymentSummary ps ON ps.DocID = dd.DocID ' +
    'WHERE 1=1 % ',
    [aWhere]
  );

  // Execute the query and return the result as JSON
  Result := fServer.ExecuteJson([], aSQLQuery);
end;


{
function TService.GetDocuments(aWhere: RawUtf8): RawUtf8;
var
  aSQLQuery: RawUtf8;
begin
  aSQLQuery := FormatUtf8(
    'SELECT Doc.*, ' +
    'ThirdParty.code AS thirdPrtyCode, ' +
    '(SELECT SUM(PaymentAmount) ' +
    ' FROM DocDetails ' +
    ' WHERE DocDetails.DocID = Doc.ID) AS TotalPayment, ' +
    'CASE ' +
    '  WHEN (SELECT SUM(PaymentAmount) ' +
    '        FROM DocDetails ' +
    '        WHERE DocDetails.DocID = Doc.ID ) >= Doc.TotalPrice ' +
    '  THEN ''Complete'' ' +
    '  ELSE ''Incomplete'' ' +
    'END AS PaymentStatus, ' +
    'CASE Doc.DocType ' +
    '  WHEN 0 THEN ''Facture'' ' +
    '  WHEN 1 THEN ''Bon de Livraison'' ' +
    '  WHEN 2 THEN ''Avoir'' ' +
    '  ELSE ''Unknown'' ' +
    'END AS DocTypeText ' +
    'FROM Doc ' +
    'LEFT JOIN ThirdParty ON Doc.ThirdPrty = ThirdParty.ID ' +
    'WHERE 1=1 % ' +
    'ORDER BY Doc.DocDate ASC',
    [aWhere]);
  Result := fServer.ExecuteJson([], aSQLQuery);
end;
}
{
function TService.GetDocuments(aWhere: RawUtf8): RawUtf8;
var
  aSQLQuery: RawUtf8;
begin
  aSQLQuery := FormatUtf8(
    'SELECT ' +
    '  Doc.*, ' +
    '  ThirdParty.code AS ''thirdPrtyCode'', ' +
    '  (SELECT SUM(PaymentAmount) ' +
    '   FROM DocDetails ' +
    '   WHERE DocDetails.DocID = Doc.ID ' +
    '     AND DocDetails.PaymentStatus IN (0, 5)) AS ''TotalPayment'', ' +
    '  (Doc.TotalPrice - ' +
    '   (SELECT SUM(PaymentAmount) ' +
    '    FROM DocDetails ' +
    '    WHERE DocDetails.DocID = Doc.ID ' +
    '      AND DocDetails.PaymentStatus IN (0, 5))) AS ''Reste'', ' +
    '  CASE ' +
    '    WHEN (SELECT SUM(PaymentAmount) ' +
    '          FROM DocDetails ' +
    '          WHERE DocDetails.DocID = Doc.ID ' +
    '            AND DocDetails.PaymentStatus IN (0, 5)) >= Doc.TotalPrice ' +
    '    THEN ''Totalement payé'' ' +
    '    WHEN (SELECT SUM(PaymentAmount) ' +
    '          FROM DocDetails ' +
    '          WHERE DocDetails.DocID = Doc.ID ' +
    '            AND DocDetails.PaymentStatus = 9) > 0 ' +
    '    THEN ''En attente'' ' +
    '    ELSE ''En cours'' ' +
    '  END AS ''PaymentStatus'', ' +
    '  CASE Doc.DocType ' +
    '    WHEN 0 THEN ''Facture'' ' +
    '    WHEN 1 THEN ''Bon de Livraison'' ' +
    '    WHEN 2 THEN ''Avoir'' ' +
    '    ELSE ''Unknown'' ' +
    '  END AS ''DocTypeText'' ' +
    'FROM ' +
    '  Doc ' +
    'LEFT JOIN ' +
    '  ThirdParty ON Doc.ThirdPrty = ThirdParty.ID ' +
    'WHERE ' +
    '  1=1 % ' +
    'ORDER BY ' +
    '  Doc.DocDate ASC',
    [aWhere]);

  Result := fServer.ExecuteJson([], aSQLQuery);
end;
}

function TService.GetDocuments(aWhere: RawUtf8): RawUtf8;
var
  aSQLQuery: RawUtf8;
begin
  aSQLQuery := FormatUtf8(
    'WITH DocDetailsSummary AS (' +
    '  SELECT ' +
    '    dd.DocID, ' +
    '    MAX(dd.PaymentNumber) OVER(PARTITION BY dd.DocID) AS LatestPaymentNumber, ' +
    '    MAX(dd.PaymentNature) OVER(PARTITION BY dd.DocID) AS LatestPaymentNature, ' +
    '    SUM(CASE WHEN dd.PaymentStatus IN (0, 9) THEN dd.PaymentAmount ELSE 0 END) OVER(PARTITION BY dd.DocID) AS TotalPaid ' +
    '  FROM DocDetails dd ' +
    '  WHERE EXISTS (SELECT 1 FROM Doc d WHERE d.ID = dd.DocID)' +
    ') ' +
    'SELECT DISTINCT ' +
    '  d.*, ' +
    '  tp.code AS ''ThirdPartyCode'', ' +
    '  COALESCE(d.TotalPrice - ds.TotalPaid, 0) AS ''Reste'', ' +
    '  COALESCE(ds.TotalPaid, 0) AS ''TotalPayment'', ' +
    '  ds.LatestPaymentNumber AS ''PaymentNumber'', ' +
    '  ds.LatestPaymentNature AS ''PaymentNature'', ' +
    '  CASE ' +
    '    WHEN COALESCE(ds.TotalPaid, 0) >= d.TotalPrice THEN ''Totalement payé'' ' +
    '    ELSE ''En cours'' ' +
    '  END AS ''Status'', ' +
    '  CASE d.DocType ' +
    '    WHEN 0 THEN ''Facture'' ' +
    '    WHEN 1 THEN ''Bon de Livraison'' ' +
    '    WHEN 2 THEN ''Avoir'' ' +
    '    ELSE ''Inconnu'' ' +
    '  END AS ''DocTypeText'' ' +
    'FROM Doc d ' +
    'INNER JOIN ThirdParty tp ON d.ThirdPrty = tp.ID ' +
    'LEFT JOIN DocDetailsSummary ds ON d.ID = ds.DocID ' +
    'LEFT JOIN DocDetails dd ON d.ID = dd.DocID ' +
    'WHERE 1=1 % ',
    [aWhere]
  );
  Result := fServer.ExecuteJson([], aSQLQuery);
end;



function TService.GetThirdPartys(aWhere: RawUtf8): RawUtf8;
var
  aSQLQuery: RawUtf8;
begin
  aSQLQuery := FormatUtf8('SELECT tp.ID,'+
   ' tp.Code, '+
   ' tp.ZoneID, '+
   ' tp.plafond, '+
   ' z.code AS ZoneCode, '+
   '   CASE tp.TypeThp ' +
   '     WHEN 0 THEN  "%" ' +
   '     WHEN 1 THEN  "%" ' +
   '     WHEN 2 THEN  "%" ' +
   '    END AS ThirdPartyTypeText ' +
   'FROM % tp  ' +
   'INNER JOIN Zone z ON z.ID = tp.ZoneID ' +
   'WHERE 1=1 % ',
    [GetEnumNameTrimed(typeinfo(ThirdPartType), ord(tpNone)),
    GetEnumNameTrimed(typeinfo(ThirdPartType), ord(tpSupplier)),
    GetEnumNameTrimed(typeinfo(ThirdPartType), ord(tpCustomer)),
    TOrmThirdParty.SqlTableName, aWhere]);

  result := fServer.ExecuteJson([], aSQLQuery);
  // +
//   'ORDER BY tp.Code ASC;',
end;

function TService.GetTotales: RawUtf8;
var SqlWhere : RawUtf8;
begin
   SqlWhere :=
   FormatUtf8('SELECT '+
  '(SELECT SUM(d.TotalPrice) FROM Doc d) AS Achats,'+
  '(SELECT SUM(dd.PaymentAmount)    '+
  ' FROM DocDetails dd  '    +
  ' WHERE dd.PaymentStatus IN (0, 9)) AS Recus, '+
  '(SELECT SUM(d.TotalPrice) FROM Doc d) AS ventes, '+
  '(SELECT SUM(d.TotalPrice) - SUM(dd.PaymentAmount)  ' +
  ' FROM Doc d  '    +
  ' LEFT JOIN DocDetails dd ON d.ID = dd.DocID '   +
  ' WHERE dd.PaymentStatus IN (0, 9)) AS dep ' +
  'FROM  (SELECT 1 AS ColonneFictive) AS TableFictive;  ' ,[]);
   Result := fServer.ExecuteJson([],SqlWhere);
end;

function TService.GetTotalSales: RawUtf8;
var SqlWhere : RawUtf8;
begin
   SqlWhere := FormatUtf8('SELECT '+
    ' CASE DocType '+
    '  WHEN 0 THEN ''Aucun'' '   +
    '  WHEN 1 THEN ''Facture'' '  +
    '  WHEN 2 THEN ''Bon de Livraison'' ' +
    '  WHEN 3 THEN ''Avoir'''    +
    ' END AS DocTypeText, '        +
    ' SUM(TotalPrice) AS TotalSales  ' +
    ' FROM Doc ' ,[] );
  result := fServer.ExecuteJson([],SqlWhere);
  //  +
  //  ' GROUP BY DocTypeText;'
end;

function TService.GetUsers(aWhere: RawUtf8): RawUtf8;
var SqlWhere : RawUtf8;
begin
  SqlWhere := FormatUtf8(
'SELECT ID,'  +
'  username,'+
'  PasswordHash,' +
'  CASE  ' +
 '   WHEN HavePermission = true THEN ''Admin'' '  +
 '   WHEN HavePermission = false THEN ''Visiteur'' ' +
  '  ELSE ''Unknown'' '  +
'  END AS havePermission  ' +
'FROM USER ' +
'WHERE 1=1 %  ',[aWhere]);
  result := fServer.ExecuteJson([],SqlWhere);
end;

function TService.GetZones(aWhere: RawUtf8): RawUtf8;
var SqlWhere : RawUtf8;
begin
  SqlWhere := FormatUtf8('SELECT * FROM % WHERE 1=1 % ',
     [TOrmZone.SqlTableName,aWhere]);
  result := fServer.ExecuteJson([],SqlWhere);
end;

{ TUserService }

function TUserManager.AddUser(const Username, Password: RawUtf8;
  HavePermission: Boolean): Boolean;
var
  User: TormUser;
begin
  User := TormUser.Create;  // Use FServer
  try
    User.Username := Username;
    User.PasswordHash := Password;// TAuthUser.ComputeHashedPassword(Password);
    User.HavePermission := HavePermission;
    Result := Self.Server.orm.Add(User, True) <> 0;
  finally
    User.Free;
  end;
end;

function TUserManager.GetUserPermissions(const Username: RawUtf8): TPermissions;
var
  User: TormUser;
begin
  User := TormUser.Create(Self.Server.Orm, 'Username=?', [Username]);  // Use FServer
  try
    if User.ID <> 0 then
     // Result := User.Permissions
    else
      Result := [];
  finally
    User.Free;
  end;
end;

function TUserManager.Login(const Username, Password: RawUtf8): Boolean;
var
  User: TormUser;
  Hash: RawUtf8;
begin
//  Hash := TAuthUser.ComputeHashedPassword(Password);
//  User := TormUser.Create(self.server.Orm,
//    FormatUtf8('Username=% And PasswordHash=%',[QuotedStr(Username),
//       QuotedStr(Hash)]));
//
//  Result := (User.ID <> 0) and
//    (User.PasswordHash = TAuthUser.ComputeHashedPassword(Password));
 TormUser.AutoFree(user);
  Hash := FormatUtf8('userName=% AND PasswordHash=%',[QuotedStr(UserName),QuotedStr(Password)]) ;
  Result := Self.Server.Orm.Retrieve(Hash,User);
end;

function TService.UsersAnaylse: RawUtf8;
var
  SqlWhere: RawUtf8;
begin
  SqlWhere :=
    'WITH PaymentSummary AS (' +
    '  SELECT ' +
    '    dd.DocID, ' +
    '    SUM(CASE WHEN dd.PaymentStatus IN (0, 9) THEN dd.PaymentAmount ELSE 0 END) AS TotalPaid ' +
    '  FROM DocDetails dd ' +
    '  GROUP BY dd.DocID' +
    ') ' +
    'SELECT ' +
    '  tp.code AS Tier, ' +
    '  tp.Plafond AS Plafound, ' +
    '  COUNT(CASE WHEN d.DocType = 0 THEN 1 END) AS Factures, ' +
    '  COUNT(CASE WHEN d.DocType = 1 THEN 1 END) AS BonsLivraison, ' +
    '  COUNT(CASE WHEN d.DocType = 2 THEN 1 END) AS Avoirs, ' +
    '  SUM(CASE WHEN d.DocType = 0 THEN d.TotalPrice ELSE 0 END) AS ValeurTotaleFactures, ' +
    '  SUM(CASE WHEN d.DocType = 1 THEN d.TotalPrice ELSE 0 END) AS ValeurTotaleBonsLivraison, ' +
    '  SUM(CASE WHEN d.DocType = 2 THEN d.TotalPrice ELSE 0 END) AS ValeurTotaleAvoirs, ' +
    '  COALESCE(SUM(ps.TotalPaid), 0) AS TotalMontantPayé, ' +
    '  SUM(d.TotalPrice - COALESCE(ps.TotalPaid, 0)) AS SoldeRestant, ' +
    '  ROUND(SUM(COALESCE(ps.TotalPaid, 0)) / SUM(d.TotalPrice) * 100, 2) AS PourcentagePayementComplet ' +
    'FROM ThirdParty tp ' +
    'LEFT JOIN Doc d ON tp.ID = d.ThirdPrty ' +
    'LEFT JOIN PaymentSummary ps ON ps.DocID = d.ID ' +
    'WHERE 1=1 ' +
    'GROUP BY tp.ID, tp.code, tp.ZoneId, tp.TypeThp, tp.Plafond ';

  Result := fServer.ExecuteJson([], SqlWhere);
end;


function TService. GetRowCountQuery( TableName, Condition: RawUtf8): RawUtf8;
var query : RawUtf8;
begin
  query  := FormatUtf8('SELECT COUNT(*) AS RowCount FROM % WHERE 1=1 %',
    [TableName,  Condition]);
   Result := fServer.ExecuteJson([], query);
end;

end.
