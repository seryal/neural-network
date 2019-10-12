# neural-network
The “hello world” of neural networks. XOR calculation.

This is a demo example of working with a neural network. Operations on matrices are not optimized. Calculations take a long time. There is something to optimize.

Neural network that can compute the XOR function.

![alt preview](https://github.com/seryal/neural-network/blob/master/images/XOR.png)

In the example, the neural network looks like this. The image does not indicate a neuron bias. This is the third neuron with always 1 output.  

![alt preview](https://github.com/seryal/neural-network/blob/master/images/Network.png)

For activation function used Sigmoid y=1/(1+exp(-1*x))
![alt preview](https://github.com/seryal/neural-network/blob/master/images/Sigmoid.png)

Program operation example

Weight matrix 0 W11 - weight value between neuron in1 and h1 if you look at the picture.

W22 - between in2 and h2

W31 and W32 - weight from bias neuron.

![alt preview](https://github.com/seryal/neural-network/blob/master/images/example.png)


Using a class implementing a neural network:
```pascal
  NNet := TNeuralNetwork.Create;
  // You can add any number of levels and number of neurons. If there is enough memory.
  NNet.AddLevel(2);       // First input level - 2 neurons. Activation function for input level always Linear y=f(x)=x;
  NNet.AddLevel(3);       // Hidden level - 3 neurons. y=sigmoid(x);
  NNet.AddLevel(2);       // Hidden level - 2 neurons. y=sigmoid(x);
  NNet.AddLevel(1);       // Output Level - 1 neuron. y=sigmoid(x);
  NNet.LearnKoef := 0.5;  // Learning ratio
  
  NNet.Input[0] := Value1;    // Input value for first neuron
  NNet.Input[1] := Value2;    // Input value for second neuron
  NNet.WaitValue[0] := Value1 xor Value2;  // The value we should get
  NNet.Calc;
  // NNet.Output[N] - output value after work neural network
  // NNet.WeigthMatrix[Level, OutputNeuron, InputNeuron].Weight;
  // NNet.Neuron[Level, NeuronNumber].Error; // calculated error after work neural network

  
  
```
