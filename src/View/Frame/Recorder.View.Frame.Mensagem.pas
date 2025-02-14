unit Recorder.View.Frame.Mensagem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Skia, FMX.Skia, FMX.Controls.Presentation, FMX.Layouts, FMX.Objects,
  Recorder.Model.Utils.Utils;

type
  TFrameMensagem = class(TFrame)
    Rectangle5: TRectangle;
    Rectangle6: TRectangle;
    Layout20: TLayout;
    Layout21: TLayout;
    BtnFecharPermissao: TSpeedButton;
    SKLblTitulo: TSkLabel;
    Layout8: TLayout;
    SkSvg1: TSkSvg;
    Layout22: TLayout;
    BtnNegarAcesso: TRectangle;
    SkLabel3: TSkLabel;
    BtnPermitirAcesso: TRectangle;
    SkLabel2: TSkLabel;
    Layout27: TLayout;
    SkLblMensagem: TSkLabel;
    procedure MostrarMensagem(const TYPE_MSG: Integer; Descricao: String; Visivel: Boolean);
    procedure BtnPermitirAcessoClick(Sender: TObject);
    procedure BtnFecharPermissaoClick(Sender: TObject);
    procedure BtnNegarAcessoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

implementation

{$R *.fmx}

procedure TFrameMensagem.BtnFecharPermissaoClick(Sender: TObject);
begin
    Self.Visible := False;
    BtnPermitirAcesso.Tag := 0;
end;

procedure TFrameMensagem.BtnNegarAcessoClick(Sender: TObject);
begin
    BtnPermitirAcesso.Tag := 0;
    Self.Visible := False;
end;

procedure TFrameMensagem.BtnPermitirAcessoClick(Sender: TObject);
begin
    if BtnPermitirAcesso.Tag = 0 then
       Self.Visible := False;
end;

procedure TFrameMensagem.MostrarMensagem(const TYPE_MSG: Integer; Descricao: String; Visivel: Boolean);
begin
    Visible := Visivel;
    if NOT Visivel then
       Exit;
    SkLblMensagem.Text        := Descricao;
    BtnNegarAcesso.Visible    := True;
    BtnPermitirAcesso.Visible := True;
    if TYPE_MSG = TYPE_PERMISSIONS then
       BtnPermitirAcesso.Tag := 1
    else
    if TYPE_MSG = TYPE_INFORMATION then
       BtnNegarAcesso.Visible    := False;
end;


end.
