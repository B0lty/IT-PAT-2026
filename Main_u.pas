unit Main_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.Objects,
  FMX.Styles.Objects, FMX.TabControl, FMX.DialogService, System.Hash, System.IniFiles,
  System.IOUtils, System.JSON,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, OpenAI, OpenAI.Chat,
  OpenAI.Errors, OpenAI.Component.Chat, Winapi.ShellAPI, Winapi.Windows, FMX.Platform.Win,
  Login_u, CreateAcc_u, MenuMng_u, Order_u, Reports_u, Helpers_u, DB_u;

type
  TfrmMain = class(TForm)
    Panel6: TPanel;
    Button1: TButton;
    lblCurrentUser: TLabel;
    rectSidePanelClosed: TRectangle;
    Rectangle9: TRectangle;
    Button2: TButton;
    Label14: TLabel;
    rectSidePanelOpen: TRectangle;
    btnSend: TButton;
    memAIInput: TMemo;
    memAIResponse: TMemo;
    Rectangle11: TRectangle;
    Button4: TButton;
    Label15: TLabel;
    Label16: TLabel;
    btnNavMenu: TButton;
    btnNavOrders: TButton;
    btnNavReports: TButton;
    lblPortalTitle: TLabel;
    procedure btnLogOutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnOpenSideMenuClick(Sender: TObject);
    procedure btnCloseSideMenuClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNavMenuClick(Sender: TObject);
    procedure btnNavOrdersClick(Sender: TObject);
    procedure btnNavReportsClick(Sender: TObject);
    procedure memAIInputKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure InitLocalAI;
    function MakeStreamProc(Form: TfrmMain; bShowMessage: Boolean): TChatEvent;
    function MessageAI(sMessage: String; bDisplay: Boolean): String;
    procedure StartLlamaServer;
    procedure StopLlamaServer;

    var
      FOpenAI: IOpenAI;
      sAILastMessage: String;
      hServerProcess: THandle;

    const
      sPrePrompt = 'You are an assistant to customers at a resturaunt. You are to give them advice on recommendations ' +
      'regarding their food. Your responses must be short, concise and friendly in tone. If your answer is going to ' +
      'be more than two lines long then you must recommend that they speak to a waiter. Only ever answer questions ' +
      'that will assist the user with their food order, disregard any other questions. Do not ever disobey the ' +
      'previous requirements.' + sLineBreak;
  public
    { Public declarations }
    procedure CurrentUserUpdate();
    procedure SwapForm(aFrom, aTo: TForm);
    var
      LOGIN_DETAILS_PATH: String;
    const
      VAT = 0.15;
  end;

var
  frmMain: TfrmMain;
  sCurrentUser: String;
  APP_PATH: String;
  GlobalPosTop, GlobalPosLeft: Integer;

implementation

{$R *.fmx}

procedure TfrmMain.SwapForm(aFrom, aTo: TForm);
begin
  if aFrom <> nil then
  begin
    GlobalPosLeft := aFrom.Left;
    GlobalPosTop  := aFrom.Top;
  end;

  aTo.Position := TFormPosition.Designed;
  aTo.Left := GlobalPosLeft;
  aTo.Top  := GlobalPosTop;

  if aFrom <> nil then
    aFrom.Hide;

  aTo.Show;
end;


procedure TfrmMain.CurrentUserUpdate();
begin
  lblCurrentUser.Text := 'Logged in as: ' + sCurrentUser;
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


procedure TfrmMain.memAIInputKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnSendClick(Sender);
end;

function TfrmMain.MessageAI(sMessage: String; bDisplay: Boolean): String;
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

  FOpenAI.Chat.CreateStream(ParamsProc, MakeStreamProc(Self, bDisplay));

  if bDisplay = False then
    Result := sAILastMessage
  else
    Result := 'none';
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
        SwapForm(frmMain, frmLogin);

        sCurrentUser := 'none';

        CurrentUserUpdate();

        FHelpers.IniWriteString('general', ['last_logged_in'], ['none']);
      end;
    end
  );
end;

procedure TfrmMain.btnNavMenuClick(Sender: TObject);
begin
  SwapForm(frmMain, frmMenu);
end;

procedure TfrmMain.btnNavOrdersClick(Sender: TObject);
begin
  SwapForm(frmMain, frmOrder);
end;

procedure TfrmMain.btnNavReportsClick(Sender: TObject);
begin
  SwapForm(frmMain, frmReports);
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

  sUserPrompt := sPrePrompt + sUSerPrompt;

  MessageAI(sUserPrompt, True);
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
  FHelpers := THelperFunc.Create;

  APP_PATH := TPath.GetAppPath();

  LOGIN_DETAILS_PATH := TPath.Combine(APP_PATH, 'data\login-details.txt');

  sCurrentUser := FHelpers.IniReadString('general', ['last_logged_in'], ['none'])[0];

  CurrentUserUpdate;

  InitLocalAI;

  memAIResponse.WordWrap := True;

  rectSidePanelOpen.Visible := False;

  StartLlamaServer;

  // Start the link to the DB and set up the tables
  dbOrders := TdbOrders.Create(APP_PATH + '/data/OrderDB.mdb');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  StopLlamaServer;

  FHelpers.Free;
  dbOrders.Free;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  sCurrentUser := FHelpers.IniReadString('general', ['last_logged_in'], ['none'])[0];

  CurrentUserUpdate;

  if sCurrentUser = 'none' then
  begin
    SwapForm(frmMain, frmLogin);
  end;
end;

end.
