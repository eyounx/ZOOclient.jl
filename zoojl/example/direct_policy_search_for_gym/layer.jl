module layer

export Layer, cal_output_l, decode_w_l!

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
  print(l.w)
  print(inputs)
  l.wx_plus_b = l.w * inputs
  if isnull(l.activation_function)
    l.outputs = l.wx_plus_b
  else
    l.outpus = l.activation_function(l.wx_plus_b)
  end
  return l.outputs
end

function decode_w_l!(l::Layer, w)
  if isnull(w)
    return
  end
  interval = l.column
  # println(interval)
  jbegin = 1
  output = []
  step = length(w) / interval
  for i in 1:step
    output = vcat(output, w[jbegin:jbegin+interval-1])
    jbegin += interval
  end
  l.w = output
  return
end

end
