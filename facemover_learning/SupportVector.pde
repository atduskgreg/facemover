class SupportVector {
  double[] classValues;
  double[] featureValues;
  
  SupportVector(int nClasses, int nFeatures){
    classValues = new double[nClasses];
    featureValues = new double[nFeatures];
  }
}
