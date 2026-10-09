program SmartEats;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main_u in 'Main_u.pas' {frmMain},
  Login_u in 'Login_u.pas' {frmLogin},
  CreateAcc_u in 'CreateAcc_u.pas' {frmCreateAcc},
  MenuMng_u in 'MenuMng_u.pas' {frmMenu},
  Order_u in 'Order_u.pas' {frmOrder},
  Reports_u in 'Reports_u.pas' {frmReports},
  Helpers_u in 'Helpers_u.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmCreateAcc, frmCreateAcc);
  Application.CreateForm(TfrmMenu, frmMenu);
  Application.CreateForm(TfrmOrder, frmOrder);
  Application.CreateForm(TfrmReports, frmReports);
  Application.Run;
end.
