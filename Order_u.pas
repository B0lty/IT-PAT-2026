unit Order_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, FMX.Edit,
  Helpers_u;

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
  //grdOrderLines.ClearContent;

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
begin
  SetLength(arrNewOrder, Length(arrNewOrder) + 1);
  arrNewOrder[Length(arrNewOrder) - 1][0] := IndexToID(cmbOrderItem.ItemIndex);
  arrNewOrder[Length(arrNewOrder) - 1][1] := StrToInt(edtOrderAmount.Text);
  UpdateOrderDisplay;
end;

procedure TfrmOrder.btnOrderBackClick(Sender: TObject);
begin
  frmMain.SwapForm(frmOrder, frmMain);
end;

procedure TfrmOrder.btnOrderClearClick(Sender: TObject);
begin
  SetLength(arrNewOrder, 0);

  edtOrderCustomer.Text := '';
  edtOrderWaiter.Text := '';
  edtOrderTable.Text := '';

  cmbOrderItem.ItemIndex := -1;
  edtOrderAmount.Text := '1';

  UpdateOrderDisplay;
end;

procedure TfrmOrder.btnOrderExportClick(Sender: TObject);
begin
  dbOrders.ExportReceipt(Main_u.APP_PATH + '/data/receipts', iPrevOrderID);

  btnOrderClearClick(Sender);

  btnOrderExport.Enabled := False;

  SHowMessage('Bill saved to: "' + Main_u.APP_PATH + '/data/receipts"');
end;

procedure TfrmOrder.btnOrderRemoveLineClick(Sender: TObject);
var
  arrOrderTmp: TArray<array[0.. 1] of Integer>;
  iRowIndex: Integer;
  i, j: Integer;
begin
  SetLength(arrOrderTmp, Length(arrNewOrder) - 1);
  iRowIndex := grdOrderLines.Row;
  j := 0;

  for i := 0 to Length(arrNewOrder) - 1 do
  begin
    if i <> iRowIndex then
    begin
      arrOrderTmp[j][0] := arrNewOrder[i][0];
      arrOrderTmp[j][1] := arrNewOrder[i][1];
      Inc(j);
    end;
  end;

  SetLength(arrNewOrder, Length(arrOrderTmp));

  for i := 0 to Length(arrOrderTmp) - 1 do
  begin
    arrNewOrder[i][0] := arrOrderTmp[i][0];
    arrNewOrder[i][1] := arrOrderTmp[i][1];
  end;

  UpdateOrderDisplay;
end;

procedure TfrmOrder.btnOrderSaveClick(Sender: TObject);
begin
  if iPrevOrderID = -1 then
    iPrevOrderID := dbOrders.NewOrder(edtOrderWaiter.Text, edtOrderCustomer.Text, StrToInt(edtOrderTable.Text), arrNewOrder)
  else
    dbOrders.UpdateOrder(edtOrderWaiter.Text, edtOrderCustomer.Text, StrToInt(edtOrderTable.Text), arrNewOrder, iPrevOrderID);

  btnOrderExport.Enabled := True;
end;

procedure TfrmOrder.edtOrderAmountValidating(Sender: TObject; var Text: string);
begin
  if Length(Text) > 3 then
    Delete(Text, 3, Length(Text) - 3);
end;

procedure TfrmOrder.edtOrderCustomerValidate(Sender: TObject; var Text: string);
begin
  Text := Text.Trim;

  if Length(Text) > 60 then
    Delete(Text, 60, Length(Text) - 60);
end;

procedure TfrmOrder.edtOrderCustomerValidating(Sender: TObject;
  var Text: string);
begin
  Text := Text.TrimLeft;

  if Length(Text) > 60 then
    Delete(Text, 60, Length(Text) - 60);
end;

procedure TfrmOrder.edtOrderTableValidating(Sender: TObject; var Text: string);
begin
  if Length(Text) > 3 then
    Delete(Text, 3, Length(Text) - 3);
end;

procedure TfrmOrder.edtOrderWaiterValidate(Sender: TObject; var Text: string);
begin
  Text := Text.Trim;

  if Length(Text) > 60 then
    Delete(Text, 60, Length(Text) - 60);
end;

procedure TfrmOrder.edtOrderWaiterValidating(Sender: TObject; var Text: string);
begin
  Text := Text.TrimLeft;

  if Length(Text) > 60 then
    Delete(Text, 60, Length(Text) - 60);
end;

procedure TfrmOrder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.Close;
end;

procedure TfrmOrder.FormShow(Sender: TObject);
begin
  dbOrders.LoadMenu;
  UpdateOrderDisplay;
  iPrevOrderID := -1;

  // Applying filters to edits
  edtOrderCustomer.FilterChar := FHelpers.ALPHABET + '-';
  edtOrderWaiter.FilterChar := FHelpers.ALPHABET + '-';
  edtOrderTable.FilterChar := FHelpers.NUMERIC;
  edtOrderAmount.FilterChar := FHelpers.NUMERIC;
end;

end.
