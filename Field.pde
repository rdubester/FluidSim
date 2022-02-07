class Field {
  float magnitude;
  float turbulence;
  OpenSimplexNoise generator;

  Field(float magnitude, float turbulence, int seed){
    this.magnitude = magnitude;
    this.turbulence = turbulence;
    this.generator = new OpenSimplexNoise(seed);
  }
  
  PVector sample(float x, float y, float t){
    float noise = (float) this.generator.eval(
      x + 1000,
      y + 1000,
      sin(TAU * t) * this.turbulence, cos(TAU * t) * this.turbulence);
    float theta = map(noise, -1, 1, -PI - QUARTER_PI, PI + QUARTER_PI);
    return PVector.fromAngle(theta).mult(this.magnitude);
    }
}
