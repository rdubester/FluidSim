class Field {
  float magnitude;
  float turbulence;
  OpenSimplexNoise generator;
  float xoffset;
  float yoffset;
  
  Field(float magnitude, float turbulence, float xoff, float yoff){
    this.magnitude = magnitude;
    this.turbulence = turbulence;
    this.xoffset = xoff;
    this.yoffset = yoff;
    this.generator = new OpenSimplexNoise();
  }
  
  Field(float magnitude, float turbulence){
    this(magnitude, turbulence, 1000, 1000);
  }
  
  PVector sample(float x, float y, float t){
    float current = (float) this.generator.eval(
      x + xoffset,
      y + yoffset,
      sin(TAU * t) * this.turbulence, cos(TAU * t) * this.turbulence);
    float foam = (float) this.generator.eval(
      5 * x + xoffset,
      5 * y + yoffset,
      sin(TAU * t) * 0.1 * this.turbulence, cos(TAU * t) * 0.1 * this.turbulence);
    float combined = lerp(current, foam, 0.2);
    float range = 1.33;
    float theta = map(combined, -1, 1, -range * PI, range* PI);
    return PVector.fromAngle(theta).mult(this.magnitude);
    }
}
