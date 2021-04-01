#!/usr/bin/python3

from sys import argv as args
import csv

filepath_in = args[1]
filepath_out = args[2]

size = 0


with open(filepath_in, "r") as fin:
    for line in fin:
        cells = line.split()[1:]
        for cell in cells:
            k,v = cell.split(":")
            k = int(k)+1
            if k > size:
                size = k

print(size)

with open(filepath_in, "r") as fin:
    with open(filepath_out, "w") as fout:
        writer = csv.writer(fout, delimiter=";")

        for line in fin:
            cells = line.split()
            features = cells[1:]
            
            row = ["0"] * size
            row[0] = cells[0]

            for f in features:
                k,v = f.split(":")
                row[int(k)] = v
            
            writer.writerow(row)


