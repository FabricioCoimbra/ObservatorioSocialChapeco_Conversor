unit FrmPrincipal_U;

interface

{$region 'Uses Interface'}
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  Vcl.Imaging.jpeg,
  Vcl.WinXCtrls;
{$endregion}

type
  TFrmPrincipal = class(TForm)
    BtnAbrirArquivo: TButton;
    Label1: TLabel;
    BtnSalvar: TButton;
    EdtDelimitador: TEdit;
    lbl2: TLabel;
    Panel1: TPanel;
    MemoDados: TMemo;
    EdtEsquerda: TSpinEdit;
    EdtDireita: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EdtSubsIni: TEdit;
    btnSubstituir: TButton;
    EdtDelBegin: TEdit;
    EdtDelFIm: TEdit;
    Label6: TLabel;
    Deletar: TButton;
    EdtSubstFIm: TEdit;
    ImgBot: TImage;
    Label7: TLabel;
    CBStyles: TComboBox;
    ActivityIndicator1: TActivityIndicator;
    ActivityIndicator2: TActivityIndicator;
    ActivityIndicator3: TActivityIndicator;
    LblTempo: TLabel;
    procedure BtnAbrirArquivoClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure DeletarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CBStylesChange(Sender: TObject);
    procedure btnSubstituirClick(Sender: TObject);
    procedure ImgBotClick(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
  private
    procedure SincronizarParametrosController();
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$region 'Uses implementation'}
uses
  ControllerConversor_U,
  DM_U;
{$endregion}

{$R *.dfm}

procedure TFrmPrincipal.BtnAbrirArquivoClick(Sender: TObject);
var
  TempoProcessamento: TDateTime;
begin
  SincronizarParametrosController();
  if DM.OpenDialog.Execute then
  begin
    TempoProcessamento := Now;
    Panel1.SendToBack;
    MemoDados.Lines := ControllerConversor.GetInstance.LerArquivo;
    Panel1.BringToFront;
    LblTempo.Caption := 'Demorou ' +
      FormatDateTime('HH:MM:ss', Now - TempoProcessamento) +
      ' para processar ' +
      MemoDados.Lines.Count.ToString +
      ' linhas';
    LblTempo.Visible := True;
  end;
  SincronizarParametrosController();
end;

procedure TFrmPrincipal.SincronizarParametrosController();
begin
  with ControllerConversor.GetInstance do
  begin
    Delimitador := EdtDelimitador.Text;
    PalavrasDireita := EdtDireita.Value;
    PalavrasEsquerda := EdtEsquerda.Value;
    MemoDados.Lines := GetData;
  end;
end;

procedure TFrmPrincipal.CBStylesChange(Sender: TObject);
begin
  Dm.AlterarEstilo(CBStyles.Text);
end;

procedure TFrmPrincipal.BtnSalvarClick(Sender: TObject);
begin
  DM.SalvarEAbrir(MemoDados.Lines);
  SincronizarParametrosController();
end;

procedure TFrmPrincipal.btnSubstituirClick(Sender: TObject);
begin
  ControllerConversor.GetInstance.SubstituirEntre(EdtSubsIni.Text, EdtSubstFIm.Text);
  SincronizarParametrosController();
end;

procedure TFrmPrincipal.DeletarClick(Sender: TObject);
begin
  ControllerConversor.GetInstance.DeletarEntre(EdtDelBegin.Text, EdtDelFIm.Text);
  SincronizarParametrosController();
end;

procedure TFrmPrincipal.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  ActivityIndicator2.Left := Trunc(NewWidth/2);
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  CBStyles.Items := DM.PegarListaEstilosWindows;
  Panel1.BringToFront;
end;

procedure TFrmPrincipal.ImgBotClick(Sender: TObject);
begin
  if Dm.OpenIMG.Execute() then
    ImgBot.Picture.LoadFromFile(Dm.OpenIMG.Filename);
end;

end.
