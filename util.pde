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

// based on sebastian league slime mold simulation code
//https://github.com/SebLague/Slime-Simulation/blob/6794cfdf584f71c657bd16366e31bf422be99ee6/Assets/Scripts/Slime/SlimeSim.compute
int[] fadeAndDiffuse(int[] values, int rows, int cols, float dt) {
  int[] processed = new int[rows * cols];
  
  // process each pixel
  for (int y = 0; y < rows; y++){
    for (int x = 0; x < cols; x++){
      int original_val = values[y * cols + x];
      // apply a 3x3 blur
      int samples = 0;
      int rsum = 0;
      int gsum = 0;
      int bsum = 0;
      for (int offsetY = -1; offsetY <= 1; offsetY++){
        for (int offsetX = -1; offsetX <= 1; offsetX++){
          int sampleY = y + offsetY;
          int sampleX = x + offsetX;
          if (sampleY < 0 || sampleY >= rows || sampleX < 0 || sampleX >= cols)
            continue;
          samples++;
          int c = values[sampleY * cols + sampleX];
          rsum += red(c) * red(c);
          gsum += green(c) * green(c);
          bsum += blue(c) * blue(c);
        }
      }
      int blurred_val = color(
        sqrt(rsum/samples),
        sqrt(gsum/samples),
        sqrt(bsum/samples));
      int diffused = lerpColor(original_val, blurred_val, diffuseSpeed * dt);
      color faded = lerpColor(diffused, color(0), sqrt(fadeSpeed * dt));
      processed[y * rows + x] = faded;
    }
  }
  return processed;
}
