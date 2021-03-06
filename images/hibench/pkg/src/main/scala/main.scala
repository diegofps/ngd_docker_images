package br.com.wespa.ngd.spark.parametertunning

import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import scala.collection.mutable.ListBuffer
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD

// Concurrency and Futures
import scala.concurrent.duration.Duration
import java.util.concurrent.Executors
import scala.concurrent._

// Logistic regression
import org.apache.spark.mllib.classification.{LogisticRegressionModel, LogisticRegressionWithLBFGS}

// K-Means
import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.Vectors

// Gradient Boosted Trees
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.BoostingStrategy
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel

// Random Forest
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.tree.model.RandomForestModel

// Decision Tree
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.tree.model.DecisionTreeModel

// SVM
import org.apache.spark.mllib.classification.{SVMModel, SVMWithSGD}

// Naive Bayes
import org.apache.spark.mllib.classification.{NaiveBayes, NaiveBayesModel}


///////////////////////////////////////////////////////////////////////////////////////////
// Extra types and utils
///////////////////////////////////////////////////////////////////////////////////////////

case class Job(repetitions: Int, training: RDD[LabeledPoint], test: RDD[LabeledPoint], model_type: String, model_params: Map[String, String])
case class Result(acc: Double, training_time: Double, evaluation_time: Double, job: Job)

object Tunner {

val DATASET_FILEPATH = "/spark/data/mllib/sample_libsvm_data.txt"
//val DATASET_FILEPATH = "hdfs://hadoop-primary:9000/sample_libsvm_data.txt"

val TYPE_GRADIENT_BOOSTED_TREES = "gradient_boosted_trees"
val TYPE_LOGISTIC_REGRESSION = "logistic_regression"
val TYPE_RANDOM_FOREST = "random_forest"
val TYPE_DECISION_TREE = "decision_tree"
val TYPE_NAIVE_BAYES = "naive_bayes"
val TYPE_KMEANS = "kmeans"
val TYPE_SVM = "svm"


def encode_categories(idds: Map[Int, Int]): String = {
    if (idds.isEmpty)
        return ""
    else
        return idds.iterator.map(x => x._1 + ":" + x._2).reduce((a,b) => a + " " + b )
}

def decode_categories(idds: String): Map[Int, Int] = {
    if (idds == "")
        return Map[Int, Int]()
    else
        return idds.split(" ").map(x => x.split(":")).map(x => (x(0).toInt, x(1).toInt)).toMap
}

def load_dataset(spark: SparkSession, filepath: String):(RDD[LabeledPoint], RDD[LabeledPoint]) = {
    val data = MLUtils.loadLibSVMFile(spark.sparkContext, filepath)
    val Array(training, test) = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    training.cache()
    test.cache()
    return (training, test)
}

///////////////////////////////////////////////////////////////////////////////////////////
// Eval jobs
///////////////////////////////////////////////////////////////////////////////////////////

def eval_logistic_regression(job: Job): Result = {

    //val (training, test) = load_dataset(DATASET_FILEPATH)

    var start = System.currentTimeMillis
    val model = new LogisticRegressionWithLBFGS().setNumClasses(2).run(job.training)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    start = System.currentTimeMillis
    val predictionAndLabel = job.test.map(p => (model.predict(p.features), p.label))
    val testTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = new BinaryClassificationMetrics(predictionAndLabel).areaUnderROC()

    return Result(auroc, trainingTime, testTime, job)
}

def eval_kmeans(job: Job): Result = {

    // Prepare dataset
    // val (_training, _test) = load_dataset(DATASET_FILEPATH)
    val training = job.training.map(x => x.features)
    val test = job.test.map(x => x.features)

    // Create and train the model
    val p = job.model_params
    val clusters = p("clusters").toInt
    val iterations = p("iterations").toInt

    var start = System.currentTimeMillis
    val kmeans = KMeans.train(training, clusters, iterations)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00
    
    // Measure performance
    start = System.currentTimeMillis
    val cost = kmeans.computeCost(test)
    val testTime = (System.currentTimeMillis - start) / 1000.00

    return Result(cost, trainingTime, testTime, job)
}

def eval_gradient_boosted_trees(job: Job): Result = {

    // val (training, test) = load_dataset(DATASET_FILEPATH)
    val boostingStrategy = BoostingStrategy.defaultParams("Classification")

    val p = job.model_params
    boostingStrategy.numIterations = p("iterations").toInt
    boostingStrategy.treeStrategy.numClasses = p("numClasses").toInt
    boostingStrategy.treeStrategy.maxDepth = p("depth").toInt
    boostingStrategy.treeStrategy.categoricalFeaturesInfo = decode_categories(p("categoricalFeatures"))

    var start = System.currentTimeMillis
    val model = GradientBoostedTrees.train(job.training, boostingStrategy)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    start = System.currentTimeMillis
    val predictionAndLabel = job.test.map(p => (model.predict(p.features), p.label))
    val testTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = new BinaryClassificationMetrics(predictionAndLabel).areaUnderROC()

    return Result(auroc, trainingTime, testTime, job)
}

def eval_random_forest(job: Job): Result = {

    // val (training, test) = load_dataset(DATASET_FILEPATH)

    val p = job.model_params
    val categoricalFeaturesInfo = decode_categories(p("categoricalFeatures"))
    val featureSubsetStrategy = p("featureSubsetStrategy")
    val numClasses = p("numClasses").toInt
    val impurity = p("impurity")
    val numTrees = p("trees").toInt
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    var start = System.currentTimeMillis
    val model = RandomForest.trainClassifier(job.training, numClasses, categoricalFeaturesInfo, numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    start = System.currentTimeMillis
    val predictionAndLabel = job.test.map(p => (model.predict(p.features), p.label))
    val testTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = new BinaryClassificationMetrics(predictionAndLabel).areaUnderROC()

    return Result(auroc, trainingTime, testTime, job)
}

def eval_decision_tree(job: Job): Result = {

    // val (training, test) = load_dataset(DATASET_FILEPATH)

    val p = job.model_params
    val categoricalFeaturesInfo = decode_categories(p("categoricalFeatures"))
    val numClasses = p("numClasses").toInt
    val impurity = p("impurity")
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    var start = System.currentTimeMillis
    val model = DecisionTree.trainClassifier(job.training, numClasses, categoricalFeaturesInfo, impurity, maxDepth, maxBins)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    start = System.currentTimeMillis
    val predictionAndLabel = job.test.map(p => (model.predict(p.features), p.label))
    val testTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = new BinaryClassificationMetrics(predictionAndLabel).areaUnderROC()

    return Result(auroc, trainingTime, testTime, job)
}

def eval_svm(job: Job): Result = {

    // val (training, test) = load_dataset(DATASET_FILEPATH)

    val p = job.model_params
    val stepSize = p("stepSize").toDouble
    val numIterations = p("iterations").toInt
    val regParam = p("regParam").toDouble
    val miniBatchFraction = p("miniBatchFraction").toDouble

    var start = System.currentTimeMillis
    val model = SVMWithSGD.train(job.training, numIterations, stepSize, regParam, miniBatchFraction)
    model.clearThreshold()
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    start = System.currentTimeMillis
    val predictionAndLabel = job.test.map(p => (model.predict(p.features), p.label))
    val testTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = new BinaryClassificationMetrics(predictionAndLabel).areaUnderROC()

    return Result(auroc, trainingTime, testTime, job)
}

def eval_naive_bayes(job: Job): Result = {

    // val (training, test) = load_dataset(DATASET_FILEPATH)

    val p = job.model_params
    val lambda = p("lambda").toDouble
    val modelType = p("modelType")

    var start = System.currentTimeMillis
    val model = NaiveBayes.train(job.training, lambda, modelType)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    start = System.currentTimeMillis
    val predictionAndLabel = job.test.map(p => (model.predict(p.features), p.label))
    val testTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = new BinaryClassificationMetrics(predictionAndLabel).areaUnderROC()

    return Result(auroc, trainingTime, testTime, job)
}

def reduce_results(results: Vector[Result]): Unit = {

}

def eval(job: Job): Seq[Result] = {

    if (job.model_type == TYPE_LOGISTIC_REGRESSION)
        return (1 to job.repetitions).map(x => eval_logistic_regression(job))
        
    else if (job.model_type == TYPE_KMEANS)
        return (1 to job.repetitions).map(x => eval_kmeans(job))
    
    else if (job.model_type == TYPE_GRADIENT_BOOSTED_TREES)
        return (1 to job.repetitions).map(x => eval_gradient_boosted_trees(job))
    
    else if (job.model_type == TYPE_RANDOM_FOREST)
        return (1 to job.repetitions).map(x => eval_random_forest(job))
    
    else if (job.model_type == TYPE_DECISION_TREE)
        return (1 to job.repetitions).map(x => eval_decision_tree(job))
    
    else if (job.model_type == TYPE_SVM)
        return (1 to job.repetitions).map(x => eval_svm(job))
    
    else if (job.model_type == TYPE_NAIVE_BAYES)
        return (1 to job.repetitions).map(x => eval_naive_bayes(job))
    
    else
        throw new RuntimeException("Invalid model_type: " + job.model_type)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Add jobs
///////////////////////////////////////////////////////////////////////////////////////////

def add_logistic_regression(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {
    jobs.append(Job(repetitions, training, test, TYPE_LOGISTIC_REGRESSION, Map()))
}

def add_kmeans(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {

    val numIterations = Range(10, 60, 10) // 5
    val numClusters = Range(1, 11) // 10

    for (clusters <- numClusters) {
        for (iterations <- numIterations) {
            jobs.append(Job(repetitions, training, test, TYPE_KMEANS, Map(
                "clusters" -> clusters.toString,
                "iterations" -> iterations.toString
            )))
        }
    }
}

def add_gradient_boosted_trees(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {

    val numIterations = Range(3, 30, 3) // 9
    val valDepths = Range(1, 7) // 6

    val categoricalFeatures = encode_categories(Map[Int, Int]())
    val numClasses = 2

    for (depth <- valDepths) {
        for (iterations <- numIterations) {
            jobs.append(Job(repetitions, training, test, TYPE_GRADIENT_BOOSTED_TREES, Map(
                "depth" -> depth.toString,
                "iterations" -> iterations.toString,
                "numClasses" -> numClasses.toString,
                "categoricalFeatures" -> categoricalFeatures
            )))
        }
    }
}

def add_random_forest(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {

    val valImpurity = Array("gini", "entropy") // 2
    val valBins = Range(32, 256, 32) // 7
    val valTrees = Range(5, 20, 5) // 3
    val valDepths = Range(1, 7) // 6

    val categoricalFeatures = encode_categories(Map[Int, Int]())
    val featureSubsetStrategy = "auto"
    val numClasses = 2

    for (impurity <- valImpurity) {
        for (bins <- valBins) {
            for (trees <- valTrees) {
                for (depth <- valDepths) {
                    jobs.append(Job(repetitions, training, test, TYPE_RANDOM_FOREST, Map(
                        "impurity" -> impurity,
                        "bins" -> bins.toString,
                        "trees" -> trees.toString,
                        "depth" -> depth.toString,
                        "categoricalFeatures" -> categoricalFeatures.toString,
                        "featureSubsetStrategy" -> featureSubsetStrategy.toString,
                        "numClasses" -> numClasses.toString
                    )))
                }
            }
        }
    }
}

def add_decision_tree(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {
    
    val valImpurity = Array("gini", "entropy") // 2
    val valBins = Range(32, 256, 32) // 7
    val valDepths = Range(1, 7) // 6

    val categoricalFeatures = encode_categories(Map[Int, Int]())
    val numClasses = 2

    for (impurity <- valImpurity) {
        for (bins <- valBins) {
            for (depth <- valDepths) {
                jobs.append(Job(repetitions, training, test, TYPE_DECISION_TREE, Map(
                    "impurity" -> impurity,
                    "bins" -> bins.toString,
                    "depth" -> depth.toString,
                    "categoricalFeatures" -> categoricalFeatures,
                    "numClasses" -> numClasses.toString
                )))
            }
        }
    }
}

def add_svm(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {

    val valStepSize = Array(0.01, 0.1, 1.0) // 3
    val valIterations = Array(100, 500, 1000) // 3
    val valRegParam = Array(0.001, 0.01, 0.1) // 3
    val valMiniBatchFraction = Array(1.0, 3.0, 5.0) // 3

    for (stepSize <- valStepSize) {
        for (iterations <- valIterations) {
            for (regParam <- valRegParam) {
                for (miniBatchFraction <- valMiniBatchFraction) {
                    jobs.append(Job(repetitions, training, test, TYPE_SVM, Map(
                        "stepSize" -> stepSize.toString,
                        "iterations" -> iterations.toString,
                        "regParam" -> regParam.toString,
                        "miniBatchFraction" -> miniBatchFraction.toString
                    )))
                }
            }
        }
    }
}

def add_naive_bayes(training: RDD[LabeledPoint], test: RDD[LabeledPoint], repetitions: Int, jobs: ListBuffer[Job]): Unit = {
    
    val valLambda = Array(0.001, 0.01, 0.1, 1.0, 10.0) // 5
    val valModelType = Array("multinomial", "bernoulli") // 2

    for (lambda <- valLambda) {
        for (modelType <- valModelType) {
            jobs.append(Job(repetitions, training, test, TYPE_NAIVE_BAYES, Map(
                "lambda" -> lambda.toString,
                "modelType" -> modelType
            )))
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////
// Main interface
///////////////////////////////////////////////////////////////////////////////////////////

def main(args: Array[String]): Unit = {

  val spark = SparkSession.builder.appName("Tunner").getOrCreate()
  try 
  {
    val (training, test) = load_dataset(spark, DATASET_FILEPATH)

    val numThreads = if (args.length >= 3) args(2).toInt else 1
    val numRepetitions = if (args.length >= 2) args(1).toInt else 10
    val target = if (args.length >= 1) args(0) else "all"
    // val valRepetitions = Range(1, numRepetitions)
    val jobs = ListBuffer[Job]()

    // Create individual jobs
    if (target == "logistic_regression" || target == "all" )
        add_logistic_regression(training, test, numRepetitions, jobs)
    
    if (target == "kmeans" || target == "all" )
        add_kmeans(training, test, numRepetitions, jobs)
    
    if (target == "gradient_boosted_trees" || target == "all" )
        add_gradient_boosted_trees(training, test, numRepetitions, jobs)

    if (target == "random_forest" || target == "all" )
        add_random_forest(training, test, numRepetitions, jobs)

    if (target == "decision_tree" || target == "all" )
        add_decision_tree(training, test, numRepetitions, jobs)

    if (target == "svm" || target == "all" )
        add_svm(training, test, numRepetitions, jobs)
        
    if (target == "naive_bayes" || target == "all" )
        add_naive_bayes(training, test, numRepetitions, jobs)

    // Run in parallel
    //implicit val ec = concurrent.ExecutionContext.fromExecutorService(Executors.newWorkStealingPool(numThreads))
    implicit val ec = concurrent.ExecutionContext.fromExecutorService(Executors.newFixedThreadPool(numThreads))
    
    println("Threads:" + numThreads)
    println("Jobs:" + jobs.size.toString)
    println("Dataset:" + DATASET_FILEPATH)
    println("Repetitions:" + numRepetitions)
    println("Starting in 5s...")
    Thread.sleep(1000 * 5)

    val futures = jobs.map(x => Future {
        println("=================================================================== EVALUATING ==================================================")
        eval(x)
    })

    futures.foreach(x => Await.ready(x, Duration.Inf))
    val results = futures.flatMap(x => x.value.last.get)

    // Apply map to evaluate them
    // var rdd = spark.sparkContext.parallelize(jobs)
    // rdd = rdd.repartition(rdd.count().toInt)
    // val results = rdd.map(eval)

    // Print results (just for sanity check)
    results.foreach(println)

    println("Bye!")
  } 
  finally {
    spark.sparkContext.stop()
  }
}

}

