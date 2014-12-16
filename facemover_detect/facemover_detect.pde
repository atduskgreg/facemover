import gab.opencv.*;
import processing.video.*;
import org.opencv.objdetect.HOGDescriptor;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfRect;
import org.opencv.core.MatOfDouble;
import org.opencv.core.Rect;
import org.opencv.core.CvType;
import java.awt.Rectangle;

int recognitionX = 100;
int recognitionY = 100;
int recognitionSize = 228;
int numClasses = 2;
String modelFilename = "rotating-face-model.txt";
float recognitionThreshold = 0.60;
int numAreas = 1;
int spacingBetweenAreas = 5;

Rectangle[] faces;
Rectangle lastFace;
OpenCV opencv;
Movie video;
Libsvm classifier;
RecognitionSystem detector;

OpenCV opencv2;


void setup() {
  size( 568, 320);
  video = new Movie(this, "sample4.mov");
  video.loop();   

  opencv = new OpenCV(this, 50, 50);
  
  opencv2 = new OpenCV(this, video.width, video.height);
  opencv2.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  classifier = new Libsvm(this);
  classifier.setNumFeatures(1728); // !important this has to be before loading
  classifier.load(modelFilename);

  detector = new RecognitionSystem(this, classifier, numClasses, recognitionX, recognitionY, numAreas, spacingBetweenAreas, recognitionSize);
  detector.setThreshold(recognitionThreshold);
  
  lastFace = new Rectangle(0,0, 50, 50);
}


void draw() {
  opencv2.loadImage(video);
  faces = opencv2.detect();

  image(video, 0, 0);
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  if(faces.length > 0){
    lastFace.x = faces[0].x;
    lastFace.y = faces[0].y;
    lastFace.width = faces[0].width;
    lastFace.height = faces[0].height;
  }
  
  PImage img = createImage(lastFace.width, lastFace.height, RGB);
  img.copy(video, 0,0, lastFace.width, lastFace.height, 0,0, lastFace.width, lastFace.height);
  double[] confidence = new double[2];
  double r = classifier.predict(new Sample(featuresForImage(img)), confidence);
  println(r + " " + confidence[0] +"/"+ confidence[1]);
  
//  if(faces.length > 0){
//    detector.setPosition(faces[0].x, faces[0].y);
////    println(faces[0].width);
//    detector.setSize(faces[0].width);
//  } //else {
//    int[] results = detector.test(video);
//    println(results[0] + " "  + detector.getTopEstimate());
//  //}
//  
  pushStyle();
  noFill();
  stroke(255,0,0);
//  detector.draw();
  popStyle();
  
  
}

float[] featuresForImage(PImage img) {
  // resize the images to a consistent size:
  img.resize(50, 50);
  // load resized image into OpenCV
  opencv.loadImage(img);
  image(opencv.getSnapshot(), 0,0);

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


void captureEvent(Capture c) {
  c.read();
}

void movieEvent(Movie m) {
  m.read();
}

