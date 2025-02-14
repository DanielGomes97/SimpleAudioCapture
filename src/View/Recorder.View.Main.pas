unit Recorder.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Types, FMX.Controls.Presentation,
  FMX.StdCtrls, System.DateUtils, FMX.Platform, FMX.Layouts,
  System.Threading, FMX.Media, FMX.Objects, FMX.Edit, FMX.Effects,
  System.Actions, FMX.ActnList, FMX.Graphics, FMX.Ani, System.netEncoding,
  System.IOUtils, FMX.ListBox, System.Skia, FMX.Skia,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  //
  Recorder.View.Frame.Mensagem,
  Recorder.View.Frame.ListAudio,
  Recorder.Model.AudioCapture,
  Recorder.Model.PermissionsUser,
  Recorder.Model.Utils.Utils;

type
  TAudioInfo = record
    FileName: string;
    Duration: string; // Duração no formato "mm:ss"
  end;

type
  TFrmViewMain = class(TForm)
    BtnRecording: TRectangle;
    LoBase: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    LblNameButtonStart: TLabel;
    TimerUpdatesInseconds: TTimer;
    Rectangle2: TRectangle;
    LblTitle: TLabel;
    LblStatus: TLabel;
    LblOriginPath: TLabel;
    LblCount: TLabel;
    Layout1: TLayout;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    LstListAudio: TListBox;
    LytMenuAudio: TLayout;
    Rectangle1: TRectangle;
    Rectangle3: TRectangle;
    Layout9: TLayout;
    Layout10: TLayout;
    Layout11: TLayout;
    Layout12: TLayout;
    SkLabel1: TSkLabel;
    SpeedButton2: TSpeedButton;
    Layout13: TLayout;
    Layout14: TLayout;
    Layout15: TLayout;
    Layout16: TLayout;
    Layout17: TLayout;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Layout18: TLayout;
    Rectangle4: TRectangle;
    RecBARCurrentAudio: TRectangle;
    Layout19: TLayout;
    SKTimeAudio: TSkLabel;
    SKTimeAudioCurrent: TSkLabel;
    TimerUpdateCurrentAudio: TTimer;
    Memo1: TMemo;
    SKTitle: TSkLabel;
    FloatAnimationWidthAudio: TFloatAnimation;
    FrameMensagem1: TFrameMensagem;
    procedure FormCreate(Sender: TObject);
    procedure TimerUpdatesInsecondsTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnRecordingClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure TimerUpdateCurrentAudioTimer(Sender: TObject);
    procedure FrameMensagem1BtnPermitirAcessoClick(Sender: TObject);

  private
    MediaPlayerAudio: TMediaPlayer;
    AudioFiles: TArray<TAudioInfo>;
    AudioInfo: TAudioInfo;

    procedure Iniciar;
    procedure Parar;
    procedure ListarAudioFiles(Title, Timer, CaminhoAudio: String);
    procedure ClickMenuOptionTrash(Sender: TObject);
    procedure ClickMenuOptionPlay(Sender: TObject);
    function  ListAudioFiles(const Directory: string): TArray<TAudioInfo>;
    procedure ListarDiretorioAudios;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmViewMain: TFrmViewMain;
  AudioCapture : TAudioCapture;
  Permissoes   : TPermissoesUser;
  aPermissaoSolicitada: TArray<String>;

const
   MediaTimeScale: Integer = $989680;
   TimeDefault: String = '00:00';
   StartRecording: String = 'Start recording';
   StopRecording : String = 'Stop Recorder';

implementation

{$R *.fmx}

procedure TFrmViewMain.Parar;
begin
    AudioCapture.StopRecording;
    LblNameButtonStart.Text := StartRecording;
    BtnRecording.Fill.Color := $FF166DB4;
    LblStatus.FontColor := $FF794343;
    LblStatus.Text := 'stopped';
    LblOriginPath.Text:= 'Saved in: ' + AudioCapture.FileAudio;
    LblCount.Text := TimeDefault;
    TimerUpdatesInseconds.Enabled := False;
    AudioCapture.FSeconds := 0;
end;

procedure TFrmViewMain.Iniciar;
begin
    AudioCapture.StartRecording;
    LblStatus.FontColor := $FF147F44;
    LblNameButtonStart.Text := StopRecording;
    BtnRecording.Fill.Color := $FF794343;
    LblStatus.Text := 'recording audio...';
    LblOriginPath.Text:= 'Saving to: ' + AudioCapture.FileAudio;
    LblCount.Text := TimeDefault;
    TimerUpdatesInseconds.Enabled := True;
end;

procedure TFrmViewMain.BtnRecordingClick(Sender: TObject);
begin
    if NOT AudioCapture.FMicroAtivo then
       begin
           //if NOT AudioCapture.CheckMicrophone then//
           //   raise Exception.Create('Audio Capture: Permission required to use the microphone.');
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
    Permissoes      := TPermissoesUser.Create;

    LblNameButtonStart.Text := StartRecording;
    BtnRecording.Fill.Color := $FF166DB4;
    AudioCapture.FMicroAtivo := False;
    AudioCapture.FAudioAtivo := False;
    MediaPlayerAudio := TMediaPlayer.Create(nil);
    //ReportMemoryLeaksOnShutdown := True; //test: vazamento de memoria
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
    //
    MediaPlayerAudio.Free;
    Permissoes.Free;
end;

procedure TFrmViewMain.TimerUpdatesInsecondsTimer(Sender: TObject);
begin
    Inc(AudioCapture.FSeconds);
    LblCount.Text := Format('%.2d:%.2d', [AudioCapture.FSeconds div 60, AudioCapture.FSeconds mod 60]); // update: time MM:SS
end;

procedure TFrmViewMain.ListarAudioFiles(Title, Timer, CaminhoAudio: String);
var
  Item: TListBoxItem;
  Frame: TFrameListAudio;
begin
    Item := TListBoxItem.Create(nil);
    Item.Text           := '';
    Item.Height         := 40;
    Item.Margins.Left   := 0;
    Item.Margins.Right  := 0;
    Item.Margins.Bottom := 10;
    Item.Margins.Top    := 0;
    Item.TagString      := CaminhoAudio;
    Item.Selectable     := False;

    Frame                         := TFrameListAudio.Create(Item); //
    Frame.Parent                  := Item;
    Frame.TagString               := CaminhoAudio;
    Frame.SkLblTitle.Text         := Title;
    Frame.SkLblTimer.Text         := Timer;
    Frame.BtnPlayAudio.TagString  := CaminhoAudio;
    Frame.BtnTrashAudio.OnClick   := ClickMenuOptionTrash;
    Frame.BtnPlayAudio.OnClick    := ClickMenuOptionPlay;
    Frame.Align                   := TAlignLayout.Client;
    LstListAudio.AddObject(Item);
end;

procedure TFrmViewMain.ClickMenuOptionTrash(Sender: TObject); //trash
begin
    //ShowMessage('Trash');
end;

procedure TFrmViewMain.ClickMenuOptionPlay(Sender: TObject); //play
var
  BtnPlayAudio: TSpeedButton;
  Frame: TFrameListAudio;
  ParentComponent: TFMXObject;
begin
    if not (Sender is TSpeedButton) then
      Exit;

    BtnPlayAudio := Sender as TSpeedButton;
    ParentComponent := BtnPlayAudio.Parent;

    while (ParentComponent <> nil) and not (ParentComponent is TFrameListAudio) do
          ParentComponent := ParentComponent.Parent;

    if ParentComponent is TFrameListAudio then
    begin
        Frame := TFrameListAudio(ParentComponent);
        MediaPlayerAudio.FileName := Frame.BtnPlayAudio.TagString;

        SKTitle.Text := MediaPlayerAudio.FileName;
        SKTimeAudio.Text := MediaPlayerAudio.Duration.ToString;
        SKTimeAudioCurrent.Text := MediaPlayerAudio.CurrentTime.ToString;
        LytMenuAudio.Visible := True;

        MediaPlayerAudio.Media.Play;
        RecBARCurrentAudio.Width := 0;
        TimerUpdateCurrentAudio.Enabled := True;
    end;
end;

procedure TFrmViewMain.FrameMensagem1BtnPermitirAcessoClick(Sender: TObject);
begin
    if FrameMensagem1.BtnPermitirAcesso.Tag = 1 then
    begin
        FrameMensagem1.BtnPermitirAcesso.Tag := 0;
        {$IFDEF ANDROID} Permissoes.SolicitarPermissao(aPermissaoSolicitada);{$ENDIF}
        FrameMensagem1.BtnPermitirAcessoClick(Sender);
    end
    else
       FrameMensagem1.BtnPermitirAcessoClick(Sender);
end;

procedure TFrmViewMain.SpeedButton1Click(Sender: TObject);
begin
    {$IFDEF ANDROID}
    if NOT Permissoes.VerificarPermissao(Permissoes.RECORD_AUDIO) then
       begin
           aPermissaoSolicitada := [Permissoes.RECORD_AUDIO];
           FrameMensagem1.MostrarMensagem(TYPE_PERMISSIONS, MSG_RECORD_AUDIO, True);
       end
    else
    if NOT Permissoes.VerificarPermissaoNegada(Permissoes.RECORD_AUDIO) then
       FrameMensagem1.MostrarMensagem(TYPE_INFORMATION, MSG_REQUEST_AGAIN, True);
    {$ENDIF}

    {Permissoes.SolicitarPermissao([Permissoes.RECORD_AUDIO,
                               Permissoes.CAMERA,
                               Permissoes.READ_EXTERNAL_STORAGE,
                               Permissoes.WRITE_EXTERNAL_STORAGE]); }
    //Memo1.Visible := False;
    //LstListAudio.Items.Clear;
    //ListarDiretorioAudios;
    //AudioFiles := ListAudioFiles(AudioCapture.FileAudio);  // Diretório onde os áudios estão salvos
end;

procedure TFrmViewMain.TimerUpdateCurrentAudioTimer(Sender: TObject);
begin
    if NOT (MediaPlayerAudio.Media.State = TMediaState.Playing) then
       begin
           FloatAnimationWidthAudio.Stop;
           RecBARCurrentAudio.Width := 0;
           Exit;
       end;
    SKTimeAudioCurrent.Text := MediaPlayerAudio.CurrentTime.ToString;
    FloatAnimationWidthAudio.StartValue := RecBARCurrentAudio.Width;
    FloatAnimationWidthAudio.StopValue  := RecBARCurrentAudio.Width + (Rectangle4.Width / (MediaPlayerAudio.Duration div MediaTimeScale));
    FloatAnimationWidthAudio.Duration   := 1.0;
    FloatAnimationWidthAudio.Start;
end;

 procedure TFrmViewMain.SpeedButton2Click(Sender: TObject);
begin
    MediaPlayerAudio.Media.Stop;
    MediaPlayerAudio.CurrentTime := 0;
    LytMenuAudio.Visible := False;
    TimerUpdateCurrentAudio.Enabled := False;
end;

procedure TFrmViewMain.SpeedButton3Click(Sender: TObject);
begin
    if (MediaPlayerAudio.Media.State = TMediaState.Playing) then
       MediaPlayerAudio.Media.Stop;
    TimerUpdateCurrentAudio.Enabled := False;
end;

procedure TFrmViewMain.SpeedButton5Click(Sender: TObject);
begin
    if NOT(MediaPlayerAudio.Media.State = TMediaState.Playing) then
       MediaPlayerAudio.Media.Play;
    TimerUpdateCurrentAudio.Enabled := True;
end;

procedure TFrmViewMain.ListarDiretorioAudios;
var
  FileName: string;
  Files: TStringDynArray;
begin
    {$IFDEF ANDROID}   Files := TDirectory.GetFiles(AudioCapture.GetOriginPath, '*.mp3'); {$ENDIF}
    {$IFDEF MSWINDOWS}
        Files := TDirectory.GetFiles(AudioCapture.GetOriginPath, '*.wav');
        Files := Files + TDirectory.GetFiles(AudioCapture.GetOriginPath, '*.mp3');
    {$ENDIF}

    for FileName in Files do
    begin
        TPath.GetFileName(FileName);
        ListarAudioFiles(TPath.GetFileName(FileName), '00:00', AudioCapture.GetOriginPath + '\'+ TPath.GetFileName(FileName));
    end;
end;

function TFrmViewMain.ListAudioFiles(const Directory: string): TArray<TAudioInfo>;
var
  FileName: string;
  AudioInfo: TAudioInfo;
  AudioList: TArray<TAudioInfo>;
  Minutes, Seconds: Integer;
  MinCurrent, SecondsCurrent: Integer;
  Files: TStringDynArray;
begin
    {$IFDEF ANDROID}   Files := TDirectory.GetFiles(AudioCapture.GetOriginPath, '*.mp3'); {$ENDIF}
    {$IFDEF MSWINDOWS}
        Files := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.wav');
        Files := Files + TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.mp3');
    {$ENDIF}
    try
        SetLength(AudioList, 0);
        for FileName in Files do
        begin
            MediaPlayerAudio.FileName := FileName;
            MediaPlayerAudio.CurrentTime := 0;
            if MediaPlayerAudio.Duration > 0 then
            begin
                Minutes := MediaPlayerAudio.Duration div MediaTimeScale div 60;
                Seconds := MediaPlayerAudio.Duration div MediaTimeScale mod 60;

                AudioInfo.FileName := TPath.GetFileName(FileName);
                AudioInfo.Duration := Format('%.2d:%.2d', [Minutes, Seconds]);

                ListarAudioFiles(AudioInfo.FileName, AudioInfo.Duration, FileName);

                SetLength(AudioList, Length(AudioList) + 1);
                AudioList[High(AudioList)] := AudioInfo;
            end;
        end;
    finally
    end;
    Result := AudioList;
end;

end.


