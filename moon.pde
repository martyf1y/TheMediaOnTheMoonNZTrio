
void resetMoonSetup() {
  moon = loadImage("moonFest.png");
  imageMode(CENTER);
  moon.resize(fullMoonSize,0);
  moon_Masking = createGraphics(moon.width, moon.height);
  moon_Masking.imageMode(CENTER);
 int moonArcAdjust = int(map(moon.width, 250, 2500, 225, 2250));
 
  PGraphics rightArc = createGraphics(moonAdjust, moonAdjust);
  rightArc.beginDraw();
  rightArc.background(0, 0, 0, 255);
  rightArc.fill(255, 255);
  rightArc.noStroke();
  rightArc.ellipseMode(CENTER);
  rightArc.ellipse(rightArc.width/2, rightArc.height/2, moonArcAdjust, moonArcAdjust);
  rightArc.filter(BLUR, 4);
  rightArc.endDraw();
  rightMoon = rightArc.get(moonAdjust/2, 0, moonAdjust/2, moonAdjust);

  PGraphics leftArc = createGraphics(moonAdjust, moonAdjust);
  leftArc.beginDraw();
  leftArc.background(0, 0, 0, 255);
  leftArc.fill(255, 255);
  leftArc.noStroke();
  leftArc.ellipseMode(CENTER);
  leftArc.ellipse(leftArc.width/2, leftArc.height/2, moonArcAdjust, moonArcAdjust);
  leftArc.filter(BLUR, 4);
  leftArc.endDraw();
  leftMoon = leftArc.get(0, 0, moonAdjust, moonAdjust);

  PGraphics shade = createGraphics(fullMoonSize, fullMoonSize);
  shade.beginDraw();
  shade.background(0, 0, 0, 0);
  shade.fill(0, 255);
  shade.noStroke();
  shade.ellipseMode(CENTER);
  int moonShadeAdjust = int(map(fullMoonSize, 150, 1500, 140, 1400));
  shade.ellipse(shade.width/2, shade.height/2, moonShadeAdjust, moonShadeAdjust);
  shade.filter(BLUR, 4);
  shade.endDraw();
  moonShade = shade.get(0, 0, fullMoonSize, fullMoonSize);
  rightMoonShade = shade.get(fullMoonSize/2, 0, fullMoonSize/2, fullMoonSize);
  
  theMoon = createGraphics(moon.width, moon.height);
  theMoon.imageMode(CENTER);
  //theMoon.ellipseMode(CENTER);
  theMoon.beginDraw();
  theMoon.background(0, 0, 0);
  theMoon.translate(moon.width/2, moon.height/2);
 // theMoon.rotate(radians(millis())/100);
  theMoon.image(moon, 0, 0);
  theMoon.endDraw();
}


void updateMoon() {
 
  // DRAW FLASHLIGHT MASK
  moon_Masking.beginDraw();
  moon_Masking.background(0);
  moon_Masking.imageMode(CENTER);
  if (changeMoon == true) {
    moon_Masking.image(leftMoon, moon.width/2, moon.height/2, maskSize, moonAdjust);
  }
  
  moon_Masking.image(rightMoon, moon.width/2+moonAdjust/4, moon.height/2, moonAdjust/2, moonAdjust);
  
  moon_Masking.endDraw();
  // APPLY FLASHLIGHT MASK TO FRAME
  mask(theMoon, moon_Masking);
}

void drawMoon() {
  // DRAW NEW FRAME
  
   if(second() == 1 && !stopRotation){
     stopRotation = true;
  // println("YES " + second() + " : " + moonRotation);
   moonRotation += 0.2;
   if(moonRotation >= 360){
     moonRotation = 0;
   }
   theMoon = createGraphics(moon.width, moon.height);
   theMoon.imageMode(CENTER);
   theMoon.beginDraw();
   theMoon.background(0, 0, 0);
   theMoon.translate(moon.width/2, moon.height/2);
   theMoon.rotate(radians(moonRotation));
   theMoon.image(moon, 0, 0);
   theMoon.endDraw();
   updateMoon();
    String[] info = {str(maskSize) + "*" + str(changeMoon)+"*"+str(moonRotation)};
    saveStrings("info.txt", info);  
   }
   else if(second() != 1){
     stopRotation = false;
   }
 
  imageMode(CENTER);
  noStroke();
  fill(0, 255);
  //tint(255, 255);
  image(moonShade, width/2, heightPos); // The dark moon

 // tint(254, 252, 215, 255);
  tint(235,  200,  131);
  image(theMoon, width/2, heightPos, fullMoonSize, fullMoonSize); // The Moon!!!
  noTint();
  if(!changeMoon){
  fill(0);
  imageMode(CORNER);
  image(rightMoonShade, width/2, heightPos - fullMoonSize/2, maskSize, fullMoonSize); // The dark moon
  //  arc(width/2, height/2-100, moonSize/2+8, 258, -HALF_PI, HALF_PI);
  }
}