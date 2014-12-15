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

PImage sample;
int numSamples = 0;
boolean saveSamples = false;

void setup() {
  size(568*2, 320, P2D);
  video = new Movie(this, "sample3.mov");
  opencv = new OpenCV(this, 568, 320);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  opencv.useGray();

  flow = new Flow();
  tracker = new FlowTracker(75, 75, flow);
  tracker.setUpdateRate(50);

  sample = createImage(75, 75, GRAY);

  video.loop();
  video.play();
}

void draw() {
  background(0);
  opencv.loadImage(video);
  faces = opencv.detect();

  tracker.update(opencv.getGray());
  
  println(tracker.getTimeSinceFace());

  pushMatrix();
  translate(opencv.width, 0);
  noFill();
  strokeWeight(1);
  stroke(255, 0, 0);

  tracker.flow.draw();

  popMatrix();

  boolean faceTracked = false;

  if (faces.length > 0) {
    faceTracked = true;
    tracker.jumpTo(faces[0].x + faces[0].width/2, faces[0].y + faces[0].height/2);
    tracker.setDimensions(int(faces[0].width), int(faces[0].height));
  } else {
    if (saveSamples && tracker.hasStarted()) {
      Rectangle region = tracker.getRegion();
      // save training images
      // deal with non-square rectangles in edge conditions
      if (region.width == region.height) {
        sample.resize(region.width, region.height);
        sample.copy(opencv.getOutput(), region.x, region.y, region.width, region.height, 0, 0, region.width, region.height);
        sample.save("data/training/sample" + numSamples + ".png");
        numSamples++;
      }
    }
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

  fill(0, 255, 0);
  noStroke();
  ellipse(tracker.getPos().x, tracker.getPos().y, 20, 20);
  if (!faceTracked) {
    noFill();
    stroke(0, 0, 255);
    rect(tracker.getRegion().x, tracker.getRegion().y, tracker.getRegion().width, tracker.getRegion().height);
  }
  pushMatrix();
  translate(opencv.width, 0);
  fill(0, 255, 0);
  noStroke();
  ellipse(tracker.getPos().x, tracker.getPos().y, 20, 20);
  if (!faceTracked) {

    noFill();
    stroke(0, 0, 255);
    rect(tracker.getRegion().x, tracker.getRegion().y, tracker.getRegion().width, tracker.getRegion().height);
  }
      popMatrix();


  stroke(255);
  strokeWeight(2);
  line(tracker.getPos().x, tracker.getPos().y, tracker.getPos().x + tracker.flowDir().x, tracker.getPos().y + tracker.flowDir().y);

  pushMatrix();
  translate(opencv.width, 0);
  stroke(255);
  strokeWeight(2);
  line(tracker.getPos().x, tracker.getPos().y, tracker.getPos().x + tracker.flowDir().x, tracker.getPos().y + tracker.flowDir().y);

  popMatrix();
}

void mousePressed() {
  tracker.jumpTo(mouseX, mouseY);
}

void movieEvent(Movie m) {
  m.read();
}

