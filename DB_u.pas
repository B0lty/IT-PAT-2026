unit DB_u;

interface

uses System.SysUtils, System.Classes, System.DateUtils, System.Math, System.StrUtils,
  Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.Phys, FireDAC.Phys.Intf,
  FireDAC.Phys.MSAcc, FireDAC.Phys.MSAccDef, FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait, FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.DApt, Winapi.Windows,
  FMX.Grid,
  MenuMng_u;

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

    var
      conOrderDB: TFDConnection;

      tblMenu: TFDTable;
      dscMenu: TDataSource;

      tblOrderItem: TFDTable;
      dscOrderItem: TDataSource;

      tblOrders: TFDTable;
      dscOrders: TDataSource;
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

// Loads the menu to be displayed on the menu management screen
procedure TdbOrders.LoadMenu;
var
  i: Integer;
begin
  frmMenu.grdMenu.RowCount := tblMenu.RecordCount;

  tblMenu.First;
  i := 0;

  while not tblMenu.Eof do
  begin
    frmMenu.grdMenu.Cells[0, i] := tblMenu.FieldByName('ItemName').AsString;
    frmMenu.grdMenu.Cells[1, i] := tblMenu.FieldByName('Category').AsString;
    frmMenu.grdMenu.Cells[2, i] := tblMenu.FieldByName('ItemPrice').AsString;
    frmMenu.grdMenu.Cells[3, i] := tblMenu.FieldByName('MenuItemID').AsString;
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

end.
