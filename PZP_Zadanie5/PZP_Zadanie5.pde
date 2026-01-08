color colorBackground, colorAccent, colorText, colorActive, colorPanelBg;
float panelHeight, canvasHeight, margin;
PFont fontAudiowide;

ArrayList<ToolButton> uiButtons = new ArrayList<ToolButton>();
String currentFilter = "Brak"; 

PImage imgOriginal; 
PImage imgPreview;  
float imgX, imgY, imgW, imgH; 

boolean isSelecting = false; 
boolean hasSelection = false; 
float startX, startY; 
float selX, selY, selW, selH; 

void setup() {
  size(1000, 700);
  colorMode(HSB, 360, 100, 100);

  colorBackground = color(230, 80, 15);   
  colorPanelBg = color(230, 80, 25);      
  colorAccent = color(170, 100, 100);     
  colorText = color(0, 0, 100);           
  colorActive = color(170, 100, 80);      

  panelHeight = height * 0.1;
  canvasHeight = height * 0.9;

  fontAudiowide = createFont("Audiowide.ttf", 24);
  if (fontAudiowide == null) fontAudiowide = createFont("Arial", 24);

  createInterface();
}

void createInterface() {
  uiButtons.clear();
  
  float gap = 5;
  float sideMargin = 10;
  
  float btnH = (panelHeight - (3 * gap)) / 2;
  
  float row1Y = canvasHeight + gap;
  float row2Y = row1Y + btnH + gap;
  
  String[] allFilters = {"Negatyw", "Szarość", "Progowanie", "Rozmycie", "Wyostrzanie", "Płaskorzeźba"};
  int numFilters = allFilters.length;
  
  float filterTotalGap = (numFilters - 1) * gap;
  float filterBtnW = (width - (2 * sideMargin) - filterTotalGap) / numFilters;
  float currentX = sideMargin;
  
  for (String name : allFilters) {
    uiButtons.add(new ToolButton(currentX, row1Y, filterBtnW, btnH, name, true));
    currentX += filterBtnW + gap;
  }
  
  int numSystem = 3;
  float systemTotalGap = (numSystem - 1) * gap;
  float systemBtnW = (width - (2 * sideMargin) - systemTotalGap) / numSystem;
  currentX = sideMargin; 
  
  ToolButton resetBtn = new ToolButton(currentX, row2Y, systemBtnW, btnH, "Reset", true);
  resetBtn.isActive = true; 
  uiButtons.add(resetBtn);
  currentX += systemBtnW + gap;
    
  uiButtons.add(new ToolButton(currentX, row2Y, systemBtnW, btnH, "Wczytaj", false));
  currentX += systemBtnW + gap;

  uiButtons.add(new ToolButton(currentX, row2Y, systemBtnW, btnH, "Zapisz", false));
}

void draw() {
  fill(colorBackground);
  noStroke();
  rect(0, 0, width, canvasHeight);

  if (imgPreview != null) {
    image(imgPreview, imgX, imgY, imgW, imgH);
    
    noFill();
    stroke(colorAccent);
    strokeWeight(1);
    rect(imgX, imgY, imgW, imgH);
  } else {
    fill(colorText);
    textAlign(CENTER, CENTER);
    textFont(fontAudiowide);
    textSize(20);
    text("Wczytaj obraz aby rozpocząć", width/2, canvasHeight/2);
  }

  if (imgPreview != null && (isSelecting || hasSelection)) {
    if (isSelecting) {
      float currentMouseX = constrain(mouseX, imgX, imgX + imgW);
      float currentMouseY = constrain(mouseY, imgY, imgY + imgH);
      float currW = currentMouseX - startX;
      float currH = currentMouseY - startY;
      
      selX = startX;
      selY = startY;
      selW = currW;
      selH = currH;
      
      if (selW < 0) { selX += selW; selW = -selW; }
      if (selH < 0) { selY += selH; selH = -selH; }
    }

    fill(hue(colorAccent), saturation(colorAccent), brightness(colorAccent), 40);
    stroke(0, 0, 0); 
    strokeWeight(3);
    rect(selX, selY, selW, selH);
    noFill(); 
    stroke(0, 0, 100);
    strokeWeight(1);
    rect(selX, selY, selW, selH);
  }

  fill(colorPanelBg);
  stroke(colorAccent);
  strokeWeight(2);
  rect(1, canvasHeight, width - 2, panelHeight - 1);

  for (ToolButton btn : uiButtons) {
    btn.display();
  }
}

void mousePressed() {
  if (mouseY > canvasHeight) {
    for (ToolButton btn : uiButtons) {
      if (btn.isMouseOver()) {
        if (btn.isToggle) {
          for (ToolButton b : uiButtons) if (b.isToggle) b.isActive = false;
          btn.isActive = true;
          currentFilter = btn.label;
          
          if (hasSelection) applyCurrentFilter();
          
        } else {
          if (btn.label.equals("Wczytaj")) {
            selectInput("Wybierz plik obrazu:", "fileSelected");
          } else if (btn.label.equals("Zapisz")) {
            if (imgPreview != null) {
              selectOutput("Zapisz obraz jako:", "fileSaved");
            }
          }
        }
      }
    }
  }
  else if (imgPreview != null) {
    if (mouseX >= imgX && mouseX <= imgX + imgW && 
        mouseY >= imgY && mouseY <= imgY + imgH) {
      isSelecting = true;
      hasSelection = false;
      startX = mouseX;
      startY = mouseY;
    }
  }
}

void mouseReleased() {
  if (isSelecting) {
    isSelecting = false;
    hasSelection = true;
    
    if (selW < 2 || selH < 2) {
      hasSelection = false;
    } else {
      applyCurrentFilter();
    }
  }
}

void applyCurrentFilter() {
  if (imgPreview == null) return;

  if (currentFilter.equals("Reset")) {
    imgPreview = imgOriginal.get(); 
    return;
  }
  
  if (!hasSelection) return;

  float scaleFactor = (float)imgPreview.width / imgW;
  
  int realX = int((selX - imgX) * scaleFactor);
  int realY = int((selY - imgY) * scaleFactor);
  int realW = int(selW * scaleFactor);
  int realH = int(selH * scaleFactor);
  
  realX = constrain(realX, 0, imgPreview.width);
  realY = constrain(realY, 0, imgPreview.height);
  if (realX + realW > imgPreview.width) realW = imgPreview.width - realX;
  if (realY + realH > imgPreview.height) realH = imgPreview.height - realY;

  if (realW <= 0 || realH <= 0) return;

  if (currentFilter.equals("Negatyw")) {
    PImage snippet = imgPreview.get(realX, realY, realW, realH);
    snippet.filter(INVERT);
    imgPreview.set(realX, realY, snippet);
  } 
  else if (currentFilter.equals("Szarość")) {
    PImage snippet = imgPreview.get(realX, realY, realW, realH);
    snippet.filter(GRAY);
    imgPreview.set(realX, realY, snippet);
  }
  else if (currentFilter.equals("Progowanie")) {
    PImage snippet = imgPreview.get(realX, realY, realW, realH);
    snippet.filter(THRESHOLD, 0.5);
    imgPreview.set(realX, realY, snippet);
  }
  else if (currentFilter.equals("Rozmycie")) {
    float[][] matrix = {
      { 0.111, 0.111, 0.111 },
      { 0.111, 0.111, 0.111 },
      { 0.111, 0.111, 0.111 } 
    };
    applyMatrix(realX, realY, realW, realH, matrix);
  } 
  else if (currentFilter.equals("Wyostrzanie")) {
    float[][] matrix = {
      {  0, -1,  0 },
      { -1,  5, -1 },
      {  0, -1,  0 } 
    };
    applyMatrix(realX, realY, realW, realH, matrix);
  }
  else if (currentFilter.equals("Płaskorzeźba")) {
    float[][] matrix = {
      { -2, -1,  0 },
      { -1,  1,  1 },
      {  0,  1,  2 } 
    };
    applyMatrix(realX, realY, realW, realH, matrix);
  }
}

void applyMatrix(int x, int y, int w, int h, float[][] matrix) {
  colorMode(RGB, 255);
  
  PImage source = imgPreview.get(x, y, w, h);
  source.loadPixels();
  imgPreview.loadPixels();
  
  int matrixSize = 3; 
  int offset = matrixSize / 2; 

  for (int i = 1; i < w - 1; i++) {
    for (int j = 1; j < h - 1; j++) {
      float rtotal = 0.0;
      float gtotal = 0.0;
      float btotal = 0.0;
      
      for (int ki = 0; ki < matrixSize; ki++) {
        for (int kj = 0; kj < matrixSize; kj++) {
          int loc = (i + ki - offset) + (j + kj - offset) * w;
          color c = source.pixels[loc];
          
          rtotal += (red(c) * matrix[kj][ki]);
          gtotal += (green(c) * matrix[kj][ki]);
          btotal += (blue(c) * matrix[kj][ki]);
        }
      }
      
      rtotal = constrain(rtotal, 0, 255);
      gtotal = constrain(gtotal, 0, 255);
      btotal = constrain(btotal, 0, 255);
      
      int destLoc = (x + i) + (y + j) * imgPreview.width;
      imgPreview.pixels[destLoc] = color(rtotal, gtotal, btotal);
    }
  }
  imgPreview.updatePixels();
  
  colorMode(HSB, 360, 100, 100);
}

void fileSelected(File selection) {
  if (selection == null) return;
  imgOriginal = loadImage(selection.getAbsolutePath());
  if (imgOriginal != null) {
    imgPreview = imgOriginal.get(); 
    calculateImageGeometry(); 
    hasSelection = false; 
  }
}

void fileSaved(File selection) {
  if (selection == null) return;
  
  String path = selection.getAbsolutePath();
  if (!path.toLowerCase().endsWith(".jpg") && 
      !path.toLowerCase().endsWith(".png") && 
      !path.toLowerCase().endsWith(".jpeg")) {
    path += ".jpg";
  }
  
  if (imgPreview != null) {
    imgPreview.save(path);
  }
}

void calculateImageGeometry() {
  if (imgPreview == null) return;
  float targetW = width - 40;
  float targetH = canvasHeight - 40;
  float imgRatio = (float)imgPreview.width / (float)imgPreview.height;
  float canvasRatio = targetW / targetH;
  if (imgRatio > canvasRatio) {
    imgW = targetW;
    imgH = targetW / imgRatio;
  } else {
    imgW = targetH * imgRatio;
    imgH = targetH;
  }
  imgX = (width - imgW) / 2;
  imgY = (canvasHeight - imgH) / 2;
}

class UIElement {
  float x, y, w, h;
  boolean isActive = false;
  UIElement(float x, float y, float w, float h) { this.x = x; this.y = y; this.w = w; this.h = h; }
  void display() {}
  boolean isMouseOver() { return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h; }
}

class ToolButton extends UIElement {
  String label;
  boolean isToggle; 
  ToolButton(float x, float y, float w, float h, String label, boolean isToggle) {
    super(x, y, w, h);
    this.label = label;
    this.isToggle = isToggle;
  }
  @Override
  void display() {
    stroke(colorAccent);
    strokeWeight(2);
    if (isActive) fill(colorActive);
    else {
      if (isMouseOver()) fill(color(hue(colorBackground), saturation(colorBackground), brightness(colorBackground) + 10));
      else fill(colorBackground);
    }
    rect(x, y, w, h);
    fill(isActive ? colorText : colorAccent);
    textAlign(CENTER, CENTER);
    textFont(fontAudiowide);
    textSize(min(16, w/label.length() * 1.8)); 
    text(label, x + w/2, y + h/2 - 2);
  }
}