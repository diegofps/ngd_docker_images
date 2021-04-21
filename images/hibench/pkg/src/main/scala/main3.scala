package br.com.wespa.ngd.spark.automl2

// Spark utils
import scala.collection.mutable.ListBuffer
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.DataFrame

// Concurrency and Futures
import scala.concurrent.duration.Duration
import java.util.concurrent.Executors
import scala.concurrent._

// Decision Tree
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.DecisionTreeClassificationModel
import org.apache.spark.ml.classification.DecisionTreeClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}

// Random Forest
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.{RandomForestClassificationModel, RandomForestClassifier}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}

// Logistic Regression
import org.apache.spark.ml.classification.LogisticRegression

// K-Means
import org.apache.spark.ml.clustering.KMeans
import org.apache.spark.ml.evaluation.ClusteringEvaluator

// Gradient Boosted Trees
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.{GBTClassificationModel, GBTClassifier}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}

// MLP
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator

// Naive Bayes
import org.apache.spark.ml.classification.NaiveBayes
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator

// Factorization Machine
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.{FMClassificationModel, FMClassifier}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, MinMaxScaler, StringIndexer}

// Linear SVC
import org.apache.spark.ml.classification.LinearSVC

// Linerar Regression
import org.apache.spark.ml.regression.LinearRegression

// Decision Tree Regression
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.VectorIndexer
import org.apache.spark.ml.regression.DecisionTreeRegressionModel
import org.apache.spark.ml.regression.DecisionTreeRegressor

// Random Forest regressaion
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.VectorIndexer
import org.apache.spark.ml.regression.{RandomForestRegressionModel, RandomForestRegressor}

// Gradient Boosted Trees
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.VectorIndexer
import org.apache.spark.ml.regression.{GBTRegressionModel, GBTRegressor}

// Factorization Machine Regression
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.MinMaxScaler
import org.apache.spark.ml.regression.{FMRegressionModel, FMRegressor}


///////////////////////////////////////////////////////////////////////////////////////////
// Extra types and utils
///////////////////////////////////////////////////////////////////////////////////////////

case class Params(
    appName: String,
    dataset: String, 
    partitionSize: Int,
    model: String, 
    maxIters: Int,
    regParam: Double,
    factorSize: Int,
    numHiddenNeurons: Int,
    blockSize: Int,
    maxDepth: Int,
    maxBins: Int,
    numTrees: Int,
    impurity: String,
    elasticNet: Double,
    stepSize: Double,
    numClusters: Int,
    maxCategories: Int)

///////////////////////////////////////////////////////////////////////////////////////////
// Main class object
///////////////////////////////////////////////////////////////////////////////////////////

object Tunner2 {

///////////////////////////////////////////////////////////////////////////////////////////
// Eval Classifiers
///////////////////////////////////////////////////////////////////////////////////////////

def eval_support_vector_classifier(data: DataFrame, p: Params): Double = {
    
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val svc = new LinearSVC()
        .setMaxIter(p.maxIters)
        .setRegParam(p.regParam)

    val model = svc.fit(trainingData)
    val result = model.transform(testData)

    val predictionAndLabels = result.select("prediction", "label")
    val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")

    return evaluator.evaluate(predictionAndLabels)
}

def eval_factorization_machine_classifier(data: DataFrame, p: Params): Double = {

    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol("indexedLabel")
        .fit(data)
    
    val featureScaler = new MinMaxScaler()
        .setInputCol("features")
        .setOutputCol("scaledFeatures")
        .fit(data)

    val fm = new FMClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("scaledFeatures")
        .setFactorSize(p.factorSize)
        .setRegParam(p.regParam)
        .setStepSize(p.stepSize)

    val labelConverter = new IndexToString()
        .setInputCol("prediction")
        .setOutputCol("predictedLabel")
        .setLabels(labelIndexer.labelsArray(0))

    val pipeline = new Pipeline()
        .setStages(Array(labelIndexer, featureScaler, fm, labelConverter))

    // Train model.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select (prediction, true label) and compute test accuracy.
    val evaluator = new MulticlassClassificationEvaluator()
        .setLabelCol("indexedLabel")
        .setPredictionCol("prediction")
        .setMetricName("accuracy")

    return evaluator.evaluate(predictions)
}

def eval_naive_bayes_classifier(data: DataFrame, p: Params): Double = {

    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Create and train the model
    val model = new NaiveBayes().fit(trainingData)

    // Select example rows to display.
    val predictions = model.transform(testData)

    // Select (prediction, true label) and compute test error
    val evaluator = new MulticlassClassificationEvaluator()
        .setLabelCol("label")
        .setPredictionCol("prediction")
        .setMetricName("accuracy")
    
    return evaluator.evaluate(predictions)
}

def eval_mlp_classifier(data: DataFrame, p: Params): Double = {
    
    // Prepare the dataset
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val inputFeatures = trainingData.head().getAs[org.apache.spark.ml.linalg.SparseVector](1).size
    val outputClasses = 2

    // Create the model
    val layers = Array[Int](inputFeatures, p.numHiddenNeurons, outputClasses)
    val trainer = new MultilayerPerceptronClassifier()
        .setLayers(layers)
        .setBlockSize(p.blockSize)
        .setMaxIter(p.maxIters)

    // Train
    val model = trainer.fit(trainingData)

    // Test
    val result = model.transform(testData)
    val predictionAndLabels = result.select("prediction", "label")
    val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")

    return evaluator.evaluate(predictionAndLabels)
}

def eval_gradient_boosted_trees_classifier(data: DataFrame, p: Params): Double = {
    
    val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol("indexedLabel")
        .fit(data)

    val featureIndexer = new VectorIndexer()
        .setInputCol("features")
        .setOutputCol("indexedFeatures")
        .setMaxCategories(4)
        .fit(data)
    
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val rf = new GBTClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("indexedFeatures")
        .setMaxIter(p.maxIters)
        .setMaxDepth(p.maxDepth)
        .setMaxBins(p.maxBins)

    val labelConverter = new IndexToString()
        .setInputCol("prediction")
        .setOutputCol("predictedLabel")
        .setLabels(labelIndexer.labelsArray(0))
    
    val pipeline = new Pipeline()
        .setStages(Array(labelIndexer, featureIndexer, rf, labelConverter))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new MulticlassClassificationEvaluator()
        .setLabelCol("indexedLabel")
        .setPredictionCol("prediction")
        .setMetricName("accuracy")

    return evaluator.evaluate(predictions)
}

def eval_random_forest_classifier(data: DataFrame, p: Params): Double = {
    
    val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol("indexedLabel")
        .fit(data)

    val featureIndexer = new VectorIndexer()
        .setInputCol("features")
        .setOutputCol("indexedFeatures")
        .setMaxCategories(4)
        .fit(data)

    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val rf = new RandomForestClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("indexedFeatures")
        .setImpurity(p.impurity)
        .setMaxDepth(p.maxDepth)
        .setMaxBins(p.maxBins)
        .setNumTrees(p.numTrees)

    val labelConverter = new IndexToString()
        .setInputCol("prediction")
        .setOutputCol("predictedLabel")
        .setLabels(labelIndexer.labelsArray(0))

    val pipeline = new Pipeline()
        .setStages(Array(labelIndexer, featureIndexer, rf, labelConverter))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)

    val evaluator = new MulticlassClassificationEvaluator()
        .setLabelCol("indexedLabel")
        .setPredictionCol("prediction")
        .setMetricName("accuracy")
    
    return evaluator.evaluate(predictions)
}

def eval_decision_tree_classifier(data: DataFrame, p: Params): Double = {
    
    val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol("indexedLabel")
        .fit(data)
    
    val featureIndexer = new VectorIndexer()
        .setInputCol("features")
        .setOutputCol("indexedFeatures")
        .setMaxCategories(4)
        .fit(data)
    
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val dt = new DecisionTreeClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("indexedFeatures")
        .setImpurity(p.impurity)
        .setMaxDepth(p.maxDepth)
        .setMaxBins(p.maxBins)

    val labelConverter = new IndexToString()
        .setInputCol("prediction")
        .setOutputCol("predictedLabel")
        .setLabels(labelIndexer.labelsArray(0))
    
    val pipeline = new Pipeline()
        .setStages(Array(labelIndexer, featureIndexer, dt, labelConverter))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)

    val evaluator = new MulticlassClassificationEvaluator()
        .setLabelCol("indexedLabel")
        .setPredictionCol("prediction")
        .setMetricName("accuracy")
    
    return evaluator.evaluate(predictions)
}

def eval_logistic_regression_classifier(data: DataFrame, p: Params): Double = {

    val model = new LogisticRegression()
        .setMaxIter(p.maxIters)
        .setRegParam(p.regParam)
        .setElasticNetParam(p.elasticNet)
        .fit(data)

    return model.binarySummary.areaUnderROC
}


///////////////////////////////////////////////////////////////////////////////////////////
// Eval Regressions
///////////////////////////////////////////////////////////////////////////////////////////

def eval_linear_regression(data: DataFrame, p: Params): Double = {

    val model = new LinearRegression()
        .setMaxIter(p.maxIters)
        .setRegParam(p.regParam)
        .setElasticNetParam(p.elasticNet)
        .fit(data)

    return model.summary.rootMeanSquaredError
}

def eval_decision_tree_regression(data: DataFrame, p: Params): Double = {
    
    val featureIndexer = new VectorIndexer()
        .setInputCol("features")
        .setOutputCol("indexedFeatures")
        .setMaxCategories(p.maxCategories)
        .fit(data)
    
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val dt = new DecisionTreeRegressor()
        .setLabelCol("label")
        .setFeaturesCol("indexedFeatures")
        .setMaxDepth(p.maxDepth)
        .setMaxBins(p.maxBins)

    val pipeline = new Pipeline().setStages(Array(featureIndexer, dt))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new RegressionEvaluator()
        .setLabelCol("label")
        .setPredictionCol("prediction")
        .setMetricName("rmse")
    
    return evaluator.evaluate(predictions)
}

def eval_random_forest_regression(data: DataFrame, p: Params): Double = {
    
    val featureIndexer = new VectorIndexer()
        .setInputCol("features")
        .setOutputCol("indexedFeatures")
        .setMaxCategories(4)
        .fit(data)
    
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val rf = new RandomForestRegressor()
        .setLabelCol("label")
        .setFeaturesCol("indexedFeatures")
        .setMaxDepth(p.maxDepth)
        .setMaxBins(p.maxBins)
        .setNumTrees(p.numTrees)

    val pipeline = new Pipeline()
        .setStages(Array(featureIndexer, rf))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)

    val evaluator = new RegressionEvaluator()
        .setLabelCol("label")
        .setPredictionCol("prediction")
        .setMetricName("rmse")

    return evaluator.evaluate(predictions)
}

def eval_gradient_boosted_trees_regression(data: DataFrame, p: Params): Double = {

    val featureIndexer = new VectorIndexer()
        .setInputCol("features")
        .setOutputCol("indexedFeatures")
        .setMaxCategories(4)
        .fit(data)
    
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    val rf = new GBTRegressor()
        .setLabelCol("label")
        .setFeaturesCol("indexedFeatures")
        .setMaxIter(p.maxIters)
        .setMaxDepth(p.maxDepth)
        .setMaxBins(p.maxBins)

    val pipeline = new Pipeline()
        .setStages(Array(featureIndexer, rf))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)

    val evaluator = new RegressionEvaluator()
        .setLabelCol("label")
        .setPredictionCol("prediction")
        .setMetricName("rmse")

    return evaluator.evaluate(predictions)
}

def eval_factorization_machine_regression(data: DataFrame, p: Params): Double = {

    // Prepare the data
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Build the model
    val featureScaler = new MinMaxScaler()
        .setInputCol("features")
        .setOutputCol("scaledFeatures")
        .fit(data)

    val fm = new FMRegressor()
        .setLabelCol("label")
        .setFeaturesCol("scaledFeatures")
        .setFactorSize(p.factorSize)
        .setRegParam(p.regParam)
        .setStepSize(p.stepSize)

    val pipeline = new Pipeline()
        .setStages(Array(featureScaler, fm))

    // Train the model
    val model = pipeline.fit(trainingData)

    // Evaluate the model
    val predictions = model.transform(testData)

    val evaluator = new RegressionEvaluator()
        .setLabelCol("label")
        .setPredictionCol("prediction")
        .setMetricName("rmse")

    return evaluator.evaluate(predictions)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Eval Clustering
///////////////////////////////////////////////////////////////////////////////////////////

def eval_kmeans_clustering(data: DataFrame, p: Params): Double = {

    // Create and train the model
    val model = new KMeans()
        .setK(p.numClusters)
        .fit(data)
    
    // Evaluate the model
    val predictions = model.transform(data)
    val evaluator = new ClusteringEvaluator()

    return evaluator.evaluate(predictions)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Utils
///////////////////////////////////////////////////////////////////////////////////////////

def load_dataset(spark: SparkSession, p: Params): DataFrame = {
    val data = spark.read.format("libsvm").load(p.dataset)
    val partitionsBefore = data.rdd.getNumPartitions

    if (p.partitionSize > 0)
    {
        val numPartitions = p.partitionSize
        val data3 = data.repartition(numPartitions)
        val partitionsNow = data3.rdd.getNumPartitions
        data3.cache

        println("Partitions before: %d, Partitions now: %d", partitionsBefore, partitionsNow)
        return data3
    }
    else
    {
        data.cache

        println("Partitions before: %d, Partitions now: %d", partitionsBefore, partitionsBefore)
        return data
    }
}

def parse_params(args: Array[String]): Params = {

    var appName = "AutoML2"
    var dataset = "hdfs://bigdata2-primary:9000/classification_dataset.libsvm"
    var partitionSize = 0
    var model = "lrc"
    var maxIters = 1000
    var regParam = 0.1
    var factorSize = 8
    var numHiddenNeurons = 10
    var blockSize = 128
    var maxDepth = 5
    var maxBins = 32
    var numTrees = 5
    var impurity = "gini"
    var elasticNet = 0.2
    var stepSize = 0.001
    var numClusters = 10
    var maxCategories = 4

    for (arg <- args) {

        if (arg.startsWith("-appName="))
            appName = arg.drop("-appName=".length)
        
        else if (arg.startsWith("-dataset="))
            dataset = arg.drop("-dataset=".length)
        
        else if (arg.startsWith("-partitionSize="))
            partitionSize = arg.drop("-partitionSize=".length).toInt
        
        else if (arg.startsWith("-model="))
            model = arg.drop("-model=".length)
        
        else if (arg.startsWith("-maxIters="))
            maxIters = arg.drop("-maxIters=".length).toInt
        
        else if (arg.startsWith("-regParam="))
            regParam = arg.drop("-regParam=".length).toDouble
        
        else if (arg.startsWith("-factorSize="))
            factorSize = arg.drop("-factorSize=".length).toInt
        
        else if (arg.startsWith("-numHiddenNeurons="))
            numHiddenNeurons = arg.drop("-numHiddenNeurons=".length).toInt
        
        else if (arg.startsWith("-blockSize="))
            blockSize = arg.drop("-blockSize=".length).toInt
        
        else if (arg.startsWith("-maxDepth="))
            maxDepth = arg.drop("-maxDepth=".length).toInt
        
        else if (arg.startsWith("-maxBins="))
            maxBins = arg.drop("-maxBins=".length).toInt
        
        else if (arg.startsWith("-numTrees="))
            numTrees = arg.drop("-numTrees=".length).toInt
        
        else if (arg.startsWith("-impurity="))
            impurity = arg.drop("-impurity=".length)
        
        else if (arg.startsWith("-elasticNet="))
            elasticNet = arg.drop("-elasticNet=".length).toDouble
        
        else if (arg.startsWith("-stepSize="))
            stepSize = arg.drop("-stepSize=".length).toDouble
        
        else if (arg.startsWith("-numClusters="))
            numClusters = arg.drop("-numClusters=".length).toInt
        
        else if (arg.startsWith("-maxCategories="))
            maxCategories = arg.drop("-maxCategories=".length).toInt
        
        else
            println("Invalid argument: " + arg);

    }

    return Params(
        appName,
        dataset,
        partitionSize,
        model, 
        maxIters,
        regParam,
        factorSize,
        numHiddenNeurons,
        blockSize,
        maxDepth,
        maxBins,
        numTrees,
        impurity,
        elasticNet,
        stepSize,
        numClusters,
        maxCategories)

}

///////////////////////////////////////////////////////////////////////////////////////////
// Main interface
///////////////////////////////////////////////////////////////////////////////////////////

def main(args: Array[String]): Unit = {

    val p = parse_params(args);

    println("appName:", p.appName)
    println("dataset:", p.dataset)
    println("partitionSize:", p.partitionSize)
    println("model:", p.model)
    println("maxIters:", p.maxIters)
    println("regParam:", p.regParam)
    println("factorSize:", p.factorSize)
    println("numHiddenNeurons:", p.numHiddenNeurons)
    println("blockSize:", p.blockSize)
    println("maxDepth:", p.maxDepth)
    println("maxBins:", p.maxBins)
    println("numTrees:", p.numTrees)
    println("impurity:", p.impurity)
    println("elasticNet:", p.elasticNet)
    println("stepSize:", p.stepSize)
    println("numClusters:", p.numClusters)
    println("maxCategories:", p.maxCategories)

    val spark = SparkSession.builder.appName(p.appName).getOrCreate()
    val data = load_dataset(spark, p)

    val startedAt = System.currentTimeMillis()
    
    // Classification models
    if (p.model == "svc")
        eval_support_vector_classifier(data, p)

    if (p.model == "fmc")
        eval_factorization_machine_classifier(data, p)

    if (p.model == "nbc")
        eval_naive_bayes_classifier(data, p)

    if (p.model == "mlpc")
        eval_mlp_classifier(data, p)

    if (p.model == "gbtc")
        eval_gradient_boosted_trees_classifier(data, p)
    
    if (p.model == "rfc")
        eval_random_forest_classifier(data, p)
    
    if (p.model == "dtc")
        eval_decision_tree_classifier(data, p)
    
    if (p.model == "lrc")
        eval_logistic_regression_classifier(data, p)
    

    // Add regression models
    if (p.model == "lr")
        eval_linear_regression(data, p)
    
    if (p.model == "dtr")
        eval_decision_tree_regression(data, p)
    
    if (p.model == "rfr")
        eval_random_forest_regression(data, p)
    
    if (p.model == "gbtr")
        eval_gradient_boosted_trees_regression(data, p)
    
    if (p.model == "fmr")
        eval_factorization_machine_regression(data, p)
    

    // Add clustering models
    if (p.model == "kmeans")
        eval_kmeans_clustering(data, p)
    
    val ellapsed = (System.currentTimeMillis() - startedAt) / 1000.0

    println("Ellapsed time: " + ellapsed + " s")
    println("Done!")

    spark.stop()

    System.exit(0)
}

}

