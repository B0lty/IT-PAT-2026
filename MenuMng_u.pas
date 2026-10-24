unit MenuMng_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, FMX.Edit, FMX.DialogService, System.Skia, FMX.Skia;

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
    svgLogo: TSkSvg;
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
    procedure edtMenuNameValidating(Sender: TObject; var Text: string);
    procedure edtMenuNameValidate(Sender: TObject; var Text: string);
    procedure edtMenuPriceValidating(Sender: TObject; var Text: string);
    procedure edtMenuPriceValidate(Sender: TObject; var Text: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenu: TfrmMenu;

implementation

uses Main_u, DB_u, Helpers_u;

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

  lblMenuCount.Text	:= 'Items: ' + IntToStr(dbOrders.tblMenu.RecordCount);
end;

procedure TfrmMenu.btnMenuAddClick(Sender: TObject);
begin
  if edtMenuPrice.Text = '' then
  begin
    ShowMessage('Input a price.');
    exit;
  end;

  if edtMenuName.Text = '' then
  begin
    ShowMessage('Input an item name.');
    exit;
  end;

  if cmbMenuCategory.Text = '' then
  begin
    ShowMessage('Input a category.');
    exit;
  end;

  try
    dbOrders.AppendMenu(edtMenuName.Text, cmbMenuCategory.Text, StrToFloat(edtMenuPrice.Text));

    dbOrders.LoadMenu;

    grdMenu.SelectRow(grdMenu.RowCount - 1);
    UpdateRowData(grdMenu.RowCount - 1);
  except
    ShowMessage('Add failed. Contact support.');
  end;

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
var
  iItem: Integer;
begin
  if grdMenu.Row < 0 then
  begin
    ShowMessage('No row selected.');
    exit;
  end;

  TDialogService.MessageDialog(
    'Confirmation to delete this item from the menu.',
    TMsgDlgType.mtConfirmation,
    mbYesNo,
    TMsgDlgBtn.mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      begin
        try
          dbOrders.DeleteMenuItem(StrToInt(grdMenu.Cells[3, grdMenu.Row]));

          dbOrders.LoadMenu;
          UpdateRowData(grdMenu.Row);
        except
          ShowMessage('Deletion failed. Contact support.');
        end;
      end;
    end
  );
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
  if grdMenu.Row < 0 then
  begin
    ShowMessage('No row selected.');
    exit;
  end;

  if edtMenuPrice.Text = '' then
  begin
    ShowMessage('Input a price.');
    exit;
  end;

  if edtMenuName.Text = '' then
  begin
    ShowMessage('Input an item name.');
    exit;
  end;

  if cmbMenuCategory.Text = '' then
  begin
    ShowMessage('Input a category.');
    exit;
  end;

  try
    dbOrders.UpdateMenu(edtMenuName.Text, cmbMenuCategory.Text, StrToFloat(edtMenuPrice.Text),
    StrToInt(grdMenu.Cells[3, grdMenu.Row]));

    dbOrders.LoadMenu;
    UpdateRowData(grdMenu.Row);
  except
    ShowMessage('Update failed. Contact support.');
  end;
end;

procedure TfrmMenu.edtMenuNameValidate(Sender: TObject; var Text: string);
begin
  Text := Text.Trim;

  if Length(Text) > 40 then
    Delete(Text, 41, Length(Text) - 40);
end;

procedure TfrmMenu.edtMenuNameValidating(Sender: TObject; var Text: string);
begin
  Text := Text.TrimLeft;

  if Length(Text) > 40 then
    Delete(Text, 41, Length(Text) - 40);
end;

procedure TfrmMenu.edtMenuPriceValidate(Sender: TObject; var Text: string);
begin
  if Length(Text) < 1 then
    exit;

  if CharInSet(Text[1], [',','.']) then
    Delete(Text, 1, 1);
  if CharInSet(Text[Length(Text)], [',','.']) then
    Delete(Text, Length(Text), 1);

  Text := StringReplace(Text, #0, '', []);
end;

procedure TfrmMenu.edtMenuPriceValidating(Sender: TObject; var Text: string);
var
  bDecimalPt: Boolean;
  i: Integer;
begin
  if Length(Text) < 1 then
    exit;

  if CharInSet(Text[1], [',','.']) then
    Delete(Text, 1, 1);

  bDecimalPt := False;
  for i := 1 to Length(Text) do
  begin
    if bDecimalPt AND CharInSet(Text[i], [',','.']) then
      Text[i] := #0;
    if CharInSet(Text[i], [',','.']) then
      bDecimalPt := True;
  end;

  if Length(Text) < 1 then
    exit;

//  if Text[Length(Text)] = #0 then
//    Delete(Text, Length(Text), 1);
  Text := StringReplace(Text, #0, '', []);

end;

procedure TfrmMenu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.SwapForm(frmMenu, frmMain);
end;

procedure TfrmMenu.FormShow(Sender: TObject);
begin
  dbOrders.LoadMenu;
  UpdateRowData(-1);

  // Applying filters to edits
  edtMenuName.FilterChar := FHelpers.ALPHANUMERIC + '-+';
  edtMenuPrice.FilterChar := FHelpers.NUMERIC + ',.';
end;

procedure TfrmMenu.grdMenuCellClick(const Column: TColumn; const Row: Integer);
begin
  UpdateRowData(grdMenu.Row);
end;

end.
