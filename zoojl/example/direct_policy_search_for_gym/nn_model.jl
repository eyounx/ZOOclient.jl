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

function cal_output_l(l::Layer, inputs)
  l.wx_plus_b = l.w * inputs
  if isnull(l.activation_function)
    l.outputs = l.wx_plus_b
  else
    l.outpus = l.activation_function(l.wx_plus_b)
  end
  return l.outputs
end

function decode_w_l!(l::layer, w)
  if isnull(w)
    return
  end
  interval = l.column
  jbegin = 0
  output = []
  step = length(w) / interval
  for i in 1:step
    output = vcat(output, w[jbegin:jbegin+interval])
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

function construct_nnmodel!(nnm::NNModel, layers)
  # len(layers) is at least 2, including input layer and output layer
  nnm.layer_size = layers
  for i in 1:(length(layers)-1)
    addlayer(nnm, layers[i], layers[i+1], activation_function=sigmoid)
    nnm.w_size += layers[i] * layers[i+1]
  end
end

function add_layer!(nnm::NNModel, in_size, out_size; input_w=Nullable(), activation_function=Nullable())
  new_layer = Layer(in_size, out_size, input_w, activation_function)
  push!(nnm.layers, new_layer)
end

function decode_w_nnm(nnm::NNModel, w)
  jbegin = 1
  for i = 1:length(nnm.layers)
    len = nnm.layers[i].row * nnm.layers[i].column
    w_temp = w[jbegin:jbegin+len]
    decode_w_l!(nnm.layers[i], w_temp)
    jbegin += len
  end
  return
end

function cal_output_nnm(nnm::NNModel, x)
  out = x
  for i in 1:len(nnm.layers)
    out = cal_output_l(nnm.layers[i], out)
  end
  return out
end

end
