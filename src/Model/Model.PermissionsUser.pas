unit Model.PermissionsUser;

interface

uses
   {$IFDEF ANDROID}
   Androidapi.Jni.Os,  // Para permissões do Android
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
        if PermissionsService.IsPermissionGranted(aNamePermission[I]) then // Verifica se a permissão já foi concedida
        begin
            ShowMessage('Permissão '+ aNamePermission[I] +' ja foi concedida');
        end
        else
        if ShouldShowRequestPermissionRationale(aNamePermission[I]) then  // Verifica se o usuário negou a permissão anteriormente
           TDialogService.ShowMessage('A permissão '+ aNamePermission[I] + ' é necessária para usar o recurso. Por favor, conceda a permissão para continuar')
        else
           PermissionsService.RequestPermissions(aNamePermission, nil);
    end;
    {$ENDIF}
end;

////////////////////////////////////////////////
   {
procedure TPermissoesUser.PedirPermissao(aNamePermission: TArray<string>);
begin

    if not PermissionsService.IsPermissionGranted(aNamePermission[0]) then   // Verifica se a permissão já foi concedida
    begin
        if ShouldShowRequestPermissionRationale(aNamePermission[0]) then  // Verifica se o usuário já negou a permissão anteriormente
        begin
            // Mostra uma mensagem explicativa
            TDialogService.ShowMessage('Esta permissão é necessária para usar o recurso. Por favor, conceda a permissão para continuar.',
            procedure(const AResult: TModalResult)
            begin
                // Solicita a permissão novamente após o usuário confirmar a mensagem
                PermissionsService.RequestPermissions(aNamePermission,
                        procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
                        begin
                            if (Length(AGrantResults) > 0) and (AGrantResults[0] = TPermissionStatus.Granted) then
                                ShowMessage('Permissão concedida!') // Permissão concedida
                        end
                       //// else
                       //     ShowMessage('Permissão negada. O recurso não funcionará corretamente.') // Permissão negada novamente
                );
            end);
        end
        else
        begin
            PermissionsService.RequestPermissions(aNamePermission, procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)  // Solicita a permissão pela primeira vez
            begin
                if (Length(AGrantResults) > 0) and (AGrantResults[0] = TPermissionStatus.Granted) then
                   ShowMessage('Permissão concedida!'); // Permissão concedida
                else
                   ShowMessage('Permissão negada. O recurso não funcionará corretamente.'); // Permissão negada pela primeira vez
            end);
        end;
    end
    else
        ShowMessage('Permissão já foi concedida.');  // Permissão já foi concedida anteriormente

end;   }

function TPermissoesUser.ShouldShowRequestPermissionRationale(const APermission: string): Boolean;
var
  LActivity: JActivity;
begin
    Result := False;
    LActivity := TAndroidHelper.Activity;   // Obtém a atividade atual (Activity) do aplicativo
    if TJBuild_VERSION.JavaClass.SDK_INT >= 23 then // Verifica se o dispositivo está rodando Android 6.0 (Marshmallow) ou superior
       Result := LActivity.shouldShowRequestPermissionRationale(StringToJString(APermission)); // Verifica se é necessário mostrar uma explicação para a permissão
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
    if (StrToInt(Copy(VersaoAndroid, 0, 1)) >= 6) then                                                                                //se a versão do android 6 ou maior, solicita as permissões, senão acessa diretamente
    begin
       Permissions := TJavaObjectArray<JString>.Create(length(Permission));
       for var i := 0 to length(Permission) -1 do
       begin
           Result := TAndroidHelper.Activity.checkSelfPermission(StringToJString(Permission[i])) = TJPackageManager.JavaClass.PERMISSION_GRANTED;
           if not (Result) then                                                                                                     //se uma das permissões do array nao tem mais permissão, sai e retorna false
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
