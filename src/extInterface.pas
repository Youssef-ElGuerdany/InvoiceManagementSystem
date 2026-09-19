unit extInterface;

interface

uses
 ExtraBase,

  mormot.core.base,


  mormot.core.interfaces;

type



  IUserManager = interface(IInvokable)
    ['{69A93906-A4C3-42BF-8761-BDDE9E864545}']
    function Login(const Username, Password: RawUtf8): Boolean;
    function AddUser(const Username, Password: RawUtf8;HavePermission: Boolean): Boolean;
    function GetUserPermissions(const Username: RawUtf8): TPermissions;
  end;

  IExtraInterface = interface(IInvokable)
    ['{700D1681-0ACD-4058-BF14-1047C9D1F3FA}']

    function Add(domaineType: TORMType;JData: RawUtf8): RawUtf8;
    function Edit(JData:RawUtf8):RawUtf8;
    function Delete(JData: RawUtf8):RawUtf8;

    function GetUsers(aWhere:RawUtf8):RawUtf8;
    function GetZones(aWhere: RawUtf8): RawUtf8;
    function GetThirdPartys(aWhere: RawUtf8): RawUtf8;
    function GetDocuments(aWhere: RawUtf8): RawUtf8;
    function GetDocDetail(aWhere: RawUtf8): RawUtf8;
    //charts
    function GetTotalSales: RawUtf8;
    function UsersAnaylse: RawUtf8;
    function GetTotales: RawUtf8;

    // this functon given the if exist rec
    // take sql Table name + field Name + field vale
   // function checkExist(JData:RawUtf8): Boolean;
    function CheckRecExist(classType :TORMType ; JData: RawUtf8): Boolean;

    function GetRowCountQuery( TableName, Condition: RawUtf8): RawUtf8;



  end;

implementation

initialization

TInterfaceFactory.RegisterInterfaces([
  TypeInfo(IUserManager),
  TypeInfo(IExtraInterface)
  ]);


end.
