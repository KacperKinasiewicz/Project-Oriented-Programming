PFont font1;
PFont font2;

color[] palette = {
  color(10, 24, 70),
  color(20, 50, 120),
  color(65, 105, 225),
  color(100, 149, 237),
  color(64, 224, 208),
  color(152, 251, 152)
};

void setup() {
  size(800, 600);
  noLoop();

  font1 = createFont("Racetrack Stencil.otf", 64);
  font2 = createFont("umber.ttf", 64);

  drawBackground();

  drawLogo(width/2, height - 100, 400, 120);
}

void draw() {
}

void drawLogo(float x, float y, float w, float h) {
  pushMatrix();
  translate(x, y);

  rectMode(CENTER);
  noStroke();
  fill(255, 230);
  rect(0, 0, w, h, h/2);

  stroke(50);
  strokeWeight(3);
  noFill();
  rect(0, 0, w - 10, h - 10, h/2);

  float fontSize = h * 0.6;
  textAlign(CENTER, CENTER);

  fill(200);
  noStroke();
  textFont(font1);
  textSize(fontSize);
  text("K", -w/5 + 4, 4);

  textFont(font2);
  textSize(fontSize);
  text("inaS", w/10 + 4, 4);

  fill(palette[0]);
  textFont(font1);
  text("K", -w/5, 0);

  fill(palette[3]);
  textFont(font2);
  text("inaS", w/10, 0);

  popMatrix();
}

void drawBackground() {
  background(245, 235, 245);

  drawLinesPattern(0, width, 0, height/3);
  drawRectGrid(0, width/2, height/3, 2*height/3);
  drawPolygonsRegion(width/2, width, height/3, 2*height/3);
  drawStarsRegion(0, width, 2*height/3, height);
  drawBubbles(0, width, 0, height);
}

void drawRectGrid(float x1, float x2, float y1, float y2) {
  float areaW = x2 - x1;
  float areaH = y2 - y1;
  int cols = int(random(4, 8));
  int rows = int(random(3, 6));
  float cellW = areaW / cols;
  float cellH = areaH / rows;

  rectMode(CORNER);
  stroke(255);
  strokeWeight(2);

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (random(1) > 0.2) {
        fill(randomColor(), 200);
        float sizeMod = random(0.7, 0.95);
        float rW = cellW * sizeMod;
        float rH = cellH * sizeMod;
        float startX = x1 + i*cellW + (cellW - rW)/2;
        float startY = y1 + j*cellH + (cellH - rH)/2;
        rect(startX, startY, rW, rH);
      }
    }
  }
}

void drawLinesPattern(float x1, float x2, float y1, float y2) {
  int n = int(random(40, 80));
  for (int i = 0; i < n; i++) {
    stroke(randomColor(), 150);
    strokeWeight(random(1, 4));
    float x = random(x1, x2);
    float y = random(y1, y2);
    float len = random(20, 100);
    line(x, y, x + len, y + len);
  }
}

void drawPolygonsRegion(float x1, float x2, float y1, float y2) {
  int n = int(random(8, 15));
  noStroke();
  for (int i = 0; i < n; i++) {
    fill(randomColor(), 180);
    float x = random(x1, x2);
    float y = random(y1, y2);
    float r = random(20, 50);
    int points = int(random(5, 8));
    drawPolygon(x, y, r, points);
  }
}

void drawStarsRegion(float x1, float x2, float y1, float y2) {
  int n = int(random(10, 20));
  noStroke();
  for (int i = 0; i < n; i++) {
    fill(randomColor(), 200);
    float x = random(x1, x2);
    float y = random(y1, y2);
    float r1 = random(10, 20);
    float r2 = random(25, 50);
    int points = int(random(4, 7));

    pushMatrix();
    translate(x, y);
    rotate(random(TWO_PI));
    drawStar(0, 0, r1, r2, points);
    popMatrix();
  }
}

void drawBubbles(float x1, float x2, float y1, float y2) {
  int n = int(random(15, 25));
  noStroke();
  for (int i = 0; i < n; i++) {
    fill(randomColor(), 100);
    float r = random(10, 60);
    float x = random(x1, x2);
    float y = random(y1, y2);
    ellipse(x, y, r, r);
  }
}

void drawPolygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void drawStar(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle / 2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a + halfAngle) * radius1;
    sy = y + sin(a + halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

color randomColor() {
  return palette[int(random(palette.length))];
}
