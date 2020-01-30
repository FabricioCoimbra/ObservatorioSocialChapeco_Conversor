unit ControllerConversor_U;

interface

{$region 'Uses interface'}
uses
  Pattern.Singleton_U,
  Classes;
{$endregion}

type
  TControllerConversor = class
  private
    Data: TStringList;
    Dados: string;
    FDelimitador: string;
    FPalavrasDireita: Integer;
    FPalavrasEsquerda: Integer;

    procedure ProcessarDados;
    procedure QuebrarLinha(Posicao: Integer);

    function QuebrarNome(Posicao: Integer): Integer;
    function QuebrarProximaPalavra(Posicao: Integer): Integer;
    function QuebrarPalavraAnterior(Posicao: Integer): Integer;
  const
    NewDelimitador = '@@';
    LetrasMaiusculas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ¡…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’« .';
  public
    constructor Create;

    procedure DeletarEntre(Inicio, Fim: string);
    procedure SubstituirEntre(Inicio, Fim: string);

    function LerArquivo: TStringList;
    function GetData: TStringList;

    property Delimitador: string write FDelimitador;
    property PalavrasDireita: Integer write FPalavrasDireita;
    property PalavrasEsquerda: Integer write FPalavrasEsquerda;

    destructor Destroy; override;
  end;

  ControllerConversor = TSingleton<TControllerConversor>;

implementation

{$region 'Uses implementation'}
uses
  DM_U,
  SysUtils,
  Forms;
{$endregion}

constructor TControllerConversor.Create;
begin
  inherited;
  Data := TStringList.Create;
end;

destructor TControllerConversor.Destroy;
begin
  inherited;
  FreeAndNil(Data);
end;

function TControllerConversor.LerArquivo: TStringList;
var
  Linha: string;
  I: Integer;
begin
  Data.Clear;
  Application.ProcessMessages;
  Data.LoadFromFile(DM.OpenDialog.FileName, TEncoding.UTF8);
  Dados := '';
  for linha in Data do
  begin
    Dados := Dados + Linha;
  end;
  Data.Clear;

  Dados := StringReplace(Dados, ';', '.', [rfReplaceAll]);
  Dados := StringReplace(Dados, FDelimitador, NewDelimitador, [rfReplaceAll]);
  Application.ProcessMessages;
  ProcessarDados;

  Dados := StringReplace(Dados, NewDelimitador, FDelimitador, [rfReplaceAll]);
  Data.Add(Dados);

  Result := Data;

  for I := Pred(Data.Count) downto 0 do
  begin
    if Trim(Data[I]) = EmptyStr then
      Data.Delete(I);
  end;
end;

procedure TControllerConversor.ProcessarDados;
var
  UltimaPosicao,
  LengthDados,
  I, J: Integer;

  PosEsquerda,
  PosDireita: Integer;
begin
  LengthDados := Pred(Length(Dados)) - 1;
  UltimaPosicao := LengthDados;
  for I := LengthDados downto 0 do
  begin
    Application.ProcessMessages;
    if (Dados[I] = '@') and (Dados[I + 1] = '@') and ((UltimaPosicao + 3) > I) then
    begin
      UltimaPosicao := I;
      Insert(';', Dados, I);
      QuebrarLinha(I);
      PosDireita := QuebrarNome(I+5);
      PosEsquerda := I;
      for J := 0 to FPalavrasDireita do
        PosDireita := QuebrarProximaPalavra(PosDireita + 2);
      for J := 0 to FPalavrasEsquerda do
        PosEsquerda := QuebrarPalavraAnterior(PosEsquerda - 1);
    end;
  end;
end;

function TControllerConversor.QuebrarProximaPalavra(Posicao: Integer): Integer;
var
  PosAtual,
  LengthDados: Integer;
begin
  Result := Posicao;
  LengthDados := Pred(Length(Dados)) - 1;
  PosAtual := Posicao;
  while (PosAtual < LengthDados) do
  begin
    if (Dados[PosAtual] = ' ') then
    begin
      Insert(';', Dados, PosAtual);
      Exit(PosAtual);
    end;
    Inc(PosAtual);
  end;
end;

function TControllerConversor.QuebrarPalavraAnterior(Posicao: Integer): Integer;
var
  PosAtual: Integer;
begin
  Result := Posicao;
  PosAtual := Posicao;
  while (PosAtual > 0) do
  begin
    if (Dados[PosAtual] = ' ') then
    begin
      Insert(';', Dados, PosAtual);
      Exit(PosAtual);
    end;
   PosAtual := Pred(PosAtual);
  end;
end;

procedure TControllerConversor.QuebrarLinha(Posicao: Integer);
var
  PosicaoDelimitador: Integer;
begin
  PosicaoDelimitador := Posicao;
  while (PosicaoDelimitador > 0) and (Dados[PosicaoDelimitador] <> '.' ) do
  begin
    PosicaoDelimitador := Pred(PosicaoDelimitador);
  end;

  if (PosicaoDelimitador > 0) then
    Inc(PosicaoDelimitador);

  Insert(sLineBreak, Dados, PosicaoDelimitador);
end;

function TControllerConversor.QuebrarNome(Posicao: Integer): Integer;
var
  PosAtual,
  LengthDados: Integer;
begin
  Result := Posicao;
  LengthDados := Pred(Length(Dados)) - 1;
  PosAtual := Posicao;
  while (PosAtual < LengthDados) do
  begin
    if not (LetrasMaiusculas.Contains(Dados[PosAtual])) then
    begin
      Insert(';', Dados, PosAtual -1);
      exit(PosAtual -1);
    end;
    Inc(PosAtual);
  end;
end;

procedure TControllerConversor.DeletarEntre(Inicio, Fim: string);
var
  Linha: String;
  I: Integer;
  PosInicial,
  PosFinal: Integer;
begin
  for I := 0 to Pred(Data.Count) do
  begin
    Linha :=  Data[I];
    PosInicial := Pos(Inicio, Linha);
    PosFinal :=  Pos(Fim, Copy(Linha, PosInicial, Length(Linha))) + PosInicial;

    Delete(Linha, PosInicial, (PosFinal - PosInicial));
    Data[I] := Linha;
  end;
end;

procedure TControllerConversor.SubstituirEntre(Inicio, Fim: string);
var
  I: Integer;
begin
  for I := 0 to Pred(Data.Count) do
    Data[I] := StringReplace(Data[I], Inicio, Fim, [rfReplaceAll]);
end;

function TControllerConversor.GetData: TStringList;
begin
  Result := Data;
end;

end.
