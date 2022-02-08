float mod(float a, float b) {
  return (a < 0) ? (b - (abs(a) % b) ) % b : (a % b);
}

// constrains a value between 0 and 1
float c01(float g) {
  return constrain(g, 0, 1);
}

//simple in/out easing
float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

// controllable in out easing
float ease(float p, float g) {
  if (p < 0.5) 
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

color lerpColors(color[] colors, float q) {
 return lerpColors(colors, q, false); 
}
// smoothly interpolate between colors in an array
// q should be a float between 0 and 1
color lerpColors(color[] colors, float q, boolean wrap) {
  // ensure q is in [0, 1]
  q = q % 1;
  int slots = wrap ? colors.length : colors.length - 1;
  // determine which color band we're in
  int idx = (int) (q * slots);
  // interpolate
  float interval = 1 / (float) slots;
  float lbound = interval * idx;
  float rbound = interval * (idx + 1);
  return lerpColor(
            colors[idx],
            colors[(idx+1) % colors.length],
            map(q, lbound, rbound, 0, 1));
}

float circle_project(float x, float r) {
  return r - sqrt(r * r - x * x);
}
