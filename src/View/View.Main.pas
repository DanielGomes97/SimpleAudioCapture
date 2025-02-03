unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Types, FMX.Controls.Presentation,
  FMX.StdCtrls, System.DateUtils, FMX.Platform, FMX.Layouts,
  System.Threading, FMX.Media, FMX.Objects, FMX.Edit, FMX.Effects,
  System.Actions, FMX.ActnList, FMX.Graphics, FMX.Ani, System.netEncoding,
  System.IOUtils, Model.AudioCapture, FMX.ListBox, System.Skia, FMX.Skia;

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
    procedure FormCreate(Sender: TObject);
    procedure TimerUpdatesInsecondsTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnRecordingClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);

  private
    procedure Iniciar;
    procedure Parar;
    procedure ListAudioFiles(Title, Timer: String);
    procedure ClickMenuOptionTrash(Sender: TObject);
    procedure ClickMenuOptionPlay(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmViewMain: TFrmViewMain;
  AudioCapture : TAudioCapture;

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

procedure TFrmViewMain.SpeedButton1Click(Sender: TObject);
begin
    ListAudioFiles('Musica do Dia', '05:30');
    ListAudioFiles('Musica da Noite', '04:42');
    ListAudioFiles('Musica da Tarde', '03:09');
    ListAudioFiles('Musica da Madrugada', '10:50');
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

//
procedure TFrmViewMain.ListAudioFiles(Title, Timer: String);
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
end;

end.


