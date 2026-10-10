unit Reports_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo;

type
  TfrmReports = class(TForm)
    btnReportAll: TButton;
    btnReportBack: TButton;
    btnReportCategory: TButton;
    btnReportDaily: TButton;
    btnReportExport: TButton;
    btnReportPopular: TButton;
    lblReportError: TLabel;
    lblReportTitle: TLabel;
    memReport: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnReportBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmReports: TfrmReports;

implementation

uses Main_u;

{$R *.fmx}

procedure TfrmReports.btnReportBackClick(Sender: TObject);
begin
  frmMain.SwapForm(frmReports, frmMain);
end;

procedure TfrmReports.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.Close;
end;

end.
