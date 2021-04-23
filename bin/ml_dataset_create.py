#!/usr/bin/python3

# EXAMPLES:
#
# ml_dataset_create.py 17000000 30 100 0.2 2 50000 classification ./classification.libsvm
#
# ml_dataset_create.py 17000000 30 100 0.2 0 50000 regression ./regression.libsvm

from sys import argv as args
import sys

if len(args) != 9:
    print("Sintax: %s <SAMPLES> <DIMS> <CLUSTERS> <NOISE> <LABELS> <JOB_SIZE> <TASK> <OUTPUT_CSV_FILEPATH>" % args[0])
    sys.exit(1)


from sklearn.datasets import dump_svmlight_file
from p_tqdm import p_imap

import numpy as np
import math
import csv
import os


samples = int(args[1])
dims = int(args[2])
clusters = int(args[3])
noise = float(args[4])
labels = int(args[5])
job_size = int(args[6])
task = args[7]
output = args[8]


def split_by_groups(n, groups):
    result = []
    
    for i in range(groups):
        start = i * n // groups
        end = (i+1) * n // groups
        result.append(end - start)
    
    return result


def split_by_size(n, max_size):
    result = []
    added = 0
    
    while added != n:
        added2 = min(added + max_size, n)
        result.append(added2 - added)
        added = added2
    
    return result


print("Create/clear the output file...")
if os.path.exists(output):
    os.remove(output)


print("Starting task...")
if task == "classification":


    print("Creating parameters...")
    centroids = np.random.rand(labels * clusters, dims)
    
    
    def classification_generator(job):

        label_idd, cluster_idd, split_idd, split_size = job
        centroid = centroids[label_idd * clusters + cluster_idd, :]
        
        x = np.random.normal(centroid, noise, (split_size, dims))
        y = [label_idd] * split_size
        
        filepath = "%s.%d_%d_%d_%d" % (output, *job)
        
        dump_svmlight_file(x, y, filepath, zero_based=False)
        
        return filepath


    print("Creating jobs...")
    jobs = []
    label_samples = split_by_groups(samples, labels)

    for label_idd, label_size in enumerate(label_samples):
        label_clusters = split_by_groups(label_size, clusters)
        
        for cluster_idd, cluster_size in enumerate(label_clusters):
            cluster_splits = split_by_size(cluster_size, job_size)
            
            for split_idd, split_size in enumerate(cluster_splits):
                jobs.append( (label_idd, cluster_idd, split_idd, split_size) )


    print("Generating dataset...")
    for filepath in p_imap(classification_generator, jobs):
        os.system("cat %s >> %s" % (filepath, output))
        os.remove(filepath)


elif task == "regression":
    
    
    print("Creating parameters...")
    canvas = 100
    input_neurons = dims
    hidden_neurons = 100
    output_neurons = 1
    
    w1 = np.random.normal(0, 1, (input_neurons, hidden_neurons))
    w2 = np.random.normal(0, 1, (hidden_neurons, output_neurons))
    centroids = np.random.normal(0,1, (clusters, dims)) * canvas - canvas / 2
    
    
    def regression_generator(job):
        
        cluster_idd, split_idd, split_size = job
        centroid = centroids[cluster_idd, :]
        
        x = np.random.normal(centroid, noise * canvas, (split_size, dims))
        y = np.matmul(np.tanh(np.matmul(x, w1)), w2).ravel()
        
        filepath = "%s.%d_%d_%d" % (output, *job)
        
        dump_svmlight_file(x, y, filepath, zero_based=False)
        
        return filepath


    print("Creating jobs...")
    jobs = []
    label_clusters = split_by_groups(samples, clusters)

    for cluster_idd, cluster_size in enumerate(label_clusters):
        cluster_splits = split_by_size(cluster_size, job_size)
        
        for split_idd, split_size in enumerate(cluster_splits):
            jobs.append( (cluster_idd, split_idd, split_size) )


    print("Generating dataset...")
    for filepath in p_imap(regression_generator, jobs):
        os.system("cat %s >> %s" % (filepath, output))
        os.remove(filepath)


else:

    print("Invalid task. Valid values are: regression, classification. Got", task)
    sys.exit(1)


print("Done!")

