program CyrusSoftGravador;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'View\uPrincipal.pas' {FrmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
