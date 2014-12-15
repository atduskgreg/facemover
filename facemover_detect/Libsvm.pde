import psvm.*;

class Libsvm extends Classifier {  
  SVM classifier;

  Libsvm(PApplet parent) {
    super( parent );
    classifier = new SVM(parent);
  }

  float[] doubleToFloat(double[] input) {
    float[] result = new float[input.length];
    for (int i = 0; i < input.length; i++) {
      result[i] = (float)input[i];
    }

    return result;
  }

  void train() {  
    println(trainingSamples.size());
    println(trainingSamples.get(0).featureVector.length);

    float[][] trainingVectors = new float[trainingSamples.size()][trainingSamples.get(0).featureVector.length];
    int[] labels = new int[trainingSamples.size()];

    for (int i = 0; i < trainingSamples.size (); i++) {
      println("training: " + trainingSamples.get(i).recordDescription);
      trainingVectors[i] = doubleToFloat(trainingSamples.get(i).featureVector);
      labels[i] = trainingSamples.get(i).label;
    }

    SVMProblem problem = new SVMProblem();
    problem.setNumFeatures(numFeatures);
    problem.setSampleData(labels, trainingVectors);
    classifier.train(problem);
  }

  void save(String filename) {
    classifier.saveModel(filename);
  }

  void load(String filename) {
    classifier.loadModel(filename, numFeatures);
  }

  void setKernel(int kernel){
    classifier.params.kernel_type = kernel;
  }

  // Use this function to get a prediction, after having trained the algorithm.
  double predict(Sample sample) {
    return classifier.test(doubleToFloat(sample.featureVector));
  }

  double predict(Sample sample, double[] confidence) {
    return classifier.test(doubleToFloat(sample.featureVector), confidence);
  }


}

