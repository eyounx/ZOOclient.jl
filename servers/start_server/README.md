# Start Server

`start_control_server.py`:  you can run this file to start the control server.

`start_evaluation_server.py`:  after writing the `configuration.txt`, you can run this file to start the evaluation servers.

`configuration.txt`: a configuration text used by  `start_evaluation_server.py`.

`fx.py`, `sparse_mse.py`:` fx.py` defines an objective function optimized by Asynchronous Sequential Racos (ASRacos). `sparse_mse.py` defines an objective function optimized by Parallel Pareto Optimization for Subset Selection (PPOSS, IJCAI'16).

`sonar.arff`: a data set used by `sparse_mse.py`

 __Package requirement:__

* liac-arff: https://pypi.python.org/pypi/liac-arff
* numpy: http://www.numpy.org