// global particle constants
float maxSpeed = 6;

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
  float lifespan = 2;
  
  int c0 = color(255, 27, 80);
  int c1 = color(232, 9, 255);
  int c2 = color(3, 150, 230);
  int[] colors = {c0, c1, c2}; 
  
  int currentColor = 0;
  float baseOpacity = 256;
  float opacity = 1;  
  float size = 4;
  
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
  void state(float t) {
    
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
    // record current position
    this.prevPos.set(this.pos);
    // update and constrain velocity
    this.vel.add(this.acc);
    this.vel.limit(maxSpeed);
    // update and constrain position
    this.pos.add(this.vel);
   // this.constrainPos(width,height);
    //reset acceleration to 0
    this.acc.mult(0);
  }
  
  void updateStyle() {    
    float age = this.prevTime / this.lifespan;
    float d = (1 - sqrt(age));
    // adjust opacity
    if (age == 0) {
     this.opacity = this.baseOpacity; 
    } else {
      this.opacity = this.baseOpacity * d;
    }
    //adjust color
    this.currentColor = lerpColors(colors, 1-d);
    //adjust size?
    
  }
  
  void show() {
    push();
    strokeWeight(3);
    stroke(this.currentColor, this.opacity);
    float dist = PVector.sub(this.pos, this.prevPos).mag();
    if (dist < 20) {
      line(this.prevPos.x, this.prevPos.y, this.pos.x, this.pos.y);
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
Particle randomParticle(int w, int h, float offset) {
    float start_y = (randomGaussian() * h / 6) + h/2;
    PVector start_pos = new PVector(0, start_y);
    float theta = map(random(1), 0, 1, -PI, PI);
    PVector start_vel = PVector.fromAngle(theta).mult(maxSpeed);
    PVector start_acc = new PVector();
    return new Particle(start_pos, start_vel, start_acc, offset);
  }
