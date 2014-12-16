import gab.opencv.*;

import org.opencv.objdetect.HOGDescriptor;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfPoint;

import org.opencv.core.CvType;

OpenCV opencv;
HOGDescriptor descriptor;
Libsvm classifier;

int nFolds = 3;

PImage before;
String modelFile = "hybrid-face-model.txt";
boolean loadFromFile = false;

void setup() {
  opencv = new OpenCV(this, 50, 50);
  size(opencv.width, opencv.height*2);

  classifier = new Libsvm(this);

  if (loadFromFile) {
    classifier.setNumFeatures(1728);
    classifier.load(dataPath(modelFile));
  } else {


    ArrayList<Sample> samples = loadSamples("train");
    HashMap<String, Float> result =  crossfold(classifier, nFolds, samples);

    println();
    println("========CUMULATIVE TRAINING RESULT ("+nFolds+" folds)================");
    println("accuracy: " + result.get("accuracy"));
    println("precision: " + result.get("precision"));
    println("recall: " + result.get("recall"));
    println("f-measure: " + result.get("fmeasure"));
    println("false positives: " + result.get("false positives"));
    println("false negatives: " + result.get("false negatives"));

    println("saving classifier...");
    classifier.save(modelFile);
    println("saved");
  }
  classifier.reset();

  ClassificationResult testResult = testOnSet(classifier, loadSamples("test"));

  println();
  println("========TEST RESULT ================");
  println("accuracy: " + testResult.getAccuracy());
  println("precision: " + testResult.getPrecision());
  println("recall: " + testResult.getRecall());
  println("f-measure: " + testResult.getFMeasure());
  println("false positives: " + testResult.numFalsePositives());
  println("false negatives: " + testResult.numFalseNegatives());

  noLoop();
}

ArrayList<Sample> loadSamples(String folderName) {
  java.io.File folder = new java.io.File(dataPath(folderName));
  String[] filenames = folder.list();

  ArrayList<Sample> result = new ArrayList<Sample>();

  PImage img;
  for (int i = 0; i < filenames.length; i++) {
    if (filenames[i].equals(".DS_Store")) {
      continue;
    }

    String labelString = split(filenames[i], '-')[0];
    int label = parseInt(labelString);
    img = loadImage(dataPath(folderName + "/" + filenames[i]));
    Sample s = new Sample(featuresForImage(img), label);
    s.setRecordDescription(filenames[i]);
    result.add(s);
  }

  return result;
}


void draw() {
  background(0);
}

float[] featuresForImage(PImage img) {
  // resize the images to a consistent size:
  img.resize(50, 50);
  // load resized image into OpenCV
  opencv.loadImage(img);

  // settings for HoG calculation
  Size winSize = new Size(40, 24);
  Size blockSize = new Size(8, 8);
  Size blockStride = new Size(16, 16);
  Size cellSize = new Size(2, 2);
  int nBins = 9;
  Size winStride = new Size(16, 16);
  Size padding = new Size(0, 0);

  HOGDescriptor descriptor = new HOGDescriptor(winSize, blockSize, blockStride, cellSize, nBins);

  MatOfFloat descriptors = new MatOfFloat();
  MatOfPoint locations = new MatOfPoint();
  descriptor.compute(opencv.getGray(), descriptors, winStride, padding, locations);
  float[] result = descriptors.toArray();
  return result;
}

HashMap crossfold(Classifier classifier, int nFolds, ArrayList<Sample> samples) {
  HashMap<String, Float> result = new HashMap<String, Float>();
  result.put("accuracy", 0.0);
  result.put("precision", 0.0);
  result.put("recall", 0.0);
  result.put("fmeasure", 0.0);
  result.put("false positives", 0.0);
  result.put("false negatives", 0.0);

  ArrayList<ArrayList<Sample>> folds = new ArrayList<ArrayList<Sample>>();
  for (int i = 0; i < nFolds; i++) {
    folds.add(new ArrayList<Sample>());
  }

  for (int i = 0; i < samples.size (); i++) {
    int fold = (int)random(0, nFolds);

    folds.get(fold).add(samples.get(i));
  }

  for (int i = 0; i < folds.size (); i++) {
    ArrayList<Sample> testing = folds.get(i);
    ArrayList<Sample> training = new ArrayList<Sample>();

    for (int j = 0; j < folds.size (); j++) {
      if (j != i) {
        training.addAll(folds.get(j));
      }
    }

    println();
    println("Executing fold " + (i+1) + "...");
    ClassificationResult score = executeFold(classifier, training, testing);

    println("training size: " + training.size() + " testing size: " + testing.size());
    result.put("accuracy", result.get("accuracy") + score.getAccuracy());
    result.put("precision", result.get("precision") + score.getPrecision());
    result.put("recall", result.get("recall") + score.getRecall());
    result.put("fmeasure", result.get("fmeasure") + score.getFMeasure());
    result.put("false positives", result.get("false positives") + score.numFalsePositives());
    result.put("false negatives", result.get("false positives") + score.numFalseNegatives());
  }

  result.put("accuracy", result.get("accuracy")/nFolds);
  result.put("precision", result.get("precision")/nFolds);
  result.put("recall", result.get("recall")/nFolds);
  result.put("fmeasure", result.get("fmeasure")/nFolds);
  result.put("false positives", result.get("false positives")/nFolds);
  result.put("false negatives", result.get("false negatives")/nFolds);

  return result;
}

ClassificationResult executeFold(Classifier classifier, ArrayList<Sample> training, ArrayList<Sample> testing) {

  classifier.reset();
  classifier.addTrainingSamples(training);
  classifier.train();

  return testOnSet(classifier, testing);
}

ClassificationResult testOnSet(Classifier classifier, ArrayList<Sample> testing) {
  ClassificationResult score = new ClassificationResult();

  for (Sample sample : testing) {
    double prediction = classifier.predict(sample);
    score.addResult((int)prediction == 1, (int)prediction == sample.label);
  }

  return score;
}

