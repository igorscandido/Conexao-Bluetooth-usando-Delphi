unit frmPrincipalU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.MultiView, FMX.Layouts,
  FMX.ListBox, System.Bluetooth, System.Bluetooth.Components, System.ImageList,
  FMX.ImgList;

type
  TfrmPrincipal = class(TForm)
    Rectangle1: TRectangle;
    btnMenu: TButton;
    Label1: TLabel;
    MultiView1: TMultiView;
    ListBox1: TListBox;
    ListBoxHeader1: TListBoxHeader;
    Label2: TLabel;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    Bluetooth1: TBluetooth;
    ImageList1: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

end.
