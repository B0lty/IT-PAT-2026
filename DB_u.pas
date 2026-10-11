unit DB_u;

interface

uses System.SysUtils, System.Classes, System.DateUtils, System.Math, System.StrUtils,
  Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.Phys, FireDAC.Phys.Intf,
  FireDAC.Phys.MSAcc, FireDAC.Phys.MSAccDef, FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait, FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.DApt, Winapi.Windows,
  FMX.Grid,
  MenuMng_u, Order_u, Helpers_u;

type
  TdbOrders = class
  private
  // blah
  public
    constructor Create(sDBPath: String);
    destructor Destroy; override;
    procedure LoadMenu;
    procedure AppendMenu(ItemName, Category: String; ItemPrice: Double);
    procedure UpdateMenu(ItemName, Category: String; ItemPrice: Double; iItemID: Integer);
    procedure DeleteMenuItem(iItemID: Integer);
    function GetMenuItemName(iItemID: Integer): String;
    function GetMenuItemPrice(iItemID: Integer): Double;
    function NewOrder(sWaiter, sCustomer: String; iTableNo: Integer; arrOrder: TArray<TOrderLine>): Integer;
    procedure UpdateOrder(sWaiter, sCustomer: String; iTableNo: Integer; arrOrder: TArray<TOrderLine>; iOrderID: Integer);
    procedure ExportReceipt(sFilePath: String; iOrderID: Integer);

    var
      conOrderDB: TFDConnection;

      tblMenu: TFDTable;
      dscMenu: TDataSource;

      tblOrderItem: TFDTable;
      dscOrderItem: TDataSource;

      tblOrders: TFDTable;
      dscOrders: TDataSource;
  end;

  TOrderLineRec = record
    ItemName: string;
    ItemPrice: Currency;
    Amount: Integer;
  end;

var
  dbOrders: TdbOrders;

implementation

uses Main_u;

constructor TdbOrders.Create(sDBPath: String);
begin
  inherited Create;

  conOrderDB := TFDConnection.Create(nil);
  try
    // Establishing connection to the database
    conOrderDB.LoginPrompt := False;
    conOrderDB.Params.Clear;
    conOrderDB.Params.DriverID := 'MSAcc';
    conOrderDB.Params.Database := sDBPath;
    conOrderDB.Connected := True;
    OutputDebugString(PChar('DB link successful!'));
  except
    on E: Exception do
      raise Exception.Create('Could not connect to the database (' + sDBPath + ').' + sLineBreak + E.Message);
  end;

  try
    // Setting up the Menu table
    tblMenu := TFDTable.Create(nil);
    dscMenu := TDataSource.Create(nil);

    tblMenu.Connection := conOrderDB;
    tblMenu.TableName := 'tblMenuItem';
    dscMenu.DataSet := tblMenu;
    tblMenu.Open;

    OutputDebugString(PChar('Menu table setup successful!'));
  except
    on E: Exception do
      raise Exception.Create('Error setting up the Menu table.'+ sLineBreak + E.Message);
  end;

  try
    // Setting up the OrderItem table
    tblOrderItem := TFDTable.Create(nil);
    dscOrderItem := TDataSource.Create(nil);

    tblOrderItem.Connection := conOrderDB;
    tblOrderItem.TableName := 'tblOrderItem';
    dscOrderItem.DataSet := tblOrderItem;
    tblOrderItem.Open;

    OutputDebugString(PChar('OrderItem table setup successful!'));
  except
    on E: Exception do
      raise Exception.Create('Error setting up the OrderItem table.'+ sLineBreak + E.Message);
  end;

  try
    // Setting up the Orders table
    tblOrders := TFDTable.Create(nil);
    dscOrders := TDataSource.Create(nil);

    tblOrders.Connection := conOrderDB;
    tblOrders.TableName := 'tblOrders';
    dscOrders.DataSet := tblOrders;
    tblOrders.Open;

    OutputDebugString(PChar('Orders table setup successful!'));
  except
    on E: Exception do
      raise Exception.Create('Error setting up the Orders table.'+ sLineBreak + E.Message);
  end;
end;


destructor TdbOrders.Destroy;
begin
  if Assigned(conOrderDB) then
  begin
    if conOrderDB.Connected then
      conOrderDB.Connected := False;
    conOrderDB.Free;
  end;
  if Assigned(tblMenu) then tblMenu.Free;
  if Assigned(tblOrderItem) then tblOrderItem.Free;
  if Assigned(tblOrders) then tblOrders.Free;
  if Assigned(dscMenu) then dscMenu.Free;
  if Assigned(dscOrderItem) then dscOrderItem.Free;
  if Assigned(dscOrders) then dscOrders.Free;

  inherited;
end;

// Loads the menu to be displayed on the menu management screen and the order placemnt screen
procedure TdbOrders.LoadMenu;
var
  i: Integer;
begin
  frmMenu.grdMenu.RowCount := tblMenu.RecordCount;

  tblMenu.First;
  i := 0;
  frmOrder.cmbOrderItem.Items.Clear;

  while not tblMenu.Eof do
  begin
    // Menu management screen
    frmMenu.grdMenu.Cells[0, i] := tblMenu.FieldByName('ItemName').AsString;
    frmMenu.grdMenu.Cells[1, i] := tblMenu.FieldByName('Category').AsString;
    frmMenu.grdMenu.Cells[2, i] := tblMenu.FieldByName('ItemPrice').AsString;
    frmMenu.grdMenu.Cells[3, i] := tblMenu.FieldByName('MenuItemID').AsString;

    // Order placement screen
    frmOrder.cmbOrderItem.Items.Append(tblMenu.FieldByName('ItemName').AsString);
    SetLength(frmOrder.arrMenuIndexToID, tblMenu.RecordCount);
    frmOrder.arrMenuIndexToID[i][0] :=  i;
    frmOrder.arrMenuIndexToID[i][1] :=  tblMenu.FieldByName('MenuItemID').AsInteger;

    tblMenu.Next;
    Inc(i);
  end;

end;

// Adds an item to the menu
procedure TdbOrders.AppendMenu(ItemName, Category: String; ItemPrice: Double);
begin
  tblMenu.Append;
  tblMenu.FieldByName('ItemName').AsString := ItemName;
  tblMenu.FieldByName('Category').AsString := Category;
  tblMenu.FieldByName('ItemPrice').AsFloat := ItemPrice;
  tblmenu.Post;
end;

// Updates an item on the menu
procedure TdbOrders.UpdateMenu(ItemName, Category: String; ItemPrice: Double; iItemID: Integer);
begin
  tblMenu.Locate('MenuItemID', iItemID, []);
  tblMenu.Edit;
  tblMenu.FieldByName('ItemName').AsString := ItemName;
  tblMenu.FieldByName('Category').AsString := Category;
  tblMenu.FieldByName('ItemPrice').AsFloat := ItemPrice;
  tblmenu.Post;
end;

// Removes an item from the menu
procedure TdbOrders.DeleteMenuItem(iItemID: Integer);
begin
  tblMenu.Locate('MenuItemID', iItemID, []);
  tblMenu.Delete;
end;

function TdbOrders.GetMenuItemName(iItemID: Integer): String;
begin
  tblMenu.Locate('MenuItemID', iItemID, []);
  result := tblMenu.FieldByName('ItemName').AsString;
end;

function TdbOrders.GetMenuItemPrice(iItemID: Integer): Double;
begin
  tblMenu.Locate('MenuItemID', iItemID, []);
  result := tblMenu.FieldByName('ItemPrice').AsFloat;
end;

function TdbOrders.NewOrder(sWaiter, sCustomer: String; iTableNo: Integer; arrOrder: TArray<TOrderLine>): Integer;
var
  iOrderID: Integer;
  i: Integer;
begin
  tblOrders.Append;
  tblOrders.FieldByName('Customer').AsString := sCustomer;
  tblOrders.FieldByName('Waiter').AsString := sWaiter;
  tblOrders.FieldByName('Table').AsInteger := iTableNo;
  tblOrders.FieldByName('OrderDate').AsDateTime := Now;
  tblOrders.Post;

  iOrderID := tblOrders.FieldByName('OrderID').AsInteger;

  for i := 0 to Length(arrOrder) - 1 do
  begin
    tblOrderItem.Append;
    tblOrderItem.FieldByName('MenuItemID').AsInteger := arrOrder[i][0];
    tblOrderItem.FieldByName('OrderID').AsInteger := iOrderID;
    tblOrderItem.FieldByName('Amount').AsInteger := arrOrder[i][1];
  end;

  Result := iOrderID;
end;

procedure TdbOrders.UpdateOrder(sWaiter, sCustomer: String; iTableNo: Integer; arrOrder: TArray<TOrderLine>; iOrderID: Integer);
var
  i, iOldOrders: Integer;
begin
  tblOrders.Locate('OrderID', iOrderID, []);
  tblOrders.Edit;
  tblOrders.FieldByName('Customer').AsString := sCustomer;
  tblOrders.FieldByName('Waiter').AsString := sWaiter;
  tblOrders.FieldByName('Table').AsInteger := iTableNo;
  tblOrders.FieldByName('OrderDate').AsDateTime := Now;
  tblOrders.Post;

  iOrderID := tblOrders.FieldByName('OrderID').AsInteger;

  iOldOrders := 0;
  i := 0;
  tblOrderItem.First;
  while not tblOrderItem.Eof do
  begin
    if tblOrderItem.FieldByName('OrderID').AsInteger = iOrderID then
    begin
      // Deleting old records that are no longer valid
      if i > length(arrOrder) then
        tblMenu.Delete;

      tblOrderItem.Edit;
      tblOrderItem.FieldByName('MenuItemID').AsInteger := arrOrder[i][0];
      tblOrderItem.FieldByName('OrderID').AsInteger := iOrderID;
      tblOrderItem.FieldByName('Amount').AsInteger := arrOrder[i][1];
      tblOrderItem.Post;

      Inc(iOldOrders)
    end;

    tblOrderItem.Next;
    Inc(i);
  end;

  if iOldOrders < Length(arrOrder) then
  begin
    for i := iOldOrders + 1 to Length(arrOrder) - 1 do
    begin
      tblOrderItem.Append;
      tblOrderItem.FieldByName('MenuItemID').AsInteger := arrOrder[i][0];
      tblOrderItem.FieldByName('OrderID').AsInteger := iOrderID;
      tblOrderItem.FieldByName('Amount').AsInteger := arrOrder[i][1];
      tblOrderItem.Post;
    end;
  end;
end;

procedure TdbOrders.ExportReceipt(sFilePath: String; iOrderID: Integer);
var
  lines: TArray<TOrderLineRec>;
  sl: TStringList;
  i, iTable: Integer;
  dSubtotal, dVat, dTotal: Double;
  sCustomer, sWaiter: String;
  OrderDate: TDateTime;
begin
  i := 0;
  tblOrderItem.First;
  while not tblOrderItem.Eof do
  begin
    SetLength(lines, 0);
    if tblOrderItem.FieldByName('OrderID').AsInteger = iOrderID then
    begin
      SetLength(lines, i + 1);

      tblMenu.Locate('MenuItemID', tblOrderItem.FieldByName('MenuItemID').AsInteger, []);

      lines[i].ItemName := tblMenu.FieldByName('ItemName').AsString;
      lines[i].ItemPrice := tblMenu.FieldByName('ItemPrice').AsFloat;
      lines[i].Amount := tblOrderItem.FieldByName('Amount').AsInteger;

      Inc(i);
    end;

    tblOrderItem.Next;
  end;

  tblOrders.Locate('OrderID', iOrderID, []);
  sCustomer := tblOrders.FieldByName('Customer').AsString;
  sWaiter := tblOrders.FieldByName('Waiter').AsString;
  iTable := tblOrders.FieldByName('Table').AsInteger;
  OrderDate := tblOrders.FieldByName('OrderDate').AsDateTime;

  sl := TStringList.Create;
  try
    sl.Add('=================================================');
    sl.Add('                  SMART EATS');
    sl.Add('           123 Main Road, Cape Town');
    sl.Add('              Tel: 012 345 6789');
    sl.Add('=================================================');
    sl.Add('Date      : ' + FormatDateTime('yyyy-mm-dd hh:nn', OrderDate));
    sl.Add('Customer  : ' + sCustomer);
    sl.Add('Waiter    : ' + sWaiter);
    sl.Add(Format('Table     : %d', [iTable]));
    sl.Add('-------------------------------------------------');
    sl.Add(Format('%-22s %4s %11s', ['Item', 'Qty', 'Line total']));
    sl.Add('-------------------------------------------------');

    dSubtotal := 0;
    for i := 0 to High(lines) do
    begin
      dSubtotal := dSubtotal + (lines[i].ItemPrice * lines[i].Amount);
      sl.Add(Format('%-22s %4d %11s', [lines[i].ItemName, lines[i].Amount,
        'R ' + FloatToStrF((lines[i].ItemPrice * lines[i].Amount), ffFixed, 10, 2)]));
    end;

    dVat := dSubtotal * frmMain.VAT;
    dTotal := dSubtotal + dVat;

    sl.Add('-------------------------------------------------');
    sl.Add(Format('%-22s %16s', ['Subtotal', 'R ' + FloatToStrF(dSubtotal, ffFixed, 10, 2)]));
    sl.Add(Format('%-22s %16s', ['VAT (15%)', 'R ' + FloatToStrF(dVat, ffFixed, 10, 2)]));
    sl.Add(Format('%-22s %16s', ['TOTAL DUE', 'R ' + FloatToStrF(dTotal, ffFixed, 10, 2)]));
    sl.Add('=================================================');
    sl.Add('          Thank you for dining with us!');
    sl.SaveToFile(sFilePath + '/recipt-' + FormatDateTime('yyyy-mm-dd-hh-nn', OrderDate) + '.txt');
  finally
    sl.Free;
  end;
end;

end.
