program CyrusSoft_Recorder;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'View\View.Main.pas' {FrmViewMain},
  Model.AudioCapture in 'Model\Model.AudioCapture.pas',
  Model.PermissionsUser in 'Model\Model.PermissionsUser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmViewMain, FrmViewMain);
  Application.Run;
end.
