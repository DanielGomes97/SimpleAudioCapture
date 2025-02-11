unit Model.PermissionsUser;

interface

uses
   {$IFDEF ANDROID}
   Androidapi.Jni.Os,  // Para permiss�es do Android
   Androidapi.Jni.Widget,
   Androidapi.Helpers, // Para JStringToString
   Androidapi.JNI.JavaTypes, // Para TJManifest_permission
   Androidapi.JNIBridge,
   Androidapi.JNI.GraphicsContentViewText,
   FMX.DialogService.Async,
   FMX.Helpers.Android,
   Androidapi.jni.App,
   FMX.Objects,
   FMX.Media,
   FMX.Platform.Android,
   {$ENDIF}
   FMX.DialogService, System.UITypes,
   System.Permissions,// Para PermissionsService
   System.IOUtils, System.netEncoding, System.Messaging, FMX.Types, System.SysUtils;

type
  TPermissoesUser = class
  private
      // {$IFDEF ANDROID}
      FAudio_Record: String;
      FCAMERA: String;
      FReadStorage: String;
      FWriteStorage: String;
      function getAUDIO_RECORD: String;
      function getCAMERA: String;
      function getReadStorage: String;
      function getWriteStorage: String;
      function ShouldShowRequestPermissionRationale(const APermission: string): Boolean;
      //{$ENDIF}
  public
      {$IFDEF ANDROID}
      procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
      procedure onRequestPermissionsResult(aData: TPermissionsRequestResultData);
      procedure RequestPermission(Permission: array of string);
      function  HasPermission(Permission : array of String): Boolean;
      const RECORD_AUDIO: String = 'android.permission.RECORD_AUDIO';
      {$ENDIF}
      property CAMERA: String read getCAMERA write FCAMERA;
      property AUDIO_RECORD: String read getAUDIO_RECORD write FAudio_Record;
      property ReadStorage: String read getReadStorage write FReadStorage;
      property WriteStorage: String read getWriteStorage write FWriteStorage;
      procedure PedirPermissao(aNamePermission: TArray<string>);
end;

implementation

uses FMX.Dialogs;

{ TPermissoesUser }
function TPermissoesUser.getAUDIO_RECORD: String;
begin
    {$IFDEF ANDROID}FAudio_Record := JStringToString(TJManifest_permission.JavaClass.RECORD_AUDIO);  {$ENDIF}
    Result := FAudio_Record;
end;

function TPermissoesUser.getCAMERA: String;
begin
    {$IFDEF ANDROID}FCAMERA := JStringToString(TJManifest_permission.JavaClass.CAMERA);  {$ENDIF}
    Result := FCAMERA;
end;

function TPermissoesUser.getReadStorage: String;
begin
    {$IFDEF ANDROID}FReadStorage := JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE);  {$ENDIF}
    Result := FReadStorage;
end;

function TPermissoesUser.getWriteStorage: String;
begin
    {$IFDEF ANDROID}FWriteStorage := JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);{$ENDIF}
    Result := FWriteStorage;
end;

 /////////////////////////////////////////////
procedure TPermissoesUser.PedirPermissao(aNamePermission: TArray<string>);
begin
    {$IFDEF ANDROID}
    for var I := 0 to Length(aNamePermission) - 1 do
    begin
        if PermissionsService.IsPermissionGranted(aNamePermission[I]) then // Verifica se a permiss�o j� foi concedida
        begin
            ShowMessage('Permiss�o '+ aNamePermission[I] +' ja foi concedida');
        end
        else
        if ShouldShowRequestPermissionRationale(aNamePermission[I]) then  // Verifica se o usu�rio negou a permiss�o anteriormente
           TDialogService.ShowMessage('A permiss�o '+ aNamePermission[I] + ' � necess�ria para usar o recurso. Por favor, conceda a permiss�o para continuar')
        else
           PermissionsService.RequestPermissions(aNamePermission, nil);
    end;
    {$ENDIF}
end;

////////////////////////////////////////////////
   {
procedure TPermissoesUser.PedirPermissao(aNamePermission: TArray<string>);
begin

    if not PermissionsService.IsPermissionGranted(aNamePermission[0]) then   // Verifica se a permiss�o j� foi concedida
    begin
        if ShouldShowRequestPermissionRationale(aNamePermission[0]) then  // Verifica se o usu�rio j� negou a permiss�o anteriormente
        begin
            // Mostra uma mensagem explicativa
            TDialogService.ShowMessage('Esta permiss�o � necess�ria para usar o recurso. Por favor, conceda a permiss�o para continuar.',
            procedure(const AResult: TModalResult)
            begin
                // Solicita a permiss�o novamente ap�s o usu�rio confirmar a mensagem
                PermissionsService.RequestPermissions(aNamePermission,
                        procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
                        begin
                            if (Length(AGrantResults) > 0) and (AGrantResults[0] = TPermissionStatus.Granted) then
                                ShowMessage('Permiss�o concedida!') // Permiss�o concedida
                        end
                       //// else
                       //     ShowMessage('Permiss�o negada. O recurso n�o funcionar� corretamente.') // Permiss�o negada novamente
                );
            end);
        end
        else
        begin
            PermissionsService.RequestPermissions(aNamePermission, procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)  // Solicita a permiss�o pela primeira vez
            begin
                if (Length(AGrantResults) > 0) and (AGrantResults[0] = TPermissionStatus.Granted) then
                   ShowMessage('Permiss�o concedida!'); // Permiss�o concedida
                else
                   ShowMessage('Permiss�o negada. O recurso n�o funcionar� corretamente.'); // Permiss�o negada pela primeira vez
            end);
        end;
    end
    else
        ShowMessage('Permiss�o j� foi concedida.');  // Permiss�o j� foi concedida anteriormente

end;   }

function TPermissoesUser.ShouldShowRequestPermissionRationale(const APermission: string): Boolean;
var
  LActivity: JActivity;
begin
    Result := False;
    LActivity := TAndroidHelper.Activity;   // Obt�m a atividade atual (Activity) do aplicativo
    if TJBuild_VERSION.JavaClass.SDK_INT >= 23 then // Verifica se o dispositivo est� rodando Android 6.0 (Marshmallow) ou superior
       Result := LActivity.shouldShowRequestPermissionRationale(StringToJString(APermission)); // Verifica se � necess�rio mostrar uma explica��o para a permiss�o
end;
////////////////////////////////////////////////




{$IFDEF ANDROID}
procedure TPermissoesUser.RequestPermission(Permission: array of string);
var
   Permissions : TJavaObjectArray<JString>;
begin                                                                //JString
    Permissions := TJavaObjectArray<JString>.Create(length(Permission));
    for var i := 0 to length(Permission) -1 do
        Permissions.Items[i] := StringToJString(Permission[i]);
    TAndroidHelper.Activity.requestPermissions(Permissions, 555);
end;


procedure TPermissoesUser.HandleActivityMessage(const Sender: TObject;const M: TMessage);
begin
    FMX.Types.Log.d('View.uMain: HandleActivtyMessage');
    if M is TPermissionsRequestResultMessage then
       onRequestPermissionsResult(TPermissionsRequestResultMessage(M).Value);
end;

procedure TPermissoesUser.onRequestPermissionsResult(aData: TPermissionsRequestResultData);
begin
    FMX.Types.Log.d('View.uMain: OnRequestPermissionsResult');
    if (aData.GrantResults.Length = 0) then
       Exit;
    for var i := 0 to aData.GrantResults.Length -1 do
    begin
        if (aData.GrantResults[i] <> TJPackageManager.JavaClass.PERMISSION_GRANTED) then
           Exit;
    end;
end;

function TPermissoesUser.HasPermission(Permission: array of String): Boolean;
var
  Permissions : TJavaObjectArray<JString>;
  VersaoAndroid : String;
begin
    VersaoAndroid := JStringToString(TJBuild_VERSION.JavaClass.RELEASE);
    if (StrToInt(Copy(VersaoAndroid, 0, 1)) >= 6) then                                                                                //se a vers�o do android 6 ou maior, solicita as permiss�es, sen�o acessa diretamente
    begin
       Permissions := TJavaObjectArray<JString>.Create(length(Permission));
       for var i := 0 to length(Permission) -1 do
       begin
           Result := TAndroidHelper.Activity.checkSelfPermission(StringToJString(Permission[i])) = TJPackageManager.JavaClass.PERMISSION_GRANTED;
           if not (Result) then                                                                                                     //se uma das permiss�es do array nao tem mais permiss�o, sai e retorna false
              begin
                  RequestPermission([RECORD_AUDIO]);
                  break;
              end;
       end;
    end
    else
       Result := true;
end;
{$ENDIF}

end.
