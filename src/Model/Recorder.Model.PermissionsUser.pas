unit Recorder.Model.PermissionsUser;

interface

uses
   {$IFDEF ANDROID}
   Androidapi.Jni.Os,  // Para permissões do Android
   Androidapi.Helpers, // Para JStringToString
   Androidapi.jni.App,
   {$ENDIF}
   System.Permissions,// Para PermissionsService
   FMX.Dialogs,
   System.SysUtils,
   Recorder.Model.Utils.Utils;

type
  TPermissoesUser = class
  private
       {$IFDEF ANDROID}
       function ShouldShowRequestPermissionRationale(const APermission: string): Boolean;
       {$ENDIF}

  public
      {$IFDEF ANDROID}
      procedure SolicitarPermissao(aNamePermission: TArray<string>);
      function VerificarPermissao(const aNamePermission: string): Boolean;
      function VerificarPermissaoNegada(const APermission: string): Boolean;
      {$ENDIF}
      procedure Mostrar;
end;

implementation

{ TPermissoesUser }
procedure TPermissoesUser.Mostrar;
begin
    ShowMessage(RECORD_AUDIO);// := '';
end;


{$IFDEF ANDROID}
function TPermissoesUser.VerificarPermissao(Const aNamePermission: string): Boolean; // Verificar se a permissão já foi permitida
begin
    Result := PermissionsService.IsPermissionGranted(aNamePermission);
end;
{$ENDIF}



{$IFDEF ANDROID}
function TPermissoesUser.VerificarPermissaoNegada(const APermission: string): Boolean;  // Verifica se o usuário negou a permissão anteriormente
var
  LActivity: JActivity;
begin
    Result := False;
    LActivity := TAndroidHelper.Activity;   // Obtém a atividade atual (Activity) do aplicativo
    if TJBuild_VERSION.JavaClass.SDK_INT >= 23 then // Verifica se o dispositivo está rodando Android 6.0 (Marshmallow) ou superior
       Result := LActivity.shouldShowRequestPermissionRationale(StringToJString(APermission)); // Verifica se é necessário mostrar uma explicação para a permissão
end;
{$ENDIF}

{$IFDEF ANDROID}
procedure TPermissoesUser.SolicitarPermissao(aNamePermission: TArray<string>);
begiN
    PermissionsService.RequestPermissions(aNamePermission, nil);
end;
{$ENDIF}


{$IFDEF ANDROID}
function TPermissoesUser.ShouldShowRequestPermissionRationale(const APermission: string): Boolean;  // Verifica se o usuário negou a permissão anteriormente
var
  LActivity: JActivity;
begin
    Result := False;
    LActivity := TAndroidHelper.Activity;   // Obtém a atividade atual (Activity) do aplicativo
    if TJBuild_VERSION.JavaClass.SDK_INT >= 23 then // Verifica se o dispositivo está rodando Android 6.0 (Marshmallow) ou superior
       Result := LActivity.shouldShowRequestPermissionRationale(StringToJString(APermission)); // Verifica se é necessário mostrar uma explicação para a permissão
end;
{$ENDIF}



end.
