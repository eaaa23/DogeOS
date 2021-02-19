import sys
import os
sys.path.append(
    os.path.join(os.getcwd(),
                 os.sep.join(__package__.split('.'))))
print(__file__)