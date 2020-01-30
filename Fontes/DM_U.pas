unit DM_U;

interface

{$region 'Uses interface'}
uses
  System.SysUtils,
  System.Classes, ShellApi,
  Vcl.Dialogs;
{$endregion}

type
  TDM = class(TDataModule)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    OpenIMG: TOpenDialog;
  private
    function PegarNomeNovaExtensao: string;
  public
    procedure SalvarEAbrir(Arquivo: TStrings);
    procedure AlterarEstilo(NomeEstilo: string);

    function PegarListaEstilosWindows: TStrings;
  end;

var
  DM: TDM;

implementation

{$region 'Uses implementation'}
uses
  Vcl.Forms,
  Winapi.Windows,
  Vcl.Styles,
  Vcl.Themes,
  FrmPrincipal_U;
{$endregion}

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.SalvarEAbrir(Arquivo: TStrings);
begin
  SaveDialog.FileName := PegarNomeNovaExtensao;
  if SaveDialog.Execute then
  begin
    Arquivo.SaveToFile(SaveDialog.FileName);
    ShellExecute(FrmPrincipal.Handle, 'open', PChar(SaveDialog.FileName), nil, nil, SW_SHOWNORMAL) ;
  end;
end;

function TDM.PegarNomeNovaExtensao: string;
var
  Diretorio,
  Nome,
  Extensao: string;
begin
  Result := OpenDialog.FileName;
  Diretorio := ExtractFileDir(Result);
  Nome := ExtractFileName(Result);
  Extensao := ExtractFileExt(Result);

  Result := Diretorio + '\' +
   Copy(Nome, 0, (Length(Nome) - Length(Extensao))) +
   '.csv';
end;

function TDM.PegarListaEstilosWindows: TStrings;
var
  StyleName: string;
begin
  // busca todos os estilos embutidos no executável
  Result := TStringList.Create;
  for StyleName in TStyleManager.StyleNames do
    Result.Add(StyleName)
end;

procedure TDM.AlterarEstilo(NomeEstilo: string);
begin
  TStyleManager.SetStyle(NomeEstilo);
end;

end.
