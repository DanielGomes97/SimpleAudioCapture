program CyrusSoftGravador;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'View\uPrincipal.pas' {FrmPrincipal},
  uAudioCapture in 'Model\uAudioCapture.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
