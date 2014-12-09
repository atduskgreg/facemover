import gab.opencv.*;

import org.opencv.objdetect.HOGDescriptor;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfPoint;

import org.opencv.core.CvType;

OpenCV opencv;
HOGDescriptor descriptor;
Libsvm classifier

PImage before;

void setup(){
  opencv = new OpenCV(this, 50, 50);
  size(opencv.width, opencv.height*2);
  

}

void draw(){
  image(opencv.getOutput(), 0,0);
  image(before, 0, before.height);
}

float[] featuresForImage(PImage img) {
    // resize the images to a consistent size:
  img.resize(50,50);
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

HashMap crossfold(Classifier classifier, int nFolds, Sample[] samples) {
  HashMap<String, Float> result = new HashMap<String, Float>();
  result.put("accuracy", 0.0);
  result.put("precision", 0.0);
  result.put("recall", 0.0);
  result.put("fmeasure", 0.0);

  ArrayList<ArrayList<Sample>> folds = new ArrayList<ArrayList<Sample>>();
  for (int i = 0; i < nFolds; i++) {
    folds.add(new ArrayList<Sample>());
  }

  for (int i = 0; i < samples.length; i++) {
    int fold = (int)random(0, nFolds);

    folds.get(fold).add(samples[i]);
  }

  for (int i = 0; i < folds.size(); i++) {
    ArrayList<Sample> testing = folds.get(i);
    ArrayList<Sample> training = new ArrayList<Sample>();

    for (int j = 0; j < folds.size(); j++) {
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
  }

  result.put("accuracy", result.get("accuracy")/nFolds);
  result.put("precision", result.get("precision")/nFolds);
  result.put("recall", result.get("recall")/nFolds);
  result.put("fmeasure", result.get("fmeasure")/nFolds);

  return result;
}

ClassificationResult executeFold(Classifier classifier, ArrayList<Sample> training, ArrayList<Sample> testing) {

  ClassificationResult score = new ClassificationResult();

  classifier.reset();
  classifier.addTrainingSamples(training);
  classifier.train();
  
  for (Sample sample : testing) {
    double prediction = classifier.predict(sample);
    score.addResult((int)prediction == 1, (int)prediction == sample.label);
  }

  println("Accuracy: "+ score.getAccuracy() +" Precision: " + score.getPrecision() + " Recall: " + score.getRecall() + " F-measure: " + score.getFMeasure());

  return score;
}
