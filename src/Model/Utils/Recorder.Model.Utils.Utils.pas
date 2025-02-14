unit Recorder.Model.Utils.Utils;

interface

const
   TYPE_INFORMATION : Integer = 1;
   TYPE_PERMISSIONS : Integer = 2;

   RECORD_AUDIO: String            = 'android.permission.RECORD_AUDIO';
   CAMERA: String                  = 'android.permission.CAMERA';
   READ_EXTERNAL_STORAGE: String   = 'android.permission.READ_EXTERNAL_STORAGE';
   WRITE_EXTERNAL_STORAGE: String  = 'android.permission.WRITE_EXTERNAL_STORAGE';

   MSG_RECORD_AUDIO: String            = 'Precisamos da permissão do microfone para que você possa usar os recursos de áudio do aplicativo';
   MSG_CAMERA: String                  = 'Precisamos da permissão da câmera para que você possa tirar fotos e compartilhar com seus amigos';
   MSG_READ_EXTERNAL_STORAGE: String   = 'Precisamos da permissão de leitura de armazenamento para que você possa acessar seus audios salvos';
   MSG_WRITE_EXTERNAL_STORAGE: String  = 'Precisamos da permissão de gravação de armazenamento para que você possa salvar arquivos no seu dispositivo';
   MSG_REQUEST_AGAIN: String           = 'Para usar este recurso, é necessário habilitar a permissão nas configurações do seu dispositivo.';

implementation

end.
