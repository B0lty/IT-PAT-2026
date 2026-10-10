unit MenuMng_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, FMX.Edit;

type
  TfrmMenu = class(TForm)
    btnMenuAdd: TButton;
    btnMenuBack: TButton;
    btnMenuClear: TButton;
    btnMenuDelete: TButton;
    btnMenuFirst: TButton;
    btnMenuLast: TButton;
    btnMenuNext: TButton;
    btnMenuPrev: TButton;
    btnMenuRefresh: TButton;
    btnMenuUpdate: TButton;
    cmbMenuCategory: TComboBox;
    edtMenuName: TEdit;
    edtMenuPrice: TEdit;
    grdMenu: TStringGrid;
    colMenuName: TStringColumn;
    colMenuCategory: TStringColumn;
    colMenuPrice: TStringColumn;
    lblMenuCategoryCaption: TLabel;
    lblMenuCount: TLabel;
    lblMenuError: TLabel;
    lblMenuNameCaption: TLabel;
    lblMenuNavCaption: TLabel;
    lblMenuPriceCaption: TLabel;
    lblMenuTitle: TLabel;
    colID: TStringColumn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnMenuBackClick(Sender: TObject);
    procedure btnMenuRefreshClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnMenuAddClick(Sender: TObject);
    procedure btnMenuClearClick(Sender: TObject);
    procedure btnMenuNextClick(Sender: TObject);
    procedure btnMenuPrevClick(Sender: TObject);
    procedure btnMenuLastClick(Sender: TObject);
    procedure btnMenuFirstClick(Sender: TObject);
    procedure UpdateRowData(iRow: Integer);
    procedure btnMenuDeleteClick(Sender: TObject);
    procedure btnMenuUpdateClick(Sender: TObject);
    procedure grdMenuCellClick(const Column: TColumn; const Row: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenu: TfrmMenu;

implementation

uses Main_u, DB_u;

{$R *.fmx}

procedure TfrmMenu.UpdateRowData(iRow: Integer);
begin
  edtMenuName.Text := grdMenu.Cells[0, iRow];
  edtMenuPrice.Text := grdMenu.Cells[2, iRow];

  if grdMenu.Cells[1, iRow] = 'Starters' then
    cmbMenuCategory.ItemIndex := 0;
  if grdMenu.Cells[1, iRow] = 'Mains' then
    cmbMenuCategory.ItemIndex := 1;
  if grdMenu.Cells[1, iRow] = 'Desserts' then
    cmbMenuCategory.ItemIndex := 2;
  if grdMenu.Cells[1, iRow] = 'Drinks' then
    cmbMenuCategory.ItemIndex := 3;

  lblMenuCount.Text	:= 'Records: ' + IntToStr(dbOrders.tblMenu.RecordCount);
end;

procedure TfrmMenu.btnMenuAddClick(Sender: TObject);
begin
  dbOrders.AppendMenu(edtMenuName.Text, cmbMenuCategory.Text, StrToFloat(edtMenuPrice.Text));

  dbOrders.LoadMenu;

  grdMenu.SelectRow(grdMenu.RowCount - 1);
  UpdateRowData(grdMenu.RowCount - 1);
end;

procedure TfrmMenu.btnMenuBackClick(Sender: TObject);
begin
  frmMain.SwapForm(frmMenu, frmMain);
end;

procedure TfrmMenu.btnMenuClearClick(Sender: TObject);
begin
  edtMenuName.Text := '';
  edtMenuPrice.Text := '';
  cmbMenuCategory.ItemIndex := -1;

  grdMenu.SelectRow(-1);
end;

procedure TfrmMenu.btnMenuDeleteClick(Sender: TObject);
begin
  dbOrders.DeleteMenuItem(StrToInt(grdMenu.Cells[3, grdMenu.Row]));
  dbOrders.LoadMenu;
  UpdateRowData(grdMenu.Row);
end;

procedure TfrmMenu.btnMenuFirstClick(Sender: TObject);
begin
  grdMenu.SelectRow(0);
  UpdateRowData(grdMenu.Row);
end;

procedure TfrmMenu.btnMenuLastClick(Sender: TObject);
begin
  grdMenu.SelectRow(grdMenu.RowCount - 1);
  UpdateRowData(grdMenu.Row);
end;

procedure TfrmMenu.btnMenuNextClick(Sender: TObject);
begin
  if grdMenu.Row < grdMenu.RowCount - 1 then
    grdMenu.SelectRow(grdMenu.Row + 1);
  UpdateRowData(grdMenu.Row);
end;

procedure TfrmMenu.btnMenuPrevClick(Sender: TObject);
begin
  if grdMenu.Row > 0 then
    grdMenu.SelectRow(grdMenu.Row - 1);
  UpdateRowData(grdMenu.Row);
end;

procedure TfrmMenu.btnMenuRefreshClick(Sender: TObject);
begin
  dbOrders.LoadMenu;
end;

procedure TfrmMenu.btnMenuUpdateClick(Sender: TObject);
begin
  dbOrders.UpdateMenu(edtMenuName.Text, cmbMenuCategory.Text, StrToFloat(edtMenuPrice.Text),
  StrToInt(grdMenu.Cells[3, grdMenu.Row]));
  dbOrders.LoadMenu;
  UpdateRowData(grdMenu.Row);
end;

procedure TfrmMenu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.Close;
end;

procedure TfrmMenu.FormShow(Sender: TObject);
begin
  dbOrders.LoadMenu;
  UpdateRowData(-1);
end;

procedure TfrmMenu.grdMenuCellClick(const Column: TColumn; const Row: Integer);
begin
  UpdateRowData(grdMenu.Row);
end;

end.
