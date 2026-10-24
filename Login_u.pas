unit Login_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, System.Hash,
  Helpers_u, System.Skia, FMX.Skia;

type
  TfrmLogin = class(TForm)
    Label8: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    btnLogin: TButton;
    btnCreateAccount: TButton;
    Rectangle1: TRectangle;
    edtPasswordLogin: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Rectangle2: TRectangle;
    edtUsernameLogin: TEdit;
    Label3: TLabel;
    lblLoginError: TLabel;
    svgLogo: TSkSvg;
    procedure btnLoginClick(Sender: TObject);
    procedure btnCreateAccountClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses Main_u, CreateAcc_u;

{$R *.fmx}



procedure TfrmLogin.btnCreateAccountClick(Sender: TObject);
begin
  frmMain.SwapForm(frmLogin, frmCreateAcc);
  edtUsernameLogin.Text := '';
  edtPasswordLogin.Text := '';
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  tLoginDetails: TextFile;
  sLine, sUsername, sPassword, sHashedInputPassword: String;
  iPos: Integer;
  bCredentialsCorrect: Boolean;
begin
  // Confirming that the data in the login details tetx file has not been tampered with.
  if FHelpers.ConfirmFileValidity(frmMain.LOGIN_DETAILS_PATH) = False then
  begin
    ShowMessage('Critical Error: All login details have been compromised..' + #10#13 + 'You will be unable to log in.');
    exit
  end;

  // Checking if the username and password are correct
  AssignFile(tLoginDetails, frmMain.LOGIN_DETAILS_PATH);

  if NOT FileExists(frmMain.LOGIN_DETAILS_PATH) then
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
  Main_u.sCurrentUser := edtUsernameLogin.Text;
  FHelpers.IniWriteString('general', ['last_logged_in'], [edtUsernameLogin.Text]);

  frmMain.CurrentUserUpdate();

  frmMain.SwapForm(frmLogin, frmMain);

  edtUsernameLogin.Text := '';
  edtPasswordLogin.Text := '';
  lblLoginError.Text := '';
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.Close;
end;

end.
