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
    // Socket para comunica??o de dados entre devices
    FSocket: TBluetoothSocket;
  protected
    // Procesamento da thread
    procedure Execute; override;
  public
    // Socket do servidor (apenas para escuta de conexoes)
    FServerSocket: TBluetoothServerSocket;
    // Ponteiro para mostrar a sa?da no formulario
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
    procedure btnServidorClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
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
  // Nome do servi?o que criaremos
  ChatServiceName = 'Chat de texto';
  // GUID (Globally Unique Identifier) do servico a ser criado (Ctrl+Shift+G)
  ChatGUI = '{E2DEFE5F-7005-4A36-9F7C-CCB00DD97DAB}';

implementation

uses frmPrincipalU;

{$R *.fmx}

procedure TfrmChat.btnEnviarClick(Sender: TObject);
var
  // Vari?vel que usaremos para converter nossa mensagem
  // de String para c?digo bin?rio
  LMsg: TBytes;
begin

  // Se dispositivo foi selecionado e ambos est?o pareados/conectados.
  if (FDispositivo <> nil) and
     (frmPrincipal.Bluetooth1.ConnectionState=TBluetoothConnectionState.Connected) then
    Try
      // Faz uma conex?o via socket com o outro device
      if (FSocket=nil) then begin

        // Cria um socket de cliente baseado no GUID do servico.
        FSocket := FDispositivo.CreateClientSocket(StringToGUID(ChatGUI), False);
        if FSocket <> nil then begin
          FSocket.Connect;
        end;

      end;

      // Converte a nossa mensagem para bin?rio
      LMsg := TEncoding.UTF8.GetBytes(edtTexto.Text);

      // Envia o texto binario atrav?s do client socket.
      FSocket.SendData(LMsg);
      // Exibe a mensagem enviada no nosso Memo.
      memHistorico.Lines.Add('Voc?: '+edtTexto.Text);
      memHistorico.GoToTextEnd;
      edtTexto.Text := '';
    Except
      On E:Exception do begin
        // ERRO: notifica usuario sobre o erro e avanca
        memHistorico.Lines.Add('Erro: '+E.Message);
        memHistorico.GoToTextEnd;
        // Libera o socket na mem?ria.
        {$IFDEF ANDROID}
          FSocket.DisposeOf;
          FSocket := nil;
        {$ELSE}
          FreeAndNil(FSocket);
        {$ENDIF}
      end;
   End;

end;
procedure TfrmChat.btnServidorClick(Sender: TObject);
begin

  // Se nenhum device foi selecionado da lista
  // para a conex?o
  if cbDispositivo.ItemIndex < 0 then begin
    ShowMessage('Escolha um dispositivo.');
    btnServidor.IsPressed := False; // Evita bug ao clicar novamente
    exit; // Para de executar o evento
  end;

  // Se botao esta pressionado (afundado)
  // inicia o servidor
  if btnServidor.IsPressed then begin

    try

      //  Cria a Thread mas n?o a inicia j?
      FThreadServidor := TServiceThread.Create(true);

      // Cria socket do servidor baseado no nome e GUID do servico.
      FThreadServidor.FServerSocket := frmPrincipal
                                        .Bluetooth1
                                        .CreateServerSocket(ChatServiceName
                                                              ,StringToGUID(ChatGUI)
                                                              ,False);
      // Atribui TMEMO para saida de dados
      FThreadServidor.FDisplay := memHistorico;

      // Nome do dispositivo para exibir as mensagens
      FThreadServidor.FNomeDispositivo := cbDispositivo.Items[cbDispositivo.ItemIndex];

      // Inicia a escuta do servidor para conex?es
      FThreadServidor.Start;

      // Ajusta os componentes do formul?rio
      btnServidor.Text := 'Parar servidor';
      memHistorico.Lines.Add('[SERVIDOR INICIADO]');
      cbDispositivo.Enabled := False;

    Except
      // Se der erro
      On E:Exception do begin

        // ERRO: notifica usuario e ajusta componentes do formulario
        memHistorico.Lines.Add(E.Message);
        memHistorico.GoToTextEnd;
        btnServidor.Text := 'Iniciar Servidor';
        btnServidor.IsPressed := False;
        cbDispositivo.Enabled := True;

      end;
    end;
  end
  // Se n?o estiver mais pressionado
  else begin

    // Se a Thread j? n?o tiver sido encerrada
    if FThreadServidor <> nil then begin

      // Flag da thread para terminar e interromper servidor
      FThreadServidor.Terminate;
      // Aguarda pela finaliza??o da Thread
      FThreadServidor.WaitFor;

      // Libera a Thread da mem?ria
      {$IFDEF ANDROID}
        FThreadServidor.DisposeOf;
        FThreadServidor := nil;
      {$ELSE}
        FreeAndNil(FThreadServidor);
      {$ENDIF}

      // Notifica o usu?rio e ajusta componentes
      memHistorico.Lines.Add('[SERVIDOR INTERROMPIDO]');
      memHistorico.GoToTextEnd;
      btnServidor.Text := 'Iniciar Servidor';
      btnServidor.IsPressed := False;
      cbDispositivo.Enabled := True;
    end;
  end;
end;

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
  // Grava o dispositivo selecionado na vari?vel do device pareado
  FDispositivo := frmPrincipal. // Formul?rio principal
                  Bluetooth1.   // Componente Bluetooth
                  // Fun??o que lista os dispositivos pareados
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

{ TServiceThread }

constructor TServiceThread.Create(ACreateSuspended: Boolean);
begin
  // Herda do construtor da classe Pai
  inherited;
end;

destructor TServiceThread.Destroy;
begin

  //  Libera as classes e atributos da mem?ria
  //  do device de acordo com o tipo
  {$IFDEF ANDROID}
    FSocket.DisposeOf;
    FServerSocket.DisposeOf;
    FSocket := nil;
    FServerSocket := nil;
  {$ELSE}
    FSocket.Free;
    FServerSocket.Free;
  {$ENDIF}

  // Herda do destrutor da classe Pai
  inherited;
end;

procedure TServiceThread.Execute;
var
  // Vari?vel que recebera a convers?o dos dados
  Msg: string;
  // Vari?vel que recebe os dados bin?rios de outro device
  LDados: TBytes;
begin
  // Repete at? que n?o tenhamos setado como True
  // o fim da Thread
  while not Terminated do
    try
      // Libera o socket atual
      FSocket := nil;

      // Cria uma nova conex?o do socket
      // pois ela pode mudar
      while not Terminated and (FSocket = nil) do
        FSocket := FServerSocket.Accept(100);

      // Caso a conex?o seja feita fazemos a leitura dos dados
      if(FSocket <> nil) then begin

        // Repete at? que n?o tenhamos setado como True
        // o fim da Thread
        while not Terminated do begin

          // Recebe os dados da leitura do socket
          LDados := FSocket.ReceiveData;

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

end.
