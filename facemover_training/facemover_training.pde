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
Mat prev;

boolean flowInitialized = false;

void setup() {
  size(568*2, 320, P2D);
  video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 568, 320);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  opencv.useGray();

  video.loop();
  video.play();
}

void draw() {
  background(0);
  opencv.loadImage(video);
  faces = opencv.detect();
  if (flowInitialized) {
    Mat of = opticalFlow();
    drawOpticalFlow(of);

    if (faces.length > 0) {
      PVector d = getAverageFlowInRegion(of, faces[0]);

      pushStyle();
      pushMatrix();
      translate(opencv.width, 0);
      stroke(255);

      float x = faces[0].x + faces[0].width/2;
      float y = faces[0].y + faces[0].height/2;
      strokeWeight(3);

      line(x, y, x+d.x*100, y+ d.y*100);

      popMatrix();
      popStyle();
    }
  } else {
    opticalFlow();
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


// CV_32FC2 mat
void drawOpticalFlow(Mat om) {
  pushStyle();
  strokeWeight(1);
  stroke(255, 0, 0);
  int stepSize = 4;
  for (int y = 0; y < om.height (); y+=stepSize) {
    for (int x = 0; x < om.width (); x+=stepSize) {
      line(x, y, x+(float)om.get(y, x)[0], y+(float)om.get(y, x)[1]);
    }
  }
  popStyle();
}

PVector getAverageFlowInRegion(Mat m, Rectangle rect) {
  PVector total =  getTotalFlowInRegion(m, rect);
  return new PVector(total.x/(m.width() * m.height()), total.y/(m.width()*m.height()));
}

PVector getTotalFlowInRegion(Mat m, Rectangle rect) {
  Mat sub = m.submat(rect.y, rect.y+rect.height, rect.x, rect.x + rect.width);
  Scalar s = Core.sumElems(sub);
  return new PVector((float)s.val[0], (float)s.val[1]);
}

Mat opticalFlow() {
  double pyramidScale = 0.5;
  int nLevels = 4;
  int windowSize = 8;
  int nIterations = 2;
  int polyN = 7;
  double polySigma = 1.5;
  int flags = Video.OPTFLOW_FARNEBACK_GAUSSIAN;

  Mat output = opencv.imitate(opencv.getGray());

  if (!flowInitialized) {
    prev = opencv.getGray().clone();
    flags = Video.OPTFLOW_USE_INITIAL_FLOW;
    flowInitialized = true;

    return prev;
  } else {

    Mat next = new Mat();
    Video.calcOpticalFlowFarneback(
    prev, 
    opencv.getGray(), 
    next, 
    pyramidScale, 
    nLevels, 
    windowSize, 
    nIterations, 
    polyN, 
    polySigma, 
    flags
      );

    pushMatrix();
    translate(opencv.width, 0);
    drawOpticalFlow(next);
    popMatrix();

    prev = opencv.getGray().clone();

    return next;
  }
}

void movieEvent(Movie m) {
  m.read();
}

