import sys
import os

if len(sys.argv) < 2:
    sys.exit(1)

pth = os.path.split(__file__)[0]
pth = os.path.join(pth, sys.argv[1])
if os.path.exists(pth):
    sys.path.append(pth)
    exit(os.system('{} {}/__main__.py {}'.format(sys.executable, pth, ' '.join(sys.argv[2:]))))
