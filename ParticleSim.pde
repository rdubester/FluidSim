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
float shutterAngle = 1.0001;

//Mode mode = Mode.PLAY;
//Mode mode = Msode.INSPECT;
Mode mode = Mode.RECORD;

//////////////////////////////////////////////////////////////////////


float border = 20;
int seed;

int num_particles = 100000;
//int num_particles = 60000;

int res = 5;
float step = 0.11;
float fmag = 0.9;
float turbulence = 0.15;

float xoffset = 121.5;
float yoffset = 458;

float diffuseSpeed = 600;
float fadeSpeed = 5;
float prevT;

//OpenSimplexNoise noise;
Field field;
PVector[][] fieldSamples;
Particle[] particles;
int[] processed;

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
  processed = fadeAndDiffuse(pixels, width, height, dt);
  for (int i = 0; i < pixels.length; i++)
    pixels[i] = processed[i];
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
  //translate(width, 0);
  //rotateZ(HALF_PI);
  // zoom in towards center of image
  scale(1 + border / float(width));
  translate(-border/2, -border / 2);
  // rotate slightly
  rotateY(-1.5 * PI/6);
  translate(120, 0);
  rotateY(-0.1);
  translate(0,0,20);
  
  //push();
  //stroke(255);
  //noFill();
  //rect(200, 200, width - 400, height - 400);
  //point(width/2, height/2);
  //pop();

  // update each particle and display
  for (Particle p : particles) {
    p.updateTime(t);
    p.apply(fieldSamples, res);
    p.updatePhysics();
    p.updateStyle();
    p.show(); 
  }
  pop();
}

//void keyPressed(){
//  float speed = 1;
//  if (key == CODED){
//    if (keyCode == UP){
//      println("up");
//      yoffset += speed;
//    }
//    if (keyCode == DOWN){
//      println("down");
//      yoffset -= speed;
//    }
//    if (keyCode == LEFT){
//      println("left");
//      xoffset -= speed;
//    }
//    if (keyCode == RIGHT){
//      println("right");
//      xoffset += speed;
//    }
//    if (keyCode == ESC) {
//      println("esc");
//      println(xoffset, yoffset);
//    }
//    field = new Field(fmag, turbulence, xoffset, yoffset);
//  }
//}
