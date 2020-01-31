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
    procedure ConfigurarDataString;
    procedure LimparLixoDosDados;

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

procedure TControllerConversor.ConfigurarDataString;
begin
  Data.Clear;
  Data.LoadFromFile(DM.OpenDialog.FileName, TEncoding.UTF8);
  Data.Clear;
  Dados := EmptyStr;
  Application.ProcessMessages;
end;

procedure TControllerConversor.LimparLixoDosDados;
var
  I: Integer;
begin
  Dados := StringReplace(Dados, ';', '.', [rfReplaceAll]);
  Dados := StringReplace(Dados, FDelimitador, NewDelimitador, [rfReplaceAll]);

  for I := 0 to 3 do
    Dados := StringReplace(Dados, '  ', ' ', [rfReplaceAll]);
end;

function TControllerConversor.LerArquivo: TStringList;
var
  Linha: string;
  I: Integer;
  InicioRegistro: Boolean;
  DadosBrutos: TStringList;
begin
  DadosBrutos := TStringList.Create;
  DadosBrutos.LoadFromFile(DM.OpenDialog.FileName, TEncoding.UTF8);
  InicioRegistro := False;

  ConfigurarDataString;

  for I := 0 to Pred(DadosBrutos.Count) do
  begin
    Linha := DadosBrutos[I];
    Application.ProcessMessages;
    if (Length(Linha) > 0) and (String('0123456789').Contains(Linha.Chars[0])) then
    begin //inicia nova linha do CSV
      if InicioRegistro then
      begin
        LimparLixoDosDados;
        ProcessarDados;

        Dados := StringReplace(Dados, NewDelimitador, FDelimitador, [rfReplaceAll]);
        Data.Add(Dados);
      end;
      InicioRegistro := True;
      Dados := EmptyStr;
    end;

    if InicioRegistro then
      Dados := Dados + ' ' + Linha + ' ';
  end;

  for I := Pred(Data.Count) downto 0 do
  begin
    if Data[I].Trim = EmptyStr then
      Data.Delete(I);
  end;
  DadosBrutos.Free;
  Result := Data;
end;

procedure TControllerConversor.ProcessarDados;
var
  UltimaPosicao,
  LengthDados,
  I, J: Integer;
  PalavrasEsquerda: string;
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
      PosDireita := QuebrarNome(I+5);
      PosEsquerda := I;
      for J := 0 to Pred(FPalavrasDireita) do
        PosDireita := QuebrarProximaPalavra(PosDireita + 2);
      for J := 0 to Pred(FPalavrasEsquerda) do
        PosEsquerda := QuebrarPalavraAnterior(PosEsquerda);

      // garantir que o nome ficar· smepre na mesma coluna;
      for J := 0 to Pred(FPalavrasEsquerda) do
      begin
        PalavrasEsquerda := Copy(Dados, 0, Pos('@', Dados));
        if PalavrasEsquerda.CountChar(';') < FPalavrasEsquerda then
          Insert(';', Dados, Pos('@', Dados));
      end;

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
  while (PosAtual > 1) do
  begin
    if (Dados[PosAtual] = ' ') then
    begin
      Insert(';', Dados, PosAtual);
      Exit(PosAtual);
    end;
   PosAtual := Pred(PosAtual);
  end;
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
