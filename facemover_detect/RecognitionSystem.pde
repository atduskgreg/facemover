import java.awt.Rectangle;

class RecognitionSystem {
  RecognitionArea[] areas;
  float threshold;
  int[] testResults;
  int maxSize;
  int spacing;

  private int indexOfTopEstimate;


  RecognitionSystem(PApplet parent, Libsvm model, int numClasses, int startX, int startY, int numAreas, int spacing, int maxSize) {
    threshold = 0.5;
    testResults = new int[numAreas];
    this.maxSize = maxSize;
    this.spacing = spacing;
    areas = new RecognitionArea[numAreas];
    
     // GRID-BASED CONVOLUTION
//     int i = 0; 
//     for(int row = 0; row < numAreas; row++){
//     for(int col = 0; col < numAreas; col++){
//     int rectSize = maxSize;
//     int x = startX + row*spacing;
//     int y = startY + col*spacing;
//     RecognitionArea area = new RecognitionArea(parent, model, numClasses, x, y, rectSize, rectSize);
//     areas[i] = area;
//     i++;
//     }
//     }
    // CONCENTRIC CONVOLUTION
    for (int i = 0; i < areas.length; i++) {
      int rectSize = maxSize - (i*spacing*2); 
      int x = startX + i*spacing;
      int y = startY + i*spacing;
      RecognitionArea area = new RecognitionArea(parent, model, numClasses, x, y, rectSize, rectSize);
      areas[i] = area;
    }
  }

  void updateSize(int s) {
    for (int i = 0; i < areas.length; i++) {
      areas[i].updateSize(s);
    }
  }

  void setSize(int s) {
    for (int i = 0; i < areas.length; i++) {
      areas[i].setSize(s);
    }
  }

  void setPosition(int x, int y) {
    for (int i = 0; i < areas.length; i++) {
      int areaSize = maxSize - (i*spacing*2);  
      int areaX = x + i*spacing;
      int areaY = y + i*spacing;

      areas[i].setPosition(areaX, areaY);
    }
  }

  void draw() {
    pushStyle();
    for (int i = 0; i < areas.length; i++) {
      pushMatrix();
      if (i == int(areas.length/2)) {
        stroke(255, 0, 0);
        strokeWeight(1);
      } else {
//        noStroke();
        strokeWeight(0.5);
      }
      areas[i].drawRect();
      popMatrix();
    }
    popStyle();
  }

  int getNumAreas() {
    return areas.length;
  }

  void setThreshold(float t) {
    threshold = t;
  }

  float getThreshold() {
    return threshold;
  }

  int[] test(PImage vid) {
    testResults = new int[areas.length];

    for (int i = 0; i < areas.length; i++) {
      testResults[i] = (int)areas[i].test(vid);
    }

    return testResults;
  }

  int[] getAllTestResults() {
    return testResults;
  }

  int getBestMatch() {
    getTopEstimate(); // for side effect of setting indexOfTopEstimate
    return testResults[indexOfTopEstimate];
  }
  
  RecognitionArea getBestArea(){
    return areas[indexOfTopEstimate];
  }

  double getTopEstimate() {
    double[] topEstimates = new double[5];
    double topEstimate = 0;
    for (int i = 0; i < areas.length; i++) {
      if (areas[i].getTopEstimate() > topEstimate) {
        topEstimate  = areas[i].getTopEstimate();
        indexOfTopEstimate = i;
      }
    }
    return topEstimate;
  }

  boolean objectMatched() {
    return getTopEstimate() > threshold;
  }

  PImage getTestImage(int i) {
    return areas[i].getTestImage();
  }
}


class RecognitionArea {
  Rectangle area;
  Libsvm model;
  float threshold;
  PImage testImage;
  double[] estimates;
  PApplet parent;
  int numClasses;

  RecognitionArea(PApplet parent, Libsvm model, int numClasses, int x, int y, int w, int h) {
    this.parent = parent;
    area = new Rectangle(x, y, w, h);
    this.model = model;
    this.numClasses = numClasses;

    testImage = createImage(w, h, RGB);
  }

  int test(PImage cam) {
    testImage.copy(cam, area.x, area.y, area.width, area.height, 0, 0, 50, 50);
    testImage.resize(50, 50);
    estimates = new double[numClasses];

    return (int)model.predict(new Sample(gradientsForImage(testImage)), estimates);
  }

  boolean objectIsMatched() {
    return (getTopEstimate() > threshold);
  }

  double getTopEstimate() {
    Arrays.sort(estimates);
    return (estimates[estimates.length-1]*estimates[estimates.length-1]);
  }

  double[] getEstimates() {
    return estimates;
  }

  void setPosition(int x, int y) {
    area.x = x;
    area.y = y;
  }

  void updateSize(int s) {
    area.width += s;
    area.height += s;
  }

  void setSize(int s) {
    area.width = s;
    area.height = s;
  }

  void setThreshold(float threshold) {
    this.threshold = threshold;
  }

  float getThreshold() {
    return threshold;
  }
  
  Rectangle getRect(){
    return area;
  }

  void drawRect() {
//    println(area.x +","+area.y + " "+ area.width +"x" + area.height);
    rect(area.x, area.y, area.width, area.height);
  }

  PImage getTestImage() {
    return testImage;
  }

  float[] gradientsForImage(PImage img) {
    // resize the images to a consistent size:
    img.resize(50, 50);
    // load resized image into OpenCV
    opencv.loadImage(img);
    image(opencv.getSnapshot(), 0, 0);

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
}

