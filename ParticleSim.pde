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
int numFrames = 200;
int windup = 1;
float shutterAngle = 1.0001;

//Mode mode = Mode.PLAY;
//Mode mode = Msode.INSPECT;
Mode mode = Mode.RECORD;

//////////////////////////////////////////////////////////////////////


float dt;

float border = 50;
int seed;

int num_particles = 200000;
//int num_particles = 100000;
//int num_particles = 50000;
int num_stars = 8000;

int res = 5;
float step = 0.11;
float fmag = 1.1;
float turbulence = 0.12;

float xoffset = 121.5;
float yoffset = 458;

float diffuseSpeed = 600;
float fadeSpeed = 5;
float prevT;

//OpenSimplexNoise noise;
Field field;
PVector[][] fieldSamples;
Particle[] particles;
Particle[] stars;
int[] processed;

float[][] dispMap;
OpenSimplexNoise dispNoise;

void setup() {
  background(0);
  size(500, 500, P3D);
  smooth(8);
  blendMode(LIGHTEST);
  strokeCap(SQUARE);

  result = new int[width*height][3];
  field = new Field(fmag, turbulence, xoffset, yoffset);
  fieldSamples = new PVector[height/res][width/res];
  particles = new Particle[num_particles];
  for (int i = 0; i < particles.length; i++) {
    float offset = random(1);
    particles[i] = randomMatter(width, height, offset);
  }
  stars = new Particle[num_stars];
  for (int i = 0; i < stars.length; i++) {
   float offset = random(1);
   stars[i] = randomStar(width, height, 18);
  }
  
  dispMap = new float[height/res][width/res];
  dispNoise = new OpenSimplexNoise();
}

// t is always between 0 and 1
void draw_(float t) {
  
  setView();
  //drawReference();
  
  dt = t - prevT;
  prevT = t;
  if (dt < 0) dt = 1 + dt;
  //println(t, dt);
  
  loadPixels();
  processed = fadeAndDiffuse(pixels, width, height, dt);
  for (int i = 0; i < pixels.length; i++)
    pixels[i] = processed[i];
  updatePixels();

  // sample the field
  float yoff = 0;
  for (int i = 0; i < fieldSamples.length; i++) {
    float xoff = 0;
    for (int j = 0; j < fieldSamples[0].length; j++) {
      fieldSamples[i][j] = field.sampleAt(xoff, yoff, t);
      xoff += step;
    }
    yoff += step;
  }
  
  float rate = 0.4;
  yoff = 0;
  for (int j = 0; j < dispMap.length; j++){
    float xoff = 0;
    for (int i = 0; i < dispMap[0].length; i++) {
      float tdisp = 20 * (0.2 * cos(t * TAU) + 0.2 * sin(0.1 * t * TAU));
      float n = (float) dispNoise.eval(xoff + 100 + tdisp, yoff+ 100);
      dispMap[i][j] = map(n, -1, 1, -4.2, 4.2);
      xoff += rate;
    }
    yoff += rate;
  }

  // update each particle and show
  for (Particle p : particles) {
    p.updateTime(t);
    p.applyField(fieldSamples, res);
    p.updatePhysics();
    p.updateStyle();
    p.circleMap(-90, -80, dispMap, res);
    p.show(); 
  }
  
  // update each star and show
  for (Particle s : stars){
    s.updateTime(t);
    s.updatePhysics();
    s.updateStyle();
    //s.circleMap(-500, -10000);
    s.show();
  }
}

void setView(){
  // zoom in towards center of image
  scale(1 + border / float(width));
  translate(-border/2, -border / 2);
  // rotate slightly
  rotateY(-1.5 * PI/6);
  translate(140, 0);
  rotateY(-0.1);
  translate(0,0,20);
}

void drawReference(){
  push();
  noFill();
  stroke(255);
  strokeWeight(0.5);
  rect(200, 200, 100, 100);
  strokeWeight(5);
  //red
  stroke(255,0,0);
  point(200,200);
  stroke(255,0,200);
  point(200, 200, 10);
  stroke(255,200,0);
  point(200, 200, -10);
  
  //point(200,300);
  // green
  stroke(0,255,0);
  point(200,300);
  // blue
  stroke(0,0,255);
  point(300, 300);
  //yellow
  stroke(255,255,0);
  point(300, 200);
  pop();
}
