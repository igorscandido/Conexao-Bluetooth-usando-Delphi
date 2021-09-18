program ConexaoBluetooth;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmPrincipalU in 'frmPrincipalU.pas' {frmPrincipal},
  frmChatU in 'frmChatU.pas' {Form1},
  frmDescobertaU in 'frmDescobertaU.pas' {frmDescoberta},
  frmPareadosU in 'frmPareadosU.pas' {frmPareados},
  frmServicosU in 'frmServicosU.pas' {frmServicos},
  frmWindowsU in 'frmWindowsU.pas' {frmWindows};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmChat, frmChat);
  Application.CreateForm(TfrmDescoberta, frmDescoberta);
  Application.CreateForm(TfrmPareados, frmPareados);
  Application.CreateForm(TfrmServicos, frmServicos);
  Application.CreateForm(TfrmWindows, frmWindows);
  Application.Run;
end.
