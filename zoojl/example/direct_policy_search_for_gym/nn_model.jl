function sigmoid(x)
  for i in 1:length(x)
    if -700 <= x[i] <= 700
      x[i] = (2.0 / (1 + exp(-x[i]))) - 1 # sigmoid function
    else
      if x[i] < -700
        x[i] = -1
      else
        x[i] = 1
      end
    end
  end
  return x
end

type Layer
  row
  column
  w
  activation_function
  wx_plus_b
  output

  function Layer(in_size, out_size; input_w=Nullable(), activation_function=Nullable())
    return new(in_size, out_size, input_w, activation_function, 0, 0)
  end
end

function cal_output(l::Layer, inputs)
  l.wx_plus_b = l.w * inputs
  if isnull(l.activation_function)
    l.outputs = l.wx_plus_b
  else
    l.outpus = l.activation_function(l.wx_plus_b)
  end
  return l.outputs
end

function decode_w(l::layer, w)
  if isnull(w)
    return
  end
  interval = l.column
  jbegin = 0
  output = []
  step = length(w) / interval
  for i in 1:step
    push!(output, w[jbegin:jbegin+interval])
    jbegin += interval
  end
  l.w = output
  return
end

type NNModel
  layers
  layer_size
  w_size
end

function construct_nnmodel(nnm::NNModel, layers)
  # len(layers) is at least 2, including input layer and output layer
  nnm.layer_size = layers
  for i in 1:(length(layers)-1)
end

end
