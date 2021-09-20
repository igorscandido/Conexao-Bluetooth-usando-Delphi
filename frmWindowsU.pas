unit frmWindowsU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.Bluetooth;

type

  TServiceThread = class(TThread)
  private
    // Socket de comunicacao via Bluetooth
    FSocket: TBluetoothSocket;
    // Função que abre o navegador do PC
    procedure Navegar(const URL: String);
    // Função que desliga o monitor do PC
    procedure MonitorOff;
    // Função que desliga o computador
    procedure PCOff;
    // Função que executa um programa do Windows
    procedure Executar(const Programa: string);
  protected
    // Processamento da Thread
    procedure Execute; override;
  public
    // Socket do servidor (apenas para escuta de conexoes)
    FServerSocket: TBluetoothServerSocket;
    // Ponteiro para listagem de mensagem no Memo
    FDisplay: TMemo;
    // Nome do dispositivo remoto
    FNomeDispositivo: String;
    // Contrutor da classe
    constructor Create(ACreateSuspended: Boolean);
    // Destrutor da classe
    destructor Destroy; override;
  end;

  TfrmWindows = class(TForm)
    Rectangle1: TRectangle;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Layout1: TLayout;
    Label2: TLabel;
    cbDispositivo: TComboBox;
    memHistorico: TMemo;
    GridPanelLayout1: TGridPanelLayout;
    btnNavegar: TButton;
    btnMonitor: TButton;
    btnCalculadora: TButton;
    btnPC: TButton;
    procedure Button2Click(Sender: TObject);
    procedure cbDispositivoChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    // Dispositivo selecionado
    FDispositivo: TBluetoothDevice;
    // Socket para conexão dos devices.
    FSocket: TBluetoothSocket;
    // Thread paralela,que recebe dados no servidor.
    FThreadServidor: TServiceThread;

    // Função para enviar os dados ao outro device.
    procedure Enviar(const MSG: String);
  end;

var
  frmWindows: TfrmWindows;
const
  // nome do servico a ser criado
  WindowsServiceName = 'Controlador do Windows';
  // GUID (globally unique identifier) do servico a ser criado (Ctrl+Shift+G)
  WindowsGUI = '{255306A7-0221-42E6-86C7-C9AB391CE4CB}';

implementation

uses
  frmPrincipalU;

{$R *.fmx}

procedure TfrmWindows.Button2Click(Sender: TObject);
begin
  // se nenhum dispositivo for selecionado.
  if cbDispositivo.ItemIndex < 0 then begin
    ShowMessage('Escolha um dispositivo.');
    Button2.IsPressed := False; // evita bug do 2º click
    exit; // bye...
  end;

  // Se botao esta pressionado (afundado), SOBE SERVIDOR.
  if Button2.IsPressed then begin
    try
      // cria Server Thread (suspensa -> TRUE).
      FThreadServidor := TServiceThread.Create(true);
      // Cria socket do servidor baseado no nome e GUID do servico.
      FThreadServidor.FServerSocket := frmPrincipal
                                        .Bluetooth1
                                        .CreateServerSocket(WindowsServiceName
                                                              ,StringToGUID(WindowsGUI)
                                                              ,False);
      // Atribui TMEMO para saida
      FThreadServidor.FDisplay := memHistorico;
      // Nome do dispositivo para exib. de msgs.
      FThreadServidor.FNomeDispositivo := cbDispositivo.Items[cbDispositivo.ItemIndex];
      // Inicia escuta do servidor
      FThreadServidor.Start;
      // ajusta componentes do formulario.
      Button2.Text := 'Parar servidor';
      memHistorico.Lines.Add('[SERVIDOR INICIADO]');
      cbDispositivo.Enabled := False;
    Except
      On E:Exception do begin
        // ERRO: notifica usuario e ajusta componentes do formulario
        memHistorico.Lines.Add(E.Message);
        memHistorico.GoToTextEnd;
        Button2.Text := 'Iniciar Servidor';
        Button2.IsPressed := False;
        cbDispositivo.Enabled := True;
      end;
    end;
  end
  // DERRUBA SERVIDOR
  else begin
    if FThreadServidor <> nil then begin
      // flag thread para terminar e interromper servidor
      FThreadServidor.Terminate;
      FThreadServidor.WaitFor; // aguarda thread finalizar
      // destroi/libera thread
      {$IFDEF ANDROID}
        FThreadServidor.DisposeOf;
        FThreadServidor := nil;
      {$ELSE}
        FreeAndNil(FThreadServidor);
      {$ENDIF}

      // notifica usuario e ajusta componentes do form.
      memHistorico.Lines.Add('[SERVIDOR INTERROMPIDO]');
      memHistorico.GoToTextEnd;
      Button2.Text := 'Iniciar Servidor';
      Button2.IsPressed := False;
      cbDispositivo.Enabled := True;
    end;
  end;
end;

procedure TfrmWindows.cbDispositivoChange(Sender: TObject);
begin
  // Grava o dispositivo selecionado na variável do device pareado
  FDispositivo := frmPrincipal. // Formulário principal
                  Bluetooth1.   // Componente Bluetooth
                  // Função que lista os dispositivos pareados
                                   // Item do ComboBox
                  LastPairedDevices[cbDispositivo.ItemIndex];
end;

procedure TfrmWindows.Enviar(const MSG: String);
var
  // Variável que receberá o valor do texto
  // convertido em binário
  LMsg: TBytes;
begin

  // Se dispositivo foi selecionado e se está pareado/conectado.
  if (FDispositivo <> nil) and
     (frmPrincipal.Bluetooth1.ConnectionState=TBluetoothConnectionState.Connected) then
    Try
      // Verifica se o socket já foi criado
      if (FSocket=nil) then begin
        // Cria o socket baseado no GUID do servico.
        FSocket := FDispositivo.CreateClientSocket(StringToGUID(WindowsGUI), False);
        // Cria a conexão via socket com o outro device
        if FSocket <> nil then begin
          FSocket.Connect;
        end;
      end;

      // Converte String em Binário
      LMsg := TEncoding.UTF8.GetBytes(MSG);
      // Envia binário atraves do socket.
      FSocket.SendData(LMsg);
      // Exibe a mensagem no Memo.
      memHistorico.Lines.Add('COMANDO: '+MSG);
      memHistorico.GoToTextEnd;
    Except
      On E:Exception do begin
      // ERRO: notifica usuario sobre o erro e avanca
        memHistorico.Lines.Add('Erro: '+E.Message);
        memHistorico.GoToTextEnd;
        // libera client socket.
        {$IFDEF ANDROID}
          FSocket.DisposeOf;
          FSocket := nil;
        {$ELSE}
          FreeAndNil(FSocket);
        {$ENDIF}
      end;
    End;

end;

procedure TfrmWindows.FormShow(Sender: TObject);
begin
  // limpa combobox.
  cbDispositivo.Clear;
  // cadastra dispositivo pareados no combobox.
  for var LDispositivo in frmPrincipal.Bluetooth1.PairedDevices do begin
    cbDispositivo.Items.Add(LDispositivo.DeviceName);
  end;
end;

{ TServiceThread }

constructor TServiceThread.Create(ACreateSuspended: Boolean);
begin
  inherited;
end;

destructor TServiceThread.Destroy;
begin

  inherited;
end;

procedure TServiceThread.Executar(const Programa: string);
begin

end;

procedure TServiceThread.Execute;
begin
  inherited;

end;

procedure TServiceThread.MonitorOff;
begin

end;

procedure TServiceThread.Navegar(const URL: String);
begin

end;

procedure TServiceThread.PCOff;
begin

end;

end.
