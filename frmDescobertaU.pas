unit frmDescobertaU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Layouts;

type
  TfrmDescoberta = class(TForm)
    Rectangle1: TRectangle;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    lstDispositivos: TListView;
    AnilIndicator1: TAniIndicator;
    Layout1: TLayout;
    btnVisivel: TButton;
    btnParear: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDescoberta: TfrmDescoberta;

implementation

uses
  frmPrincipalU;

{$R *.fmx}

end.