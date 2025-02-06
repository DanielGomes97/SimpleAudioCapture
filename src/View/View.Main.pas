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
    Rectangle5: TRectangle;
    Layout19: TLayout;
    SKTimeAudio: TSkLabel;
    SKTimeAudioCurrent: TSkLabel;
    TimerUpdatedraft: TTimer;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure TimerUpdatesInsecondsTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnRecordingClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);

  private
    procedure Iniciar;
    procedure Parar;
    procedure ListarAudioFiles(Title, Timer: String);
    procedure ClickMenuOptionTrash(Sender: TObject);
    procedure ClickMenuOptionPlay(Sender: TObject);
    function  ListAudioFiles(const Directory: string): TArray<TAudioInfo>;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmViewMain: TFrmViewMain;
  AudioCapture : TAudioCapture;

const
   MediaTimeScale: Integer = $989680;

implementation

{$R *.fmx}

uses View.Frame.ListAudio;

procedure TFrmViewMain.Parar;
begin
    AudioCapture.StopRecording;
    LblNameButtonStart.Text := 'Start recording';
    BtnRecording.Fill.Color := $FF166DB4;
    LblStatus.FontColor := $FF794343;
    LblStatus.Text := 'stopped';
    LblOriginPath.Text:= 'Saved in: ' + AudioCapture.FileAudio;
    LblCount.Text := '00:00';
    TimerUpdatesInseconds.Enabled := False;
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
    LblNameButtonStart.Text := 'Start recording';
    BtnRecording.Fill.Color := $FF166DB4;
    AudioCapture.FMicroAtivo := False;
    AudioCapture.FAudioAtivo := False;
    //ReportMemoryLeaksOnShutdown := True;
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

procedure TFrmViewMain.TimerUpdatesInsecondsTimer(Sender: TObject);
begin
    Inc(AudioCapture.FSeconds);
    LblCount.Text := Format('%.2d:%.2d', [AudioCapture.FSeconds div 60, AudioCapture.FSeconds mod 60]); // update: time MM:SS
end;

procedure TFrmViewMain.ListarAudioFiles(Title, Timer: String);
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
    //Item.TagString      := Descricao;
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

procedure TFrmViewMain.ClickMenuOptionTrash(Sender: TObject);
begin
    ShowMessage('Trash');

end;

procedure TFrmViewMain.ClickMenuOptionPlay(Sender: TObject);
begin
    ShowMessage('Play');
    AudioCapture.Play;
end;

procedure TFrmViewMain.SpeedButton1Click(Sender: TObject);
var
  AudioFiles: TArray<TAudioInfo>;
  AudioInfo: TAudioInfo;
begin
    Memo1.Visible := False;
    LstListAudio.Items.Clear;
    //ListAudioFiles('Musica do Dia', '05:30'); ListAudioFiles('Musica da Noite', '04:42');ListAudioFiles('Musica da Tarde', '03:09'); ListAudioFiles('Musica da Madrugada', '10:50');

    AudioFiles := ListAudioFiles(AudioCapture.FileAudio);  // Diretório onde os áudios estão salvos
    for AudioInfo in AudioFiles do // Exibe os arquivos e suas durações
        ListarAudioFiles(AudioInfo.FileName, Format('%s', [AudioInfo.Duration]));
        //Memo1.Lines.Add(Format('Arquivo: %s, Duração: %s', [AudioInfo.FileName, AudioInfo.Duration]));
end;

function TFrmViewMain.ListAudioFiles(const Directory: string): TArray<TAudioInfo>;
var
  Files: TStringDynArray;
  MediaPlayer: TMediaPlayer;
  FileName: string;
  AudioInfo: TAudioInfo;
  AudioList: TArray<TAudioInfo>;
  Minutes, Seconds: Integer;
  MinCurrent, SecondsCurrent: Integer;
begin
    // Lista todos os arquivos .mp3 (Android) ou .wav (Windows) no diretório
    {$IFDEF ANDROID}   Files := TDirectory.GetFiles(Directory, '*.mp3'); {$ENDIF}
    {$IFDEF MSWINDOWS} Files := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.wav'); {$ENDIF}
    MediaPlayer := TMediaPlayer.Create(nil); // Inicializa o MediaPlayer
    try
        SetLength(AudioList, 0);
        for FileName in Files do
        begin
            MediaPlayer.FileName := FileName; // Carrega o arquivo de áudio no MediaPlayer
            MediaPlayer.CurrentTime := 0; //zerar

            // Verifica se a duração foi carregada corretamente
            if MediaPlayer.Duration > 0 then
            begin
                //tempo atual
                {MinCurrent              := MediaPlayer.CurrentTime div MediaTimeScale div 60;
                SecondsCurrent          := MediaPlayer.CurrentTime div MediaTimeScale mod 60;
                MediaPlayer.CurrentTime := Format('Current: %d:%.2d',[MinCurrent, SecondsCurrent]);  }

                //tempo restante
                {RemMins := (MediaPlayer.Duration - MediaPlayer.CurrentTime) div MediaTimeScale div 60;
                RemSecs := (MediaPlayer.Duration - MediaPlayer.CurrentTime) div MediaTimeScale mod 60;
                LblTempoAtual.Text := Format('Remaining: %d:%.2d',[RemMins, RemSecs]);  }

                // Converte a duração para minutos e segundos
                Minutes := MediaPlayer.Duration div MediaTimeScale div 60;
                Seconds := MediaPlayer.Duration div MediaTimeScale mod 60;

                // Preenche a estrutura TAudioInfo
                AudioInfo.FileName := TPath.GetFileName(FileName);
                AudioInfo.Duration := Format('%.2d:%.2d', [Minutes, Seconds]);

                // Adiciona à lista
                SetLength(AudioList, Length(AudioList) + 1);
                AudioList[High(AudioList)] := AudioInfo;
            end;
        end;
    finally
       MediaPlayer.Free;
    end;
    Result := AudioList;
end;

end.


