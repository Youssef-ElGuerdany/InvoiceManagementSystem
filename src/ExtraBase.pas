unit ExtraBase;

interface

uses
  System.SysUtils,
  system.DateUtils,
  mormot.orm.core,
  mormot.rest.core,


  mormot.core.base;


const
  HttpPort = '11111';
type


  TImportType = (imZone,impClient,imFourn);

  EformAction = (faNone,faAdd,faEdit,faDelete);

  TDocType = ( dtFact, dtBL, dtAv);

  ThirdPartType = (tpNone, tpSupplier, tpCustomer);


  TormBase = class(Torm)
  public
  /// code is the unique key for all classes
    fcode: RawUtf8;
  published
    property code: RawUtf8 read fcode write fcode;
  end;


  TPermissionType = (
    ptCreateDocuments,
    ptReadDocuments,
    ptUpdateDocuments,
    ptDeleteDocuments,
    ptCreateUsers,
     ptManageUsers
     );

  TPermissions = set of TPermissionType;

  // 0- user class
  TormUser = class(TormBase)
  private
    fUsername: RawUtf8;
    fPasswordHash: RawUtf8;
    fHavePermission : Boolean;
  published
    property Username: RawUtf8 read fUsername write fUsername;
    property PasswordHash: RawUtf8 read fPasswordHash write fPasswordHash;
    property HavePermission: Boolean read fHavePermission write fHavePermission;

  end;

  // 1. Zone Class
  TOrmZone = class(TormBase)
  end;

  // 2. ThirdParty Class
  TOrmThirdParty = class(TormBase)
  private
    FZoneId: TID;
    FTypeThp: ThirdPartType; // tpNone = 0, tpCustomer = 1, tpClient = 2
    FPlafond: Integer;
  published
    property ZoneId: TID  read FZoneId write FZoneId;
    property TypeThp: ThirdPartType read FTypeThp write FTypeThp;
    property Plafond: Integer read FPlafond write FPlafond;
  end;

  // 3. DOC Class
  TOrmDoc = class(TormBase)
  private
    FDocDate: TDateTime;
    FTotalPrice: currency;
    FDocType: TDocType; // DtNone = 0, DtFact = 1, DtBL = 2, DtAV = 3
    FThirdPrty: integer;
    FModifDate : TDateTime;
  public
    function IsPaid: Boolean;
  published
    property DocDate: TDateTime read FDocDate write FDocDate;
    property TotalPrice: currency read FTotalPrice write FTotalPrice;
    property DocType: TDocType read FDocType write FDocType;
    property ThirdPrty: integer read FThirdPrty write FThirdPrty;
    property ModifDate: TDateTime read FModifDate write FModifDate;
  end;


  // 4. DocDetails Class
 type
  // Enums as discussed earlier
  TPaymentStatus = (
    psPartiallyPaid,  // *Factures Partiellement payées
    psFullyPaid,      // *Factures totalement payées
    psPending,        // *Factures en cours
    psNoInvoice       // *Aucune Facture
  );

  TPaymentNature = (
    pnCheque,         // *CHQ
    pnLNC,            // *LNC
    pnBankTransfer,   // *VIREMENT
    pnCash,           // *ESPECE
    pnOther,          // *AUTRE
    pnNoPayment       // *Aucun Règlement
  );

  TPaymentSituation = (
    psSettled,            // *réglé   0
    psUnpaid,             // *impayé
    psRejected,           // *rejeté
    psReplaced,           // *remplacé
    psExtended,           // *prorogé
    psInProgress,         // *encours
    psCancelled,          // *annulé
    psCancelledReplaced,  // *annulé et remplacé
    psNoPayment,          // *Aucun Règlement
    psDiscrepancy,        // *Ecarts   9
    psReprocessed         // *Représenté
  );


  TOrmDocDetails = class(TormBase)
  private
    FDocID: TID; // Foreign key to TOrmDoc
    FDocState: TPaymentStatus;
    FPaymentNature: TPaymentNature;
    FPaymentNumber: RawUtf8;
    FPaymentAmount: Currency;
    FPaymentStatus: TPaymentSituation;
    FEcheance: RawUtf8;
    FObservation: RawUtf8;
    FdetailDate: TDateTime;


  public
    // Determine if the document is overdue
    function IsOverdue: Boolean;

  published
    property DocID: TID read FDocID write FDocID;
    property DocState: TPaymentStatus read FDocState write FDocState;  // Enum Property
    property PaymentNature: TPaymentNature read FPaymentNature write FPaymentNature;  // Enum Property
   // changed By code fro TormBase
    property PaymentNumber: RawUtf8 read FPaymentNumber write FPaymentNumber;
    property PaymentAmount: Currency read FPaymentAmount write FPaymentAmount;
    property PaymentStatus: TPaymentSituation read FPaymentStatus write FPaymentStatus;  // Enum Property
    property detailDate: TDateTime read FdetailDate write FdetailDate;
    property Echeance: RawUtf8 read FEcheance write FEcheance;
    property Observation: RawUtf8 read FObservation write FObservation;
  end;


  //*************************  PART 2 Advanced mormot ***********************************************
  // Mormot history impl

   TOrmMyHistory = class(TOrmHistory);


    TORMType = (
    ormZone,
    ormThirdParty,
    ormDoc,
    ormDocDetails,
    ormUsers
  );

   function CreateOrmInstance(AType: TORMType): tORM;



implementation

 function CreateOrmInstance(AType: TORMType): Torm;
 var orm :TOrm;
begin
  Result := nil;
  case Atype of
    ormZone       : Result := TOrmZone.Create ;
    ormThirdParty : Result := TOrmThirdParty.Create;
    ormDoc        : Result := TOrmDoc.Create;
    ormDocDetails : Result := TOrmDocDetails.Create;
    ormUsers      : Result := TormUser.Create;
  end;
end;

function TOrmDoc.IsPaid: Boolean;
begin
  // Assume we fetch all related DocDetails and sum the PaymentAmount
  // For simplicity, this example assumes all payments match the total price
  Result := TotalPrice <= 0;
end;

function TOrmDocDetails.IsOverdue: Boolean;
begin
    Result := Now > detailDate;
end;



end.
