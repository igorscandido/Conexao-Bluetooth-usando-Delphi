unit frmServicosU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.Objects, FMX.ListView, FMX.Controls.Presentation,
  FMX.Layouts;

type
  TForm2 = class(TForm)
    AnilIndicator1: TAniIndicator;
    Layout1: TLayout;
    btnConectar: TButton;
    lstServicos: TListView;
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
  Form2: TForm2;

implementation

{$R *.fmx}

end.
