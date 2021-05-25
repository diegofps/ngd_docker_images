#!/usr/bin/python3


from sklearn.datasets import load_svmlight_file
import numpy as np
import sys


if len(sys.argv) != 2:
    print("SINTAX: %s <DATASET.libsvm>")
    sys.exit(1)


dataset = sys.argv[1]
if dataset.endswith(".libsvm"):
    dataset = dataset[:-7]


print("Loading dataset...")
x, y = load_svmlight_file(dataset + ".libsvm", zero_based=False)
x = x.toarray()


print("Dumping data...")
np.save(dataset + ".x.npy", x)
np.save(dataset + ".y.npy", y)


print("Done!")
