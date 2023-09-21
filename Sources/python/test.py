# 
#   test.py
#   FilamentChanger
#   
#   Created by Serhii Mumriak on 13.08.2023
# 

import sys
import ctypes

class Reactor:
    def register_timer(self, callback, waketime=10):
        return "Timer"

    def register_callback(self, callback, waketime=10):
        return

class Printer:
    def __init__(self):
        self.reactor = Reactor()
        self.runout_helper = RunoutHelper()

    def get_reactor(self):
        return self.reactor

    def register_event_handler(self, event, callback):
        print("Called register_event_handler")
        callback()
        return

    def lookup_object(self, name, default=None):
        print(f"Looking for {name}")
        return self

    def set_value(self):
        pass

    def get_counts(self):
        pass
        
    def set_counts(self):
        pass
        
    def reset_counts(self):
        pass
        
    def get_distance(self):
        pass
        
    def set_distance(self):
        pass
        
    def is_enabled(self):
        pass
        
    def get_clog_detection_length(self):
        pass
        
    def set_clog_detection_length(self):
        pass
        
    def update_clog_detection_length(self):
        pass

    def set_extruder(self, name):
        pass

    def get_position(self):
        return [0.0, 0.0, 0.0, 0.0]

    def set_position(self, position):
        pass

    def do_set_position(self, position):
        pass

    def do_move(self, movepos, speed, accel, sync=True):
        pass

    def do_homing_move(self, movepos, speed, accel, triggered, check_trigger):
        pass

    def sync_to_extruder(self, extruder):
        pass

    def reset_synchronization(self):
        pass

    def dwell(self, time):
        pass

    def wait_moves(self):
        pass

    def manual_move(self, coord, speed):
        pass

    def get(self, name):
        return "hello"

    def set(self, name, value):
        pass

class RunoutHelper:
    def __init__(self):
        pass
        
class GCode:
    def __init__(self):
        pass

    def register_command(self, command, callback, description):
        pass

class Config:
    def __init__(self):
        self.printer = Printer()
        self.gCode = GCode()
        self.reactor = "reactor"

    def __del__(self):
        del self.printer
        del self.gCode

    def get_printer(self):
        return self.printer

    def getint(self, name):
        return 10

    def getfloat(self, name):
        return 10.5

    def get(self, name):
        return "hello"

    def getintlist(self, name):
        return (12, 13)


FilamentChanger = ctypes.POINTER(ctypes.c_char)
libFilamentChanger = ctypes.PyDLL(".build/debug/libFilamentChanger.so")

libFilamentChanger.createFilamentChanger.argtypes = [ctypes.py_object]
libFilamentChanger.createFilamentChanger.restype = FilamentChanger

libFilamentChanger.releaseFilamentChanger.argtypes = [FilamentChanger]

config = Config()

class FilamentChangerWrapper:
    def __init__(self, config):
        self.filamentChanger = libFilamentChanger.createFilamentChanger(config)

    def __del__(self):
        libFilamentChanger.releaseFilamentChanger(self.filamentChanger)

filamentChanger = FilamentChangerWrapper(config)

del config
del filamentChanger

import time

time.sleep(1)
