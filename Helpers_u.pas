unit Helpers_u;

interface

uses System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Hash, System.IniFiles, System.IOUtils, System.JSON;

type
  THelperFunc = class(TObject)
    private
    // blah
    public
      constructor Create;
      destructor Destroy; override;
      function ConfirmFileValidity(sPath: String): boolean;
      procedure AppendToTextFile(sPath: String; cDelimiter: Char; arrData: TArray<String>);
      procedure SetFileHashKey(sPath: String);
      procedure IniWriteString(sSection: String; arrKeys, arrValues: TArray<String>);
      function IniReadString(sSection: String; arrKeys, arrDefaults: TArray<String>): TArray<String>;
  end;

var
  FHelpers: THelperFunc;

implementation

uses Main_u;


constructor THelperFunc.Create;
begin
  inherited Create;
end;


destructor THelperFunc.Destroy;
begin
  inherited;
end;

function THelperFunc.ConfirmFileValidity(sPath: String): boolean;
var
  tTextFile: TextFile;
  sFileData, sFileHash, sLine, sHashKey: String;
  bFirstLine: Boolean;
begin
  AssignFile(tTextFile, sPath);

  if NOT FileExists(sPath) then
  begin
    Result := False;
    exit
  end;

  Reset(tTextFile);

  try
    sFileData := '';

    bFirstLine := True;

    while NOT EOF(tTextFile) do
    begin
      if NOT bFirstLine then
      begin
        Readln(tTextFile, sLine);
        sFileData := sFileData + sLine;
      end
      else
        Readln(tTextFile, sHashKey);

      bFirstLine := False;
    end;
  finally
    CloseFile(tTextFile);
  end;

  sFileHash := THashSHA2.GetHashString(sFileData);

  if sFileHash = sHashKey then
    Result := True
  else
    Result := False;

end;

procedure THelperFunc.AppendToTextFile(sPath: String; cDelimiter: Char; arrData: TArray<String>);
var
  tTextFile: TextFile;
  sOutput: String;
  iIndex: Integer;
begin
  // Formatting data with delimiters
  // Differentiate between zero and one indexed arrays
  if Low(arrData) = 0 then
  begin
    sOutput := '';
    for iIndex := 0 to Length(arrData)-1 do
    begin
      if iIndex = Length(arrData)-1 then
        sOutput := sOutput + arrData[iIndex]
      else
        sOutput := sOutput + arrData[iIndex] + cDelimiter;
    end;
  end
  else if Low(arrData) = 1 then
  begin
    sOutput := '';
    for iIndex := 1 to Length(arrData) do
    begin
      if iIndex = Length(arrData) then
        sOutput := sOutput + arrData[iIndex]
      else
        sOutput := sOutput + arrData[iIndex] + cDelimiter;
    end;
  end;

  // Writing data to file
  AssignFile(tTextFile, sPath);
  Append(tTextFile);
  try
    Writeln(tTextFile, sOutput);
  finally
    CloseFile(tTextFile);
  end;

end;


procedure THelperFunc.SetFileHashKey(sPath: String);
var
  tTextFile: TextFile;
  sFileData, sFileHash, sLine: String;
  bFirstLine: Boolean;
  arrListLines: TArray<String>;
  iIndex, iArrLength: Integer;
begin
  AssignFile(tTextFile, sPath);

  if NOT FileExists(sPath) then
    exit;

  iArrLength := 0;

  Reset(tTextFile);
  try
    sFileData := '';
    bFirstLine := True;

    while not EOF(tTextFile) do
    begin
      Inc(iArrLength);
      SetLength(arrListLines, iArrlength);

      Readln(tTextFile, sLine);

      if not bFirstLine then
      begin
        sFileData := sFileData + sLine;
        arrListLines[iArrLength-1] := sLine;
      end;

      bFirstLine := False;
    end;

    sFileHash := THashSHA2.GetHashString(sFileData);

    Rewrite(tTextFile);

    Writeln(tTextFile, sFileHash);

    for iIndex := 0 to Length(arrListLines) - 1 do
    begin
      Writeln(tTextFile, arrListLines[iIndex]);
    end;
  finally
    CloseFile(tTextFile);
  end;
end;


procedure THelperFunc.IniWriteString(sSection: String; arrKeys, arrValues: TArray<String>);
var
  iIndex: Integer;
  iniFile: TIniFile;
begin
  // Allows for bulk writing to the ini file

  if Length(arrKeys) <> Length(arrValues) then
  begin
      exit
  end;

  iniFile := TIniFile.Create(ChangeFileExt(APP_PATH + '\data\data', '.ini'));
  try
    for iIndex := 0 to Length(arrValues) - 1 do
    begin
      iniFile.WriteString(sSection, arrkeys[iIndex], arrValues[iIndex]);
    end;
  finally
    iniFile.Free;
  end;
end;


function THelperFunc.IniReadString(sSection: String; arrKeys, arrDefaults: TArray<String>): TArray<String>;
var
  iIndex: Integer;
  iniFile: TIniFile;
  iResultLength: Integer;
begin
  // Allows for bulk reading from the ini file

  if Length(arrKeys) <> Length(arrDefaults) then
  begin
      Result := [''];
      exit
  end;

  iResultLength := 0;

  iniFile := TIniFile.Create(ChangeFileExt(Main_u.APP_PATH + '\data\data', '.ini'));
  try
    for iIndex := 0 to Length(arrDefaults) - 1 do
    begin
      Inc(iResultLength);
      SetLength(Result, iResultLength);
      Result[iIndex] := iniFile.ReadString(sSection, arrkeys[iIndex], arrDefaults[iIndex]);
    end;
  finally
    iniFile.Free;
  end;
end;

end.
