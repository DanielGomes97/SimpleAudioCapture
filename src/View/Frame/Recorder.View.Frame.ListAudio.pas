unit Recorder.View.Frame.ListAudio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Skia, FMX.Skia, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrameListAudio = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    BtnTrashAudio: TSpeedButton;
    Layout4: TLayout;
    BtnPlayAudio: TSpeedButton;
    SkLblTitle: TSkLabel;
    SkLblTimer: TSkLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
