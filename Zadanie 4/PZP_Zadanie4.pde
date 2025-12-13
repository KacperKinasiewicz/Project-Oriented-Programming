color colorBackground, colorAccent, colorText, colorActive;
float panelHeight, canvasHeight, margin = 10;
PGraphics drawingLayer;
float drawingX, drawingY, drawingW, drawingH;
PFont fontAudiowide;

String currentTool = "Pędzel";
color currentColor = color(0, 0, 0);
float currentSize = 10;

ArrayList<ToolButton> toolButtons = new ArrayList<ToolButton>();
ArrayList<ColorButton> colorButtons = new ArrayList<ColorButton>();
Slider sizeSlider;

void setup() {
  size(600, 800);
  colorMode(HSB, 360, 100, 100);

  colorBackground = color(230, 80, 15);
  colorAccent = color(170, 100, 100);
  colorText = color(0, 0, 100);
  colorActive = color(170, 100, 80);

  panelHeight = height * 0.25;
  canvasHeight = height * 0.75;

  drawingX = margin;
  drawingY = margin;
  drawingW = width - (2 * margin);
  drawingH = canvasHeight - (2 * margin);

  fontAudiowide = createFont("Audiowide.ttf", 24);
  if (fontAudiowide == null) fontAudiowide = createFont("Arial", 24);

  drawingLayer = createGraphics((int)drawingW, (int)drawingH);
  drawingLayer.beginDraw();
  drawingLayer.colorMode(HSB, 360, 100, 100);
  drawingLayer.background(0, 0, 100);
  drawingLayer.endDraw();

  createInterface();
}

void createInterface() {
  float toolW = 100, toolH = 40, toolGap = 10;
  float colorSize = 35, colorGap = 15;
  float sliderW = 150, sectionGap = 40;
  
  float colorsSectionW = (4 * colorSize) + (3 * colorGap);
  float totalWidth = toolW + sectionGap + colorsSectionW + sectionGap + sliderW;
  float startX = (width - totalWidth) / 2;
  float startY = canvasHeight + margin + (panelHeight - 2 * margin) / 2;

  ToolButton brushBtn = new ToolButton(startX, startY - 45, toolW, toolH, "Pędzel");
  brushBtn.isActive = true;
  toolButtons.add(brushBtn);
  toolButtons.add(new ToolButton(startX, startY - 45 + toolH + toolGap, toolW, toolH, "Gumka"));

  color[] palette = {
    color(0, 0, 100), color(0, 0, 0),
    color(0, 100, 100), color(120, 100, 100),
    color(240, 100, 100), color(180, 100, 100),
    color(300, 100, 100), color(60, 100, 100)
  };

  float colorsX = startX + toolW + sectionGap;
  float colorsY = startY - 42.5;

  for (int i = 0; i < palette.length; i++) {
    float x = colorsX + (i % 4) * (colorSize + colorGap);
    float y = colorsY + (i / 4) * (colorSize + colorGap);
    ColorButton btn = new ColorButton(x, y, colorSize, colorSize, palette[i]);
    if (i == 1) btn.isActive = true;
    colorButtons.add(btn);
  }

  sizeSlider = new Slider(colorsX + colorsSectionW + sectionGap, startY - 10, sliderW, 20, 1, 50, 10);
}

void draw() {
  background(colorBackground);

  if (mousePressed) {
    if (mouseX > drawingX && mouseX < drawingX + drawingW && mouseY > drawingY && mouseY < drawingY + drawingH) {
      drawingLayer.beginDraw();
      drawingLayer.strokeCap(ROUND);
      drawingLayer.strokeWeight(currentSize);
      
      if (currentTool.equals("Gumka")) drawingLayer.stroke(0, 0, 100);
      else drawingLayer.stroke(currentColor);
      
      drawingLayer.line(pmouseX - drawingX, pmouseY - drawingY, mouseX - drawingX, mouseY - drawingY);
      drawingLayer.endDraw();
    }
    
    if (mouseY > canvasHeight && sizeSlider.isMouseOver()) {
      sizeSlider.update();
      currentSize = sizeSlider.currentVal;
    }
  }

  image(drawingLayer, drawingX, drawingY);

  noFill();
  stroke(colorAccent);
  strokeWeight(2);
  rect(drawingX, drawingY, drawingW, drawingH);
  rect(margin, canvasHeight + margin, width - 2 * margin, panelHeight - 2 * margin);

  for (ToolButton btn : toolButtons) btn.display();
  for (ColorButton btn : colorButtons) btn.display();
  sizeSlider.display();

  if (mouseY < canvasHeight) {
    noCursor();
    ellipseMode(CENTER);
    
    if (currentTool.equals("Gumka")) {
      fill(0, 0, 100);
      stroke(0);
      strokeWeight(1);
    } else {
      fill(currentColor);
      if (brightness(currentColor) > 95 && saturation(currentColor) < 5) {
        stroke(0);
        strokeWeight(1);
      } else {
        noStroke();
      }
    }
    ellipse(mouseX, mouseY, currentSize, currentSize);
  } else {
    cursor(ARROW);
  }
}

void mousePressed() {
  if (mouseY > canvasHeight) {
    for (ToolButton btn : toolButtons) {
      if (btn.isMouseOver()) {
        for (ToolButton b : toolButtons) b.isActive = false;
        btn.isActive = true;
        currentTool = btn.label;
      }
    }

    for (ColorButton btn : colorButtons) {
      if (btn.isMouseOver()) {
        for (ColorButton b : colorButtons) b.isActive = false;
        btn.isActive = true;
        currentColor = btn.btnColor;
        
        if (currentTool.equals("Gumka")) {
          currentTool = "Pędzel";
          toolButtons.get(0).isActive = true;
          toolButtons.get(1).isActive = false;
        }
      }
    }

    if (sizeSlider.isMouseOver()) {
      sizeSlider.update();
      currentSize = sizeSlider.currentVal;
    }
  }
}

class UIElement {
  float x, y, w, h;
  boolean isActive = false;

  UIElement(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }

  void display() {}

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }
}

class ToolButton extends UIElement {
  String label;

  ToolButton(float x, float y, float w, float h, String label) {
    super(x, y, w, h);
    this.label = label;
  }

  @Override
  void display() {
    stroke(colorAccent);
    strokeWeight(2);
    fill(isActive ? colorActive : colorBackground);
    rect(x, y, w, h);

    fill(isActive ? colorText : colorAccent);
    textAlign(CENTER, CENTER);
    textFont(fontAudiowide);
    textSize(18);
    text(label, x + w/2, y + h/2);
  }
}

class ColorButton extends UIElement {
  color btnColor;

  ColorButton(float x, float y, float w, float h, color c) {
    super(x, y, w, h);
    this.btnColor = c;
  }

  @Override
  void display() {
    stroke(isActive ? colorText : colorAccent);
    strokeWeight(isActive ? 3 : 2);
    fill(btnColor);
    ellipseMode(CORNER);
    ellipse(x, y, w, h);
  }
}

class Slider extends UIElement {
  float minVal, maxVal, currentVal;

  Slider(float x, float y, float w, float h, float minV, float maxV, float startV) {
    super(x, y, w, h);
    minVal = minV; maxVal = maxV; currentVal = startV;
  }

  void update() {
    float newVal = map(mouseX, x, x + w, minVal, maxVal);
    currentVal = constrain(round(newVal), minVal, maxVal);
  }

  @Override
  void display() {
    fill(colorText);
    textAlign(LEFT, BOTTOM);
    textFont(fontAudiowide);
    textSize(16);
    text("Grubość: " + int(currentVal), x, y - 5);

    stroke(colorAccent);
    strokeWeight(4);
    line(x, y + h/2, x + w, y + h/2);

    float handleX = map(currentVal, minVal, maxVal, x, x + w);
    
    if (isMouseOver() || (mousePressed && isMouseOver())) fill(colorActive);
    else fill(colorAccent);
    
    noStroke();
    rectMode(CENTER);
    rect(handleX, y + h/2, 10, 20);
    rectMode(CORNER);
  }
}
