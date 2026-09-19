unit config;

interface

uses mormot.core.variants;

var

  RemoteConfig: Variant;

implementation
 uses mormot.core.os;

initialization

var
  filePath: string;

filePath := Stringfromfile('config.json');

RemoteConfig := _json(filePath);

end.
