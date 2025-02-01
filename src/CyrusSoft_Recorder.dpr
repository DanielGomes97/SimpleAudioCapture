program CyrusSoft_Recorder;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  View.Main in 'View\View.Main.pas' {FrmViewMain},
  Model.AudioCapture in 'Model\Model.AudioCapture.pas',
  Model.PermissionsUser in 'Model\Model.PermissionsUser.pas',
  View.Frame.ListAudio in 'View\Frame\View.Frame.ListAudio.pas' {FrameListAudio: TFrame};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TFrmViewMain, FrmViewMain);
  Application.Run;
end.
