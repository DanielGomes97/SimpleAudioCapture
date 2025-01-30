unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Types, FMX.Controls.Presentation,
  FMX.StdCtrls, System.DateUtils, FMX.Platform, FMX.Layouts,
  System.Threading, FMX.Media, FMX.Objects, FMX.Edit, FMX.Effects,
  System.Actions, FMX.ActnList, FMX.Graphics, FMX.Ani, System.netEncoding, System.Messaging,

  {$IFDEF ANDROID}
    FMX.platform.Android, Androidapi.Jni.Os, Androidapi.Helpers, Androidapi.Jni.Widget, FMX.Helpers.Android,
    Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes, Androidapi.JNIBridge,
    Androidapi.jni.App,
  {$ENDIF}
  System.IOUtils;


type
  TFrmPrincipal = class(TForm)
    BtnGravar: TRectangle;
    LoBase: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Label1: TLabel;
    TimerSegundo: TTimer;
    Rectangle2: TRectangle;
    LblTitulo: TLabel;
    LblStatus: TLabel;
    LblCaminho: TLabel;
    LblNumero: TLabel;
    TimerReset: TTimer;
    Layout1: TLayout;
    procedure BtnGravarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerSegundoTimer(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    {$IFDEF ANDROID}
      procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
      procedure onRequestPermissionsResult(aData: TPermissionsRequestResultData);
      procedure PedirPermissao(Permissao: array of string);
      Function TemPermissao(Permissao : array of String): Boolean;

    {$ENDIF}
  private
    procedure IniciarGravacao;
    procedure SetnomeArquivo(const Value: String);
    procedure ClearFileTemp(arquivoNome: String);
    procedure StartCapture(tempoGravacao: TLabel);
    //procedure Stop;
    function StopCapture: Boolean;
    function HasMicrophone: Boolean;
    function IsMicrophoneRecording: Boolean;
    function GetAudioFileName(const AFileName: string): string;
    //procedure changedExecuteControls;
    procedure NovaGravacao;
    //procedure EscutarAudio(arquivo: String);
    //procedure Play;
    procedure PararGravacao;
    function VerificarMicrofone: Boolean;
    { Private declarations }


  public
    { Public declarations }
    arquivoDeAudio: String;
    FSeconds: Integer;
    FnomeArquivo: String;
    lbTimeTemp    : TLabel;
    FMicrophone: TAudioCaptureDevice;
    FMediaPlayer : TMediaPlayer;
    FMicroAtivo, FAudioAtivo : Boolean;
  end;

var
  FrmPrincipal: TFrmPrincipal;
  {$IFDEF ANDROID} const RECORD_AUDIO: String = 'android.permission.RECORD_AUDIO'; {$ENDIF}

implementation

{$R *.fmx}

procedure TFrmPrincipal.ClearFileTemp(arquivoNome : String);
var
  arquivoOld, oldName : String;
begin
    arquivoOld := Trim(arquivoDeAudio);
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

//ao ativar opção de escutar audio, essa função será reabilitada.
//procedure TFrmPrincipal.EscutarAudio(arquivo: String);
//begin
//    {$IFDEF ANDROID}
//       if not (TemPermissao([RECORD_AUDIO])) then
//          raise Exception.Create('Necessario ter permissão para usar audio.');
 //   {$ENDIF}
//  if ((arquivo) <> '') then
//     SetnomeArquivo(arquivo);
//  if NOT(FileExists(arquivo)) then
//  begin
//      if ((arquivo) = '') or not (FileExists(arquivo)) then
//         raise Exception.Create('Arquivo de mídia não encontrado.'+ sLineBreak+ arquivo)
//      else
//         raise Exception.Create('Desculpe, você só tem permissão de escutar este áudio.');
//  end;
//end;

{$IFDEF ANDROID}
procedure TFrmPrincipal.PedirPermissao(Permissao: array of string);
var
   Permissions : TJavaObjectArray<JString>;
begin
    Permissions := TJavaObjectArray<JString>.Create(length(Permissao));
    for var i := 0 to length(Permissao) -1 do
        Permissions.Items[i] := StringToJString(Permissao[i]);
    TAndroidHelper.Activity.requestPermissions(Permissions, 555);
end;
{$ENDIF}
{$IFDEF ANDROID}
procedure TFrmPrincipal.HandleActivityMessage(const Sender: TObject;const M: TMessage);
begin
    FMX.Types.Log.d('uPrincipal: HandleActivtyMessage');
    if M is TPermissionsRequestResultMessage then
       onRequestPermissionsResult(TPermissionsRequestResultMessage(M).Value);
end;
{$ENDIF}
{$IFDEF ANDROID}
procedure TFrmPrincipal.onRequestPermissionsResult(aData: TPermissionsRequestResultData);
begin
    FMX.Types.Log.d('uPrincipal: OnRequstPermissionsResult');
    if (aData.GrantResults.Length > 0) then
    begin
        for var i := 0 to aData.GrantResults.Length -1 do
        begin
            if (aData.GrantResults[i] <> TJPackageManager.JavaClass.PERMISSION_GRANTED) then
               Exit;
        end;
    end;
end;
{$ENDIF}
{$IFDEF ANDROID}
function TFrmPrincipal.TemPermissao(Permissao: array of String): Boolean;
var
  Permissions : TJavaObjectArray<JString>;
  VersaoAndroid : String;
begin
    VersaoAndroid := JStringToString(TJBuild_VERSION.JavaClass.RELEASE);
    if (StrToInt(Copy(VersaoAndroid, 0, 1)) >= 6) then //se a versão do android 6 ou maior, solicita as permissões, senão acessa diretamente
    begin
       Permissions := TJavaObjectArray<JString>.Create(length(Permissao));
       for var i := 0 to length(Permissao) -1 do
       begin
           Result := TAndroidHelper.Activity.checkSelfPermission(StringToJString(Permissao[i])) = TJPackageManager.JavaClass.PERMISSION_GRANTED;
           if not (Result) then //se uma das permissões do array nao tem mais permissão, sai e retorna false
              begin
                  PedirPermissao([RECORD_AUDIO]);
                  break;
              end;
       end;
    end
    else
       Result := true;
end;
{$ENDIF}
procedure TFrmPrincipal.SetnomeArquivo(const Value: String);
begin
    FnomeArquivo := Value;
    if not DirectoryExists(ExtractFilePath(FnomeArquivo)) then
       CreateDir(ExtractFilePath(FnomeArquivo));
end;

function TFrmPrincipal.GetAudioFileName(const AFileName: string): string;

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

procedure TFrmPrincipal.BtnFecharClick(Sender: TObject);
begin
    //EditSenha.Text := '';
    //LoMensagem.Visible := False;
end;

procedure TFrmPrincipal.PararGravacao;
begin
    StopCapture;
    Label1.Text := 'Start recording';
    BtnGravar.Fill.Color := $FF166DB4;
    LblStatus.FontColor := $FF794343;
    LblStatus.Text := 'stopped';
    LblCaminho.Text:= 'Saved in: ' + arquivoDeAudio;
    LblNumero.Text := '00:00';
    TimerSegundo.Enabled := False;
    FSeconds := 0;
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

procedure TFrmPrincipal.BtnGravarClick(Sender: TObject);
begin
    if NOT FMicroAtivo then
       begin
            if NOT VerificarMicrofone then//
               raise Exception.Create('Audio Capture: Permission required to use the microphone.');
            FMicroAtivo := True;
       end;

    if {Copy(}Label1.Text{, 1, 2)} = 'Stop Recorder' then
       PararGravacao
    else
    begin
        {$IFDEF ANDROID}
        if NOT FAudioAtivo then
           begin
               if not (TemPermissao([RECORD_AUDIO])) then
               begin
                   raise Exception.Create('The Application does not have permission to manipulate the audio.');
                   exit;
               end;
               FAudioAtivo := True;
           end;
        {$ENDIF}
        IniciarGravacao;
    end;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
    Label1.Text := 'Start recording';
    BtnGravar.Fill.Color := $FF166DB4;
    FMicroAtivo := False;
    FAudioAtivo := False;
    NovaGravacao;
end;

procedure TFrmPrincipal.NovaGravacao;
var
  data: TDateTime;
  NomeArquivo: String;
begin
    data :=  Now;
    NomeArquivo :=  'Date-' + (Data.Day).ToString;
    NomeArquivo :=  NomeArquivo + '-' + (Data.Month).ToString;
    NomeArquivo :=  NomeArquivo + '-' + (Data.Year).ToString;
    NomeArquivo :=  Trim(NomeArquivo + '-' + copy(TimeToStr(now), 1, 2) + '-' + copy(TimeToStr(now), 4, 2) + '-' + copy(TimeToStr(now), 7, 2)) ; //Hora deve estar no formato HH:MM:SS
    LblStatus.Text  := '';
    LblCaminho.Text := '';
    LblNumero.Text  := '';
    {$IFDEF ANDROID}   arquivoDeAudio := GetAudioFileName(NomeArquivo + '.mp3'); {$ENDIF}
    {$IFDEF IOS}       arquivoDeAudio := ExtractFilePath( ParamStr(0) ) + NomeArquivo + '.mp3'; {$ENDIF}
    {$IFDEF MSWINDOWS} arquivoDeAudio := ExtractFilePath( ParamStr(0) ) + NomeArquivo + '.wav'; {$ENDIF}

    FMediaPlayer := TMediaPlayer.Create(Self);
    FMicrophone  := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  if (assigned(FMediaPlayer.Media)) then
     if (FMediaPlayer.Media.State = TMediaState.Playing) then
        FMediaPlayer.Media.stop;
  if (assigned(FMicrophone)) then
     if (FMicrophone.State = TCaptureDeviceState.Capturing) then
        FMicrophone.StopCapture;
  try
    {$IFDEF MSWINDOWS} FMediaPlayer.free;
    {$ELSE}  FMediaPlayer.DisposeOf; {$ENDIF}
    FMicrophone := nil;
  except
  end;
  try
    {$IFDEF MSWINDOWS} FMicrophone.free;
    {$ELSE} FMicrophone.DisposeOf; {$ENDIF}
    FMicrophone := nil;
  except
  end;
end;

//verificar se manter ou nao...
{procedure TFrmPrincipal.changedExecuteControls;
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

procedure TFrmPrincipal.TimerSegundoTimer(Sender: TObject);
//var
//  Min, Sec: Integer;
begin
    Inc(FSeconds); //inc

    //Min := FSeconds div 60; // cal min
   // Sec := FSeconds mod 60; // cal sec
    //LblNumero.Text := Format('%.2d:%.2d', [Min, Sec]); // update: time MM:SS
    LblNumero.Text := Format('%.2d:%.2d', [FSeconds div 60, FSeconds mod 60]); // update: time MM:SS
end;

function TFrmPrincipal.VerificarMicrofone: Boolean;
begin
    if assigned(FMediaPlayer.Media) then
       if (FMediaPlayer.Media.State = TMediaState.Playing) then
          FMediaPlayer.Media.stop;
    if (FMicrophone.State = TCaptureDeviceState.Capturing) then
          FMicrophone.StopCapture;
    FMicrophone := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
    if (HasMicrophone) then
    begin
        FMicrophone.FileName := arquivoDeAudio;
        try
            Result := True;
        except on E : Exception do
            Result := False;
        end;
    end
    else
       Result := False;
end;

procedure TFrmPrincipal.StartCapture(tempoGravacao: TLabel);
begin
    if assigned(FMediaPlayer.Media) then
       if (FMediaPlayer.Media.State = TMediaState.Playing) then
          FMediaPlayer.Media.stop;
    if (FMicrophone.State = TCaptureDeviceState.Capturing) then
          FMicrophone.StopCapture;
    lbTimeTemp    := tempoGravacao;
    FMicrophone := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
    if (HasMicrophone) then
    begin
        FMicrophone.FileName := arquivoDeAudio;
        try
            FMicrophone.StartCapture;
        except on E : Exception do
            raise Exception.Create('Audio Capture: Permission required to use the microphone.');
        end;
    end
    else
       raise Exception.Create('Sorry, invalid microphone!');
end;

{procedure TFrmPrincipal.Play;
begin
    if (Trim(FNomeArquivo) = '') or not(FileExists(FNomeArquivo)) then
       raise Exception.Create('Arquivo não encontrado...' + sLineBreak + FNomeArquivo)
    else
    begin
        if IsMicrophoneRecording then
            StopCapture;
        FMediaPlayer.FileName := FNomeArquivo;
        FMediaPlayer.Media.Play;
    end;
end;  }

{procedure TFrmPrincipal.Stop;
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
        FMediaPlayer := TMediaPlayer.Create(Self);
    except
    end;
end;   }

function TFrmPrincipal.StopCapture : Boolean;
begin
    result := false;
    try
        if (IsMicrophoneRecording) then
        begin
             try
                FMicrophone.StopCapture;
                result := true;
             except on E : Exception do
                raise Exception.Create('Operation not supported by this device.' + sLineBreak + 'Message: ' + E.Message);
             end;
        end;
    except
    end;
end;

function TFrmPrincipal.HasMicrophone: Boolean;
begin
    Result := Assigned(FMicrophone);
end;
function TFrmPrincipal.IsMicrophoneRecording: Boolean;
begin
    Result := HasMicrophone and (FMicrophone.State = TCaptureDeviceState.Capturing);
end;



end.


