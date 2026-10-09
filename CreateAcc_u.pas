unit CreateAcc_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCreateAcc: TfrmCreateAcc;

implementation

{$R *.fmx}

end.
