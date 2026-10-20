unit CreateAcc_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, System.Hash,
  Helpers_u;

type
  TfrmCreateAcc = class(TForm)
    Label9: TLabel;
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
    lblCreateAccountError: TLabel;
    procedure btnCreateAccountConfirmClick(Sender: TObject);
    procedure btnCancelCreateAccountClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCreateAcc: TfrmCreateAcc;

implementation

uses Main_u, Login_u;

{$R *.fmx}

procedure TfrmCreateAcc.btnCancelCreateAccountClick(Sender: TObject);
begin
  frmMain.SwapForm(frmCreateAcc, frmLogin);

  edtUsernameCreate.Text := '';
  edtPasswordCreate.Text := '';
  edtPasswordConfirmCreate.Text := '';
end;


procedure TfrmCreateAcc.btnCreateAccountConfirmClick(Sender: TObject);
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
  if FHelpers.ConfirmFileValidity(frmMain.LOGIN_DETAILS_PATH) = False then
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
    if (CharInSet(edtPasswordCreate.Text[iIndex], ['0'..'9'])) then
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
  AssignFile(tLoginDetails, frmMain.LOGIN_DETAILS_PATH);

  if NOT FileExists(frmMain.LOGIN_DETAILS_PATH) then
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
  FHelpers.AppendToTextFile(frmMain.LOGIN_DETAILS_PATH, ';', [edtUsernameCreate.Text, THashSHA2.GetHashString(edtPasswordCreate.Text)]);

  // Updating current user
  Main_u.sCurrentUser := edtUsernameCreate.Text;
  FHelpers.IniWriteString('general', ['last_logged_in'], [edtUsernameCreate.Text]);

  frmMain.CurrentUserUpdate();

  // Entering the main page of the project
  frmMain.SwapForm(frmCreateAcc, frmMain);

  // Saving the logged in user's username
  // sCurrentUser := edtUsernameCreate.Text;

  frmMain.CurrentUserUpdate();

  edtUsernameCreate.Text := '';
  edtPasswordCreate.Text := '';
  edtPasswordConfirmCreate.Text := '';
  lblCreateAccountError.Text := '';

  // Extra security via creating a hash of all the data in the file and putting the hash at the top as a key.
  FHelpers.SetFileHashKey(frmMain.LOGIN_DETAILS_PATH);

  FHelpers.IniWriteString('general', ['last_logged_in'], [sCurrentUser]);
end;

procedure TfrmCreateAcc.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.Close;
end;

end.
