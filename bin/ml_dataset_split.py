#!/usr/bin/python3

import numpy as np
import random
import sys


# Validate input and parse parameters
if len(sys.argv) != 3:
    print("SINTAX: %s <DATASET_PREFIX=./regression> <TRAINSIZE=0.7>" % sys.argv[0])
    sys.exit(1)


dataset = sys.argv[1]
size = float(sys.argv[2])

if size < 0.0 or size > 1.0:
    print("Invalid value for TRAINSIZE:", size)
    sys.exit(1)


# Load datasets
print("Loading dataset...")
x = np.load(dataset + ".x.npy")
y = np.load(dataset + ".y.npy")

rows, _ = x.shape

train_size = int(rows * size)


# Sort indexes
print("Shuffling indexes...")
idx = list(range(rows))
random.shuffle(idx)
train_idx = idx[:train_size]
test_idx = idx[train_size:]
print("size:%d, trainsize:%d, testsize:%d" % (len(idx), len(train_idx), len(test_idx)))


# Save train set
print("Saving trainset...")
train_x = x[train_idx,:]
train_y = y[train_idx]

np.save(dataset + ".train.x.npy", train_x)
np.save(dataset + ".train.y.npy", train_y)


# Save test set
print("Saving testset...")
test_x = x[test_idx,:]
test_y = y[test_idx]

np.save(dataset + ".test.x.npy", test_x)
np.save(dataset + ".test.y.npy", test_y)


# Over
print("Done!")
