program SmartEats;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main_u in 'Main_u.pas' {frmMain},
  Login_u in 'Login_u.pas' {Form1},
  CreateAccount_u in 'CreateAccount_u.pas' {Form2},
  MenuManagement_u in 'MenuManagement_u.pas' {Form3},
  Order_u in 'Order_u.pas' {Form4},
  Reports_u in 'Reports_u.pas' {Form5};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
