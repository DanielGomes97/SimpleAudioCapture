program CyrusSoft_Recorder;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'View\View.Main.pas' {FrmPrincipal},
  Model.AudioCapture in 'Model\Model.AudioCapture.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
