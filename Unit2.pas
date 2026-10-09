unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.Objects,
  FMX.Styles.Objects, FMX.TabControl, FMX.DialogService, System.Hash, System.IniFiles,
  System.IOUtils, System.JSON,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, OpenAI, OpenAI.Chat,
  OpenAI.Errors, OpenAI.Component.Chat, Winapi.ShellAPI, Winapi.Windows, FMX.Platform.Win;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnLogin: TButton;
    btnCreateAccount: TButton;
    edtPasswordLogin: TEdit;
    Label1: TLabel;
    Rectangle1: TRectangle;
    Label2: TLabel;
    Rectangle2: TRectangle;
    edtUsernameLogin: TEdit;
    Label3: TLabel;
    tbCtrlMain: TTabControl;
    tbLogin: TTabItem;
    tbCreateAccount: TTabItem;
    Panel3: TPanel;
    Panel4: TPanel;
    btnCreateAccountConfirm: TButton;
    btnCancelCreateAccount: TButton;
    Rectangle3: TRectangle;
    edtPasswordCreate: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Rectangle4: TRectangle;
    edtUsernameCreate: TEdit;
    Label6: TLabel;
    Rectangle5: TRectangle;
    edtPasswordConfirmCreate: TEdit;
    Label7: TLabel;
    tbMainPage: TTabItem;
    Label8: TLabel;
    Label9: TLabel;
    Panel5: TPanel;
    btnLogOut: TButton;
    lblLoginError: TLabel;
    lblCreateAccountError: TLabel;
    lblCurrentUser: TLabel;
    rectSidePanelClosed: TRectangle;
    Rectangle6: TRectangle;
    btnOpenSideMenu: TButton;
    Label10: TLabel;
    rectSidePanelOpen: TRectangle;
    btnSend: TButton;
    memAIInput: TMemo;
    memAIResponse: TMemo;
    Rectangle8: TRectangle;
    btnCloseSideMenu: TButton;
    Label11: TLabel;
    Label12: TLabel;
    procedure btnCreateAccountClick(Sender: TObject);
    procedure btnCancelCreateAccountClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnCreateAccountConfirmClick(Sender: TObject);
    procedure btnLogOutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnOpenSideMenuClick(Sender: TObject);
    procedure btnCloseSideMenuClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure AppendToTextFile(sPath: String; cDelimiter: Char; arrData: TArray<String>);
    function ConfirmFileValidity(sPath: String): boolean;
    procedure SetFileHashKey(sPath: String);
    procedure CurrentUserUpdate();
    procedure IniWriteString(sSection: String; arrKeys, arrValues: TArray<String>);
    function IniReadString(sSection: String; arrKeys, arrDefaults: TArray<String>): TArray<String>;
    procedure InitLocalAI;
    function MakeStreamProc(Form: TfrmMain; bShowMessage: Boolean): TChatEvent;
    function MessageAI(sMessage: String): String;
    procedure StartLlamaServer;
    procedure StopLlamaServer;

    var
      sCurrentUser: String;
      APP_PATH: String;
      FOpenAI: IOpenAI;
      sAILastMessage: String;
      hServerProcess: THandle;
    const
      LOGIN_DETAILS_PATH = 'data\login-details.txt';
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.AppendToTextFile(sPath: String; cDelimiter: Char; arrData: TArray<String>);
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


function TfrmMain.ConfirmFileValidity(sPath: String): boolean;
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


procedure TfrmMain.SetFileHashKey(sPath: String);
var
  tTextFile: TextFile;
  sFileData, sFileHash, sLine: String;
  bFirstLine: Boolean;
//  SList: TStringList;
  arrListLines: TArray<String>;
  iIndex, iArrLength: Integer;
begin
  AssignFile(tTextFile, sPath);

  if NOT FileExists(sPath) then
    exit;

  iArrLength := 0;

  Reset(tTextFile);
//  SList := TStringList.Create;
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
//    SList.Free;
  end;
end;


procedure TfrmMain.CurrentUserUpdate();
begin
  lblCurrentUser.Text := 'Logged in as: ' + sCurrentUser;
end;


procedure TfrmMain.IniWriteString(sSection: String; arrKeys, arrValues: TArray<String>);
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


function TfrmMain.IniReadString(sSection: String; arrKeys, arrDefaults: TArray<String>): TArray<String>;
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

  iniFile := TIniFile.Create(ChangeFileExt(APP_PATH + '\data\data', '.ini'));
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


procedure TfrmMain.InitLocalAI;
begin
  // Initialize AI with a dummy key and local llama.cpp as the url
  FOpenAI := TOpenAI.Create('local-dummy-key');
  FOpenAI.BaseURL := 'http://127.0.0.1:8080/v1';
end;


function TfrmMain.MakeStreamProc(Form: TfrmMain; bShowMessage: Boolean): TChatEvent;
// AI CODED FUNCTION EDITED BY ME
begin
  Result := procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
  var
    IncomingText: string;
  begin
    // Exit immediately on done - Chat object is invalid at this point
    // because llama.cpp sends data: [DONE] which is not valid JSON
    if IsDone or not Assigned(Chat) then
    begin
      TThread.Queue(nil,
        procedure
        begin
          Form.btnSend.Enabled := True;
        end);
      Exit;
    end;

    try
      IncomingText := '';

      if Length(Chat.Choices) = 0 then
        Exit;

      if Assigned(Chat.Choices[0].Delta) then
        IncomingText := Chat.Choices[0].Delta.Content
      else if Assigned(Chat.Choices[0].Message) then
        IncomingText := Chat.Choices[0].Message.Content;

      if not IncomingText.IsEmpty then
        TThread.Queue(nil,
          procedure
          begin
            if bShowMessage then
              Form.memAIResponse.Lines.Text := Form.memAIResponse.Lines.Text + IncomingText
            else
              sAILastMessage := sAILastMessage + IncomingText;
          end);
    except
      on E: Exception do
        TThread.Queue(nil,
          procedure
          begin
            if bShowMessage then
              Form.memAIResponse.Lines.Add('[Error: ' + E.ClassName + ': ' + E.Message + ']')
            else
              sAILastMessage := '[Error: ' + E.ClassName + ': ' + E.Message + ']';
            Form.btnSend.Enabled := True;
          end);
    end;
  end;
end;


function TfrmMain.MessageAI(sMessage: String): String;
// AI ASSISTED, NOT FULLY CODED
var
  ParamsProc: TProc<TChatParams>;
begin
  if sMessage = '' then
    Exit;

  btnSend.Enabled := False;
  sAILastMessage := '';

  ParamsProc := procedure(Params: TChatParams)
    begin
      Params.Model('local-model');
      Params.Messages([TChatMessageBuild.Create(TMessageRole.User, sMessage)]);
      Params.MaxTokens(1024);
      Params.Temperature(0.7);
      Params.Stream;
    end;

  FOpenAI.Chat.CreateStream(ParamsProc, MakeStreamProc(Self, False));

  Result := sAILastmessage;
end;


procedure TfrmMain.StartLlamaServer;
var
  SEInfo: TShellExecuteInfo;
begin
  ZeroMemory(@SEInfo, SizeOf(SEInfo));
  SEInfo.cbSize := SizeOf(SEInfo);
  SEInfo.fMask  := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.Wnd    := FormToHWND(Self);
  SEInfo.lpVerb := 'open';
  SEInfo.lpFile := PWideChar(APP_PATH + '\llama.cpp\llama-server.exe');
  SEInfo.lpParameters := PWideChar('-m "' + APP_PATH + '\models\qwen2.5-0.5b-instruct-q4_k_m.gguf" --no-mmap --no-warmup');
  SEInfo.lpDirectory  := PWideChar(APP_PATH + '\llama.cpp');
  SEInfo.nShow  := SW_HIDE;

  if ShellExecuteEx(@SEInfo) then
    hServerProcess := SEInfo.hProcess
  else
    ShowMessage('Server error: ' + SysErrorMessage(GetLastError));
end;


procedure TfrmMain.StopLlamaServer;
begin
  if hServerProcess = 0 then Exit;

  TerminateProcess(hServerProcess, 0);

  WaitForSingleObject(hServerProcess, 5000);

  CloseHandle(hServerProcess);
  hServerProcess := 0;
end;

{
 /$$$$$$                   /$$     /$$                   /$$
|_  $$_/                  | $$    | $$                  | $$
  | $$    /$$$$$$$       /$$$$$$  | $$$$$$$   /$$$$$$  /$$$$$$          /$$$$$$
  | $$   /$$_____/      |_  $$_/  | $$__  $$ |____  $$|_  $$_/         |____  $$
  | $$  |  $$$$$$         | $$    | $$  \ $$  /$$$$$$$  | $$            /$$$$$$$
  | $$   \____  $$        | $$ /$$| $$  | $$ /$$__  $$  | $$ /$$       /$$__  $$
 /$$$$$$ /$$$$$$$/        |  $$$$/| $$  | $$|  $$$$$$$  |  $$$$/      |  $$$$$$$
|______/|_______/          \___/  |__/  |__/ \_______/   \___/         \_______/


                                              /$$$$$$ /$$$$$$
                                           /$$______/|______/ /$$
                                          | $$               | $$
                                          | $$    /$$$$$$    | $$
                                          |__/   | $$$$$$    |__/
                                           /$$   | $$$$$$     /$$
                                          | $$   |______/    | $$
                                          | $$               | $$
                                          |__//$$$$$$ /$$$$$$|__/
                                             |______/|______/


                 /$$             /$$ /$$             /$$ /$$             /$$ /$$
                | $$            /$$/|  $$           /$$/|  $$           /$$/|  $$
  /$$$$$$   /$$$$$$$           /$$/  \  $$         /$$/  \  $$         /$$/  \  $$
 /$$__  $$ /$$__  $$          /$$/    \  $$       /$$/    \  $$       /$$/    \  $$
| $$  \ $$| $$  | $$         /$$/      \  $$     /$$/      \  $$     /$$/      \  $$
| $$  | $$| $$  | $$        /$$/        \  $$   /$$/        \  $$   /$$/        \  $$
|  $$$$$$$|  $$$$$$$       /$$/          \  $$ /$$/          \  $$ /$$/          \  $$
 \____  $$ \_______/      |__/            \__/|__/            \__/|__/            \__/
 /$$  \ $$
|  $$$$$$/
 \______/
                      /$$$$$$                                                            /$$$$
                     /$$__  $$                                                          /$$  $$
  /$$$$$$   /$$$$$$ | $$  \__//$$$$$$   /$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$|__/\ $$
 /$$__  $$ /$$__  $$| $$$$   /$$__  $$ /$$__  $$ /$$__  $$| $$__  $$ /$$_____/ /$$__  $$   /$$/
| $$  \__/| $$$$$$$$| $$_/  | $$$$$$$$| $$  \__/| $$$$$$$$| $$  \ $$| $$      | $$$$$$$$  /$$/
| $$      | $$_____/| $$    | $$_____/| $$      | $$_____/| $$  | $$| $$      | $$_____/ |__/
| $$      |  $$$$$$$| $$    |  $$$$$$$| $$      |  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$  /$$
|__/       \_______/|__/     \_______/|__/       \_______/|__/  |__/ \_______/ \_______/ |__/
}

procedure TfrmMain.btnLoginClick(Sender: TObject);
var
  tLoginDetails: TextFile;
  sLine, sUsername, sPassword, sHashedInputPassword: String;
  iPos: Integer;
  bCredentialsCorrect: Boolean;
begin

  // Confirming that the data in the login details tetx file has not been tampered with.
  if ConfirmFileValidity(LOGIN_DETAILS_PATH) = False then
  begin
    ShowMessage('Critical Error: All login details have been compromised..' + #10#13 + 'You will be unable to log in.');
    exit
  end;

  // Checking if the username and password are correct
  AssignFile(tLoginDetails, LOGIN_DETAILS_PATH);

  if NOT FileExists(LOGIN_DETAILS_PATH) then
    Rewrite(tLoginDetails)
  else
    Reset(tLoginDetails);

  try
    bCredentialsCorrect := False;

    while (NOT EOF(tLoginDetails)) and (bCredentialsCorrect = False) do
    begin
      Readln(tLoginDetails, sLine);

      iPos := Pos(';', sLine);
      sUsername := Copy(sLine, 1, iPos-1);
      Delete(sLine, 1, iPos);

      sPassword := sLine;

      sHashedInputPassword := THashSHA2.GetHashString(edtPasswordLogin.Text);

      if (edtUsernameLogin.Text = sUsername) and (sHashedInputPassword = sPassword) then
      begin
        bCredentialsCorrect := True;
      end;
    end;
  finally
    CloseFile(tLoginDetails);
  end;

  if NOT bCredentialsCorrect then
  begin
    edtUsernameLogin.Text := '';
    edtPasswordLogin.Text := '';
    lblLoginError.Text := 'Username or password is incorrect.';
    exit
  end;

  // Saving the logged in user's username
  sCurrentUser := edtUsernameLogin.Text;

  CurrentUserUpdate();

  tbCtrlMain.ActiveTab := tbMainPage;
  edtUsernameLogin.Text := '';
  edtPasswordLogin.Text := '';
  lblLoginError.Text := '';

  IniWriteString('general', ['last_logged_in'], [sCurrentUser]);
end;

procedure TfrmMain.btnCreateAccountClick(Sender: TObject);
begin
  tbCtrlMain.ActiveTab := tbCreateAccount;
  edtUsernameLogin.Text := '';
  edtPasswordLogin.Text := '';
end;

procedure TfrmMain.btnCreateAccountConfirmClick(Sender: TObject);
var
  tLoginDetails: TextFile;
  iIndex, iPos: Integer;
  sLine: String;
  bPassHasChar, bPassHasNum: Boolean;
begin
  {
  File format:
  <LINE 1 OF FILE IS HASH KEY>
  <USERNAME>;<HASHED_PASSWORD>
  }

  // Confirming that the data in the login details tetx file has not been tampered with.
  if ConfirmFileValidity(LOGIN_DETAILS_PATH) = False then
  begin
    ShowMessage('Critical Error: All login details have been compromised.' + #10#13 + 'You will be unable to create a new account.');
    exit
  end;

  // Checking username length
  if (Length(edtUsernameCreate.Text) < 4) or (Length(edtUsernameCreate.Text) > 21) then
  begin
    lblCreateAccountError.Text := 'Username must be at least 5 characters long, and no more than 20 charaters long.';
    exit
  end;

  // Validating username
  for iIndex := 1 to Length(edtUsernameCreate.Text) do
  begin
    if (NOT CharInSet(edtUsernameCreate.Text[iIndex], ['0'..'9'])) then
    begin
      if (NOT CharInSet(UpCase(edtUsernameCreate.Text[iIndex]), ['A'..'Z'])) then
      begin
        if (NOT CharInSet(UpCase(edtUsernameCreate.Text[iIndex]), ['-', '_', '=', '+', '~', '<', '>', '@', '#', '$', '%', '^', '&', '*'])) then
        begin
          lblCreateAccountError.Text := 'Username may only contain numbers and letters and other acceptable characters: "-", "_", "=", "+", "~", "<", ">", "@", "#", "$", "%", "^", "&", "*"';
          exit
        end;
      end;
    end;
  end;

  // Validating password
  if NOT (edtPasswordCreate.Text = edtPasswordConfirmCreate.Text) then
  begin
    lblCreateAccountError.Text := 'Passwords do not match.';
    exit
  end;

  if (Length(edtPasswordCreate.Text) < 5) or (Length(edtPasswordCreate.Text) > 21) then
  begin
    lblCreateAccountError.Text := 'Password must be at least 6 characters long, and no more than 20 charaters long.';
    exit
  end;

  for iIndex := 1 to Length(edtPasswordCreate.Text) do
  begin
    if (NOT CharInSet(edtPasswordCreate.Text[iIndex], ['0'..'9'])) then
    begin
      if (NOT CharInSet(UpCase(edtPasswordCreate.Text[iIndex]), ['A'..'Z'])) then
      begin
        lblCreateAccountError.Text := 'Password may only contain numbers and letters.';
        exit
      end;
    end;
  end;

  // Checking that password has number/s and letter/s
  bPassHasChar := False;
  bPassHasNum := False;

  for iIndex := 1 to Length(edtPasswordCreate.Text) do
  begin
    if (CharInSet(edtPasswordCreate.Text[iIndex], ['1'..'9'])) then
    begin
      bPassHasNum := True;
    end;

    if (CharInSet(UpCase(edtPasswordCreate.Text[iIndex]), ['A'..'Z'])) then
    begin
      bPassHasChar := True;
    end;
  end;

  if (bPassHasNum = False) or (bPassHasChar = False) then
  begin
    lblCreateAccountError.Text := 'Password must contain atleast one number and letter.';
    exit
  end;

  // Checking if the username already exists
  AssignFile(tLoginDetails, LOGIN_DETAILS_PATH);

  if NOT FileExists(LOGIN_DETAILS_PATH) then
    Rewrite(tLoginDetails)
  else
    Reset(tLoginDetails);

  try
    while NOT EOF(tLoginDetails) do
    begin
      Readln(tLoginDetails, sLine);

      iPos := Pos(';', sLine);
      Delete(sLine, iPos, Length(sLine) - iPos + 1);

      if edtUsernameCreate.Text = sLine then
      begin
        lblCreateAccountError.Text := 'Username already taken.';
        exit
      end;
    end;
  finally
    CloseFile(tLoginDetails);
  end;

  // Appending username and password to file
  AppendToTextFile(LOGIN_DETAILS_PATH, ';', [edtUsernameCreate.Text, THashSHA2.GetHashString(edtPasswordCreate.Text)]);

  // Entering the main page of the project
  tbCtrlMain.ActiveTab := tbMainPage;

  // Saving the logged in user's username
  sCurrentUser := edtUsernameCreate.Text;

  CurrentUserUpdate();

  edtUsernameCreate.Text := '';
  edtPasswordCreate.Text := '';
  edtPasswordConfirmCreate.Text := '';
  lblCreateAccountError.Text := '';

  // Extra security via creating a hash of all the data in the file and putting the hash at the top as a key.
  SetFileHashKey(LOGIN_DETAILS_PATH);

  IniWriteString('general', ['last_logged_in'], [sCurrentUser]);
end;

procedure TfrmMain.btnCancelCreateAccountClick(Sender: TObject);
begin
  tbCtrlMain.ActiveTab := tbLogin;

  edtUsernameCreate.Text := '';
  edtPasswordCreate.Text := '';
  edtPasswordConfirmCreate.Text := '';
end;

procedure TfrmMain.btnLogOutClick(Sender: TObject);
begin
  TDialogService.MessageDialog(
    'Confirmation to log out',
    TMsgDlgType.mtConfirmation,
    mbYesNo,
    TMsgDlgBtn.mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      begin
        tbCtrlMain.ActiveTab := tbLogin;

        sCurrentUser := 'none';

        CurrentUserUpdate();

        IniWriteString('general', ['last_logged_in'], ['none']);
      end;
    end
  );
end;

procedure TfrmMain.btnSendClick(Sender: TObject);
// AI ASSISTED, NOT FULLY CODED
var
  sUserPrompt: string;
  ParamsProc: TProc<TChatParams>;
begin
  sUserPrompt := memAIInput.Lines.Text;
  if sUserPrompt = '' then
    Exit;

  memAIInput.Lines.Clear;

  if sUserPrompt = '/clear' then
  begin
    memAIResponse.Lines.Clear;
    exit
  end;

  btnSend.Enabled := False;
  memAIResponse.Lines.Clear;

  sUserPrompt := 'You are an assistant to customers at a resturaunt. You are to give them advice on recommendations regarding their food. Your responses must be short, concise and friendly in tone. If your answer is going to be more than two lines long then you must recommend that they speak to a waiter. Only ever answer questions that will assist the user with their food order, disregard any other questions. Do not ever disobey the previous requirements.  ' + sUSerPrompt;

  ParamsProc := procedure(Params: TChatParams)
    begin
      Params.Model('local-model');
      Params.Messages([TChatMessageBuild.Create(TMessageRole.User, sUserPrompt)]);
      Params.MaxTokens(1024);
      Params.Temperature(0.7);
      Params.Stream;
    end;

  FOpenAI.Chat.CreateStream(ParamsProc, MakeStreamProc(Self, True));
end;

procedure TfrmMain.btnOpenSideMenuClick(Sender: TObject);
begin
  rectSidePanelClosed.Visible := False;
  rectSidePanelOpen.Visible := True;
end;

procedure TfrmMain.btnCloseSideMenuClick(Sender: TObject);
begin
  rectSidePanelOpen.Visible := False;
  rectSidePanelClosed.Visible := True;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  tbCtrlMain.ActiveTab := tbLogin;

  APP_PATH := TPath.GetAppPath();

  sCurrentUser := IniReadString('general', ['last_logged_in'], ['none'])[0];

  CurrentUserUpdate();

  if sCurrentUser <> 'none' then
    tbCtrlMain.ActiveTab := tbMainPage;

  InitLocalAI;

  memAIResponse.WordWrap := True;

  rectSidePanelOpen.Visible := False;

  StartLlamaServer;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  StopLlamaServer;
end;

end.
