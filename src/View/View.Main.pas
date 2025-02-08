unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Types, FMX.Controls.Presentation,
  FMX.StdCtrls, System.DateUtils, FMX.Platform, FMX.Layouts,
  System.Threading, FMX.Media, FMX.Objects, FMX.Edit, FMX.Effects,
  System.Actions, FMX.ActnList, FMX.Graphics, FMX.Ani, System.netEncoding,
  System.IOUtils, Model.AudioCapture, FMX.ListBox, System.Skia, FMX.Skia,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

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
    procedure FormCreate(Sender: TObject);
    procedure TimerUpdatesInsecondsTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnRecordingClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure TimerUpdateCurrentAudioTimer(Sender: TObject);

  private
    //
    MediaPlayerAudio: TMediaPlayer;
    Files: TStringDynArray;
    AudioFiles: TArray<TAudioInfo>;
    AudioInfo: TAudioInfo;
    //
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

const
   MediaTimeScale: Integer = $989680;
   TimeDefault: String = '00:00';
   StartRecording: String = 'Start recording';
   StopRecording : String = 'Stop Recorder';
   //ColorRed: TAlphaColor = $

implementation

{$R *.fmx}

uses View.Frame.ListAudio;

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
    LblNameButtonStart.Text := StartRecording;
    BtnRecording.Fill.Color := $FF166DB4;
    AudioCapture.FMicroAtivo := False;
    AudioCapture.FAudioAtivo := False;
    MediaPlayerAudio := TMediaPlayer.Create(nil); // Inicializa o MediaPlayer
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
    //
    MediaPlayerAudio.Free;
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
    //Item.Tag            := Codigo;
    Item.TagString      := CaminhoAudio;
    Item.Selectable     := False;
    Frame                         := TFrameListAudio.Create(Item); //
    Frame.Parent                  := Item;
    Frame.SkLblTitle.Text         := Title;
    Frame.SkLblTimer.Text         := Timer;
    //Frame.BtnOpcaoLista.Tag       := Codigo;
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
begin
    BtnPlayAudio := Sender As TSpeedButton;
    ShowMessage(BtnPlayAudio.TagString);
    exit;

    SKTitle.Text := MediaPlayerAudio.FileName;
    SKTimeAudio.Text := MediaPlayerAudio.Duration.ToString;
    SKTimeAudioCurrent.Text := MediaPlayerAudio.CurrentTime.ToString;
    LytMenuAudio.Visible := True;

    MediaPlayerAudio.Media.Play;
    RecBARCurrentAudio.Width := 0;
    TimerUpdateCurrentAudio.Enabled := True;
    //
end;

procedure TFrmViewMain.SpeedButton1Click(Sender: TObject);
begin
    Memo1.Visible := False;
    LstListAudio.Items.Clear;
    AudioFiles := ListAudioFiles(AudioCapture.FileAudio);  // Diretório onde os áudios estão salvos
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
  Caminho: String;
begin
    Caminho := AudioCapture.GetOriginPath;

    {$IFDEF ANDROID}   Files := TDirectory.GetFiles(Directory, '*.mp3'); {$ENDIF}
    {$IFDEF MSWINDOWS}
        Files := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.wav');
        Files := Files + TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.mp3');
    {$ENDIF}
end;

function TFrmViewMain.ListAudioFiles(const Directory: string): TArray<TAudioInfo>;
var
  FileName: string;
  AudioInfo: TAudioInfo;
  AudioList: TArray<TAudioInfo>;
  Minutes, Seconds: Integer;
  MinCurrent, SecondsCurrent: Integer;
begin
    // Lista todos os arquivos .mp3 (Android) ou .wav (Windows) no diretório
    {$IFDEF ANDROID}   Files := TDirectory.GetFiles(AudioCapture.GetOriginPath, '*.mp3'); {$ENDIF}
    {$IFDEF MSWINDOWS}
        //Files := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.wav');
        //Files := Files + TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.mp3');
        Files := TDirectory.GetFiles(AudioCapture.GetOriginPath, '*.wav');

        {$ENDIF}
    try
        SetLength(AudioList, 0);
        for FileName in Files do
        begin
            MediaPlayerAudio.FileName := FileName; // Carrega o arquivo de áudio no MediaPlayer
            MediaPlayerAudio.CurrentTime := 0; //zerar
            if MediaPlayerAudio.Duration > 0 then // Verifica se a duração foi carregada corretamente
            begin
                // Converte a duração para minutos e segundos
                Minutes := MediaPlayerAudio.Duration div MediaTimeScale div 60;
                Seconds := MediaPlayerAudio.Duration div MediaTimeScale mod 60;

                // Preenche a estrutura TAudioInfo
                AudioInfo.FileName := TPath.GetFileName(FileName);
                AudioInfo.Duration := Format('%.2d:%.2d', [Minutes, Seconds]);

                //alimentar frame.
                ListarAudioFiles(AudioInfo.FileName, AudioInfo.Duration, FileName);

                // Adiciona à lista
                SetLength(AudioList, Length(AudioList) + 1);
                AudioList[High(AudioList)] := AudioInfo;
            end;
        end;
    finally
    end;
    Result := AudioList;
end;

end.


