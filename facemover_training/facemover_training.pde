import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

import org.opencv.video.Video;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import org.opencv.core.Core;
import org.opencv.core.Scalar;

OpenCV opencv;
Movie video;
Rectangle[] faces;
Flow flow;
FlowTracker tracker;


void setup() {
  size(568*2, 320, P2D);
  video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 568, 320);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  opencv.useGray();

  flow = new Flow();
  tracker = new FlowTracker(50,50,flow);

  video.loop();
  video.play();
}

void draw() {
  background(0);
  opencv.loadImage(video);
  faces = opencv.detect();

  tracker.update(opencv.getGray());
 
  pushMatrix();
  translate(opencv.width, 0);
  noFill();
  strokeWeight(1);
  stroke(255, 0, 0);
  
  tracker.flow.draw();
  
  popMatrix();

  if (faces.length > 0) {
    PVector faceFlow = tracker.flow.getAverageFlowInRegion(faces[0].x, faces[0].y, faces[0].width, faces[0].height);
    tracker.jumpTo(faces[0].x + faces[0].width/2, faces[0].y + faces[0].height/2);
    tracker.setDimensions(int(faces[0].width * 0.5), int(faces[0].height * 0.5));

    pushMatrix();
    translate(opencv.width, 0);
    stroke(255);
    strokeWeight(3);

    float x = faces[0].x + faces[0].width/2;
    float y = faces[0].y + faces[0].height/2;
    line(x, y, x+faceFlow.x*100, y+ faceFlow.y*100);

    popMatrix();
  }

  image(video, 0, 0);  

  noFill();
  stroke(0, 255, 0);
  strokeWeight(2);

  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }

  pushMatrix();
  translate(opencv.width, 0);
  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  popMatrix();
  
  fill(0,255,0);
  noStroke();
  ellipse(tracker.getPos().x, tracker.getPos().y, 20, 20);
  noFill();
  stroke(0,0,255);
  rect(tracker.getRegion().x, tracker.getRegion().y, tracker.getRegion().width, tracker.getRegion().height);
}

void mousePressed(){
  tracker.jumpTo(mouseX, mouseY);
}

void movieEvent(Movie m) {
  m.read();
}

