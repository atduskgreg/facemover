import gab.opencv.*;
import processing.video.*;
import org.opencv.objdetect.HOGDescriptor;

import org.opencv.objdetect.HOGDescriptor;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfRect;
import org.opencv.core.MatOfDouble;

import org.opencv.core.Rect;

import org.opencv.core.CvType;

OpenCV opencv;
Capture video;
HOGDescriptor detector;
Libsvm classifier;

void setup(){
  size(640/2, 480/2);
  video = new Capture(this, 640/2, 480/2);
  video.start();   
  
  classifier = new Libsvm(this);
  
  opencv = new OpenCV(this, video.width, video.height);
  
  detector = new HOGDescriptor();
  
  Mat svmData = new Mat();

  detector.setSVMDetector(svmData);  

}


void draw(){
  opencv.loadImage(video);
  
  doDetections();
  
  image(opencv.getOutput(),0,0);
}

void doDetections(){
  MatOfRect foundLocations = new MatOfRect();
  MatOfDouble foundWeights = new MatOfDouble();
  detector.detectMultiScale(opencv.getGray(), foundLocations, foundWeights);
  
  double[] r = foundLocations.get(0,0);
  
  println(r);
  
  println("locations: " + foundLocations.width() + "x" + foundLocations.height());
  println("weights: " + foundWeights.width() + "x" + foundWeights.height());

}



void captureEvent(Capture c) {
  c.read();
}

Mat featuresForImage(PImage img) {
  // resize the images to a consistent size:
//  img.resize(50, 50);
  // load resized image into OpenCV
  opencv.loadImage(img);

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
//  float[] result = descriptors.toArray();
//  return result;
  return descriptors;
}
