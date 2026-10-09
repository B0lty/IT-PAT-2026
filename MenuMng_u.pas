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
    colMenuID: TStringColumn;
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenu: TfrmMenu;

implementation

{$R *.fmx}

end.
