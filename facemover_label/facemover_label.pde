import processing.video.*;
Movie video;

ArrayList<String> states;
boolean going = false;
String movieFilename = "sample4.mov";
int frameNum = 0;
boolean done = false;

void setup() {
  size( 568, 320);
  video = new Movie(this, movieFilename);
  video.play();
  video.pause();

  states = new ArrayList<String>();
}

void draw() {


  image(video, 0, 0); 

  if (going) {
    if (video.time() == video.duration() && !done) {  
      println("done");
      println(states.size() + " states" );

      String[] lines = states.toArray(new String[states.size()]);
      saveStrings(movieFilename + ".csv", lines);
      done = true;

    }
  }
}

void keyPressed() {
  going = true;
  video.play();
}

void movieEvent(Movie m) {
  m.read();
  if(going){
    states.add(frameNum + ","+ video.time() +"," +mouseX + "," + mouseY+"," +keyPressed);
    frameNum++;
  }
}

