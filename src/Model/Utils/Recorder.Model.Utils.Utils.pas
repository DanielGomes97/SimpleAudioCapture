unit Recorder.Model.Utils.Utils;

interface

const
   TYPE_INFORMATION : Integer = 1;
   TYPE_PERMISSIONS : Integer = 2;

   RECORD_AUDIO: String            = 'android.permission.RECORD_AUDIO';
   CAMERA: String                  = 'android.permission.CAMERA';
   READ_EXTERNAL_STORAGE: String   = 'android.permission.READ_EXTERNAL_STORAGE';
   WRITE_EXTERNAL_STORAGE: String  = 'android.permission.WRITE_EXTERNAL_STORAGE';

   MSG_RECORD_AUDIO: String            = 'Precisamos da permiss�o do microfone para que voc� possa usar os recursos de �udio do aplicativo';
   MSG_CAMERA: String                  = 'Precisamos da permiss�o da c�mera para que voc� possa tirar fotos e compartilhar com seus amigos';
   MSG_READ_EXTERNAL_STORAGE: String   = 'Precisamos da permiss�o de leitura de armazenamento para que voc� possa acessar seus audios salvos';
   MSG_WRITE_EXTERNAL_STORAGE: String  = 'Precisamos da permiss�o de grava��o de armazenamento para que voc� possa salvar arquivos no seu dispositivo';
   MSG_REQUEST_AGAIN: String           = 'Para usar este recurso, � necess�rio habilitar a permiss�o nas configura��es do seu dispositivo.';

implementation

end.
