class Star extends Particle {
  
  Star(PVector pos, PVector vel, PVector acc, float offset) {
   super(pos, vel, acc, offset);
   this.maxVel = random(5,20);
  }
  
  void updateStyle(){
    float speed = this.maxVel / float(20);
    float age = this.prevTime / this.lifespan;
    this.currentColor = lerpColor(#ffd4d4, #fff7e3, this.offset);
    this.currentColor = lerpColor(#404040, this.currentColor, sqrt(age));
    //this.currentOpacity = 1 - (this.maxVel / 20) * 150;
    this.currentOpacity = 20;
    this.currentSize = lerp(0, 0.5, speed);
  }
}

Particle randomStar(int w, int h, float speed){
  float start_y = random(w);
  float vdisp = abs(start_y - w / 2.0) / (w / 2.0);
  float start_x = 50 + pow(10 * vdisp, 3) - 100 * random(1);  
  PVector start_pos = new PVector(start_x, start_y, -150);
  float theta = map(start_y, 0, w, -1, 1);
  PVector start_vel = PVector.fromAngle(theta).mult(speed);
  start_vel.set(start_vel.x, start_vel.y, random(18,20));
  PVector start_acc = new PVector();
  float offset = random(1);
  return new Star(start_pos, start_vel, start_acc, offset);
}
