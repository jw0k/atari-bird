#!/usr/bin/python

import sys, re

if len(sys.argv) != 3:
    print "usage: fixcas.py path/to/cas numberOfLoaderBlocks"
    sys.exit(2)

try:
    f = open(sys.argv[1], "r+b") #r+ - otworz do odczytu i do zapisu (nadpisywanie), b - binary
except Exception, e:
    print str(e)
    sys.exit(1)

try:
    content = f.read()
    matches = list(re.finditer(r"data", content))

    lastLoaderBlockIndex = int(sys.argv[2])-1
    fourthDataBlockStartIndex = matches[lastLoaderBlockIndex].start()
    fourthDataBlockControlByteIndex = fourthDataBlockStartIndex + 10
    f.seek(fourthDataBlockControlByteIndex)
    f.write("\xFE")

    firstDataBlock = lastLoaderBlockIndex+1
    fifthDataBlockStartIndex = matches[firstDataBlock].start()
    fifthDataBlockIRGIndex = fifthDataBlockStartIndex + 6
    f.seek(fifthDataBlockIRGIndex)
    irg = 20000 #ms
    msb = irg / 256
    lsb = irg - msb*256
    f.write(bytearray([lsb, msb]))

finally:
    f.close()