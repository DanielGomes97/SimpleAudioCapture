unit Model.AudioCapture;

interface
uses
   System.DateUtils, System.SysUtils, FMX.Media, System.IOUtils, Model.PermissionsUser;

type
   TAudioCapture = class
  private
    FFileName: String;
    function  GetFileName: String;
    procedure SetFileName(const Value: String);
    procedure ClearFileTemp;

  public
  { Public declarations }
    FileAudio: String;
    FSeconds: Integer;
    //FFileName: String;
    //lbTimeTemp    : TLabel;
    FMicrophone: TAudioCaptureDevice;
    FMediaPlayer : TMediaPlayer;
    FMicroAtivo, FAudioAtivo : Boolean;


    property FileName: String read GetFileName write SetFileName;
    procedure StartRecording;
    procedure ConfigRecording;
    function GetAudioFileName(const AFileName: string): string;
   end;

implementation

{ TAudioCapture }
procedure TAudioCapture.ConfigRecording;
var
  LData: TDateTime;
  LFileName: String;
begin
    LData :=  Now;
    LFileName :=  'Data-' + (LData.Day).ToString;
    LFileName :=  LFileName + '-' + (LData.Month).ToString;
    LFileName :=  LFileName + '-' + (LData.Year).ToString;
    {$IFDEF ANDROID}   FileAudio := GetAudioFileName(LFileName + '.mp3'); {$ENDIF}
    {$IFDEF IOS}       FileAudio := ExtractFilePath( ParamStr(0) ) + LFileName + '.mp3'; {$ENDIF}
    {$IFDEF MSWINDOWS} FileAudio := ExtractFilePath( ParamStr(0) ) + LFileName + '.wav'; {$ENDIF}

    FMediaPlayer := TMediaPlayer.Create(nil);
    FMicrophone  := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;

    //views
    {LblStatus.Text  := '';
    LblCaminho.Text := '';
    LblNumero.Text  := ''; }
end;

procedure TAudioCapture.ClearFileTemp;
var
  arquivoOld, oldName : String;
begin
    arquivoOld := Trim(FileAudio);
    oldName    := ExtractFilePath(arquivoOld) + 'OLD_'+ ExtractFileName(arquivoOld);
    if (arquivoOld <> '') and FileExists(arquivoOld) then
    begin
        if not (DeleteFile(arquivoOld)) then
        begin
            if (FileExists(oldName)) then
               DeleteFile( oldName );
            RenameFile(arquivoOld, oldName);
        end;
    end;
end;

function TAudioCapture.GetAudioFileName(const AFileName: string): string;
begin
    {$IFDEF ANDROID}
        var PastaDownloads, SubPasta: String;
        PastaDownloads := TPath.GetSharedDownloadsPath;
        SubPasta := TPath.Combine(PastaDownloads, 'CurysGravacao');//criar pasta click dentro da pasta downloads...
            if not TDirectory.Exists(SubPasta) then
               TDirectory.CreateDirectory(SubPasta);
        Result := TPath.Combine(SubPasta, AFileName);
    {$ENDIF}
    {$IFDEF IOS} result := TPath.GetDocumentsPath + PathDelim + AFileName; {$ENDIF}
    {$IFDEF MSWINDOWS} result := 'C:\' + AFileName; {$ENDIF}
end;

function TAudioCapture.GetFileName: String;
begin
    if FFileName = '' then
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
    ConfigRecording;
    SetFileName(const Value: String);
end;
procedure TFrmPrincipal.IniciarGravacao;
begin
    NovaGravacao;
    SetNomeArquivo(arquivoDeAudio);
    LblStatus.FontColor := $FF147F44;
    Label1.Text := 'Stop Recorder';
    BtnGravar.Fill.Color := $FF794343;
    LblStatus.Text := 'recording audio...';
    LblCaminho.Text:= 'Saving to: ' + arquivoDeAudio;
    LblNumero.Text := '00:00';
    FSeconds := 0;
    TimerSegundo.Enabled := True;
    ClearFileTemp(FnomeArquivo);
    StartCapture(LblNumero);
    if not DirectoryExists(ExtractFilePath(FnomeArquivo)) then
       CreateDir(ExtractFilePath(FnomeArquivo));
end;


end.

{
uses
   System.DateUtils, FMX.Dialogs;

type
  TGestorBook = class
    private
    FNameBook: String;
    FAutor: String;
    FDayClient: Integer;
    FNumberPage: Integer;
    FDescription: String;
    FClient: String;
    FDateClient: TDateTime;


    public
       property NameBook: String read FNameBook write FNameBook;
       property Description: String read FDescription write FDescription;
       property NumberPage: Integer read FNumberPage write FNumberPage;
       property Autor: String read FAutor write FAutor;
       property NameClient: String read FClient write FClient;
       property DateClient: TDateTime read FDateClient write FDateClient;
       property DayClient: Integer read FDayClient write FDayClient;

       function AlugarLivro(Date: TDateTime; QuantDay: Integer; NomeCliente: String; NomeLivro: String): Boolean;
       //procedure DevolverLivro(Date: TDateTime; QuantDay);
}
