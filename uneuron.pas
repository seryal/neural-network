unit uneuron;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TNeuron }

  TActivationFunction = (afSigmoid, afLinear, afBias);

  TNeuron = class
  private
    // error
    FError: double;
    // wait value
    FWaitValue: double;
    FActivationFunction: TActivationFunction;
    FInputValue: double;
    FOutputValue: double;
    FWeight: double;
    FWeigth: double;
    FDelta: double;
    function GetInputValue: double;
    function GetOutputValue: double;
    procedure SetInputValue(AValue: double);
    function Sigmoid(AValue: double): double;
    function Linear(AValue: double): double;
  public
    constructor Create(AActivationFunction: TActivationFunction);
    procedure Start;
    property InputValue: double read GetInputValue write SetInputValue;
    property OutputValue: double read GetOutputValue;
    property Weight: double read FWeight write FWeigth;
    property ActivationFunction: TActivationFunction read FActivationFunction write FActivationFunction default afLinear;
    property Error: double read FError write FError;
    property WaitValue: double read FWaitValue write FWaitValue;
    property Delta: double read FDelta write FDelta;
  end;

implementation

{ TNeuron }

procedure TNeuron.SetInputValue(AValue: double);
begin
  if FInputValue = AValue then
    Exit;
  FInputValue := AValue;

end;


function TNeuron.GetInputValue: double;
begin
  Result := FInputValue;
  if FActivationFunction = afBias then
    Result := 1;
end;

function TNeuron.GetOutputValue: double;
begin
  Result := FOutputValue;
  if FActivationFunction = afBias then
    Result := 1;
end;

function TNeuron.Sigmoid(AValue: double): double;
begin
  Result := 1 / (1 + exp(-1 * AValue));
end;

function TNeuron.Linear(AValue: double): double;
begin
  Result := AValue;
end;

constructor TNeuron.Create(AActivationFunction: TActivationFunction);
begin
  // Randomize;
  FActivationFunction := AActivationFunction;
end;

procedure TNeuron.Start;
begin
  case FActivationFunction of
    afSigmoid:
      FOutputValue := Sigmoid(FInputValue);
    afLinear:
      FOutputValue := Linear(FInputValue);
    afBias:
      FOutputValue := 1;
  end;
end;

end.
