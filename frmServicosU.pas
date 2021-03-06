unit frmServicosU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.Objects, FMX.ListView, FMX.Controls.Presentation,
  FMX.Layouts, System.Bluetooth, FMX.ListView.Appearances;

type
  TfrmServicos = class(TForm)
    AnilIndicator1: TAniIndicator;
    Layout1: TLayout;
    btnConectar: TButton;
    lstServicos: TListView;
    Rectangle1: TRectangle;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FDispositivo: TBluetoothDevice;
  end;

var
  frmServicos: TfrmServicos;

implementation

uses
  frmPrincipalU;

{$R *.fmx}

procedure TfrmServicos.Button2Click(Sender: TObject);
var
  LListItem: TListViewItem;
begin

  //  Verifica se existe um dispositivo pareado
  if FDispositivo = nil then begin
    ShowMessage('Selecione um dispositivo.');
    Exit;
  end;

  // Tela de loading que indica ao usu?rio o carregamento
  // dos servi?os
  AnilIndicator1.Visible := True;
  AnilIndicator1.Enabled := True;
  // N?o ? poss?vel clicar enquanto carrega
  btnConectar.Enabled := False;

  // Cria uma thread para realizar o procedimento
  // e n?o travar o processo principal, por tanto
  // o usu?rio continua conseguindo usar o app
  // enquanto carrega-se os servi?os
  TThread.CreateAnonymousThread(
  // Passa uma fun??o a ser realizada pela thread
  procedure
  begin
    Try

      with frmPrincipal do begin

        lstServicos.Items.Clear; // Limpa a lista de servi?os anterior

        // Captura lista de servicos do device atualmente selecionado
        FDispositivo.GetServices;

        // Percorre todos os servi?os e adiciona cada um a um item da lista
        for var LServico in FDispositivo.LastServiceList do begin

          // Adiciona um novo item a lista
          LListItem := lstServicos.Items.Add;

          LListItem.ImageIndex := 0;  //  Seleciona o index da Imagem no ImageList
          LListItem.Text := LServico.Name;  //  Nome do servi?o

          // Se o servi?o n?o tiver nome
          if LListItem.Text = '' then
            LListItem.Text := '<Desconhecido>';

          // Converte o bin?rio do endere?o MAC para String e adiciona
          LListItem.Detail := GUIDToString(LServico.UUID);

        end;

      end;

    finally

      // Realiza os procedimentos na Thread principal da aplica??o
      TThread.Synchronize(TThread.CurrentThread, procedure begin
        AnilIndicator1.Visible := False;
        AnilIndicator1.Enabled := False;
        btnConectar.Enabled := True;
      end);

    end;

  end
  ).Start; // Inicia a Thread

end;

end.
