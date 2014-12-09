import gab.opencv.*;
import processing.video.*;
import org.opencv.objdetect.HOGDescriptor;

OpenCV opencv;
Capture video;
HOGDescriptor detector;

void setup(){
  size(640/2, 480/2);
  video = new Capture(this, 640/2, 480/2);
  video.start();   
  
  opencv = new OpenCV(this, video.width, video.height);
  
  detector = new HOGDescriptor();
//  
  detector.load(dataPath("hand_gesture_model.txt"));
}


void draw(){
  opencv.loadImage(video);
  image(opencv.getOutput(),0,0);
}

void captureEvent(Capture c) {
  c.read();
}
