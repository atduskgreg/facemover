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
String modelFilename = "face-hog-model.txt";
float recognitionThreshold = 0.60;
int numAreas = 15;
int spacingBetweenAreas = 5;

Rectangle[] faces;
PVector lastFacePos;

OpenCV opencv;
Capture video;
Libsvm classifier;
RecognitionSystem detector;

OpenCV opencv2;

void setup() {
  size(640/2, 480/2);
  video = new Capture(this, 640/2, 480/2);
  video.start();   

  opencv = new OpenCV(this, 50, 50);
  
  opencv2 = new OpenCV(this, video.width, video.height);
  opencv2.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  classifier = new Libsvm(this);
  classifier.load(modelFilename);
  classifier.setNumFeatures(1728);
  
  detector = new RecognitionSystem(this, classifier, numClasses, recognitionX, recognitionY, numAreas, spacingBetweenAreas, recognitionSize);
  detector.setThreshold(recognitionThreshold);
  
  lastFacePos = new PVector();
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
    detector.setPosition(faces[0].x, faces[0].y);
//    println(faces[0].width);
//    detector.setSize(faces[0].width);
  } else {
    int[] results = detector.test(video);
    println(detector.getTopEstimate());
  }
  
  pushStyle();
  noFill();
  stroke(255,0,0);
  detector.draw();
  popStyle();
  
  
}



void captureEvent(Capture c) {
  c.read();
}

