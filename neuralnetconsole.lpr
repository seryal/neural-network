program neuralnetconsole;

uses
  SysUtils,
  crt,
  uneuron,
  uneuralnetwork;

var
  NNet: TNeuralNetwork;
  n, i, j: integer;
  m: integer;
  val1, val2: integer;
  waitVal: integer;
  gError: integer;
  gGood: integer;
  GoodFlag: boolean;
  cStart, cStop: TDateTime;

  procedure DrawMatrix;
  var
    n: integer;
    i: integer;
    j: integer;
  begin
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

  end;

begin
  cStart := now;

  ClrScr;
  GotoXY(1, 1);

  Randomize;
  cursoroff;
  gError := 0;
  gGood := 0;
  m := 0;
  NNet := TNeuralNetwork.Create;
  NNet.AddLevel(2);
  NNet.AddLevel(3);
  NNet.AddLevel(2);
  NNet.AddLevel(1);
  NNet.LearnKoef := 0.5;


  WriteLn('Test XOR function');
  WriteLn();

  GoodFlag := True;
  while ((gError >= (gGood / 2)) or (gGood < 500)) and (m < 200000) do
  begin
    Inc(m);
    GotoXY(1, 2);

    //    if GoodFlag then
    //    begin
    val1 := random(2);
    val2 := random(2);
    //      GoodFlag := False;
    //    end;


    NNet.Input[0] := val1;
    NNet.Input[1] := val2;
    waitVal := val1 xor val2;
    NNet.WaitValue[0] := waitVal;
    //    TextColor(LightGray);

{
    for i := 0 to NNet.NeuronCount[0] - 2 do // bias not include
    begin
      writeln(Format('Input value %.2d = %6.2n', [i, NNet.Input[i]]));

    end;
    writeln(Format('Wait value     = %6.2n', [NNet.WaitValue[0]]));
    TextColor(DarkGray);
    writeln(Format('Iteration      = %6d', [m]));
}

    //DrawMatrix;
    NNet.Calc;


    //writeln;
    for i := 0 to NNet.NeuronCount[NNet.LevelCount - 1] - 2 do
    begin
      //      TextColor(LightRed);
      Inc(gError);
      if (NNet.Neuron[NNet.LevelCount - 1, i].WaitValue - NNet.Output[i] <= 0.2) and
        (NNet.Neuron[NNet.LevelCount - 1, i].WaitValue - NNet.Output[i] >= -0.2) then
      begin
        //        TextColor(LightGreen);
        Dec(gError);
        Inc(gGood);
        GoodFlag := True;
      end;

{      writeln(Format('Output value %.2d = %6.3n', [i, NNet.Output[i]]));
      writeln(Format('Error value %.2d  = %6.3n', [i, NNet.Neuron[NNet.LevelCount - 1, i].Error]));

      writeln(Format('Error Count     = %-8d', [gError]));
      writeln(Format('Good Count      = %-8d', [gGood]));
 }

    end;

    //TextColor(LightBlue);
    //WriteLn('------------------------------');

    //ReadLn;
  end;
  TextColor(White);
  cStop := now;
  DrawMatrix;
  writeln;
  TextColor(LightGray);
  writeln(Format('Iteration       = %-8d', [m]));
  TextColor(LightRed);
  writeln(Format('Error Count     = %-8d', [gError]));
  TextColor(LightGreen);
  writeln(Format('Good Count      = %-8d', [gGood]));

  writeln;
  cursoron;
  if (gError * 2 > gGood) then
  begin
    TextColor(LightRed);
    WriteLn('Training completed with error: ' + FormatDateTime('hh:mm:ss.zzz', cStop - cStart));
  end
  else
  begin
    TextColor(LightGreen);
    WriteLn('Training completed successfully: ' + FormatDateTime('hh:mm:ss.zzz', cStop - cStart));
  end;
  writeln;

  TextColor(LightGray);
  WriteLn();
  WriteLn('Press Enter Key...');
  ReadLn;
  FreeAndNil(NNet);
end.
