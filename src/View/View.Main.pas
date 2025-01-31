unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Types, FMX.Controls.Presentation,
  FMX.StdCtrls, System.DateUtils, FMX.Platform, FMX.Layouts,
  System.Threading, FMX.Media, FMX.Objects, FMX.Edit, FMX.Effects,
  System.Actions, FMX.ActnList, FMX.Graphics, FMX.Ani, System.netEncoding,
  System.IOUtils, Model.AudioCapture;

type
  TFrmViewMain = class(TForm)
    BtnRecording: TRectangle;
    LoBase: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    LblNameButtonStart: TLabel;
    TimeUpdatesInseconds: TTimer;
    Rectangle2: TRectangle;
    LblTitle: TLabel;
    LblStatus: TLabel;
    LblOriginPath: TLabel;
    LblCount: TLabel;
    Layout1: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure TimeUpdatesInsecondsTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnRecordingClick(Sender: TObject);

  private
    procedure Iniciar;
    procedure Parar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmViewMain: TFrmViewMain;
  AudioCapture : TAudioCapture;

implementation

{$R *.fmx}

procedure TFrmViewMain.Parar;
begin
    AudioCapture.StopRecording;
    LblNameButtonStart.Text := 'Start recording';
    BtnRecording.Fill.Color := $FF166DB4;
    LblStatus.FontColor := $FF794343;
    LblStatus.Text := 'stopped';
    LblOriginPath.Text:= 'Saved in: ' + AudioCapture.FileAudio;
    LblCount.Text := '00:00';
    TimeUpdatesInseconds.Enabled := False;
    AudioCapture.FSeconds := 0;
end;

procedure TFrmViewMain.Iniciar;
begin
    AudioCapture.StartRecording;
    LblStatus.FontColor := $FF147F44;
    LblNameButtonStart.Text := 'Stop Recorder';
    BtnRecording.Fill.Color := $FF794343;
    LblStatus.Text := 'recording audio...';
    LblOriginPath.Text:= 'Saving to: ' + AudioCapture.FileAudio;
    LblCount.Text := '00:00';
    TimeUpdatesInseconds.Enabled := True;
end;

procedure TFrmViewMain.BtnRecordingClick(Sender: TObject);
begin
    if NOT AudioCapture.FMicroAtivo then
       begin
            if NOT AudioCapture.CheckMicrophone then//
               raise Exception.Create('Audio Capture: Permission required to use the microphone.');
            AudioCapture.FMicroAtivo := True;
       end;

    if LblNameButtonStart.Text = 'Stop Recorder' then
       Parar
    else
    begin
        {$IFDEF ANDROID}
        if NOT AudioCapture.FAudioAtivo then
           begin
               AudioCapture.CheckPermissionAudio;
               AudioCapture.FAudioAtivo := True;
           end;
        {$ENDIF}
        Iniciar;
    end;
end;

procedure TFrmViewMain.FormCreate(Sender: TObject);
begin
    AudioCapture    := TAudioCapture.Create;
    LblNameButtonStart.Text := 'Start recording';
    BtnRecording.Fill.Color := $FF166DB4;
    AudioCapture.FMicroAtivo := False;
    AudioCapture.FAudioAtivo := False;
    ReportMemoryLeaksOnShutdown := True;
end;

procedure TFrmViewMain.FormDestroy(Sender: TObject);
begin
    if (assigned(AudioCapture.FMediaPlayer.Media)) then
       if (AudioCapture.FMediaPlayer.Media.State = TMediaState.Playing) then
          AudioCapture.FMediaPlayer.Media.stop;
    if (assigned(AudioCapture.FMicrophone)) then
       if (AudioCapture.FMicrophone.State = TCaptureDeviceState.Capturing) then
          AudioCapture.FMicrophone.StopCapture;
    AudioCapture.PermissoesUser.Free;
    AudioCapture.FMediaPlayer.Free;
    AudioCapture.Free;
end;

procedure TFrmViewMain.TimeUpdatesInsecondsTimer(Sender: TObject);
begin
    Inc(AudioCapture.FSeconds);
    LblCount.Text := Format('%.2d:%.2d', [AudioCapture.FSeconds div 60, AudioCapture.FSeconds mod 60]); // update: time MM:SS
end;

end.


