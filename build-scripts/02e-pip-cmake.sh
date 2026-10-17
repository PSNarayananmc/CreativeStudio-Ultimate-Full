#!/bin/bash
python3 -m pip install --quiet "cmake==3.31.6" ninja 2>&1 | tail -2; hash -r; /usr/local/bin/cmake --version | head -1; echo PIP_CMAKE_DONE
