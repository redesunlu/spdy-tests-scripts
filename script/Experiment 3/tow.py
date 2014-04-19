#!/usr/bin/python

from scapy.all import *


def calc_tow(captureFile):
    capture = rdpcap(captureFile)
    return capture[len(capture)-1].time - capture[0].time
