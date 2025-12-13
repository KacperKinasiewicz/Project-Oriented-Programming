void setup() {
  size(600, 800); 
  // tryb hsb zeby latwiej zmieniac jasnosc
  colorMode(HSB, 360, 100, 100);
  smooth(); 
  strokeCap(SQUARE); // kwadratowe zakonczenia linii
}

void draw() {
  background(230, 80, 20); 
  
  // przesuwam 0,0 na srodek zeby latwiej obracac
  translate(width / 2, height / 3);
  
  rysujWahadlo();
  rysujTarcze();
  rysujWskazowki();
}

void rysujWahadlo() {
  pushMatrix(); 
  
  // sinus daje ruch niejednostajny (bujanie)
  float pendulumAngle = sin(frameCount * 0.05) * (PI / 4);
  
  rotate(pendulumAngle); 
  
  // mapuje wychylenie na jasnosc - im dalej tym ciemniej
  float brightnessVal = map(abs(pendulumAngle), 0, PI/4, 100, 50);
  
  stroke(160, 60, 60); 
  strokeWeight(4);     
  line(0, 0, 0, 360); 
  
  noStroke();
  fill(160, 100, brightnessVal); 
  
  pushMatrix();
  translate(0, 360);
  rotate(PI/4); // obracam kwadrat
  rectMode(CENTER);
  rect(0, 0, 50, 50);
  popMatrix();
  
  popMatrix(); // reset macierzy
}

void rysujTarcze() {
  fill(210, 60, 30); 
  stroke(170, 100, 100); 
  strokeWeight(10);      
  ellipse(0, 0, 420, 420); 

  // cyfry
  fill(170, 20, 100); 
  textAlign(CENTER, CENTER); 
  
  for (int i = 1; i < 13; i++) {
    pushMatrix(); 
    rotate(radians(i * 30)); // co 30 stopni
    translate(0, -185); // odsuwam na krawedz
    
    rotate(radians(-i * 30)); // odkrecam tekst zeby byl prosto
    
    textSize(24); 
    text(i, 0, 0);

    popMatrix();
  }
  
  // kreski minutowe
  stroke(170, 100, 100); 
  strokeWeight(2);
  for (int i = 0; i < 60; i++) {
    if (i % 5 != 0) { 
      pushMatrix();
      rotate(radians(i * 6)); // co 6 stopni
      translate(0, -190);
      line(0, 0, 0, 10); 
      popMatrix();
    }
  }
}

void rysujWskazowki() {
  float s = second();
  float m = minute();
  // dodaje minuty do godziny dla plynnosci
  float h = hour() + m / 60.0; 

  // --- RYSOWANIE ---
  
  // godzina
  pushMatrix();
  // odejmuje 90 stopni bo 0 to godzina 3
  float hAngle = map(h % 12, 0, 12, 0, TWO_PI) - HALF_PI;
  rotate(hAngle);
  stroke(200, 80, 90); 
  strokeWeight(12);
  line(0, 0, 110, 0); 
  popMatrix();
  
  // minuta
  pushMatrix();
  float mAngle = map(m, 0, 60, 0, TWO_PI) - HALF_PI;
  rotate(mAngle);
  stroke(160, 90, 90); 
  strokeWeight(6);
  line(0, 0, 170, 0); 
  popMatrix();
  
  // sekunda
  pushMatrix();
  float sAngle = map(s, 0, 60, 0, TWO_PI) - HALF_PI;
  rotate(sAngle);
  stroke(100, 100, 100); 
  strokeWeight(3);
  line(-30, 0, 180, 0); 
  
  popMatrix();
  
  // srodek
  fill(230, 80, 20); 
  stroke(170, 100, 100); 
  strokeWeight(3);
  ellipse(0, 0, 20, 20);
}
