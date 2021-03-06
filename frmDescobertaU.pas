unit frmDescobertaU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Layouts, System.Bluetooth, frmServicosU;

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
    procedure btnVisivelClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnParearClick(Sender: TObject);
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

procedure TfrmDescoberta.btnParearClick(Sender: TObject);
var
  LDispositivo: TBluetoothDevice;
begin

  // Verifica se n?o tem um dispositivo selecionado
  // da lista de devices
  if lstDispositivos.ItemIndex < 0 then begin
    // Se n?o tiver, indica ao usu?rio o que fazer
    ShowMessage('Selecione um dispositivo.');
    Exit;
  end;

  // Guarda o dispositivo da lista na vari?vel
  LDispositivo:= frmPrincipal
              .Bluetooth1 // Acessa o componente Bluetooth
              .LastDiscoveredDevices // Acessa a lista de devices descobertos
              // A partir do item selecionado na lista
              // seleciona o device do componente Bluetooth
              .Items[lstDispositivos.ItemIndex];

  // Faz o pareamento com o device da vari?vel
  frmPrincipal.Bluetooth1.Pair(LDispositivo);

  // Armazena o device pareado na propriedade que tamb?m
  // guarda o device do formul?rio Servicos da unit frmServicosU
  frmServicos.FDispositivo := LDispositivo;

  // Chama a fun??o que lista os servi?os no formul?rio
  frmServicos.Button2Click(nil);
  // Mostra o formul?rio com os servi?os
  frmServicos.Show;

end;

procedure TfrmDescoberta.btnVisivelClick(Sender: TObject);
begin

  // Ao deixar o dispositivo vis?vel o loading ficar?
  // ativo, mostrando que uma a??o est? ocorrendo
  // e identificando o usu?rio
  AnilIndicator1.Visible := True;
  AnilIndicator1.Enabled := True;
  // O bot?o n?o fica dispon?vel durante esse tempo
  btnVisivel.Enabled := False;

  // Verifica qual ambiente estamos usando
  // Se ? Windows ou qualquer outro device
  {$IFDEF WIN32}
    // Se for Windows chamamos a fun??o que faz o
    // device poder ser descoberto por 15s
    // 15000 = 15s ; 1000 = 1s
    frmPrincipal.Bluetooth1.StartDiscoverable(15000);
  {$ELSE}
    // Caso seja qualquer outro que n?o o Windows
    // chamamos tamb?m a fun??o de deixar vis?vel
    // o device por 15s
    frmPrincipal.Bluetooth1.StartDiscoverable(15);
  {$ENDIF}

end;

procedure TfrmDescoberta.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDescoberta.Button2Click(Sender: TObject);
begin

  // Limpa o ListView caso ele j? contenha algum dispositivo
  // isso impede que tenhamos dois items para um mesmo device
  lstDispositivos.Items.Clear;

  // Ao buscar por dispositivos mostramos o Loading
  // ao usu?rio para mostr?-lo que tem algo acontecendo
  AnilIndicator1.Visible := True;
  AnilIndicator1.Enabled := True;
  // Desativamos o bot?o pareamento pois ele ainda est? buscando
  btnParear.Enabled := False;

  // Chama a fun??o do componente Bluetooth que busca por
  // dispositivos usando o Bluetooth do device
  // 10000 = 10s; 1000 = 1s
  frmPrincipal.Bluetooth1.DiscoverDevices(10000);

end;

end.
