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

end.
