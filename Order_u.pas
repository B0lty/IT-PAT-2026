unit Order_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Rtti, FMX.Grid.Style,
  FMX.Grid, FMX.ScrollBox, FMX.Edit;

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
    lblOrderLastID: TLabel;
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOrder: TfrmOrder;

implementation

{$R *.fmx}

end.
