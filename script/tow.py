from scapy.all import *
import sys
import os

if len(sys.argv) != 2:
    sys.exit('ERROR: Bad parameters!')

if not os.path.exists(sys.argv[1]):
    sys.exit('ERROR: Directory %s was not found!' % sys.argv[1])
else:
	captureFile = sys.argv[1]
	
capture = rdpcap(captureFile)
print "%f" % (capture[len(capture)-1].time - capture[0].time)
	
