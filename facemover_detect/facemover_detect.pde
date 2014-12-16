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

String movieFilename = "sample6.mov";

int recognitionX = 100;
int recognitionY = 100;
int recognitionSize = 228;
int numClasses = 2;
String modelFilename = "rotating-face-model.txt";
float recognitionThreshold = 0.60;
int numAreas = 15;
int spacingBetweenAreas = 5;

boolean useTracker = true;

Rectangle[] faces;
OpenCV opencv;
Movie video;
Libsvm classifier;
RecognitionSystem detector;

OpenCV opencv2;

// labeler
ArrayList<String> states;
int frameNum = 0;
boolean done = false;
boolean going = false;
PVector lastTrack;
boolean currentTrack = false;

void setup() {
  size( 568, 320);
  video = new Movie(this, movieFilename);
  video.play();   
  video.pause();

  opencv = new OpenCV(this, 50, 50);

  opencv2 = new OpenCV(this, video.width, video.height);
  opencv2.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  classifier = new Libsvm(this);
  classifier.setNumFeatures(1728); // !important this has to be before loading
  classifier.load(modelFilename);

  detector = new RecognitionSystem(this, classifier, numClasses, recognitionX, recognitionY, numAreas, spacingBetweenAreas, recognitionSize);
  detector.setThreshold(recognitionThreshold);

  states = new ArrayList<String>();

  lastTrack = new PVector();
}

void checkAndSaveLabels() {
  if (going) {
    if (video.time() >= video.duration() && !done) {  
      println("done");
      println(states.size() + " states" );

      String[] lines = states.toArray(new String[states.size()]);
      saveStrings(movieFilename + ".csv", lines);
      done = true;
    }
  }
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

  currentTrack = false;


  if (faces.length > 0) {
    detector.setPosition(faces[0].x  +faces[0].width/2 - recognitionSize/2, faces[0].y + faces[0].height/2 - recognitionSize/2);
    lastTrack.x = faces[0].x;
    lastTrack.y = faces[0].y;
    currentTrack = true;
  } else {
    int[] results = detector.test(video);
  }
  //  
  pushStyle();
  noFill();
  stroke(255, 0, 0);
  detector.draw();
  popStyle();

  if (useTracker && faces.length == 0 && detector.objectMatched() && detector.getBestMatch() == 1) {
    println(detector.getBestMatch() +  " "  + detector.getTopEstimate());
    pushStyle();
    noFill();
    strokeWeight(2);
    stroke(0, 0, 255);
    detector.getBestArea().drawRect();
    Rectangle r = detector.getBestArea().getRect();
    
    currentTrack = true;
    lastTrack.x = r.x + r.width/2;
    lastTrack.y = r.y + r.height/2;
    
    popStyle();
  }

  checkAndSaveLabels();
}

void keyPressed() {
  going = true;
  video.play();
}

void movieEvent(Movie m) {
  m.read();
  if (going) {
    //TODO: set this based on center of tracker box.

    states.add(frameNum + ","+ video.time() +"," +lastTrack.x + "," + lastTrack.y+"," +currentTrack);
    frameNum++;
  }
}

