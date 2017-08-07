using PyCall

@pyimport numpy as np

a = np.array([[1, 2], [3, 4]])

a = PyObject(a)

b = a[:mean](axis=1)

print(pybuiltin(:type)(b))

isinstance = pybuiltin("isinstance")

print(isinstance(b, np.ndarray))
