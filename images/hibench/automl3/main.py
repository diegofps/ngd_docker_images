#!/usr/bin/python3

from sklearn.metrics import mean_squared_error
from pyspark.sql.types import FloatType

import numpy as np
import json
import sys



# utils
def load_dataset(params):
    
    trainset_x = params["trainset"] + ".x.npy"
    trainset_y = params["trainset"] + ".y.npy"

    testset_x = params["testset"] + ".x.npy"
    testset_y = params["testset"] + ".y.npy"

    trainset_x = np.load(trainset_x)
    trainset_y = np.load(trainset_y)

    testset_x = np.load(testset_x)
    testset_y = np.load(testset_y)

    trainset = (trainset_x, trainset_y)
    testset = (testset_x, testset_y)

    return trainset, testset



# run methods
def run_ridge(params):

    from sklearn import linear_model

    print("Loading dataset")
    trainset, testset = load_dataset(params)
    alpha = params["alpha"]

    print("Training model")
    model = linear_model.Ridge(alpha=alpha)
    model = model.fit(*trainset)

    print("Testing model")
    pred = model.predict(testset[0])
    mse =  float(mean_squared_error(testset[1], pred))
    
    print("result:", mse)
    return (mse,)


def run_lasso(params):

    from sklearn import linear_model

    print("Loading dataset")
    trainset, testset = load_dataset(params)
    alpha = params["alpha"]

    print("Training model")
    model = linear_model.Lasso(alpha=alpha)
    model = model.fit(*trainset)

    print("Testing model")
    pred = model.predict(testset[0])
    mse =  float(mean_squared_error(testset[1], pred))
    
    print("result:", mse)
    return (mse,)


def run_sgd(params):

    from sklearn.preprocessing import StandardScaler
    from sklearn.linear_model import SGDRegressor
    from sklearn.pipeline import make_pipeline

    print("Loading dataset")
    trainset, testset = load_dataset(params)
    max_iter = params["max_iter"]
    tol = params["tol"]

    print("Training model")
    model = make_pipeline(
        StandardScaler(), 
        SGDRegressor(max_iter=max_iter, tol=tol)
    )
    model = model.fit(*trainset)

    print("Testing model")
    pred = model.predict(testset[0])
    mse =  float(mean_squared_error(testset[1], pred))

    print("result:", mse)
    return (mse,)


def run_dtr(params):

    from sklearn.tree import DecisionTreeRegressor

    print("Loading dataset")
    trainset, testset = load_dataset(params)
    max_depth = params["max_depth"]

    print("Training model")
    model = DecisionTreeRegressor(random_state=0, max_depth=max_depth)
    model = model.fit(*trainset)

    print("Testing model")
    pred = model.predict(testset[0])
    mse =  float(mean_squared_error(testset[1], pred))

    print("result:", mse)
    return (mse,)


def run_nearest_regression(params):
    from sklearn import neighbors

    print("Loading dataset")
    trainset, testset = load_dataset(params)
    n_neighbors = params["n_neighbors"]
    weights = params["weights"]

    print("Training model")
    model = neighbors.KNeighborsRegressor(n_neighbors, weights=weights)
    model = model.fit(*trainset)

    print("Testing model")
    pred = model.predict(testset[0])
    mse = float(mean_squared_error(testset[1], pred))

    print("result:", mse)
    return (mse,)



# Run
def run_basic(params):

    model = params["model"]
    params = params["params"]
    
    if model == "ridge":
        return run_ridge(params)
    
    elif model == "lasso":
        return run_lasso(params)
    
    elif model == "sgd":
        return run_sgd(params)
    
    elif model == "dtr":
        return run_dtr(params)
    
    elif model == "nearest_regression":
        return run_nearest_regression(params)
    
    else:
        raise RuntimeError("Invalid model: " + model)


def run_df(row):

    params = json.loads(row["value"])
    return run_basic(params)


def run_rdd(row):
    print(row)
    params = json.loads(row[0])
    return run_basic(params)


# Test methods
def test_decision_tree_regression(dataset):
    run({
        "model": "dtr",
        "params": {
            "trainset": dataset + ".train",
            "testset": dataset + ".test",
            "max_depth": 5
        }
    })


def test_ridge_regression(dataset):
    run({
        "model": "ridge",
        "params": {
            "trainset": dataset + ".train",
            "testset": dataset + ".test",
            "alpha": 0.1
        }
    })


def test_lasso_regression(dataset):
    run({
        "model": "lasso",
        "params": {
            "trainset": dataset + ".train",
            "testset": dataset + ".test",
            "alpha": 0.1
        }
    })


def test_sgd_regression(dataset):
    run({
        "model": "sgd",
        "params": {
            "trainset": dataset + ".train",
            "testset": dataset + ".test",
            "max_iter": 1000,
            "tol": 0.001,
        }
    })


def test_nearest_regression(dataset):
    run({
        "model": "nearest_regression",
        "params": {
            "trainset": dataset + ".train",
            "testset": dataset + ".test",
            "n_neighbors": 50,
            "weights": "uniform"
        }
    })



# Spark methods
def add_decision_tree_regression(dataset, repetitions, jobs):
    repetition_vals = range(repetitions)
    max_depth_vals = [2, 3, 4, 5]

    for max_depth in max_depth_vals:
        for repetition in repetition_vals:
            
            jobs.append({
                "model": "dtr",
                "params": {
                    "trainset": dataset + ".train",
                    "testset": dataset + ".test",
                    "max_depth": max_depth
                }
            })


def add_ridge_regression(dataset, repetitions, jobs):

    alpha_vals = [0.1, 0.2, 0.3, 0.4, 0.5]
    repetition_vals = range(repetitions)

    for alpha in alpha_vals:
        for repetition in repetition_vals:

            jobs.append({
                "model": "ridge",
                "params": {
                    "trainset": dataset + ".train",
                    "testset": dataset + ".test",
                    "alpha": alpha
                }
            })


def add_lasso_regression(dataset, repetitions, jobs):

    alpha_vals = [0.1, 0.2, 0.3, 0.4, 0.5]
    repetition_vals = range(repetitions)

    for alpha in alpha_vals:
        for repetition in repetition_vals:

            jobs.append({
                "model": "lasso",
                "params": {
                    "trainset": dataset + ".train",
                    "testset": dataset + ".test",
                    "alpha": alpha
                }
            })


def add_sgd_regression(dataset, repetitions, jobs):

    max_iter_vals = [100, 1000, 10000, 100000]
    repetition_vals = range(repetitions)

    for max_iter in max_iter_vals:
        for repetition in repetition_vals:

            jobs.append({
                "model": "sgd",
                "params": {
                    "trainset": dataset + ".train",
                    "testset": dataset + ".test",
                    "max_iter": max_iter,
                    "tol": 0.001,
                }
            })


# Main methods
def build_jobs(dataset, repetitions, model):
    jobs = []

    if model == "decision_tree" or model == "all":
        add_decision_tree_regression(dataset, repetitions, jobs)
    
    if model == "ridge" or model == "all":
        add_ridge_regression(dataset, repetitions, jobs)
    
    if model == "lasso" or model == "all":
        add_lasso_regression(dataset, repetitions, jobs)
    
    if model == "sgd" or model == "all":
        add_sgd_regression(dataset, repetitions, jobs)

    return jobs


def main_rdd(args):

    if len(args) != 4:
        print("SINTAX: %s spark <SPLITTED_DATASET> <REPETITIONS> <MODEL>" % args[0])
        sys.exit(1)

    dataset = args[1]
    repetitions = int(args[2])
    model = args[3]
    jobs = build_jobs(dataset, repetitions, model)
    jobs = [json.dumps(job) for job in jobs]

    print("dataset:", dataset)
    print("repetitions:", repetitions)
    print("model:", model)
    print("num_jobs:", len(jobs))
    print("jobs:", jobs)

    from pyspark.sql import SparkSession
    spark = SparkSession.builder.appName("AutoML3").getOrCreate()
        #.config("spark.some.config.option", "some-value") \

    jobsRDD = spark.sparkContext.parallelize(jobs, len(jobs))
    print("partitions:", jobsRDD.getNumPartitions())
    results = jobsRDD.glom().map(run_rdd).collect()

    print(results)


def main_df(args):

    if len(args) != 4:
        print("SINTAX: %s spark <SPLITTED_DATASET> <REPETITIONS> <MODEL>" % args[0])
        sys.exit(1)

    dataset = args[1]
    repetitions = int(args[2])
    model = args[3]

    jobs = build_jobs(dataset, repetitions, model)
    jobs = [json.dumps(job) for job in jobs]

    print("dataset:", dataset)
    print("repetitions:", repetitions)
    print("model:", model)
    print("num_jobs:", len(jobs))
    print("jobs:", jobs)

    from pyspark.sql import SparkSession
    spark = SparkSession.builder.appName("AutoML3").getOrCreate()
        #.config("spark.some.config.option", "some-value") \

    jobsDF = spark.createDataFrame(jobs, schema="string")
    jobsDF.repartition(len(jobs))
    print("partitions:", jobsDF.rdd.getNumPartitions())

    #jobsDF = spark.sparkContext.parallelize(jobs, numSlices=len(jobs))

    resultsDF = jobsDF.rdd.map(run_df).toDF(["result"])
    resultsDF.show()


def main_mp(args):

    if len(args) != 5:
        print("SINTAX: %s local <SPLITTED_DATASET> <REPETITIONS> <MODEL> <PROCS>" % args[0])
        sys.exit(1)

    dataset = args[1]
    repetitions = int(args[2])
    model = args[3]
    procs = int(args[4])

    jobs = build_jobs(dataset, repetitions, model)

    from multiprocessing import Pool
    with Pool(procs) as p:
        results = p.map(run_basic, jobs)

    print(results)

    print("Done!")


def main_serial(args):

    if len(args) != 4:
        print("SINTAX: %s local <SPLITTED_DATASET> <REPETITIONS> <MODEL>" % args[0])
        sys.exit(1)

    dataset = args[1]
    repetitions = int(args[2])
    model = args[3]

    jobs = build_jobs(dataset, repetitions, model)
    results = [run_basic(job) for job in jobs]

    print(results)

    print("Done!")


def main_sanity(args):

    if len(args) != 3:
        print("SINTAX: %s local <SPLITTED_DATASET> <FUNC_NAME>" % args[0])
        sys.exit(1)

    dataset = args[1]
    func = args[2]

    globals()[func](dataset)

    print("Done!")


def main(args):

    if len(args) < 2:
        print("SINTAX: %s <MODE=spark|local> ...")
        sys.exit(1)

    mode = args[1]

    if mode == "df":
        main_df(args[1:])

    elif mode == "rdd":
        main_rdd(args[1:])

    elif mode == "mp":
        main_mp(args[1:])

    elif mode == "serial":
        main_serial(args[1:])

    elif mode == "sanity":
        main_sanity(args[1:])

    else:
        print("Invalid mode:", mode)



main(sys.argv)
