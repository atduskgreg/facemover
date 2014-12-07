class FlowTracker{
  PVector pos;
  int width;
  int height;
  Flow flow;
  boolean started = false;
  PVector flowDir;
  int updateRate = 100;
  
  FlowTracker(int width, int height, Flow flow){
    this.width = width;
    this.height = height;
    this.flow = flow;
    pos = new PVector();
    flowDir = new PVector();
  }
  
  void setUpdateRate(int r){
    updateRate = r;
  }
  
  void jumpTo(int x, int y){
    pos.x = x;
    pos.y = y;
    started = true;
  }
  
  boolean hasStarted(){
    return started;
  }
  
  void setDimensions(int w, int h){
    width = w;
    height = h;
  }
  
  PVector flowDir(){
    return flowDir;
  }
  
  Rectangle regionAroundPoint(float x, float y){
    Rectangle r = new Rectangle( (int)x - width/2, (int)y - height/2, width, height);
    if(r.x < 0){
      r.x = 0;
    }
    if(r.y < 0){
      r.y = 0;
    }
    
    if(r.x + r.width > flow.width()){
      r.width = flow.width() - r.x;
    }
    
    if(r.y + r.height > flow.height()){
      r.height = flow.height() - r.y;
    }
    
    return r;
  }
  
  void update(Mat m){
    flow.calculateOpticalFlow(m);
    
    if(started){
      Rectangle r = regionAroundPoint(pos.x, pos.y);
      flowDir = flow.getAverageFlowInRegion(r.x, r.y, r.width, r.height);
      flowDir.mult(updateRate);
      pos.add(flowDir);
      
      if(pos.x < 0){
        pos.x = 0;
      }
      if(pos.y < 0){
        pos.y = 0;
      }
      if(pos.x > flow.width()){
        pos.x = flow.width();
      }
      if(pos.y > flow.height()){
        pos.y = flow.height();
      }      
    }
  }
  
  PVector getPos(){
    return pos;
  }
  
  Rectangle getRegion(){
    return regionAroundPoint(pos.x, pos.y);
  }
  
}
