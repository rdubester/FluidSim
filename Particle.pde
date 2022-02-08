abstract class Particle {
  
  float maxVel;
  
  PVector pos;
  PVector vel;
  PVector acc;
  
  PVector prevPos;
  PVector startPos;
  PVector startVel;
  PVector startAcc;
  
  
  float offset;
  float prevTime = 0;
  float lifespan = 1;
  
  float baseOpacity = 1;
  float baseSize = 2;
  
  color[] baseColors;
  int currentColor;
  float currentOpacity;  
  float currentSize;
  
  Particle(PVector pos, PVector vel, PVector acc, float offset) {
    this.pos = pos;
    this.vel = vel;
    this.acc = new PVector();
    this.prevPos  = pos.copy();
    this.startPos = pos.copy();
    this.startVel = vel.copy();
    this.startAcc = acc.copy();
    this.offset = offset;
  }
  
  // set the state of the particle given the simulation time
  void updateTime(float t) {
    
    // observe a time offset behind the simulation time
    // which is also a value between 0 and 1
    float observedTime = mod(t - this.offset, this.lifespan);
    
    // compute a delta from the pervious observed time
    float deltaT = observedTime - this.prevTime;
    
    // reset the particle if it travels back in time
    if (deltaT < 0) {
      this.resetPhysics();
      this.prevTime = 0;
    }
    // save the observed time
    this.prevTime = observedTime;
  }
  
  // modify the acceleration of a particle given samples of an 
  // underlying vector field
  void applyField(PVector[][] field_samples, int res) {
    
    int sample_rows = field_samples.length;
    int sample_cols = field_samples[0].length;
    
    int i = int(this.pos.y / res);
    int j = int(this.pos.x / res);
    
    if (i < 0 || i >= sample_rows) return;
    if (j < 0 || j >= sample_cols) return;
    
    PVector force = field_samples[i][j];
    this.acc.add(force);
  }

  void updatePhysics() {
    this.prevPos.set(this.pos);
    this.vel.add(this.acc);
    this.vel.limit(this.maxVel);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
  
  abstract void updateStyle();
  
  void show() {
    push();
    strokeWeight(this.currentSize);
    stroke(this.currentColor, this.currentOpacity);
    float dist = PVector.sub(this.pos, this.prevPos).mag();
    if (dist < 20) {
      line(
        this.prevPos.x, this.prevPos.y, this.prevPos.z,
        this.pos.x, this.pos.y, this.pos.z);
    }
    pop();
  }
  
  void resetPhysics(){
    this.pos.set(this.startPos);
    this.prevPos.set(this.startPos);
    this.vel.set(this.startVel);
    this.acc.set(this.startAcc);
  }
  
  void constrainPos(int w, int h) {
    this.pos.set(
      mod(this.pos.x,  w),
      mod(this.pos.y, h));
  }
  
  void circleMap(float yRad, float xRad){
    float ySign = abs(yRad) / yRad;
    float xSign = abs(xRad) / xRad;
    float ydisp = this.pos.y - width / 2;
    float xdisp = this.pos.x - height / 2;
    float z = ySign * circle_project(ydisp, abs(yRad));
    z += xSign * circle_project(xdisp, abs(xRad));
    this.pos.set(this.pos.x, this.pos.y, z);
    int shaded = lerpColor(this.currentColor,0, abs(ydisp) * 5 / width);
    this.currentColor = shaded; 
  }
}
