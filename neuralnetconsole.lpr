program neuralnetconsole;

uses
  SysUtils,
  crt,
  uneuron,
  uneuralnetwork;

const
  InputValues: array [0..3, 0..1] of byte = ((0, 0), (0, 1), (1, 0), (1, 1));
  OutputValues: array [0..3] of byte = (0, 1, 1, 0);
var
  NNet: TNeuralNetwork;
  cStart, cStop: TDateTime;
  Epoche: integer;
  Iteration: integer;
  gError: double;
  gAnswerCount: integer;
  bAnswerCount: integer;

  procedure DrawMatrix;
  var
    n: integer;
    i: integer;
    j: integer;
  begin
    GotoXY(1, 2);

    TextColor(LightGray);


    for i := 0 to NNet.NeuronCount[0] - 2 do // bias not include
    begin
      writeln(Format('Input value %.2d = %6.2n', [i, NNet.Input[i]]));

    end;
    writeln(Format('Wait value     = %6.2n', [NNet.WaitValue[0]]));
    TextColor(DarkGray);
    writeln(Format('Epoche      = %6d', [Epoche]));


    TextColor(Blue);
    WriteLn('===================================');
    for n := 0 to Length(NNet.WeigthMatrix) - 1 do
    begin
      TextColor(LightGreen);
      writeln(Format('Weight matrix number: %d', [n]));
      for i := 0 to Length(NNet.WeigthMatrix[n]) - 1 do
      begin
        TextColor(Yellow);
        for j := 0 to Length(NNet.WeigthMatrix[n, i]) - 1 do
        begin
          Write(Format('[W%d%d %7.3n] ', [i + 1, j + 1, NNet.WeigthMatrix[n, i, j].Weight]));
        end;
        WriteLn();
      end;
      //      WriteLn();
    end;

    TextColor(LightRed);
    writeln;
    writeln(Format('Error value %.2d  = %6.4n', [0, gError]));
    TextColor(LightGreen);
    writeln;
    writeln(Format('Correct answer %.2d  = %6d', [0, gAnswerCount]));
    TextColor(LightRed);
    writeln(Format('Wrong answer %.2d  = %6d', [0, bAnswerCount]));


    TextColor(LightBlue);
    WriteLn('------------------------------');

  end;

begin
  gAnswerCount := 0;
  bAnswerCount := 0;
  cStart := now;

  ClrScr;
  GotoXY(1, 1);

  Randomize;
  cursoroff;
  NNet := TNeuralNetwork.Create;
  NNet.AddLevel(2);
  NNet.AddLevel(2);
  NNet.AddLevel(1);
  NNet.LearnKoef := 0.1;

  WriteLn('Test XOR function');
  WriteLn();
  repeat
    gError := 0;
    for Iteration := 0 to 3 do
    begin

      NNet.Input[0] := InputValues[Iteration, 0];
      NNet.Input[1] := InputValues[Iteration, 1];
      NNet.WaitValue[0] := OutputValues[Iteration];

      NNet.Calc;
      case OutputValues[Iteration] of
        0:
          if NNet.Output[0] < 0.2 then
            Inc(gAnswerCount)
          else
            Inc(bAnswerCount);
        1:
          if NNet.Output[0] > 0.8 then
            Inc(gAnswerCount)
          else
            Inc(bAnswerCount);
      end;



      NNet.RecalcWeight;
      gError := gError + sqr(NNet.Neuron[NNet.LevelCount - 1, 0].Error);

    end;
    //  DrawMatrix;
    Inc(epoche);

    if Epoche / 100 = trunc(Epoche / 100) then
      DrawMatrix;
  until gError < 0.001;
  DrawMatrix;


  TextColor(White);
  cStop := now;


  WriteLn('Training ' + FormatDateTime('hh:mm:ss.zzz', cStop - cStart));


  TextColor(LightGray);
  WriteLn();
  WriteLn('Press Enter Key...');
  ReadLn;
  FreeAndNil(NNet);
end.
