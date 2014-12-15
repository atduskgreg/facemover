import java.util.Arrays;


class Classifier {
  PApplet parent;
  ArrayList<Sample> trainingSamples;
  int numFeatures = 2;

  Classifier(PApplet parent) {
    this.parent = parent;
    trainingSamples = new ArrayList<Sample>();
  }

  void addTrainingSample(double[] featureVector, int label) {
    addTrainingSample(new Sample(featureVector, label));
  }

  void addTrainingSample(Sample sample) {
    setNumFeatures(sample.numFeatures());
    trainingSamples.add(sample);
  }

  void addTrainingSamples(Sample[] samples) {
    setNumFeatures(samples[0].numFeatures());
    trainingSamples =  new ArrayList<Sample>(Arrays.asList(samples));
  }  

  void addTrainingSamples(ArrayList<Sample> samples) {
    setNumFeatures(samples.get(0).numFeatures());
    trainingSamples.addAll(samples);
  }
  
  void reset(){
    trainingSamples.clear();
  }
  
  // implemented in sub-class
  void train(){}
  
  void setNumFeatures(int numFeatures){
    this.numFeatures = numFeatures;
    println("here: " + this.numFeatures);
  }
  
  // using 
  void save(String filename){
    classifier.save(filename);
  }
  
  void load(String filename){
    classifier.load(filename);
  }
  
  // implemented in sub-class
  double predict(Sample sample){
    return 0.0;
  }
}
