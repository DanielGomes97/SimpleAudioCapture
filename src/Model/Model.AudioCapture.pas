unit Model.AudioCapture;

interface
uses
   System.DateUtils, System.SysUtils, FMX.Media, System.IOUtils, Model.PermissionsUser;

type
   TAudioCapture = class
  private
    FFileName: String; //
    function  GetFileName: String;
    procedure SetFileName(const Value: String);
    procedure StartCapture;
    function HasMicrophone: Boolean;
    function IsMicrophoneRecording: Boolean;
    function StopCapture: Boolean;

  public
  { Public declarations }
    FileAudio: String;
    FileOrigin: String;
    FSeconds: Integer;
    FMicrophone  : TAudioCaptureDevice;
    FMediaPlayer : TMediaPlayer;
    FMicroAtivo, FAudioAtivo : Boolean;
    PermissoesUser : TPermissoesUser;//ins

    property  FileName: String read GetFileName write SetFileName;
    procedure StartRecording;
    function  StopRecording: Boolean;
    procedure ConfigRecording;
    function  GetAudioFileName(const AFileName: string): string;
    function  CheckMicrophone: Boolean;
    function  CheckPermissionAudio: Boolean;
    procedure ListenAudio(AFileName: string);
    procedure Stop;
    procedure Play;
    constructor Create;
   end;

implementation

{ TAudioCapture }
procedure TAudioCapture.ConfigRecording;
var
  LData: TDateTime;
  LFileName: String;
begin
    LData :=  Now;
    LFileName :=  'Date-' + (LData.Day).ToString;
    LFileName :=  LFileName + '-' + (LData.Month).ToString;
    LFileName :=  LFileName + '-' + (LData.Year).ToString;
    LFileName :=  Trim(LFileName + '-' + copy(TimeToStr(now), 1, 2) + '-' + copy(TimeToStr(now), 4, 2) + '-' + copy(TimeToStr(now), 7, 2)) ; //Hora deve estar no formato HH:MM:SS
    {$IFDEF ANDROID}   FileAudio := GetAudioFileName(LFileName + '.mp3'); {$ENDIF}
    {$IFDEF IOS}       FileAudio := ExtractFilePath( ParamStr(0) ) + LFileName + '.mp3'; {$ENDIF}
    {$IFDEF MSWINDOWS} FileAudio := ExtractFilePath( ParamStr(0) ) + LFileName + '.wav'; {$ENDIF}
end;

constructor TAudioCapture.Create;
begin
    FMediaPlayer := TMediaPlayer.Create(nil);
    FMicrophone  := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
    FSeconds := 0;
    PermissoesUser := TPermissoesUser.Create;
end;

function TAudioCapture.CheckPermissionAudio: Boolean;
begin
    Result := True;
    {$IFDEF ANDROID}
      if not (PermissoesUser.TemPermissao([PermissoesUser.RECORD_AUDIO])) then
         raise Exception.Create('Necessario ter permissão para usar audio.');
    {$ENDIF}
end;

function TAudioCapture.GetAudioFileName(const AFileName: string): string;
begin
    {$IFDEF ANDROID}
        var SubPasta: String;
        SubPasta := TPath.Combine(TPath.GetSharedDownloadsPath, 'CurysGravacao'); //create folder in downloads...
            if not TDirectory.Exists(SubPasta) then
               TDirectory.CreateDirectory(SubPasta);
        Result := TPath.Combine(SubPasta, AFileName);
    {$ENDIF}
    {$IFDEF IOS} result := TPath.GetDocumentsPath + PathDelim + AFileName; {$ENDIF}
    {$IFDEF MSWINDOWS} result := 'C:\' + AFileName; {$ENDIF}
end;

function TAudioCapture.GetFileName: String;
begin
    if FFileName = '' then //check
       raise Exception.Create('File invalid.');
    Result := FFileName;
end;

procedure TAudioCapture.SetFileName(const Value: String);
begin
    FFileName := Value;
    if not DirectoryExists(ExtractFilePath(FFileName)) then
       CreateDir(ExtractFilePath(FFileName));
end;

procedure TAudioCapture.StartRecording;
begin
    ConfigRecording; //default
    SetFileName(FileAudio);
    FSeconds := 0;
    StartCapture;
end;

procedure TAudioCapture.StartCapture;
begin
    if assigned(FMediaPlayer.Media) then
       if (FMediaPlayer.Media.State = TMediaState.Playing) then
          FMediaPlayer.Media.stop;
    if (FMicrophone.State = TCaptureDeviceState.Capturing) then
          FMicrophone.StopCapture;
    FMicrophone := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
    if (HasMicrophone) then
    begin
        FMicrophone.FileName := FileAudio;
        try
            FMicrophone.StartCapture;
        except on E : Exception do
            raise Exception.Create('Audio Capture: Permission required to use the microphone.');
        end;
    end
    else
       raise Exception.Create('Sorry, invalid microphone!');
end;

function TAudioCapture.StopCapture : Boolean;
begin
    result := false;
    if (IsMicrophoneRecording) then
    begin
        try
           FMicrophone.StopCapture;
           result := true;
        except on E : Exception do
           raise Exception.Create('Operation not supported by this device.' + sLineBreak + 'Message: ' + E.Message);
        end;
    end;
end;

function TAudioCapture.StopRecording: Boolean;
begin
    Result := False;
    if (IsMicrophoneRecording) then
    begin
         try
            FMicrophone.StopCapture;
            Result := True;
         except on E : Exception do
            raise Exception.Create('Operation not supported by this device.' + sLineBreak + 'Message: ' + E.Message);
         end;
    end;
end;

//When activating the option to listen to audio, this function will be re-enabled.
procedure TAudioCapture.ListenAudio(AFileName: string);
begin
    CheckPermissionAudio;
    //{$IFDEF ANDROID}
    //   if not (PermissoesUser.TemPermissao([PermissoesUser.RECORD_AUDIO])) then
    //      raise Exception.Create('Necessario ter permissão para usar audio.');
    // {$ENDIF}
  if ((AFileName) <> '') then
     //FFileName := AFileName; //SetnomeArquivo(arquivo);
  if NOT(FileExists(AFileName)) then
  begin
      if ((AFileName) = '') or not (FileExists(AFileName)) then
         raise Exception.Create('Media file not found.'+ sLineBreak+ AFileName)
      else
         raise Exception.Create('Sorry, you are only allowed to listen to this audio.');
  end;
end;

function TAudioCapture.HasMicrophone: Boolean;
begin
    Result := Assigned(FMicrophone);
end;
function TAudioCapture.IsMicrophoneRecording: Boolean;
begin
    Result := HasMicrophone and (FMicrophone.State = TCaptureDeviceState.Capturing);
end;

function TAudioCapture.CheckMicrophone: Boolean;
begin
    if assigned(FMediaPlayer.Media) then
       if (FMediaPlayer.Media.State = TMediaState.Playing) then
          FMediaPlayer.Media.stop;
    if (FMicrophone.State = TCaptureDeviceState.Capturing) then
          FMicrophone.StopCapture;
    FMicrophone := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
    if (HasMicrophone) then
    begin
        FMicrophone.FileName := FFileName;
        Result := True;
    end
    else
       Result := False;
end;

procedure TAudioCapture.Play;
begin
    if (Trim(FFileName) = '') or not(FileExists(FFileName)) then
       raise Exception.Create('Arquivo não encontrado...' + sLineBreak + FFileName)
    else
    begin
        if IsMicrophoneRecording then
            StopCapture;
        FMediaPlayer.FileName := FFileName;
        FMediaPlayer.Media.Play;
    end;
end;

procedure TAudioCapture.Stop;
begin
    try
        if (FMediaPlayer <> nil) and (FMediaPlayer.Media <> nil) then
        begin
            if (FMediaPlayer.Media.State = TMediaState.Playing) then
               FMediaPlayer.Media.Stop;
        end;
    except
    end;
    try
        if (assigned(FMediaPlayer)) then
           FMediaPlayer.Media.Free;
        FMediaPlayer := TMediaPlayer.Create(nil);
    except
    end;
end;

{procedure TAudioCapture.changedExecuteControls;
var
  thr, thr2 : TThread;
begin
   thr := TThread.CreateAnonymousThread(procedure
       var pMax, pAtu : TMediaTime;
       begin
          thr.FreeOnTerminate := true;
          begin
             pMax               := FMediaPlayer.Media.Duration;
             while (FMediaPlayer.Media.State = TMediaState.Playing) do
             begin
                Try
                  Sleep(10);
                  pAtu := FMediaPlayer.Media.CurrentTime;
                Except end;
                Sleep(10);
             end;
          end;
       end);
   thr.Start;
end;  }

end.
