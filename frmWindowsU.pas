unit frmWindowsU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox;

type
  TfrmWindows = class(TForm)
    Rectangle1: TRectangle;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Layout1: TLayout;
    Label2: TLabel;
    cbDispositivo: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWindows: TfrmWindows;

implementation

{$R *.fmx}

end.