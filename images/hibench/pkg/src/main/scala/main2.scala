package br.com.wespa.ngd.spark.automl

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

case class Job2(idd: Int, data: DataFrame, model_type: String, model_params: Map[String, String])
case class Result2(acc: Double, job: Job2)

object Tunner2 {

// Default test datasets
val DATASET_CLASSIFICATION = "hdfs://hadoop-primary:9000/classification_dataset.libsvm"
val DATASET_CLUSTERING = "hdfs://hadoop-primary:9000/clustering_dataset.libsvm"
val DATASET_REGRESSION = "hdfs://hadoop-primary:9000/regression_dataset.libsvm"


// Regression types
val TYPE_GRADIENT_BOOSTED_TREES_REGRESSION = "gradient_boosted_trees_regression"
val TYPE_FACTORIZATION_MACHINE_REGRESSION = "factorization_machine_regression"
val TYPE_DECISION_TREE_REGRESSION = "decision_tree_regression"
val TYPE_RANDOM_FOREST_REGRESSION = "random_forest_regression"
val TYPE_LINEAR_REGRESSION = "linear_regression"


// Classification types
val TYPE_GRADIENT_BOOSTED_TREES_CLASSIFIER = "gradient_boosted_trees_classifier"
val TYPE_FACTORIZATION_MACHINE_CLASSIFIER = "factorization_machine_classifier"
val TYPE_LOGISTIC_REGRESSION_CLASSIFIER = "logistic_regression_classifier"
val TYPE_SUPPORT_VECTOR_CLASSIFIER = "support_vector_classifier"
val TYPE_RANDOM_FOREST_CLASSIFIER = "random_forest_classifier"
val TYPE_DECISION_TREE_CLASSIFIER = "decision_tree_classifier"
val TYPE_NAIVE_BAYES_CLASSIFIER = "naive_bayes_classifier"
val TYPE_MLP_CLASSIFIER = "mlp_classifier"


// Clustering types
val TYPE_KMEANS_CLUSTERING = "kmeans_clustering"


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
    val data = spark.read
        .format("libsvm")
        .option("numFeatures", 30)
        .load(filepath)
    
    data.cache()

    println("Counting dataset to force cache creation")
    data.count()

    return data
}

def eval(job: Job2): Result2 = {


    // Classification
    if (job.model_type == TYPE_LOGISTIC_REGRESSION_CLASSIFIER)
        return eval_logistic_regression_classifier(job)
        
    else if (job.model_type == TYPE_DECISION_TREE_CLASSIFIER)
        return eval_decision_tree_classifier(job)
    
    else if (job.model_type == TYPE_RANDOM_FOREST_CLASSIFIER)
        return eval_random_forest_classifier(job)
        
    else if (job.model_type == TYPE_GRADIENT_BOOSTED_TREES_CLASSIFIER)
        return eval_gradient_boosted_trees_classifier(job)
    
    else if (job.model_type == TYPE_MLP_CLASSIFIER)
        return eval_mlp_classifier(job)
    
    else if (job.model_type == TYPE_NAIVE_BAYES_CLASSIFIER)
        return eval_naive_bayes_classifier(job)
    
    else if (job.model_type == TYPE_FACTORIZATION_MACHINE_CLASSIFIER)
        return eval_factorization_machine_classifier(job)
    
    else if (job.model_type == TYPE_SUPPORT_VECTOR_CLASSIFIER)
        return eval_support_vector_classifier(job)
    

    // Regression
    else if (job.model_type == TYPE_LINEAR_REGRESSION)
        return eval_linear_regression(job)
    
    else if (job.model_type == TYPE_DECISION_TREE_REGRESSION)
        return eval_decision_tree_regression(job)
    
    else if (job.model_type == TYPE_RANDOM_FOREST_REGRESSION)
        return eval_random_forest_regression(job)
    
    else if (job.model_type == TYPE_GRADIENT_BOOSTED_TREES_REGRESSION)
        return eval_gradient_boosted_trees_regression(job)
    
    else if (job.model_type == TYPE_FACTORIZATION_MACHINE_REGRESSION)
        return eval_factorization_machine_regression(job)
    

    // Clustering
    else if (job.model_type == TYPE_KMEANS_CLUSTERING)
        return eval_kmeans_clustering(job)
    

    // Error
    else
        throw new RuntimeException("Invalid model_type: " + job.model_type)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Eval Classifiers
///////////////////////////////////////////////////////////////////////////////////////////

def eval_support_vector_classifier(job: Job2): Result2 = {
    
    val p = job.model_params
    val regParam = p("regParam").toDouble

    // Prepare the data
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    // Create the model trainer
    val svc = new LinearSVC()
        .setMaxIter(10)
        .setRegParam(regParam)

    // Train
    val model = svc.fit(trainingData)

    // Test
    val result = model.transform(testData)

    val predictionAndLabels = result.select("prediction", "label")
    val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictionAndLabels)

    return Result2(accuracy, job)
}

def eval_factorization_machine_classifier(job: Job2): Result2 = {
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val p = job.model_params
    val factorSize = p("factorSize").toInt
    val regParam = p("regParam").toDouble

    val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol("indexedLabel")
        .fit(job.data)
    
    val featureScaler = new MinMaxScaler()
        .setInputCol("features")
        .setOutputCol("scaledFeatures")
        .fit(job.data)

    val fm = new FMClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("scaledFeatures")
        .setFactorSize(factorSize)
        .setRegParam(regParam)
        .setStepSize(0.001)

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

    val accuracy = evaluator.evaluate(predictions)

    return Result2(accuracy, job)
}

def eval_naive_bayes_classifier(job: Job2): Result2 = {
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    // Create and train the model
    val model = new NaiveBayes().fit(trainingData)

    // Select example rows to display.
    val predictions = model.transform(testData)

    // Select (prediction, true label) and compute test error
    val evaluator = new MulticlassClassificationEvaluator()
        .setLabelCol("label")
        .setPredictionCol("prediction")
        .setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)

    return Result2(accuracy, job)
}

def eval_mlp_classifier(job: Job2): Result2 = {
    val p = job.model_params
    
    val hiddenNeurons = p("hiddenNeurons").toInt

    // Prepare the dataset
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val inputFeatures = trainingData.head().getAs[org.apache.spark.ml.linalg.SparseVector](1).size
    val outputClasses = 2

    // Create the model
    val layers = Array[Int](inputFeatures, hiddenNeurons, outputClasses)
    val trainer = new MultilayerPerceptronClassifier()
        .setLayers(layers)
        .setBlockSize(128)
        .setMaxIter(1000)

    // Train
    val model = trainer.fit(trainingData)

    // Test
    val result = model.transform(testData)
    val predictionAndLabels = result.select("prediction", "label")
    val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictionAndLabels)

    return Result2(accuracy, job)
}

def eval_gradient_boosted_trees_classifier(job: Job2): Result2 = {
    val p = job.model_params
    
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    val labelIndexer = new StringIndexer().setInputCol("label").setOutputCol("indexedLabel").fit(job.data)
    val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(4).fit(job.data)
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val rf = new GBTClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("indexedFeatures")
        .setMaxIter(100)
        .setMaxDepth(maxDepth)
        .setMaxBins(maxBins)

    val labelConverter = new IndexToString().setInputCol("prediction").setOutputCol("predictedLabel").setLabels(labelIndexer.labelsArray(0))
    val pipeline = new Pipeline().setStages(Array(labelIndexer, featureIndexer, rf, labelConverter))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new MulticlassClassificationEvaluator().setLabelCol("indexedLabel").setPredictionCol("prediction").setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)

    return Result2(accuracy, job)
}

def eval_random_forest_classifier(job: Job2): Result2 = {
    val p = job.model_params
    
    val numTrees = p("trees").toInt
    val impurity = p("impurity")
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    val labelIndexer = new StringIndexer().setInputCol("label").setOutputCol("indexedLabel").fit(job.data)
    val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(4).fit(job.data)
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val rf = new RandomForestClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("indexedFeatures")
        .setImpurity(impurity)
        .setMaxDepth(maxDepth)
        .setMaxBins(maxBins)
        .setNumTrees(numTrees)

    val labelConverter = new IndexToString().setInputCol("prediction").setOutputCol("predictedLabel").setLabels(labelIndexer.labelsArray(0))
    val pipeline = new Pipeline().setStages(Array(labelIndexer, featureIndexer, rf, labelConverter))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new MulticlassClassificationEvaluator().setLabelCol("indexedLabel").setPredictionCol("prediction").setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)

    return Result2(accuracy, job)
}

def eval_decision_tree_classifier(job: Job2): Result2 = {
    val p = job.model_params
    
    //val categoricalFeaturesInfo = decode_categories(p("categoricalFeatures"))
    //val numClasses = p("numClasses").toInt
    val impurity = p("impurity")
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    val labelIndexer = new StringIndexer().setInputCol("label").setOutputCol("indexedLabel").fit(job.data)
    val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(4).fit(job.data)
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val dt = new DecisionTreeClassifier()
        .setLabelCol("indexedLabel")
        .setFeaturesCol("indexedFeatures")
        .setImpurity(impurity)
        .setMaxDepth(maxDepth)
        .setMaxBins(maxBins)

    val labelConverter = new IndexToString().setInputCol("prediction").setOutputCol("predictedLabel").setLabels(labelIndexer.labelsArray(0))
    val pipeline = new Pipeline().setStages(Array(labelIndexer, featureIndexer, dt, labelConverter))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new MulticlassClassificationEvaluator().setLabelCol("indexedLabel").setPredictionCol("prediction").setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)

    return Result2(accuracy, job)
}

def eval_logistic_regression_classifier(job: Job2): Result2 = {

    val p = job.model_params
    val reg = p("reg").toDouble
    val elasticNet = p("elasticNet").toDouble

    var start = System.currentTimeMillis
    val model = new LogisticRegression().setMaxIter(1000).setRegParam(reg).setElasticNetParam(elasticNet).fit(job.data)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    val auroc = model.binarySummary.areaUnderROC

    return Result2(auroc, job)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Eval Regressions
///////////////////////////////////////////////////////////////////////////////////////////

def eval_linear_regression(job: Job2): Result2 = {

    val p = job.model_params
    val reg = p("reg").toDouble
    val elasticNet = p("elasticNet").toDouble

    var start = System.currentTimeMillis
    val model = new LinearRegression().setMaxIter(1000).setRegParam(reg).setElasticNetParam(elasticNet).fit(job.data)
    val trainingTime = (System.currentTimeMillis - start) / 1000.00

    val rmse = model.summary.rootMeanSquaredError

    return Result2(rmse, job)
}

def eval_decision_tree_regression(job: Job2): Result2 = {
    val p = job.model_params
    
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(4).fit(job.data)
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val dt = new DecisionTreeRegressor()
        .setLabelCol("label")
        .setFeaturesCol("indexedFeatures")
        .setMaxDepth(maxDepth)
        .setMaxBins(maxBins)

    val pipeline = new Pipeline().setStages(Array(featureIndexer, dt))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new RegressionEvaluator().setLabelCol("label").setPredictionCol("prediction").setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)

    return Result2(rmse, job)
}

def eval_random_forest_regression(job: Job2): Result2 = {
    val p = job.model_params
    
    val numTrees = p("trees").toInt
    //val impurity = p("impurity")
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(4).fit(job.data)
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val rf = new RandomForestRegressor()
        .setLabelCol("label")
        .setFeaturesCol("indexedFeatures")
        //.setImpurity(impurity)
        .setMaxDepth(maxDepth)
        .setMaxBins(maxBins)
        .setNumTrees(numTrees)

    val pipeline = new Pipeline().setStages(Array(featureIndexer, rf))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new RegressionEvaluator().setLabelCol("label").setPredictionCol("prediction").setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)

    return Result2(rmse, job)
}

def eval_gradient_boosted_trees_regression(job: Job2): Result2 = {
    val p = job.model_params
    
    val maxDepth = p("depth").toInt
    val maxBins = p("bins").toInt

    val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(4).fit(job.data)
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val rf = new GBTRegressor()
        .setLabelCol("label")
        .setFeaturesCol("indexedFeatures")
        .setMaxIter(100)
        .setMaxDepth(maxDepth)
        .setMaxBins(maxBins)

    val pipeline = new Pipeline().setStages(Array(featureIndexer, rf))

    // Train
    val model = pipeline.fit(trainingData)

    // Test
    val predictions = model.transform(testData)
    val evaluator = new RegressionEvaluator().setLabelCol("label").setPredictionCol("prediction").setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)
    
    return Result2(rmse, job)
}

def eval_factorization_machine_regression(job: Job2): Result2 = {
    val Array(trainingData, testData) = job.data.randomSplit(Array(0.7, 0.3))

    val p = job.model_params
    val factorSize = p("factorSize").toInt
    val regParam = p("regParam").toDouble

    val featureScaler = new MinMaxScaler().setInputCol("features").setOutputCol("scaledFeatures").fit(job.data)

    val fm = new FMRegressor()
        .setLabelCol("label")
        .setFeaturesCol("scaledFeatures")
        .setFactorSize(factorSize)
        .setRegParam(regParam)
        .setStepSize(0.001)

    val pipeline = new Pipeline().setStages(Array(featureScaler, fm))

    // Train model.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)
    val evaluator = new RegressionEvaluator().setLabelCol("label").setPredictionCol("prediction").setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)

    return Result2(rmse, job)
}


///////////////////////////////////////////////////////////////////////////////////////////
// Eval Clustering
///////////////////////////////////////////////////////////////////////////////////////////

def eval_kmeans_clustering(job: Job2): Result2 = {

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


///////////////////////////////////////////////////////////////////////////////////////////
// Add Classification Jobs
///////////////////////////////////////////////////////////////////////////////////////////

def add_support_vector_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valRegParam = Array(0, 0.15, 0.30, 0.45, 0.6, 0.75, 0.9) // 7

    for (repetition <- 1 to repetitions) {
        for (regParam <- valRegParam) {
            jobs.append(Job2(jobs.size, data, TYPE_SUPPORT_VECTOR_CLASSIFIER, Map(
                "regParam" -> regParam.toString,
            )))
        }
    }
}

def add_factorization_machine_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {
    val valFactorSize = Array(2,4,8,16) // 4
    val valRegParam = Array(0, 0.25, 0.5) // 3

    for (repetition <- 1 to repetitions) {
        for (factorSize <- valFactorSize) {
            for (regParam <- valRegParam) {
                jobs.append(Job2(jobs.size, data, TYPE_FACTORIZATION_MACHINE_CLASSIFIER, Map(
                    "factorSize" -> factorSize.toString,
                    "regParam" -> regParam.toString,
                )))
            }
        }
    }    
}

def add_naive_bayes_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {
    val valTypes = Array("multinomial", "complement", "bernoulli", "gaussian") // 4

    for (repetition <- 1 to repetitions) {
        for (types <- valTypes) {
            jobs.append(Job2(jobs.size, data, TYPE_NAIVE_BAYES_CLASSIFIER, Map(
                "types" -> types.toString,
            )))
        }
    }    
}

def add_mlp_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valHiddenNeurons = Array(1,3,7,13,31,51) // 6

    for (repetition <- 1 to repetitions) {
        for (hiddenNeurons <- valHiddenNeurons) {
            jobs.append(Job2(jobs.size, data, TYPE_MLP_CLASSIFIER, Map(
                "hiddenNeurons" -> hiddenNeurons.toString,
            )))
        }
    }
}

def add_gradient_boosted_trees_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valBins = Array(4, 8, 16, 32) // 4
    val valDepths = Array(3, 5) // 2

    for (repetition <- 1 to repetitions) {
        for (bins <- valBins) {
            for (depth <- valDepths) {
                jobs.append(Job2(jobs.size, data, TYPE_GRADIENT_BOOSTED_TREES_CLASSIFIER, Map(
                    "bins" -> bins.toString,
                    "depth" -> depth.toString,
                )))
            }
        }
    }
}

def add_random_forest_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valImpurity = Array("gini", "entropy") // 2
    val valBins = Array(32, 64, 128, 256) // 4
    val valTrees = Array(10, 20, 40) // 3
    val valDepths = Array(3, 5, 7) // 3

    for (repetition <- 1 to repetitions) {
        for (impurity <- valImpurity) {
            for (bins <- valBins) {
                for (trees <- valTrees) {
                    for (depth <- valDepths) {
                        jobs.append(Job2(jobs.size, data, TYPE_RANDOM_FOREST_CLASSIFIER, Map(
                            "impurity" -> impurity,
                            "bins" -> bins.toString,
                            "trees" -> trees.toString,
                            "depth" -> depth.toString,
                            //"categoricalFeatures" -> categoricalFeatures.toString,
                            // "featureSubsetStrategy" -> featureSubsetStrategy.toString,
                            // "numClasses" -> numClasses.toString
                        )))
                    }
                }
            }
        }
    }
}

def add_decision_tree_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {
    
    val valImpurity = Array("gini", "entropy") // 2
    val valBins = Array(32, 64, 128, 256) // 4
    val valDepths = Array(3, 5, 7) // 3

    for (repetition <- 1 to repetitions) {
        for (impurity <- valImpurity) {
            for (bins <- valBins) {
                for (depth <- valDepths) {
                    jobs.append(Job2(jobs.size, data, TYPE_DECISION_TREE_CLASSIFIER, Map(
                        "impurity" -> impurity,
                        "bins" -> bins.toString,
                        "depth" -> depth.toString,
                        //"categoricalFeatures" -> categoricalFeatures,
                        //"numClasses" -> numClasses.toString
                    )))
                }
            }
        }
    }
}

def add_logistic_regression_classifier(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valReg = Array(0.3, 0.6, 0.9) // 3
    val valElasticNet = Array(0.2, 0.4, 0.6, 0.8) // 4

    for (repetition <- 1 to repetitions) {
        for (reg <- valReg) {
            for (elasticNet <- valElasticNet) {
                jobs.append(Job2(jobs.size, data, TYPE_LOGISTIC_REGRESSION_CLASSIFIER, Map(
                    "reg" -> reg.toString,
                    "elasticNet" -> elasticNet.toString
                )))
            }
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////
// Add Regression Jobs
//////////////////////////////////////////////////////////////////////////////////////////

def add_linear_regression(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valReg = Array(0.3, 0.6, 0.9) // 3
    val valElasticNet = Array(0.2, 0.4, 0.6, 0.8) // 4

    for (repetition <- 1 to repetitions) {
        for (reg <- valReg) {
            for (elasticNet <- valElasticNet) {
                jobs.append(Job2(jobs.size, data, TYPE_LINEAR_REGRESSION, Map(
                    "reg" -> reg.toString,
                    "elasticNet" -> elasticNet.toString
                )))
            }
        }
    }
}

def add_decision_tree_regression(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {
    
    //val valImpurity = Array("gini", "entropy") // 2
    val valBins = Array(32, 64, 128, 256) // 4
    val valDepths = Array(3, 5, 7) // 3

    for (repetition <- 1 to repetitions) {
        //for (impurity <- valImpurity) {
            for (bins <- valBins) {
                for (depth <- valDepths) {
                    jobs.append(Job2(jobs.size, data, TYPE_DECISION_TREE_REGRESSION, Map(
          //              "impurity" -> impurity,
                        "bins" -> bins.toString,
                        "depth" -> depth.toString,
                    )))
                }
            }
        //}
    }
}

def add_random_forest_regression(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    //val valImpurity = Array("gini", "entropy") // 2
    val valBins = Array(32, 64, 128, 256) // 4
    val valTrees = Array(10, 20, 40) // 3
    val valDepths = Array(3, 5, 7) // 3

    for (repetition <- 1 to repetitions) {
        //for (impurity <- valImpurity) {
            for (bins <- valBins) {
                for (trees <- valTrees) {
                    for (depth <- valDepths) {
                        jobs.append(Job2(jobs.size, data, TYPE_RANDOM_FOREST_REGRESSION, Map(
                            //"impurity" -> impurity,
                            "bins" -> bins.toString,
                            "trees" -> trees.toString,
                            "depth" -> depth.toString,
                        )))
                    }
                }
            }
        //}
    }
}

def add_gradient_boosted_trees_regression(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valBins = Array(4, 8, 16, 32) // 4
    val valDepths = Array(3, 5) // 2

    for (repetition <- 1 to repetitions) {
        for (bins <- valBins) {
            for (depth <- valDepths) {
                jobs.append(Job2(jobs.size, data, TYPE_GRADIENT_BOOSTED_TREES_REGRESSION, Map(
                    "bins" -> bins.toString,
                    "depth" -> depth.toString,
                )))
            }
        }
    }
}

def add_factorization_machine_regression(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {
    val valFactorSize = Array(2,4,8,16) // 4
    val valRegParam = Array(0, 0.25, 0.5) // 3

    for (repetition <- 1 to repetitions) {
        for (factorSize <- valFactorSize) {
            for (regParam <- valRegParam) {
                jobs.append(Job2(jobs.size, data, TYPE_FACTORIZATION_MACHINE_REGRESSION, Map(
                    "factorSize" -> factorSize.toString,
                    "regParam" -> regParam.toString,
                )))
            }
        }
    }    
}


///////////////////////////////////////////////////////////////////////////////////////////
// Add Clustering Jobs
///////////////////////////////////////////////////////////////////////////////////////////

def add_kmeans_clustering(data: DataFrame, repetitions: Int, jobs: ListBuffer[Job2]): Unit = {

    val valClusters = Array(2, 3, 4, 5, 6, 7, 8, 9, 10) // 9

    for (repetition <- 1 to repetitions) {
        for (clusters <- valClusters) {
            jobs.append(Job2(jobs.size, data, TYPE_KMEANS_CLUSTERING, Map(
                "clusters" -> clusters.toString,
            )))
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////
// Main interface
///////////////////////////////////////////////////////////////////////////////////////////

def main(args: Array[String]): Unit = {

    var datasetFilepath = DATASET_CLASSIFICATION
    var numRepetitions = 10
    var numThreads = 1
    var model = "lrc"

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

    val spark = SparkSession.builder.appName("AutoML").getOrCreate()
    val data = load_dataset(spark, datasetFilepath)
    val jobs = ListBuffer[Job2]()


    // Add classification models
    if (model == "svc" || model == "all" )
        add_support_vector_classifier(data, numRepetitions, jobs)

    if (model == "fmc" || model == "all" )
        add_factorization_machine_classifier(data, numRepetitions, jobs)

    if (model == "nbc" || model == "all" )
        add_naive_bayes_classifier(data, numRepetitions, jobs)

    if (model == "mlpc" || model == "all" )
        add_mlp_classifier(data, numRepetitions, jobs)

    if (model == "gbtc" || model == "all" )
        add_gradient_boosted_trees_classifier(data, numRepetitions, jobs)
    
    if (model == "rfc" || model == "all" )
        add_random_forest_classifier(data, numRepetitions, jobs)
    
    if (model == "dtc" || model == "all" )
        add_decision_tree_classifier(data, numRepetitions, jobs)
    
    if (model == "lrc" || model == "all" )
        add_logistic_regression_classifier(data, numRepetitions, jobs)
    

    // Add regression models
    if (model == "lr" || model == "all" )
        add_linear_regression(data, numRepetitions, jobs)
    
    if (model == "dtr" || model == "all" )
        add_decision_tree_regression(data, numRepetitions, jobs)
    
    if (model == "rfr" || model == "all" )
        add_random_forest_regression(data, numRepetitions, jobs)
    
    if (model == "gbtr" || model == "all" )
        add_gradient_boosted_trees_regression(data, numRepetitions, jobs)
    
    if (model == "fmr" || model == "all" )
        add_factorization_machine_regression(data, numRepetitions, jobs)
    

    // Add clustering models
    if (model == "kmeans" || model == "all" )
        add_kmeans_clustering(data, numRepetitions, jobs)
    

    println("Model: " + model)
    println("Threads: " + numThreads)
    println("Jobs: " + jobs.size.toString)
    println("Dataset: " + datasetFilepath)
    println("Repetitions: " + numRepetitions)
    println("Partitions: " + data.rdd.getNumPartitions)

    val startedAt = System.currentTimeMillis()

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

    println("Ellapsed time: " + ellapsed)
    println("Done!")
    spark.stop()
    System.exit(0)
}

}

