program ConexaoBluetooth;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmPrincipalU in 'frmPrincipalU.pas' {frmPrincipal},
  frmChatU in 'frmChatU.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
