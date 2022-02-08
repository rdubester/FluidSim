// global particle constants
float maxSpeed = 5;

class Particle {
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
  
  int c0 = color(205, 7, 40);
  int c1 = color(202, 9, 235);
  int c2 = color(3, 150, 230);
  
  //int[] baseColors = {c0, c0, c1, c2, c2, 255}; 
  //int[] baseColors = {c0, c1, c2, c1};
  //int[] baseColors = {c2, c1};
  int[] baseColors = {#D1767F, #36A3AD};
  //int[] baseColors = {#ffffff};
  float baseOpacity = 1;
  float baseSize = 2;
  
  boolean special;
  int currentColor = 0;
  float currentOpacity = 1;  
  float currentSize = 1;
  
  Particle(PVector pos, PVector vel, PVector acc, float offset, boolean special) {
    this.pos = pos;
    this.vel = vel;
    this.acc = new PVector();
    this.prevPos  = pos.copy();
    this.startPos = pos.copy();
    this.startVel = vel.copy();
    this.startAcc = acc.copy();
    this.offset = offset;
    this.special = special;
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
  void apply(PVector[][] field_samples, int res) {
    
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
    this.vel.limit(maxSpeed);
    this.pos.add(this.vel);
    //this.constrainPos(width,height);
    this.acc.mult(0);
  }
  
  void updateStyle() {    
    float age = this.prevTime / this.lifespan;
    float d = sqrt(age);
    this.currentOpacity = this.baseOpacity * (1-d);
    //this.currentColor = lerpColors(baseColors, d);
    this.currentColor = lerpColors(baseColors, this.offset, true);
    this.currentSize = lerp(this.baseSize, 0, d);
    //this.currentSize = this.baseSize;
    if (this.special) {
      this.currentColor = lerpColor(color(255), color(#EECC8D), random(1));
      this.currentSize = this.baseSize / 2;
      this.currentOpacity = this.baseOpacity;
    }
  }
  
  void show() {
    push();
    strokeWeight(this.currentSize);
    float ydisp = this.pos.y - width / 2;
    float xdisp = this.pos.x - height / 2;
    float z = -circle_project(ydisp, 120);
    z -= circle_project(xdisp, 220);
    this.pos.set(this.pos.x, this.pos.y, z);
    int shaded = lerpColor(this.currentColor,0, abs(ydisp) * 5 / width);
    stroke(shaded, this.currentOpacity);
    float dist = PVector.sub(this.pos, this.prevPos).mag();
    if (dist < 20) {
      line(this.prevPos.x, this.prevPos.y, this.prevPos.z,
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
    float newx = (this.pos.x + w) % w;
    float newy = (this.pos.y + h) % h;
    this.pos.set(newx, newy);
  }
}

// generate a new particle with random position and velocity
Particle randomParticle(int w, int h, float offset, boolean useGaussian) {
  float start_y = useGaussian ? randomGaussian()*h/6 + h/2 : random(h);
  PVector start_pos = new PVector(0, start_y);
  float theta = map(random(1), 0, 1, -PI/5, PI/5);
  //float theta = map(random(1), 0, 1, -0.5, 0.5);
  PVector start_vel = PVector.fromAngle(theta).mult(maxSpeed);
  PVector start_acc = new PVector();
  boolean special = random(1) < 0.02;
  return new Particle(start_pos, start_vel, start_acc, offset, special);
}
