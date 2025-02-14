program Recorder;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  Recorder.View.Main in 'View\Recorder.View.Main.pas' {FrmViewMain},
  Recorder.Model.AudioCapture in 'Model\Recorder.Model.AudioCapture.pas',
  Recorder.Model.PermissionsUser in 'Model\Recorder.Model.PermissionsUser.pas',
  Recorder.View.Frame.ListAudio in 'View\Frame\Recorder.View.Frame.ListAudio.pas' {FrameListAudio: TFrame},
  Recorder.View.Frame.Mensagem in 'View\Frame\Recorder.View.Frame.Mensagem.pas' {FrameMensagem: TFrame},
  Recorder.Model.Utils.Utils in 'Model\Utils\Recorder.Model.Utils.Utils.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TFrmViewMain, FrmViewMain);
  Application.Run;
end.
