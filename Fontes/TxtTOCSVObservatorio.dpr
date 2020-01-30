program TxtTOCSVObservatorio;

uses
  Vcl.Forms,
  FrmPrincipal_U in 'FrmPrincipal_U.pas' {FrmPrincipal},
  Vcl.Themes,
  Vcl.Styles,
  Pattern.Singleton_U in 'Pattern\Pattern.Singleton_U.pas',
  ControllerConversor_U in 'ControllerConversor_U.pas',
  DM_U in 'DM_U.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
