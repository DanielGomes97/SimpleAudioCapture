unit Model.PermissionsUser;

interface

uses
   {$IFDEF ANDROID}
   FMX.platform.Android, Androidapi.Jni.Os, Androidapi.Helpers, Androidapi.Jni.Widget, FMX.Helpers.Android,
   Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes, Androidapi.JNIBridge,
   Androidapi.jni.App,
   {$ENDIF}
   System.IOUtils, System.netEncoding, System.Messaging, FMX.Types, SysUtils;

type
  TPermissoesUser = class

  public
      //{$IFDEF ANDROID}  {$ENDIF}
      {$IFDEF ANDROID}
      procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
      procedure onRequestPermissionsResult(aData: TPermissionsRequestResultData);
      procedure PedirPermissao(Permissao: array of string);
      Function TemPermissao(Permissao : array of String): Boolean;
      const RECORD_AUDIO: String = 'android.permission.RECORD_AUDIO';
      {$ENDIF}
  private
  end;

implementation

{ TPermissoesUser }

{$IFDEF ANDROID}
procedure TPermissoesUser.PedirPermissao(Permissao: array of string);
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
procedure TPermissoesUser.HandleActivityMessage(const Sender: TObject;const M: TMessage);
begin
    FMX.Types.Log.d('uPrincipal: HandleActivtyMessage');
    if M is TPermissionsRequestResultMessage then
       onRequestPermissionsResult(TPermissionsRequestResultMessage(M).Value);
end;
{$ENDIF}
{$IFDEF ANDROID}
procedure TPermissoesUser.onRequestPermissionsResult(aData: TPermissionsRequestResultData);
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
function TPermissoesUser.TemPermissao(Permissao: array of String): Boolean;
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

end.
