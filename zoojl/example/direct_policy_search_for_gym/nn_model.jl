module nn_model

importall layer

export NNModel, construct_nnmodel!, add_layer!, decode_w_nnm, cal_output_nnm

type NNModel
  layers
  layer_size
  w_size

  function NNModel()
    return new([], [], 0)
  end
end

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

function construct_nnmodel!(nnm::NNModel, layers)
  # len(layers) is at least 2, including input layer and output layer
  nnm.layer_size = layers
  for i in 1:(length(layers)-1)
    add_layer!(nnm, layers[i], layers[i+1], activation_function=sigmoid)
    nnm.w_size += layers[i] * layers[i+1]
  end
end

function add_layer!(nnm::NNModel, in_size, out_size; input_w=Nullable(), activation_function=Nullable())
  new_layer = Layer(in_size, out_size, input_w=input_w, activation_function=activation_function)
  push!(nnm.layers, new_layer)
end

function decode_w_nnm(nnm::NNModel, w)
  jbegin = 1
  for i = 1:length(nnm.layers)
    len = nnm.layers[i].row * nnm.layers[i].column
    w_temp = w[jbegin:jbegin+len-1]
    decode_w_l!(nnm.layers[i], w_temp)
    jbegin += len
  end
  return
end

function cal_output_nnm(nnm::NNModel, x)
  out = x
  for i in 1:length(nnm.layers)
    out = cal_output_l(nnm.layers[i], out)
  end
  return out
end

end
