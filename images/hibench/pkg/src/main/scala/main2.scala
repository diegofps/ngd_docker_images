package br.com.wespa.ngd.spark.parametertunning

import scala.collection.mutable.ListBuffer
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.DataFrame

// Concurrency and Futures
import scala.concurrent.duration.Duration
import java.util.concurrent.Executors
import scala.concurrent._

// Logistic Regression
import org.apache.spark.ml.classification.LogisticRegression

// K-Means
import org.apache.spark.ml.clustering.KMeans
import org.apache.spark.ml.evaluation.ClusteringEvaluator


///////////////////////////////////////////////////////////////////////////////////////////
// Extra types and utils
///////////////////////////////////////////////////////////////////////////////////////////

case class Job2(idd: Int, data: DataFrame, model_type: String, model_params: Map[String, String])
case class Result2(acc: Double, job: Job2)

object Tunner2 {

val DATASET_CLASSIFIERS = "/spark/data/mllib/sample_libsvm_data.txt"
//val DATASET_KMEANS = "/spark/data/mllib/sample_kmeans_data.txt"
val DATASET_KMEANS = "hdfs://bigdata2-primary:9000/sample_kmeans_data.txt"

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

def load_dataset(spark: SparkSession, filepath: String): DataFrame = {
    val data = spark.read.format("libsvm").load(filepath)
    data.cache()
    return data
}

///////////////////////////////////////////////////////////////////////////////////////////
// Eval jobs
///////////////////////////////////////////////////////////////////////////////////////////

def eval_logistic_regression(job: Job2): Result2 = {

    val p = job.model_params
    val reg = p("reg").toDouble
    val elasticNet = p("elasticNet").toDouble

    var start = System.currentTimeMillis
    val model = new LogisticRegression().setMaxIter(1000).setRegParam(reg).setElasticNetParam(elasticNet).fit(job.data)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = model.binarySummary.areaUnderROC

    return Result2(auroc, job)
}

def eval_kmeans(job: Job2): Result2 = {

    // Create and train the model
    val p = job.model_params
    val clusters = p("clusters").toInt

    var start = System.currentTimeMillis
    val model = new KMeans().setK(clusters).fit(job.data)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00
    
    // Measure performance
    val predictions = model.transform(job.data)
    val evaluator = new ClusteringEvaluator()
    val silhouette = evaluator.evaluate(predictions)

    return Result2(silhouette, job)
}


def eval(job: Job2): Result2 = {

    if (job.model_type == TYPE_LOGISTIC_REGRESSION)
        return eval_logistic_regression(job)
        
    else if (job.model_type == TYPE_KMEANS)
        return eval_kmeans(job)
    
    else
        throw new RuntimeException("Invalid model_type: " + job.model_type)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Add jobs
///////////////////////////////////////////////////////////////////////////////////////////

def add_logistic_regression(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valReg = Array(0.3, 0.6, 0.9) // 3
    val valElasticNet = Array(0.2, 0.4, 0.6, 0.8) // 4

    for (repetition <- 1 to repetitions) {
        for (reg <- valReg) {
            for (elasticNet <- valElasticNet) {
                jobs.append(Job2(jobs.size, data, TYPE_LOGISTIC_REGRESSION, Map(
                    "reg" -> reg.toString,
                    "elasticNet" -> elasticNet.toString
                )))
            }
        }
    }
}

def add_kmeans(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valClusters = Array(2, 4, 6, 8) // 4

    for (repetition <- 1 to repetitions) {
        for (clusters <- valClusters) {
            jobs.append(Job2(jobs.size, data, TYPE_KMEANS, Map(
                "clusters" -> clusters.toString,
            )))
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////
// Main interface
///////////////////////////////////////////////////////////////////////////////////////////

def main(args: Array[String]): Unit = {

    var datasetFilepath = DATASET_CLASSIFIERS
    var model = "kmeans"
    var numRepetitions = 10
    var numThreads = 1

    for (arg <- args) {
      if (arg.startsWith("-m="))
        model = arg.drop(3)

      else if (arg.startsWith("-ds="))
        datasetFilepath = arg.drop(4)

      else if (arg.startsWith("-t="))
        numThreads = arg.drop(3).toInt

      else if (arg.startsWith("-r="))
        numRepetitions = arg.drop(3).toInt

      else
        println("Unexpected parameter: " + arg)
    }

    val startedAt = System.currentTimeMillis()
    val spark = SparkSession.builder.appName("Tunner").getOrCreate()
    val data = load_dataset(spark, datasetFilepath)
    val jobs = ListBuffer[Job2]()

    if (model == "lr" || model == "all" )
        add_logistic_regression(data, numRepetitions, jobs)
    
    if (model == "kmeans" || model == "all" )
        add_kmeans(data, numRepetitions, jobs)
    
    println("Model:" + model)
    println("Threads:" + numThreads)
    println("Jobs:" + jobs.size.toString)
    println("Dataset:" + datasetFilepath)
    println("Repetitions:" + numRepetitions)

    //implicit val ec = concurrent.ExecutionContext.fromExecutorService(Executors.newWorkStealingPool(numThreads))
    implicit val ec = concurrent.ExecutionContext.fromExecutorService(Executors.newFixedThreadPool(numThreads))

    val futures = jobs.map(x => Future {
        val tid = Thread.currentThread().getId
        println(s"=== ${tid}: STARTING ${x.idd} / ${jobs.size} - ${x.model_type} ===")
        val result = eval(x)
        println(s"=== ${tid}: FINISHED ${x.idd} / ${jobs.size} - ${x.model_type} ===")
        result
    })

    futures.foreach(x => Await.ready(x, Duration.Inf))
    val results = futures.map(x => x.value.last.get)

    val ellapsed = (System.currentTimeMillis() - startedAt) / 1000.0

    results.foreach(println)

    println("Ellapsed time:" + ellapsed)
    println("Bye!")
    spark.stop()
    System.exit(0)    
}

}

