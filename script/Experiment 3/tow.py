#!/usr/bin/python

from os.path import exists
from scapy.all import *
from import argv, exit


def calc_tow(captureFile):
    capture = rdpcap(captureFile)
    return capture[len(capture)-1].time - capture[0].time


if len(argv) != 2:
    exit('ERROR: Bad parameters!')

if not exists(argv[1]):
    exit('ERROR: Directory %s was not found!' % argv[1])
else:
    captureFile = argv[1]

print calc_tow(captureFile)
