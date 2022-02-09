class Matter extends Particle {
 
  color red = #b53b03;
  color cobalt = #0385b5;
  
  color orange = #e6572c;
  color teal = #2ce6d7;

  color yellow = #fdbf01;
  color purple = #7f01fd; 
  
  boolean special;

  void updateStyle() {    
    float age = this.prevTime / this.lifespan;
    float d = sqrt(age);
    if (this.special) {
      this.currentColor = lerpColor(color(255), color(#FFD700), random(1));
      this.currentSize = this.baseSize / 2;
      this.currentOpacity = this.baseOpacity;
    } else {
      this.currentOpacity = this.baseOpacity * (1-d);
      this.currentColor = lerpColors(baseColors, this.offset, true);
      this.currentSize = lerp(this.baseSize, 0, d);
    }
  }

  Matter (PVector pos, PVector vel, PVector acc, float offset, boolean special){
    super(pos, vel, acc, offset);
    this.special = special;
    this.maxVel = 6;
    float r = random(1);
    if (r > 0.3) {
      this.baseColors = new int[] {red, cobalt};
    } else if (r > 0.6){
       this.baseColors = new int[] {orange, teal};
    } else {
      this.baseColors = new int[] {yellow, purple};
    }
    
    this.baseOpacity = 0.3;
  }
}

// generate a new particle with random position and velocity
Matter randomMatter(int w, int h, float offset) {
  //float start_y = randomGaussian()*h/6 + h/2;
  float start_y = random(h);
  PVector start_pos = new PVector(0, start_y);
  float theta = map(random(1), 0, 1, -PI/5, PI/5);
  //float theta = map(random(1), 0, 1, -0.5, 0.5);
  PVector start_vel = PVector.fromAngle(theta);
  PVector start_acc = new PVector();
  boolean special = random(1) < 0.02;
  return new Matter(start_pos, start_vel, start_acc, offset, special);
}
