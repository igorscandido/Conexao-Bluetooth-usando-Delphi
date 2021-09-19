unit frmChatU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Edit, System.Bluetooth;

type
  TServiceThread = class(TThread)
  private
    // Socket para comunica��o de dados entre devices
    FSocket: TBluetoothSocket;
  protected
    // Procesamento da thread
    procedure Execute; override;
  public
    // Socket do servidor (apenas para escuta de conexoes)
    FServerSocket: TBluetoothServerSocket;
    // Ponteiro para mostrar a sa�da no formulario
    FDisplay: TMemo;
    // Nome do dispositivo remoto
    FNomeDispositivo: String;
    // Contrutor da classe
    constructor Create(ACreateSuspended: Boolean);
    // Destrutor da classe
    destructor Destroy; override;
  end;

  TfrmChat = class(TForm)
    Rectangle1: TRectangle;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    memHistorico: TMemo;
    Label2: TLabel;
    cbDispositivo: TComboBox;
    btnServidor: TButton;
    edtTexto: TEdit;
    btnEnviar: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbDispositivoChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    // Dispositivo selecionado
    FDispositivo: TBluetoothDevice;
    // Socket do cliente.
    FSocket: TBluetoothSocket;
    // Thread paralela, recebe dados no servidor.
    FThreadServidor: TServiceThread;
  end;

var
  frmChat: TfrmChat;
const
  // Nome do servi�o que criaremos
  ChatServiceName = 'Chat de texto';
  // GUID (Globally Unique Identifier) do servico a ser criado (Ctrl+Shift+G)
  ChatGUI = '{E2DEFE5F-7005-4A36-9F7C-CCB00DD97DAB}';

implementation

uses frmPrincipalU;

{$R *.fmx}

procedure TfrmChat.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmChat.Button2Click(Sender: TObject);
begin
  // Apaga as linhas do memo para "zerar" a conversa
  memHistorico.Lines.Clear;
end;

procedure TfrmChat.cbDispositivoChange(Sender: TObject);
begin
  // Grava o dispositivo selecionado na vari�vel do device pareado
  FDispositivo := frmPrincipal. // Formul�rio principal
                  Bluetooth1.   // Componente Bluetooth
                  // Fun��o que lista os dispositivos pareados
                                   // Item do ComboBox
                  LastPairedDevices[cbDispositivo.ItemIndex];
end;

procedure TfrmChat.FormShow(Sender: TObject);
begin
  // Limpa o ComboBox
  cbDispositivo.Clear;
  // Cadastra os dispositivos pareados
  // atualmente no ComboBox
  for var LDispositivo in frmPrincipal.Bluetooth1.PairedDevices do begin
    cbDispositivo.Items.Add(LDispositivo.DeviceName);
  end;
end;

end.
