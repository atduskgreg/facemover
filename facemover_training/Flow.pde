class Flow {
  Mat prev;
  Mat flow;
  boolean hasFlow = false;
  double pyramidScale = 0.5;
  int nLevels = 4;
  int windowSize = 8;
  int nIterations = 2;
  int polyN = 7;
  double polySigma = 1.5;
  int runningFlags = Video.OPTFLOW_FARNEBACK_GAUSSIAN;

  Flow() {
    flow = new Mat();
  }
  
  int width(){
    return flow.width();
  }
  
  int height(){
    return flow.height();
  }

  boolean hasFlow(){
    return hasFlow;
  }

  // this Mat would come from getCurrentMat() in OpenCV
  void calculateOpticalFlow(Mat m) {
    int flags = runningFlags;
    if (!hasFlow) {
      prev = m.clone();
      flags = Video.OPTFLOW_USE_INITIAL_FLOW;
      hasFlow = true;
    }
    Video.calcOpticalFlowFarneback(prev, m, flow, pyramidScale, nLevels, windowSize, nIterations, polyN, polySigma, flags);
    prev = m.clone();
  }

  PVector getTotalFlowInRegion(int x, int y, int w, int h) {
    Mat region = flow.submat(y, y+h, x, x+w);
    Scalar total = Core.sumElems(region);
    return new PVector((float)total.val[0], (float)total.val[1]);
  }

  PVector getAverageFlowInRegion(int x, int y, int w, int h) {
    PVector total = getTotalFlowInRegion(x, y, w, h);
    return new PVector(total.x/(flow.width() * flow.height()), total.y/(flow.width()*flow.height()));
  }

  PVector getTotalFlow() {
    return getTotalFlowInRegion(0, 0, flow.width(), flow.height());
  }

  PVector getAverageFlow() {
    return getAverageFlowInRegion(0, 0, flow.width(), flow.height());
  }
  
  PVector getFlowAt(int x, int y){
    return new PVector((float)flow.get(y, x)[0], (float)flow.get(y, x)[1]);
  }
  
  void draw() {
    int stepSize = 4;

    for (int y = 0; y < flow.height(); y+=stepSize) {
      for (int x = 0; x < flow.width(); x+=stepSize) {
        PVector flowVec = getFlowAt(x,y);
        line(x, y, x+flowVec.x, y+flowVec.y);
      }
    }
  }
}

