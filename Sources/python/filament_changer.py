#
#  filament_changer.py
#  FilamentChanger
#  
#  Created by Serhii Mumriak on 20.09.2023
#

import sys
import ctypes

FilamentChanger = ctypes.POINTER(ctypes.c_char)
libFilamentChanger = ctypes.PyDLL("./libFilamentChanger.so")

libFilamentChanger.createFilamentChanger.argtypes = [ctypes.py_object]
libFilamentChanger.createFilamentChanger.restype = FilamentChanger

libFilamentChanger.releaseFilamentChanger.argtypes = [FilamentChanger]

config = Config()

class FilamentChangerWrapper:
    def __init__(self, config):
        self.filamentChanger = libFilamentChanger.createFilamentChanger(config)

    def __del__(self):
        libFilamentChanger.releaseFilamentChanger(self.filamentChanger)

def load_config(config):
    return FilamentChangerWrapper(config)
