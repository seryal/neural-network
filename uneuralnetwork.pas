unit uneuralnetwork;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, uneuron, Classes;

type
  TWeight = record
    Weight: double;
  end;

  // array of weight
  // 1. count of Weight matrix
  // 2. count output neuron (neuron count of Level = N)
  // 3. count input neuron (neuron count of Level = N-1)
  TWeightMatrix = array of array of array of TWeight;

  // Matrix with all Neuron
  TArrayNeuron = array of TNeuron;

  // One Level with Neuron
  TArrayLevel = array of TArrayNeuron;


  { TNeuralNetwork }

  TNeuralNetwork = class
  private
    FLearnKoef: double;
    FAlfa: double;
    FLevelCount: integer;
    FMatrix: TArrayLevel;
    FWeigthMatrix: TWeightMatrix;
    function GetInput(AIndex: integer): double;
    function GetNeuronCount(ALevel: integer): integer;
    function GetNeuron(ALevel, AIndex: integer): TNeuron;
    function GetOutput(AIndex: integer): double;
    function GetWaitValue(AIndex: integer): double;
    procedure SetInput(AIndex: integer; AValue: double);
    procedure CreateWeightMatrix;
    procedure SetWaitValue(AIndex: integer; AValue: double);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddLevel(ANeuralCount: integer);
    procedure Calc;
    procedure RecalcWeight;
    procedure SaveToFile(AFileName: TFileName);
    procedure LoadFromFile(AFileName: TFilename);
    property LevelCount: integer read FLevelCount;
    property NeuronCount[ALevel: integer]: integer read GetNeuronCount;
    property Input[AIndex: integer]: double read GetInput write SetInput;
    property WaitValue[AIndex: integer]: double read GetWaitValue write SetWaitValue;
    property Output[AIndex: integer]: double read GetOutput;
    property Neuron[ALevel, AIndex: integer]: TNeuron read GetNeuron;
    property WeigthMatrix: TWeightMatrix read FWeigthMatrix;
    property LearnKoef: double read FLearnKoef write FLearnKoef;
  end;

implementation

{ TNeuralNetwork }

function TNeuralNetwork.GetNeuronCount(ALevel: integer): integer;
begin
  Result := length(FMatrix[ALevel]);
end;

function TNeuralNetwork.GetNeuron(ALevel, AIndex: integer): TNeuron;
var
  _ArrayNeural: TArrayNeuron;
begin
  _ArrayNeural := FMatrix[ALevel];
  Result := _ArrayNeural[AIndex];
end;

function TNeuralNetwork.GetInput(AIndex: integer): double;
begin
  Result := FMatrix[0, AIndex].InputValue;
end;

function TNeuralNetwork.GetOutput(AIndex: integer): double;
var
  _ArrayNeural: TArrayNeuron;
begin
  _ArrayNeural := FMatrix[FLevelCount - 1];
  Result := _ArrayNeural[AIndex].OutputValue;

end;

function TNeuralNetwork.GetWaitValue(AIndex: integer): double;
begin
  Result := Neuron[FLevelCount - 1, AIndex].WaitValue;
end;

procedure TNeuralNetwork.SetInput(AIndex: integer; AValue: double);
var
  _ArrayNeural: TArrayNeuron;
begin
  _ArrayNeural := FMatrix[0];
  _ArrayNeural[AIndex].InputValue := AValue;
end;

procedure TNeuralNetwork.CreateWeightMatrix;
var
  matrixCount: integer;
  inputNeuronCount: integer;
  outputNeuronCount: integer;
  i, j: integer;
begin
  //Randomize;
  matrixCount := FLevelCount - 1;
  outputNeuronCount := NeuronCount[FLevelCount - 2];
  inputNeuronCount := NeuronCount[FLevelCount - 1] - 1;

  // weigth matrix count
  SetLength(FWeigthMatrix, matrixCount);

  // Output neuron count (Level N+1)
  SetLength(FWeigthMatrix[matrixCount - 1], outputNeuronCount);

  // Input neuron count (Level N)
  for i := 0 to outputNeuronCount - 1 do
    SetLength(FWeigthMatrix[matrixCount - 1, i], inputNeuronCount);

  // add random weigth for all matrix -1 to 1
  for i := 0 to outputNeuronCount - 1 do
    for j := 0 to inputNeuronCount - 1 do
    begin
      FWeigthMatrix[matrixCount - 1, i, j].Weight := random - 0.5;
    end;
end;

procedure TNeuralNetwork.SetWaitValue(AIndex: integer; AValue: double);
begin
  Neuron[FLevelCount - 1, AIndex].WaitValue := AValue;
end;

constructor TNeuralNetwork.Create;
begin
  FLevelCount := 0;
end;

destructor TNeuralNetwork.Destroy;
var
  _ArrayNeuron: TArrayNeuron;
  i, j: integer;
begin
  for i := 0 to FLevelCount - 1 do
  begin
    _ArrayNeuron := FMatrix[i];
    for j := 0 to Length(_ArrayNeuron) - 1 do
      FreeAndNil(_ArrayNeuron[j]);
  end;
  inherited Destroy;
end;

procedure TNeuralNetwork.AddLevel(ANeuralCount: integer);
var
  i: integer;
  _ArrayNeuron: TArrayNeuron;

  tmp: double;
begin
  Inc(FLevelCount);
  SetLength(FMatrix, FLevelCount);
  SetLength(_ArrayNeuron, ANeuralCount + 1);  // +1 = bias neuron
  for i := 0 to ANeuralCount do
  begin
    if LevelCount = 1 then
      _ArrayNeuron[i] := TNeuron.Create(afLinear)
    else
      _ArrayNeuron[i] := TNeuron.Create(afSigmoid);

    // bias neuron
    if i = ANeuralCount then
    begin
      _ArrayNeuron[i] := TNeuron.Create(afBias);
    end;

  end;
  FMatrix[FLevelCount - 1] := _ArrayNeuron;

  // If Added second Level or more. Add weigth matrix.
  if LevelCount = 1 then
    exit;
  CreateWeightMatrix;
end;

procedure TNeuralNetwork.Calc;
var
  wMatrix: array of array of TWeight;
  n: integer;
  inN, outN: integer;
  tmp: double;
begin
  for n := 0 to NeuronCount[0] - 1 do
    Neuron[0, n].Start;


  n := Length(FWeigthMatrix);
  for n := 0 to Length(FWeigthMatrix) - 1 do
  begin
    wMatrix := FWeigthMatrix[n];
    for  inN := 0 to NeuronCount[n + 1] - 2 do  // exclude BIAS
    begin
      Neuron[n + 1, inN].InputValue := 0;
      for outN := 0 to NeuronCount[n] - 1 do
      begin
        Neuron[n + 1, inN].InputValue := Neuron[n + 1, inN].InputValue + Neuron[n, outN].OutputValue * wMatrix[outN, inN].Weight;
      end;
      Neuron[n + 1, inN].Start;
    end;
  end;

  // calc error
  for inN := 0 to NeuronCount[n + 1] - 1 do
  begin
    Neuron[n + 1, inN].Error := WaitValue[inN] - Neuron[n + 1, inN].OutputValue;
  end;

  for n := Length(FWeigthMatrix) - 1 downto 0 do
  begin
    wMatrix := FWeigthMatrix[n];
    outN := NeuronCount[n];
    for outN := 0 to NeuronCount[n] - 2 do // for bias no ERROR
    begin
      Neuron[n, outN].Error := 0;
      for inN := 0 to NeuronCount[n + 1] - 2 do
        Neuron[n, outN].Error := Neuron[n, outN].Error + wMatrix[outN, inN].Weight * Neuron[n + 1, inN].Error;
    end;
  end;

  //RecalcWeight;

end;

procedure TNeuralNetwork.RecalcWeight;
var
  n: integer;
  inN, outN: integer;
  wMatrix: array of array of TWeight;
  tmp: double;
begin
  for n := 0 to length(FWeigthMatrix) - 1 do
  begin
    wMatrix := FWeigthMatrix[n];
    for outN := 0 to length(wMatrix) - 1 do
    begin
      for inN := 0 to length(wMatrix[outN]) - 1 do
      begin
        tmp := Neuron[n + 1, inN].OutputValue;
        //        tmp :=
        //wMatrix[i, j] := wMatrix[i, j] + LearnKoef * Neuron[n, i].Error * Neuron[n, i].InputValue * tmp * (1 - tmp);
        //wMatrix[i, j] := wMatrix[i, j] + LearnKoef * Neuron[n, i].Error * Neuron[n, i].OutputValue;
        wMatrix[outN, inN].Weight := wMatrix[outN, inN].Weight + LearnKoef * Neuron[n + 1, inN].Error *
          Neuron[n, outN].OutputValue * tmp * (1 - tmp);
      end;
    end;
  end;

end;

procedure TNeuralNetwork.SaveToFile(AFileName: TFileName);
var
  fileStream: TFileStream;
  elementSize: integer;
  i, j, k: integer;
  arraySize: integer;
  val: double;
begin
  fileStream := TFileStream.Create(AFileName, fmCreate);
  try
    arraySize := 0;
    elementSize := sizeof(TWeight);
    for i := 0 to Length(FWeigthMatrix) - 1 do
      for j := 0 to length(FWeigthMatrix[i]) - 1 do
        for k := 0 to Length(FWeigthMatrix[i, j]) - 1 do
        begin
          //        arraySize := arraySize + length(FWeigthMatrix[i, j]);
          val := FWeigthMatrix[i, j, k].Weight;
          fileStream.Write(val, elementSize);
        end;

    //    fileStream.Write(FWeigthMatrix[0, 0, 0], arraySize * elementSize);
  finally
    FreeAndNil(fileStream);
  end;
end;


procedure TNeuralNetwork.LoadFromFile(AFileName: TFilename);
var
  fileStream: TFileStream;
  elementSize: integer;
  i, j, k: integer;
  val: double;

begin
  fileStream := TFileStream.Create(AFileName, fmOpenRead);
  try

    elementSize := sizeof(TWeight);

    for i := 0 to Length(FWeigthMatrix) - 1 do
      for j := 0 to length(FWeigthMatrix[i]) - 1 do
        for k := 0 to length(FWeigthMatrix[i, j]) - 1 do
        begin
          fileStream.Read(val, elementSize);
          FWeigthMatrix[i, j, k].Weight := val;
        end;

  finally
    FreeAndNil(fileStream);
  end;
end;

end.







