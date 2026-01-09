int stanGry = 0; 
Player gracz;
Enemy potwor;
Portal portal;
ArrayList<Sciana> sciany;

PVector pozKlucza;
boolean kluczZebrany = false;
boolean gora, dol, lewo, prawo;

int limitCzasu = 20; 
int pozostalyCzas;
int czasStartuMilis;

void setup() {
  size(800, 600);
  resetujGre();
}

void resetujGre() {
  gracz = new Player();
  potwor = new Enemy(100, 50);
  portal = new Portal(720, 80);
  pozKlucza = new PVector(70, 530);
  kluczZebrany = false;
  gora = dol = lewo = prawo = false;
  
  sciany = new ArrayList<Sciana>();
  sciany.add(new Sciana(200, 100, 20, 200));
  sciany.add(new Sciana(400, 400, 20, 200));
  sciany.add(new Sciana(600, 100, 20, 200));
}

void draw() {
  background(20, 20, 35);

  switch(stanGry) {
    case 0:
      wyswietlTekst("UCIECZKA Z LABIRYNTU", "Znajdź klucz i dotrzyj do portalu.\nOmijaj ściany i potwora!\nNaciśnij ENTER, aby zacząć.");
      break;
      
    case 1:
      int uplynietyCzas = (millis() - czasStartuMilis) / 1000;
      pozostalyCzas = limitCzasu - uplynietyCzas;
      
      if (pozostalyCzas <= 0) {
        pozostalyCzas = 0;
        stanGry = 3; 
      }

      for (Sciana s : sciany) s.display();

      if (!kluczZebrany) {
        fill(255, 200, 0);
        ellipse(pozKlucza.x, pozKlucza.y, 30, 30);
        fill(255);
        textSize(12);
        textAlign(CENTER);
        text("KLUCZ", pozKlucza.x, pozKlucza.y - 25);
        
        if (dist(gracz.x, gracz.y, pozKlucza.x, pozKlucza.y) < 45) {
          kluczZebrany = true;
          gracz.maEkwipunek = true;
          portal.czyAktywny = true;
        }
      }

      portal.display();
      potwor.update(gracz.x, gracz.y);
      potwor.display();
      gracz.update(); 
      gracz.display();
      
      fill(255);
      textAlign(LEFT);
      textSize(24);
      text("CZAS: " + pozostalyCzas + "s", 25, 40);
      
      if (dist(gracz.x, gracz.y, potwor.x, potwor.y) < 55) {
        stanGry = 3;
      }
      
      if (kluczZebrany) {
        if (abs(gracz.x - portal.x) < 40 && abs(gracz.y - portal.y) < 50) {
          stanGry = 2;
        }
      }
      break;
      
    case 2:
      wyswietlTekst("WYGRANA!", "Uciekłeś z labiryntu!\nNaciśnij R, aby zagrać ponownie.");
      break;
      
    case 3:
      String powod = (pozostalyCzas <= 0) ? "Czas się skończył!" : "Potwór Cię złapał!";
      wyswietlTekst("PRZEGRANA", powod + "\nNaciśnij R, aby spróbować ponownie.");
      break;
  }
}

void keyPressed() {
  if (stanGry == 0 && keyCode == ENTER) {
    stanGry = 1;
    czasStartuMilis = millis();
  }
  if ((stanGry == 2 || stanGry == 3) && (key == 'r' || key == 'R')) {
    stanGry = 0;
    resetujGre();
  }
  setKlawisz(keyCode, true);
}

void keyReleased() {
  setKlawisz(keyCode, false);
}

void setKlawisz(int k, boolean stan) {
  if (k == UP) gora = stan;
  if (k == DOWN) dol = stan;
  if (k == LEFT) lewo = stan;
  if (k == RIGHT) prawo = stan;
}

void wyswietlTekst(String t1, String t2) {
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(40);
  text(t1, width/2, height/2 - 30);
  textSize(20);
  text(t2, width/2, height/2 + 50);
}

class Sciana {
  float x, y, w, h;
  Sciana(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }
  void display() {
    fill(80, 80, 100);
    noStroke();
    rect(x, y, w, h);
  }
}

class Player {
  float x, y;
  float predkosc = 4;
  float hitBox = 28; 
  PShape calyBohater;
  PShape warstwaEkwipunek;
  boolean maEkwipunek = false;

  Player() {
    x = 720; y = 530;
    calyBohater = loadShape("bohater.svg");
    if (calyBohater != null) warstwaEkwipunek = calyBohater.getChild("ekwipunek");
  }

  boolean sprawdzKolizje(float nx, float ny) {
    for (Sciana s : sciany) {
      if (nx + hitBox > s.x && nx - hitBox < s.x + s.w &&
          ny + hitBox > s.y && ny - hitBox < s.y + s.h) {
        return true;
      }
    }
    return false;
  }

  void update() {
    float moveX = 0;
    float moveY = 0;

    if (gora) moveY -= predkosc;
    if (dol) moveY += predkosc;
    if (lewo) moveX -= predkosc;
    if (prawo) moveX += predkosc;

    if (!sprawdzKolizje(x + moveX, y)) {
      x = constrain(x + moveX, hitBox, width - hitBox);
    }
    if (!sprawdzKolizje(x, y + moveY)) {
      y = constrain(y + moveY, hitBox, height - hitBox);
    }
  }

  void display() {
    if (calyBohater != null) {
      if (warstwaEkwipunek != null) warstwaEkwipunek.setVisible(maEkwipunek);
      shapeMode(CENTER);
      shape(calyBohater, x, y, 70, 70);
    }
  }
}

class Enemy {
  float x, y;
  float predkosc = 1.6;
  PShape calyPotwor;
  PShape warstwaZloc;
  boolean czyZly = false;

  Enemy(float startX, float startY) {
    x = startX; y = startY;
    calyPotwor = loadShape("potwor.svg");
    if (calyPotwor != null) warstwaZloc = calyPotwor.getChild("zloc");
  }

  void update(float graczX, float graczY) {
    if (x < graczX) x += predkosc;
    if (x > graczX) x -= predkosc;
    if (y < graczY) y += predkosc;
    if (y > graczY) y -= predkosc;
    czyZly = (dist(x, y, graczX, graczY) < 180);
  }

  void display() {
    if (calyPotwor != null) {
      if (warstwaZloc != null) warstwaZloc.setVisible(czyZly);
      shapeMode(CENTER);
      shape(calyPotwor, x, y, 75, 75);
    }
  }
}

class Portal {
  float x, y;
  PShape calyPortal;
  PShape warstwaEnergia;
  boolean czyAktywny = false;

  Portal(float sx, float sy) {
    x = sx; y = sy;
    calyPortal = loadShape("portal.svg");
    if (calyPortal != null) warstwaEnergia = calyPortal.getChild("energia");
  }

  void display() {
    if (calyPortal != null) {
      if (warstwaEnergia != null) warstwaEnergia.setVisible(czyAktywny);
      shapeMode(CENTER);
      shape(calyPortal, x, y, 100, 120);
    }
  }
}