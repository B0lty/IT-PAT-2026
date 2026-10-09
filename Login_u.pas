unit Login_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.fmx}

end.
