import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import java.util.List;

import org.opencv.video.Video;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import org.opencv.core.Core;
import org.opencv.core.Scalar;

OpenCV opencv;
Movie video;
Rectangle[] faces;
Flow flow;

void setup() {
  size(568*2, 320, P2D);
  video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 568, 320);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  opencv.useGray();

  flow = new Flow();

  video.loop();
  video.play();
}

void draw() {
  background(0);
  opencv.loadImage(video);
  faces = opencv.detect();

  flow.calculateOpticalFlow(opencv.getGray());
  pushMatrix();
  translate(opencv.width, 0);
  pushStyle();
  noFill();
  strokeWeight(1);
  stroke(255, 0, 0);
  flow.draw();
  popStyle();
  popMatrix();

  if (faces.length > 0) {
    PVector faceFlow = flow.getAverageFlowInRegion(faces[0].x, faces[0].y, faces[0].width, faces[0].height);

    pushStyle();
    pushMatrix();
    translate(opencv.width, 0);
    stroke(255);
    strokeWeight(3);

    float x = faces[0].x + faces[0].width/2;
    float y = faces[0].y + faces[0].height/2;
    line(x, y, x+faceFlow.x*100, y+ faceFlow.y*100);

    popMatrix();
    popStyle();
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
}

void movieEvent(Movie m) {
  m.read();
}

