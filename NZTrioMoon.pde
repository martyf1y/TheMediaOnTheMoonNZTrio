//twitter
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;

Twitter twitter;
String searchString = "nztrio";
List<Status> tweets;
int currentTweet;
Status status;
String thisTwit;
String[] theTweets = new String[20];
int tweetPacket = 12;
boolean newTweet = false;
boolean notweets = true;
int tweetCounter = 0;

// Word particle variables
ArrayList<Particle> particles = new ArrayList<Particle>();
int pixelSteps = 1; // Amount of pixels to skip
boolean drawAsPoints = true;
int wordIndex = 0;
int messageWidth = 580;
int messageHeight = 200;
int messagePositionX;
int messagePositionY;
int messageSize = 31;
color bgColor = color(0, 20, 40, 40);
String fontName = "Gabriola";
Boolean runAway = false;
color newColor;
boolean goFree = false;
color[] QColor = new color[7];
boolean goAgain = true;

///// Word timers
int wordEndTime = 11000;
int wordTimer;
float longEndTime = 300000;
int longTimer;
boolean waitType = false;
int stringCount = 0;
String message;
String[] defaultMessage = new String[6]; 

//// Moon masking
PGraphics moon_Masking, theMoon;
int playerX, playerY;
int hit = 0;
//// Moon sizes
int leftMoonSize = 0;
int fullMoonSize = 620;
int moonAdjust = int(map(fullMoonSize, 150, 1500, 250, 2500));
int heightPos;
//int arcAdjust = int(map(moonAdjust, 250, 2500, 225, 2250));
float maskSize = fullMoonSize/2;
boolean changeMoon = false;
PImage moon, rightMoon, leftMoon, cropLeftMoon, moonShade, rightMoonShade;
float moonRotation = 0;
float messageRadius;
int moonShift = 180;
float sizepercent = 0;

//// Fireflies
ArrayList poop; // Star Particles

/// BG
color b1, b2, c1, c2;
int Y_AXIS = 1;
PGraphics BG;
PImage gradBackground;

int checkHour = 0;


int hourTimer = 0;
 boolean stopRotation = false;
void setup()
{
  //size(1280, 720);
  fullScreen();
  noCursor();
  smooth();
  String lines[] = loadStrings("info.txt");
  String[] list = split(lines[0], '*');
   maskSize = float(list[0]);
   changeMoon = boolean(list[1]);
   moonRotation = int(list[2]);
  heightPos = height/2-height/10;
  messagePositionX = width/2;
  messagePositionY = height-height/17;

  //Fireflies
  poop = new ArrayList();
  for (int i=0; i<50; i++) {
    Fireflies P = new Fireflies(1);
    poop.add(P);
  }
  for (int i=0; i<45; i++) {
    Fireflies P = new Fireflies(2);
    poop.add(P);
  }
  for (int i=0; i<10; i++) {
    Fireflies P = new Fireflies(3);
    poop.add(P);
  }
    for (int i=0; i<6; i++) {
    Fireflies P = new Fireflies(4);
    poop.add(P);
  }
  // Define colors for background
  b1 = color(0);
  b2 = color(0, 15, 50);
  //  b2 = color(0, 26, 38);
  c1 = color(0, 15, 50);
  c2 = color(102, 51, 0);


  QColor[0] = color(250, 198, 0);
  QColor[1] = color(113, 24, 196);
  QColor[2] = color(255, 185, 15);
  QColor[3] = color(124, 252, 0);
  QColor[4] = color(156, 42, 200);
  QColor[5] = color(255, 255, 255);
  QColor[6] = color(235, 200, 131);




  BG = createGraphics(width, height);
  //I have put it so you create the BG in the function
  setGradient(0, 400, width, height, c1, c2, Y_AXIS);
  setGradient(0, 0, width, 400, b1, b2, Y_AXIS);  
  gradBackground = BG.get();


  //twitter
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("");
  cb.setOAuthConsumerSecret("");
  cb.setOAuthAccessToken("");
  cb.setOAuthAccessTokenSecret("");

  // Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();
  //getNewTweets();
  currentTweet = 0;
 // thread("refreshTweets");

  ////// Moon
  resetMoonSetup();

  updateMoon();

  defaultMessage[0] = "Get your #Glow on and send your loved ones a message via the Moon.";
  defaultMessage[1] = "Visit www.nztrio.com/event-directory for NZTrio GLOW concert info.";
  defaultMessage[2] = "We hope to see you in the audience on Sept. 25 or 27th at GLOW.";
  defaultMessage[3] = "Thankyou everyone for supporting the arts in whatever way you do.";
  defaultMessage[4] = "NZTrio wishes everyone a happy Moon Festival.";
  defaultMessage[5] = "Celebrate the Moon Festival and send your wishes to #GLOW.";

  hourTimer = hour();
  frameRate(60);
}

void draw()
{
  //background(244);
  background(0, 20, 40);
  imageMode(CENTER);
  tint(255, 255, 102);
  image(gradBackground, width/2, height/2, width, height);
  noTint();

  for (int i=0; i<poop.size(); i++) {
    Fireflies Pn1 = (Fireflies) poop.get(i);
    Pn1.display();
    // Pn1.update();
  }

  pushMatrix();
  translate(-moonShift, 0);

  drawMoon();
  updateMessage();   

  // CLEAR BACKGROUND
  if (runAway && !waitType) {
    for (int x = particles.size() -1; x > -1; x--) {
      // Simulate and draw pixels
      Particle particle = particles.get(x);
      // particle.target.x = width/2+fullMoonSize/2-15-moonTarget;
      particle.move();  
      particle.draw();

      // Remove any dead pixels out of bounds
      if (particle.isKilled ) {
        particles.remove(particle);
        if(!goFree){ // only take away when new
        float pixelPercent = 1/sizepercent;
        if (!changeMoon) {
          float halfCircle = pixelPercent*(fullMoonSize/2);
          float oneDay = halfCircle/4;
          maskSize -= oneDay/tweetPacket;  
          if (maskSize <= 1) {
            maskSize = 0;
            changeMoon = true;
          }
        } else {
          if (maskSize >= moonAdjust) {
            goFree = true;
            maskSize = moonAdjust;
          } else {
            float halfCircle = pixelPercent*(moonAdjust);
            float oneDay = halfCircle/3.1;
            maskSize += oneDay/tweetPacket;
          }
        }
      }
      }
    }

    updateMoon(); 

    //Stop adding to only one per frame

    if (particles.size() == 0) {
      runAway = false; 
      waitType = false;
      wordTimer = millis(); // resets time
      
      String[] info = {str(maskSize) + "*" + str(changeMoon)+"*"+str(moonRotation)};
      saveStrings("info.txt", info);  

    }
  }
  ////////// MESSAGE //////////
  fill(newColor);
  textSize(messageSize);
  textAlign(LEFT);
  PFont font = createFont(fontName, messageSize);
  textFont(font);
  if (waitType) {
    text(message, messagePositionX-messageWidth/2, messagePositionY-messageHeight/2, messageWidth, messageHeight);
    if (!runAway) {
      wordTimer = millis(); // resets timer
    }
  }
  messageRadius = map(maskSize, 0, fullMoonSize/2, 0, moonAdjust/4 - 30);
  //int moonArcAdjust = int(map(moon.width, 250, 2500, 225, 2250));
  //int moonArcAdjustX = int(map(maskSize, 0, fullMoonSize/2, 0, moonArcAdjust));

  //  arc(width/2, heightPos,  moonArcAdjustX,moonArcAdjust, -HALF_PI, HALF_PI);

  popMatrix();

  fill(0);
  noStroke();
  rect(0, 0, width/8-30, height);
  rect(width-width/8 +50, 0, width/8, height);
  //  println("Frames: " + frameRate);
/* String timers = "TIMER Tweet " + str(millis()-wordTimer) + " / " + wordEndTime + "\n";
 timers += "Old Tweet " + str(millis()-wordTimer) + " / " + str(wordEndTime + 20000) + "\n";
 timers += "Default Message " + str(millis()-longTimer) + " / " + longEndTime + "\n";
 timers += "Hour Check " + str(hour()*10+(int(map(60, 0, 60, 0, 10)))) + " = " + 48 % 24 + "\n";

 timers += "New Tweet? " +  (newTweet?"YES":"NO") + "\n"; 
   fill(255);
   text(timers, width/2+width/4, 20);*/
  
  if(hour() == 0){
    tweetCounter = 0;
    tweetPacket = 12;
  }
  if(tweetCounter>=10){
   tweetPacket = 16; 
  }
}

void mask(PImage target, PImage mask) {
  mask.loadPixels();
  target.loadPixels();
  if (mask.pixels.length != target.pixels.length) {
    println("Images are not the same size");
  } else {
    for (int i=0; i<target.pixels.length; i++) {
      target.pixels[i] = ((mask.pixels[i] & 0xff) << 24) | (target.pixels[i] & 0xffffff);
    }
    target.updatePixels();
  }
}


void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
  noFill();
  BG.beginDraw();
  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      BG.stroke(c);
      BG.line(x, i, x+w, i);
    }
  }
  BG.endDraw();
}

// Toggle draw modes
void keyPressed() {
  if (key == 'p') {
    drawAsPoints = (! drawAsPoints);
    if (drawAsPoints) {
      background(0);
      bgColor = color(0, 20, 40, 40);
    } else {
      background(255);
      bgColor = color(0, 20, 40, 100);
    }
  }
  if (key == 'w' ) {
    heightPos -=10;
  } else if (key == 's' ) {
    heightPos +=10;
  }
  if (key == ' ' || key == 'z' || key == 'x') {
    if (key == ' ' ) {    
      leftMoonSize = 0;
      fullMoonSize = 430;
    } else if (key == 'z') {
      fullMoonSize +=10;
    } else {
      fullMoonSize -=10;
    }
    moonAdjust = int(map(fullMoonSize, 150, 1500, 250, 2500));
    //arcAdjust = int(map(moonAdjust, 250, 2500, 225, 2250));
    ////// Moon
    resetMoonSetup();
    updateMoon();
  }
}
