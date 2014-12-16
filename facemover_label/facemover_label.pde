import processing.video.*;
Movie video;

String movieFilename = "sample4.mov";

VideoLabeler labeler;

void setup() {
  size( 568, 320);
  video = new Movie(this, movieFilename);
  video.play();
  video.pause();
  
  labeler = new VideoLabeler(movieFilename + ".csv", video);

}

void draw() {
  image(video, 0, 0); 
  labeler.update();
}

void keyPressed() {
  labeler.start();
  video.play();
}

void movieEvent(Movie m) {
  m.read();
 labeler.onNewFrame();
}

