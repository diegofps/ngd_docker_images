#!/usr/bin/python3


from sys import argv as args
import numpy as np
import math
import sys
import csv


if len(args) == 1:
    print("Sintax: %s <DIMS> <NOISE> <SAMPLES> <OUTPUT_CSV_FILEPATH>" % args[0])
    sys.exit(0)


dims = int(args[1]) if len(args) >= 2 else 10
noise = float(args[2]) if len(args) >= 3 else 0.0
samples = int(args[3]) if len(args) >= 4 else 1000
output = args[4] if len(args) >= 5 else "./regression_dataset.csv"


with open(output, "w") as fout:
    
    writer = csv.writer(fout, delimiter=";")
    header = ["Y"] + ["X%d" % i for i in range(dims)]
    writer.writerow(header)
    
    offsets = np.random.rand(dims) * 2 * math.pi
    frequencies = np.random.rand(dims) * 1.0
    
    y_data = np.zeros( (samples, dims + 1) )
    y_data[:,1:] = np.random.normal(0, 1, (samples, dims)) * 2 * math.pi
    noise_data = np.random.normal(0, noise, samples)

    for s in range(samples):
        y_data[s,0] = np.sum(np.sin(offsets + y_data[s,1:] * frequencies)) + noise_data[s]
        writer.writerow([str(x) for x in y_data[s,:]])
