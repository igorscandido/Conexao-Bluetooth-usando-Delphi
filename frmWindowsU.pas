unit frmWindowsU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  // Bibliotecas exclusivas se o sistema for Windows
  {$IFDEF WIN32}
   Winapi.Shellapi, FMX.Platform.Win, winapi.windows,
  {$ENDIF}
  System.Bluetooth;

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
    procedure btnNavegarClick(Sender: TObject);
    procedure btnMonitorClick(Sender: TObject);
    procedure btnCalculadoraClick(Sender: TObject);
    procedure btnPCClick(Sender: TObject);
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

procedure TfrmWindows.btnCalculadoraClick(Sender: TObject);
begin
  // Envia via socket o comando referente a função desejada
  Enviar('[CALCULADORA]');
end;

procedure TfrmWindows.btnMonitorClick(Sender: TObject);
begin
  // Envia via socket o comando referente a função desejada
  Enviar('[MONITOROFF]');
end;

procedure TfrmWindows.btnNavegarClick(Sender: TObject);
begin
  // Envia via socket o comando referente a função desejada
  Enviar('[ELETROWEB]');
end;

procedure TfrmWindows.btnPCClick(Sender: TObject);
begin
  // Envia via socket o comando referente a função desejada
  Enviar('[PCOFF]');
end;

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

  //  Libera o socket da memória
  {$IFDEF ANDROID}
    FSocket.DisposeOf;
    FServerSocket.DisposeOf;
    FSocket := nil;
    FServerSocket := nil;
  {$ELSE}
    FSocket.Free;
    FServerSocket.Free;
  {$ENDIF}

  inherited;
end;

procedure TServiceThread.Executar(const Programa: string);
begin

// Se o device for sistema Windows.
{$IFDEF WIN32}
  Try
    // Executa o programa .exe da constante Programa
  	ShellExecute(WindowHandleToPlatform(Application.MainForm.Handle).Wnd,
                                        nil,
                                        PChar(Programa),
                                        nil,
                                        nil,
                                        1);
  except
    // Se der qualquer erro mostra no memo
    On E: Exception Do begin
      if FDisplay <> nil then
        FDisplay.Lines.Add('Erro ao tentar executar programa: '+E.Message);
    end;
  end;
// Se a plataforma for Linux, Android, IOS
{$ELSE}
  Showmessage('Sistema operacional não suportado');
{$ENDIF}

end;

procedure TServiceThread.Execute;
var
  // Variável que recebera a conversão dos dados
  Msg: string;
  // Variável que recebe os dados binários de outro device
  LDados: TBytes;
begin

  // Repete até que não tenhamos setado como True
  // o fim da Thread
  while not Terminated do
    try
      // Libera o socket atual
      FSocket := nil;

      // Cria uma nova conexão do socket
      // pois ela pode mudar
      while not Terminated and (FSocket = nil) do
        FSocket := FServerSocket.Accept(100);

      // Caso a conexão seja feita fazemos a leitura dos dados
      if(FSocket <> nil) then begin

        // Repete até que não tenhamos setado como True
        // o fim da Thread
        while not Terminated do begin

          // Recebe os dados da leitura do socket
          LDados := FSocket.ReceiveData;


          // Converte de Bytes para Texto (String)
          Msg := TEncoding.UTF8.GetString(LDados);

          // Chama a função que carrega os dados
          if Msg='[ELETROWEB]' then
            Navegar('https://www.eletromococa.com.br/');

          // Chama a função que desliga o monitor do PC
          if Msg='[MONITOROFF]' then
            MonitorOff;

          // Chama a função que desliga computador
          if Msg='[PCOFF]' then
            PCOff;
          // Chama a função que executa calculadora
          if Msg='[CALCULADORA]' then
            Executar('C:\Windows\System32\calc.exe');


          // Verifica se os dados foram recebidos
          // e existe um display para mostrar
          if (Length(LDados) > 0) and (FDisplay <> nil) then

            // Sincroniza com a Thread Principal
            // e adiciona a mensagem no Memo
            Synchronize(procedure begin
                FDisplay.Lines.Add(FNomeDispositivo+': '+TEncoding.UTF8.GetString(LDados));
                FDisplay.GoToTextEnd;
            end);

          // Espera 0,1s para executar os procedimentos novamente
          Sleep(100);

        end;
      end;
    except

      // Em caso de ocorrer qualquer erro
      on E : Exception do
      begin
        // ERRO: notifica usuario na thread principal, apenas se possui um TMEMO para mostrar
        if FDisplay <> nil then begin
          Msg := E.Message;
          Synchronize(procedure
            begin
              FDisplay.Lines.Add('Servidor encerrado: ' + Msg);
              FDisplay.GoToTextEnd;
            end);
        end;
      end;
    end;

end;

procedure TServiceThread.MonitorOff;
begin

// Se a plataforma for Windows executa.
{$IFDEF WIN32}
  try
    // Executa no terminal a função de desligar o monitor
    SendMessage(WindowHandleToPlatform(Application.MainForm.Handle).Wnd, 274, SC_MONITORPOWER, 2)
  except
    On E:Exception do
      ShowMessage('Não foi possivel desligar o monitor: '+E.Message);
  end;
// Se a plataforma for Android, iOS, MacOS ou Linux mostra um aviso.
{$ELSE}
  Showmessage('Sistema operacional não suportado');
{$ENDIF}

end;

procedure TServiceThread.Navegar(const URL: String);
begin
// Se a plataforma for Windows executa.
{$IFDEF WIN32}
  Try
    // Executa a função que abre o navegador no link
    ShellExecute(WindowHandleToPlatform(Application.MainForm.Handle).Wnd,
                                        nil,
                                        PChar(URL),
                                        nil,
                                        nil,
                                        1);
  except
    On E: Exception Do begin
      if FDisplay <> nil then
        FDisplay.Lines.Add('Erro ao tentar carregar site: '+E.Message);
    end;
  end;
// Se a plataforma for Android, iOS, MacOS ou Linux mostra um aviso.
{$ELSE}
  Showmessage('Sistema operacional não suportado');
{$ENDIF}
end;

procedure TServiceThread.PCOff;
begin
// Se a plataforma for Windows executa.
{$IFDEF WIN32}
  Try
    // Executa a função no Shell para desligar o PC
    WinExec(PAnsiChar('cmd.exe /c shutdown -s -f -t 10'), sw_normal);
  except
    On E: Exception Do begin
      if FDisplay <> nil then
        FDisplay.Lines.Add('Erro ao tentar desligar o computador: '+E.Message);
    end;
  end;
// Se a plataforma for Android, iOS, MacOS ou Linux mostra um aviso.
{$ELSE}
  Showmessage('Sistema operacional não suportado');
{$ENDIF}
end;

end.
