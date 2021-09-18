unit frmPrincipalU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.MultiView, FMX.Layouts,
  FMX.ListBox, System.Bluetooth, System.Bluetooth.Components, System.ImageList,
  FMX.ImgList, frmDescobertaU, frmChatU, frmPareadosU, frmServicosU, frmWindowsU,
  FMX.ListView.Appearances;

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
    procedure ListBoxItem1Click(Sender: TObject);
    procedure ListBoxItem2Click(Sender: TObject);
    procedure ListBoxItem3Click(Sender: TObject);
    procedure ListBoxItem4Click(Sender: TObject);
    procedure Bluetooth1DiscoverableEnd(const Sender: TObject);
    procedure Bluetooth1DiscoveryEnd(const Sender: TObject;
      const ADeviceList: TBluetoothDeviceList);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.Bluetooth1DiscoverableEnd(const Sender: TObject);
begin

  // Quando o componente Bluetooth deixar de estar visível
  // a outros dispositivos com Bluetooth ativo
  // ele deve remover o Loading e voltar com o btnVisivel
  // como clicavel para poder iniciar o processo de visibilidade
  // novamente
  with frmDescoberta do begin
    AnilIndicator1.Visible := False; // Remove o loading
    AnilIndicator1.Enabled := False; // Remove o loading
    btnVisivel.Enabled := True; // Volta com o botão podendo ser clicado
  end;
  // Mostra uma mensagem para orientar o usuário
  ShowMessage('Dispositivo oculto novamente');

end;

procedure TfrmPrincipal.Bluetooth1DiscoveryEnd(const Sender: TObject;
  const ADeviceList: TBluetoothDeviceList);
var
  // Declare uma variavel que sera usada para poder
  // criar um item para cada dispositivo encontrado
  // pelo componente Bluetooth1
  LListItem: TListViewItem;
begin

  // Quando acabar a descoberta de dispositivos
  with frmDescoberta do begin

    // Percorre a lista de dispositivos encontrados
    // usando o parâmetro ADeviceList fornecido
    // pela própria função
    for var LDispositivo in ADeviceList do begin

      // Cria um item para cada dispositivo no ListView
      // lstDispositivos, esse item vai conter o nome
      // uma imagem padrão e um detalhe que será o endereço
      // MAC do dispositivo encontrado
      LListItem := frmDescoberta.lstDispositivos.Items.Add; // Adiciona o item
      LListItem.ImageIndex := 0;                 // Define a Imagem
      LListItem.Text := LDispositivo.DeviceName; // Define o nome do dispositivo
      LListItem.Detail := LDispositivo.Address;  // Define o MAC adress do device

    end;

    // Desativa o Loading do formulário
    AnilIndicator1.Enabled := False;
    AnilIndicator1.Visible := False;
    // Ativa o botão permitindo que seja feito pareamento
    btnParear.Enabled := True;
  end;
end;

procedure TfrmPrincipal.ListBoxItem1Click(Sender: TObject);
begin
  frmDescoberta.Show;
end;

procedure TfrmPrincipal.ListBoxItem2Click(Sender: TObject);
begin
  frmPareados.Show;
end;

procedure TfrmPrincipal.ListBoxItem3Click(Sender: TObject);
begin
  frmChat.Show;
end;

procedure TfrmPrincipal.ListBoxItem4Click(Sender: TObject);
begin
  frmWindows.Show;
end;

end.
