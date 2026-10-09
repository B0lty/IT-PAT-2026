program SmartEats;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit2 in 'Unit2.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
