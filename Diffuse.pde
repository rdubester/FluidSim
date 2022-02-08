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
