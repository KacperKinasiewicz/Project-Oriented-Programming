color colorBackground;
color colorPanel;
color colorAccent;
color colorText;
color colorActive;

float panelHeight;
float margin = 40;
float scrollY = 0;

PFont fontAudiowide, fontPixelify, fontPressStart;
PFont currentFont;
int currentSize = 20;

float cursorX;
float cursorY;

ArrayList<Button> sizeButtons = new ArrayList<Button>();
ArrayList<Button> fontButtons = new ArrayList<Button>();
ArrayList<TextCharacter> textCharacters = new ArrayList<TextCharacter>();

void setup() {
  size(600, 800);
  
  colorMode(HSB, 360, 100, 100);
  strokeCap(SQUARE);
  
  colorBackground = color(230, 80, 15);
  colorPanel = color(230, 70, 25);
  colorAccent = color(170, 100, 100);
  colorText = color(0, 0, 100);
  colorActive = color(170, 100, 80);
  
  panelHeight = height * 0.25;

  fontAudiowide = loadFontSafe("Audiowide.ttf", "Arial");
  fontPixelify = loadFontSafe("PixelifySans.ttf", "Courier New");
  fontPressStart = loadFontSafe("PressStart2P.ttf", "Verdana");
  
  currentFont = fontAudiowide;
  textFont(currentFont);
  textSize(currentSize);
  
  cursorX = margin;
  cursorY = margin + textAscent();

  createInterface();
}

PFont loadFontSafe(String fontName, String fallbackName) {
  PFont loadedFont = createFont(fontName, 32);
  if (loadedFont != null) {
    return loadedFont;
  } else {
    return createFont(fallbackName, 32);
  }
}

void createInterface() {
  float sideMargin = 35;
  float buttonGapSmall = 10;
  float buttonGapLarge = 20;
  float rowGap = 15;
  
  float panelY = height - panelHeight;
  float contentWidth = width - (sideMargin * 2);
  float buttonHeight = 50;
  
  float startY = panelY + (panelHeight - (buttonHeight * 2 + rowGap)) / 2;
  
  int[] availableSizes = {12, 16, 20, 24, 28, 32};
  
  float totalGapWidth = (availableSizes.length - 1) * buttonGapSmall;
  float sizeButtonWidth = (contentWidth - totalGapWidth) / availableSizes.length;
  
  for (int i = 0; i < availableSizes.length; i++) {
    float posX = sideMargin + i * (sizeButtonWidth + buttonGapSmall);
    
    Button btn = new Button(posX, startY, sizeButtonWidth, buttonHeight, str(availableSizes[i]), null, availableSizes[i], 1);
    
    if (availableSizes[i] == currentSize) {
      btn.isActive = true;
    }
    sizeButtons.add(btn);
  }

  PFont[] fontsList = {fontAudiowide, fontPixelify, fontPressStart};
  String[] namesList = {"Audiowide", "Pixelify", "PressStart"};
  
  float totalFontGapWidth = (fontsList.length - 1) * buttonGapLarge;
  float fontButtonWidth = (contentWidth - totalFontGapWidth) / fontsList.length;
  
  float fontRowY = startY + buttonHeight + rowGap;
  
  for (int i = 0; i < fontsList.length; i++) {
    float posX = sideMargin + i * (fontButtonWidth + buttonGapLarge);
    
    Button btn = new Button(posX, fontRowY, fontButtonWidth, buttonHeight, namesList[i], fontsList[i], 0, 2);
    
    if (i == 0) {
      btn.isActive = true;
    }
    fontButtons.add(btn);
  }
}

void draw() {
  background(colorBackground);
  
  pushMatrix();
  translate(0, scrollY);
  textAlign(LEFT);
  
  for (TextCharacter character : textCharacters) {
    character.display();
  }
  
  if (frameCount % 60 < 30) {
    textFont(currentFont);
    textSize(currentSize);
    noStroke();
    fill(colorAccent);
    float cursorHeight = textAscent() + textDescent();
    rect(cursorX, cursorY - textAscent(), 12, cursorHeight);
  }
  popMatrix();

  noStroke();
  fill(colorPanel);
  rect(0, height - panelHeight, width, panelHeight);
  
  stroke(colorAccent);
  strokeWeight(3);
  noFill();
  line(0, height - panelHeight, width, height - panelHeight);
  rect(10, 10, width - 20, height - 20);

  for (Button btn : sizeButtons) {
    btn.display();
  }
  for (Button btn : fontButtons) {
    btn.display();
  }
}

void keyPressed() {
  if (key == CODED) {
    return; 
  }
  
  if (key == BACKSPACE) {
    if (textCharacters.size() > 0) {
      textCharacters.remove(textCharacters.size() - 1);
      
      if (textCharacters.size() > 0) {
        TextCharacter lastChar = textCharacters.get(textCharacters.size() - 1);
        textFont(lastChar.fontUsed);
        textSize(lastChar.sizeUsed);
        cursorX = lastChar.posX + textWidth(lastChar.character);
        cursorY = lastChar.posY;
      } else {
        textFont(currentFont);
        textSize(currentSize);
        cursorX = margin;
        cursorY = margin + textAscent();
      }
    }
  } 
  else if ((key >= ' ' && key <= '~') || key >= 128) {
    textFont(currentFont);
    textSize(currentSize);
    
    float charWidth = textWidth(key);
    
    if (cursorX + charWidth > width - margin) {
      cursorX = margin;
      cursorY += textAscent() + textDescent() + 5;
    }
    
    textCharacters.add(new TextCharacter(key, cursorX, cursorY, currentFont, currentSize));
    cursorX += charWidth;
  } 
  else if (key == ENTER || key == RETURN) {
    textFont(currentFont);
    textSize(currentSize);
    cursorX = margin;
    cursorY += textAscent() + textDescent() + 5;
  }
}

void mouseWheel(MouseEvent event) {
  if (mouseY < height - panelHeight) {
    float direction = event.getCount();
    scrollY -= direction * 20;
    
    if (scrollY > 0) {
      scrollY = 0;
    }
  }
}

void mousePressed() {
  if (mouseY > height - panelHeight) {
    if (checkButtonClick(sizeButtons)) {
      currentSize = getSelectedSize();
    }
    if (checkButtonClick(fontButtons)) {
      currentFont = getSelectedFont();
    }
  }
}

boolean checkButtonClick(ArrayList<Button> buttonsList) {
  boolean wasClicked = false;
  for (Button btn : buttonsList) {
    if (btn.isMouseOver()) {
      for (Button other : buttonsList) {
        other.isActive = false;
      }
      btn.isActive = true;
      wasClicked = true;
    }
  }
  return wasClicked;
}

int getSelectedSize() {
  for (Button btn : sizeButtons) {
    if (btn.isActive) return btn.valueSize;
  }
  return 20;
}

PFont getSelectedFont() {
  for (Button btn : fontButtons) {
    if (btn.isActive) return btn.buttonFont;
  }
  return fontAudiowide;
}

class TextCharacter {
  char character;
  float posX, posY;
  PFont fontUsed;
  int sizeUsed;
  
  TextCharacter(char c, float x, float y, PFont font, int size) {
    character = c;
    posX = x;
    posY = y;
    fontUsed = font;
    sizeUsed = size;
  }
  
  void display() {
    textFont(fontUsed);
    textSize(sizeUsed);
    fill(colorText);
    text(character, posX, posY);
  }
}

class Button {
  PShape shapeObject;
  float posX, posY, widthVal, heightVal;
  String label;
  PFont buttonFont;
  int valueSize;
  int type;
  boolean isActive = false;
  
  Button(float x, float y, float w, float h, String l, PFont font, int val, int t) {
    posX = x;
    posY = y;
    widthVal = w;
    heightVal = h;
    label = l;
    buttonFont = font;
    valueSize = val;
    type = t;
    
    shapeObject = createShape(RECT, 0, 0, widthVal, heightVal);
    shapeObject.setStrokeWeight(2);
  }
  
  void display() {
    pushMatrix();
    translate(posX, posY);
    
    if (isActive) {
      shapeObject.setFill(colorActive);
      shapeObject.setStroke(colorAccent);
    } else {
      shapeObject.setFill(colorPanel);
      shapeObject.setStroke(colorAccent);
    }
    shape(shapeObject);
    
    if (isActive) {
      fill(colorBackground);
    } else {
      fill(colorAccent);
    }
    
    textAlign(CENTER, CENTER);
    
    if (type == 1) { 
      textFont(currentFont);
      textSize(valueSize);
    } else { 
      textFont(buttonFont);
      
      float labelSize = 18;
      if (label.equals("Pixelify")) {
        labelSize = 21.6;
      } else if (label.equals("PressStart")) {
        labelSize = 14.4;
      }
      textSize(labelSize);
    }
    
    text(label, widthVal/2, heightVal/2);
    popMatrix();
  }
  
  boolean isMouseOver() {
    return mouseX >= posX && mouseX <= posX + widthVal && 
           mouseY >= posY && mouseY <= posY + heightVal;
  }
}
