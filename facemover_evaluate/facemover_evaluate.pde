String groundTruthPath = "ground.sample4.mov.csv";
String testPath = "test.sample4.mov.csv";

Table groundTruth;
Table testTrack;

float totalDistance = 0.0;

int falsePositives = 0;
int falseNegatives = 0;

void setup(){
  groundTruth = loadTable(groundTruthPath);
  testTrack = loadTable(testPath);
  
  
  for(int i = 0; i < groundTruth.getRowCount(); i++){
    TableRow groundFrame = groundTruth.getRow(i);
    TableRow testFrame = testTrack.getRow(i);
    
    PVector groundP = new PVector(groundFrame.getInt(2), groundFrame.getInt(3));
    PVector testP = new PVector(testFrame.getInt(2), testFrame.getInt(3));
    
    totalDistance += PVector.dist(groundP, testP);
    
    boolean groundB = groundFrame.getString(4).equals("true");
    boolean testB = testFrame.getString(4).equals("true");
    
    if(groundB && !testB){
      falseNegatives++;
    }
    
    if(!groundB && testB){
      falsePositives++;
    }
    
  }
  
  
  int numCorrect = groundTruth.getRowCount() - (falseNegatives + falsePositives);
  
  println("num frames correct: " + numCorrect + "/" + groundTruth.getRowCount());
  println("accuracy: " + (float)numCorrect/groundTruth.getRowCount());
  println("false positives: " + falsePositives);
  println("false negatives: " + falseNegatives);
  
  println("average distance off: " + totalDistance/groundTruth.getRowCount());

  
  noLoop();
}

void draw(){
}
