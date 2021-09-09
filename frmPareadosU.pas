unit frmPareadosU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.Objects, FMX.ListView, FMX.Controls.Presentation,
  FMX.Layouts;

type
  TfrmPareados = class(TForm)
    Layout1: TLayout;
    btnDesparear: TButton;
    btnServicos: TButton;
    lstDispositivos: TListView;
    Rectangle1: TRectangle;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPareados: TfrmPareados;

implementation

{$R *.fmx}

end.
