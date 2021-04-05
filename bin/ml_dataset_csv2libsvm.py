#!/usr/bin/python3


from sys import argv as args
import sys
import csv


if len(args) < 3:
    print("Sintax: %s <INPUT_CSV> <OUTPUT_LIBSVM>")
    sys.exit(0)


csv_filepath = args[1]
libsvm_filepath = args[2]

with open(csv_filepath, "r") as fin:
    with open(libsvm_filepath, "w") as fout:
    
        reader = csv.reader(fin, delimiter=";")
        header = next(reader)
        
        for cells in reader:
            clazz = cells[0]
            cluster = cells[1]
            features = cells[2:]
            
            line = str(clazz) + " " + " ".join([str(i+1) + ":" + str(x) for i,x in enumerate(features)]) + "\n"
            
            fout.write(line)

