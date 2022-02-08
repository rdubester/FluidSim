enum Mode {
  PLAY,
    RECORD,
    INSPECT
}

int[][] result;
float t = 0;

void draw() {
  switch (mode) {
    // endless loop
  case PLAY:
    t += 0.01;
    draw_(t % 1);
    break;
    // mouse controls current frame
  case INSPECT:
    t = mouseX/float(width);
    draw_(t);
    break;
    // save to series of PNG files with motion blur
  case RECORD:
    // set all result values to 0
    for (int i=0; i<result.length; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;
    // draw each sample for the current frame
    for (int sample=0; sample<samplesPerFrame; sample++) {
      t = map(
        (frameCount - 1) % numFrames + sample*shutterAngle/samplesPerFrame,
        0, numFrames,
        0, 1);
      // draw the sample and save to the pixels array
      draw_(t);
      loadPixels();
      // add the sample rgb values to the corresponding chanel of result
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }
    // load the result back into the pixel array
    for (int i=0; i<pixels.length; i++) {
      pixels[i] = 0xff << 24 |
        int(result[i][0]/float(samplesPerFrame)) << 16 |
        int(result[i][1]/float(samplesPerFrame)) << 8 |
        int(result[i][2]/float(samplesPerFrame));
    }
    // update the canvas and save to a png
    updatePixels();
    println(frameCount);
    if (frameCount < numFrames * windup) break;
    saveFrame("out/fr####.png");
    println(frameCount, "/", numFrames);
    if (frameCount == numFrames * (windup + 1)) {
      exit();
    }
    break;
  }
}

//////////////////////////////////////////////////////////////////////

int samplesPerFrame = 1;
int numFrames = 100;
int windup = 2;
float shutterAngle = 1;

//Mode mode = Mode.PLAY;
//Mode mode = Mode.INSPECT;
Mode mode = Mode.RECORD;

//////////////////////////////////////////////////////////////////////


float border = 100;
int seed;

//int num_particles = 100000;
int num_particles = 120000;
//int num_particles = 10;

int res = 5;
float step = 0.1;
float fmag = 0.75;
float turbulence = 0.15;

float diffuseSpeed = 600;
float fadeSpeed = 10;
float prevT;

//OpenSimplexNoise noise;
Field field;
PVector[][] fieldSamples;
Particle[] particles;

void setup() {
  background(0);
  size(500, 500, P3D);
  smooth(8);
  blendMode(LIGHTEST);
  strokeCap(SQUARE);

  result = new int[width*height][3];
  field = new Field(fmag, turbulence, 951, 110);
  fieldSamples = new PVector[height/res][width/res];
  particles = new Particle[num_particles];
  for (int i = 0; i < particles.length; i++) {
    float offset = random(1);
    particles[i] = randomParticle(width, height, offset, false);
  }
}

// t is always between 0 and 1
void draw_(float t) {
  push();
  
  float dt = t - prevT;
  if (dt < 0) {
    dt = 1 + dt;
  }
  prevT = t;
  
  loadPixels();
  fadeAndDiffuse(dt);
  updatePixels();

  // sample the field
  float yoff = 0;
  for (int i = 0; i < fieldSamples.length; i++) {
    float xoff = 0;
    for (int j = 0; j < fieldSamples[0].length; j++) {
      fieldSamples[i][j] = field.sample(xoff, yoff, t);
      xoff += step;
    }
    yoff += step;
  }
  
  // rotate particles come from the top
  translate(width, 0);
  rotateZ(HALF_PI);
  // zoom in towards center of image
  scale(1 + border / float(width));
  translate(-border/2, -border / 2);
  // rotate slightly
  rotateY(-1.5 * PI/6);
  translate(100, 0);
  
  //push();
  //stroke(255);
  //noFill();
  //rect(200, 200, width - 400, height - 400);
  //point(width/2, height/2);
  //pop();

  // update each particle and display
  for (int a = 0; a < particles.length; a++) {
    Particle p = particles[a];
    // set the particle's state given time
    p.state(t);
    // apply field and update physcs
    p.apply(fieldSamples, res);
    p.updatePhysics();
    // display the particle
    p.updateStyle();
    p.show(); 
  }
  
  pop();
}

// based on sebastian league slime mold simulation code
//https://github.com/SebLague/Slime-Simulation/blob/6794cfdf584f71c657bd16366e31bf422be99ee6/Assets/Scripts/Slime/SlimeSim.compute
void fadeAndDiffuse(float dt) {
  int rows = height;
  int cols = width;
  int[] processed = new int[rows * cols];
  
  // process each pixel
  for (int y = 0; y < rows; y++){
    for (int x = 0; x < cols; x++){
      int original_val = pixels[y * cols + x];
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
          int c = pixels[sampleY * cols + sampleX];
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
  for (int i = 0; i < pixels.length; i++)
    pixels[i] = processed[i];
}