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
int recognitionSize = 100;
int numClasses = 2;
String modelFilename = "tv_dog_model.txt";
float recognitionThreshold = 0.60;
int numAreas = 5;
int spacingBetweenAreas = 5;

Rectangle[] faces;
PVector lastFacePos;

OpenCV opencv;
Capture video;
Libsvm classifier;
RecognitionSystem detector;

void setup() {
  size(640/2, 480/2);
  video = new Capture(this, 640/2, 480/2);
  video.start();   

  opencv = new OpenCV(this, video.width, video.height);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  classifier = new Libsvm(this);
  classifier.load("face-hog-model.txt");
  detector = new RecognitionSystem(this, classifier, numClasses, recognitionX, recognitionY, numAreas, spacingBetweenAreas, recognitionSize);
  detector.setThreshold(recognitionThreshold);
  
  lastFacePos = new PVector();
}


void draw() {
  opencv.loadImage(video);
  faces = opencv.detect();

  image(opencv.getOutput(), 0, 0);
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  if(faces.length > 0){
    detector.setPosition(0, 0);
  } else {
    int[] results = detector.test(video);
    println(results);
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

