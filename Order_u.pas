unit Order_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, FMX.Edit,
  Helpers_u, System.Skia, FMX.Skia;

type
  TfrmOrder = class(TForm)
    btnOrderAddItem: TButton;
    btnOrderBack: TButton;
    btnOrderClear: TButton;
    btnOrderExport: TButton;
    btnOrderRemoveLine: TButton;
    btnOrderSave: TButton;
    cmbOrderItem: TComboBox;
    edtOrderAmount: TEdit;
    edtOrderCustomer: TEdit;
    edtOrderTable: TEdit;
    edtOrderWaiter: TEdit;
    grdOrderLines: TStringGrid;
    colOrderItem: TStringColumn;
    colOrderPrice: TStringColumn;
    colOrderQty: TStringColumn;
    colOrderLine: TStringColumn;
    lblOrderAmountCaption: TLabel;
    lblOrderCustomerCaption: TLabel;
    lblOrderError: TLabel;
    lblOrderItemCaption: TLabel;
    lblOrderLinesCaption: TLabel;
    lblOrderSubtotalCaption: TLabel;
    lblOrderSubtotalValue: TLabel;
    lblOrderTableCaption: TLabel;
    lblOrderTitle: TLabel;
    lblOrderTotalCaption: TLabel;
    lblOrderTotalValue: TLabel;
    lblOrderVatCaption: TLabel;
    lblOrderVatValue: TLabel;
    lblOrderWaiterCaption: TLabel;
    svgLogo: TSkSvg;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOrderBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOrderClearClick(Sender: TObject);
    procedure UpdateOrderDisplay;
    procedure btnOrderAddItemClick(Sender: TObject);
    function IndexToID(iIndex: Integer): Integer;
    procedure btnOrderRemoveLineClick(Sender: TObject);
    procedure btnOrderSaveClick(Sender: TObject);
    procedure btnOrderExportClick(Sender: TObject);
    procedure edtOrderWaiterValidate(Sender: TObject; var Text: string);
    procedure edtOrderWaiterValidating(Sender: TObject; var Text: string);
    procedure edtOrderCustomerValidate(Sender: TObject; var Text: string);
    procedure edtOrderCustomerValidating(Sender: TObject; var Text: string);
    procedure edtOrderAmountValidating(Sender: TObject; var Text: string);
    procedure edtOrderTableValidating(Sender: TObject; var Text: string);
  private
    { Private declarations }
    var
      iPrevOrderID: Integer;
  public
    { Public declarations }
    var
      // Stores the PK of each menu item and its index in the combobox, formatted as <index, PK>
      arrMenuIndexToID: TArray<array[0.. 1] of Integer>;

      // The PK of the menu item and the QTY to be purchased, formatted as <PK, QTY>
      arrNewOrder: TArray<TOrderLine>;
  end;

var
  frmOrder: TfrmOrder;

implementation

uses Main_u, DB_u;

{$R *.fmx}

function TfrmOrder.IndexToID(iIndex: Integer): Integer;
var
  i: Integer;
begin
  for i := 0 to Length(arrMenuIndexToID) - 1 do
  begin
    if arrMenuIndexToID[i][0] = iIndex then
    begin
      result := arrMenuIndexToID[i][1];
      exit;
    end;
  end;

  result := -1;
end;

procedure TfrmOrder.UpdateOrderDisplay;
var
  i: Integer;
  dSubtotal: Double;
begin
  if Length(arrNewOrder) < 1 then
  begin
    grdOrderLines.RowCount := 1;
    grdOrderLines.Cells[0, 0] := '';
    grdOrderLines.Cells[1, 0] := '';
    grdOrderLines.Cells[2, 0] := '';
    grdOrderLines.Cells[3, 0] := '';

    lblOrderSubtotalValue.Text := 'R 0.00';
    lblOrderVatValue.Text := 'R 0.00';
    lblOrderTotalValue.Text := 'R 0.00';

    exit;
  end;

  grdOrderLines.RowCount := Length(arrNewOrder);
  dSubtotal := 0;

  for i := 0 to Length(arrNewOrder) - 1 do
  begin
    grdOrderLines.Cells[0, i] := dbOrders.GetMenuItemName(arrNewOrder[i][0]);
    grdOrderLines.Cells[1, i] := FloatToStr(dbOrders.GetMenuItemPrice(arrNewOrder[i][0]));
    grdOrderLines.Cells[2, i] := IntToStr(arrNewOrder[i][1]);
    grdOrderLines.Cells[3, i] := FloatToStr(StrToFloat(grdOrderLines.Cells[1, i]) * StrToInt(grdOrderLines.Cells[2, i]));

    dSubtotal := dSubtotal + StrToFloat(grdOrderLines.Cells[3, i]);
  end;

  lblOrderSubtotalValue.Text := 'R ' + FloatToStrF(dSubtotal, ffFixed, 10, 2);
  lblOrderVatValue.Text := 'R ' + FloatToStrF(dSubtotal * frmMain.VAT, ffFixed, 10, 2);
  lblOrderTotalValue.Text := 'R ' + FloatToStrF(dSubtotal * frmMain.VAT + dSubtotal, ffFixed, 10, 2);;

end;

procedure TfrmOrder.btnOrderAddItemClick(Sender: TObject);
var
  iAmount: Integer;
begin
  if cmbOrderItem.ItemIndex < 0 then
  begin
    ShowMessage('Select an item.');
    exit;
  end;

  if TryStrToInt(edtOrderAmount.Text, iAmount) = False then
  begin
    ShowMessage('Amount invalid. Err: Not a string');
    exit;
  end;

  if NOT (iAmount > 0) then
  begin
    ShowMessage('Amount too low.');
    exit;
  end;

  SetLength(arrNewOrder, Length(arrNewOrder) + 1);
  arrNewOrder[Length(arrNewOrder) - 1][0] := IndexToID(cmbOrderItem.ItemIndex);
  arrNewOrder[Length(arrNewOrder) - 1][1] := iAmount;
  UpdateOrderDisplay;
end;

procedure TfrmOrder.btnOrderBackClick(Sender: TObject);
begin
  frmMain.SwapForm(frmOrder, frmMain);
end;

procedure TfrmOrder.btnOrderClearClick(Sender: TObject);
begin
  SetLength(arrNewOrder, 0);

  btnOrderSave.Text := 'Save Order';

  edtOrderCustomer.Text := '';
  edtOrderWaiter.Text := '';
  edtOrderTable.Text := '';

  cmbOrderItem.ItemIndex := -1;
  edtOrderAmount.Text := '1';

  iPrevOrderID := -1;

  btnOrderExport.Enabled := False;

  UpdateOrderDisplay;

  grdOrderLines.SelectRow(-1);
end;

procedure TfrmOrder.btnOrderExportClick(Sender: TObject);
begin
  dbOrders.ExportReceipt(Main_u.APP_PATH + '/data/receipts', iPrevOrderID);

  btnOrderClearClick(Sender);

  ShowMessage('Bill saved to: "' + Main_u.APP_PATH + '/data/receipts"');
end;

procedure TfrmOrder.btnOrderRemoveLineClick(Sender: TObject);
var
  iRowIndex, i: Integer;
begin
  if Length(arrNewOrder) < 1 then
  begin
    ShowMessage('No order lines to remove.');
    exit;
  end;

  iRowIndex := grdOrderLines.Row;
  if (iRowIndex < 0) or (iRowIndex >= Length(arrNewOrder)) then
  begin
    ShowMessage('Select an order line to remove.');
    exit;
  end;

  for i := iRowIndex to Length(arrNewOrder) - 2 do
    arrNewOrder[i] := arrNewOrder[i + 1];

  SetLength(arrNewOrder, Length(arrNewOrder) - 1);

  UpdateOrderDisplay;

  if Length(arrNewOrder) > 0 then
  begin
    if iRowIndex > Length(arrNewOrder) - 1 then
      iRowIndex := Length(arrNewOrder) - 1;
    grdOrderLines.SelectRow(iRowIndex);
  end
  else
    grdOrderLines.SelectRow(-1);
end;

procedure TfrmOrder.btnOrderSaveClick(Sender: TObject);
var
  iTableNo: Integer;
begin
  if Length(arrNewOrder) < 1 then
  begin
    ShowMessage('No items in order.');
    exit;
  end;

    if edtOrderWaiter.Text.Trim = '' then
  begin
    ShowMessage('Enter the waiter''s name.');
    exit;
  end;

  if edtOrderCustomer.Text.Trim = '' then
  begin
    ShowMessage('Enter the customer name or order description.');
    exit;
  end;

  if (not TryStrToInt(edtOrderTable.Text.Trim, iTableNo)) or (iTableNo < 1) or (iTableNo > 999) then
  begin
    ShowMessage('Enter a valid table number (1-999).');
    exit;
  end;

  if iPrevOrderID = -1 then
  begin
    iPrevOrderID := dbOrders.NewOrder(edtOrderWaiter.Text.Trim, edtOrderCustomer.Text.Trim,
      iTableNo, arrNewOrder);
    btnOrderSave.Text := 'Update Order';
    ShowMessage('Order saved.');
  end
  else
  begin
    dbOrders.UpdateOrder(edtOrderWaiter.Text.Trim, edtOrderCustomer.Text.Trim,
      iTableNo, arrNewOrder, iPrevOrderID);
    ShowMessage('Order updated.');
  end;

  btnOrderExport.Enabled := True;
end;
procedure TfrmOrder.edtOrderAmountValidating(Sender: TObject; var Text: string);
begin
  if Length(Text) > 3 then
    Delete(Text, 4, Length(Text) - 3);
end;

procedure TfrmOrder.edtOrderCustomerValidate(Sender: TObject; var Text: string);
begin
  Text := Text.Trim;

  if Length(Text) > 60 then
    Delete(Text, 61, Length(Text) - 60);
end;

procedure TfrmOrder.edtOrderCustomerValidating(Sender: TObject;
  var Text: string);
begin
  Text := Text.TrimLeft;

  if Length(Text) > 60 then
    Delete(Text, 61, Length(Text) - 60);
end;

procedure TfrmOrder.edtOrderTableValidating(Sender: TObject; var Text: string);
begin
  if Length(Text) > 3 then
    Delete(Text, 4, Length(Text) - 3);
end;

procedure TfrmOrder.edtOrderWaiterValidate(Sender: TObject; var Text: string);
begin
  Text := Text.Trim;

  if Length(Text) > 60 then
    Delete(Text, 61, Length(Text) - 60);
end;

procedure TfrmOrder.edtOrderWaiterValidating(Sender: TObject; var Text: string);
begin
  Text := Text.TrimLeft;

  if Length(Text) > 60 then
    Delete(Text, 61, Length(Text) - 60);
end;

procedure TfrmOrder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.SwapForm(frmOrder, frmMain);
end;

procedure TfrmOrder.FormShow(Sender: TObject);
begin
  dbOrders.LoadMenu;
  UpdateOrderDisplay;
  btnOrderClearClick(Sender);

  // Applying filters to edits
  edtOrderCustomer.FilterChar := FHelpers.ALPHABET + '-';
  edtOrderWaiter.FilterChar := FHelpers.ALPHABET + '-';
  edtOrderTable.FilterChar := FHelpers.NUMERIC;
  edtOrderAmount.FilterChar := FHelpers.NUMERIC;
end;

end.
