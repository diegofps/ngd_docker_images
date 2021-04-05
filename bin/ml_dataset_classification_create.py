#!/usr/bin/python3


from sys import argv as args
import numpy as np
import math
import sys
import csv


if len(args) == 1:
    print("Sintax: %s <SAMPLES_IN_CLUSTER> <DIMS> <CLUSTERS> <NOISE> <CLASSES> <OUTPUT_CSV_FILEPATH>" % args[0])
    sys.exit(0)

samples_in_cluster = int(args[1]) if len(args) >= 2 else 1000
dims = int(args[2]) if len(args) >= 3 else 10
clusters = int(args[3]) if len(args) >= 4 else 1
noise = float(args[4]) if len(args) >= 5 else 0.0
classes = int(args[5]) if len(args) >= 6 else 2
output = args[6] if len(args) >= 7 else "./classification_dataset.csv"


with open(output, "w") as fout:
    
    writer = csv.writer(fout, delimiter=";")
    y_data = np.zeros( dims + 2 )
        
    header = ["CLASS", "CLUSTER"] + ["X%d" % i for i in range(dims)]
    writer.writerow(header)
    
    for k in range(classes):
        
        offsets = np.random.rand(clusters, dims) * 2 * math.pi
        frequencies = np.random.rand(clusters, dims) * 1.0
        y_data[0] = k
        
        for c in range(clusters):
            
            offset = offsets[c,:]
            frequency = frequencies[c,:]
            
            x_data = np.random.normal(0, 1, (samples_in_cluster, dims)) * 2 * math.pi
            noise_data = np.random.normal(samples_in_cluster, dims) * noise
            y_data[1] = c

            for s in range(samples_in_cluster):
                y_data[2:] = np.sin( offset + x_data[s,:] * frequency )
                writer.writerow([str(x) for x in y_data])
            

