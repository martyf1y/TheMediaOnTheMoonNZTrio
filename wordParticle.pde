// Makes all particles draw the next word
void nextWord(String word) {
  // Draw messageRadiusword in memory
  PGraphics pg = createGraphics(messageWidth, messageHeight);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(messageSize);
  pg.textAlign(LEFT);
  PFont font = createFont(fontName, messageSize);
  pg.textFont(font);
  pg.text(word, 0, 0, messageWidth, messageHeight);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to

  for (int i = 0; i < (messageWidth*messageHeight)-1; i+=6) {

    // Only continue if the pixel is not blank
    if (pg.pixels[i] != 0) {
      // Convert index to its coordinates
      int x = i % messageWidth;
      int y = i / messageWidth;

      // Create a new particle
      Particle newParticle = new Particle();     

      newParticle.pos.x = x + messagePositionX-messageWidth/2;
      newParticle.pos.y = y + messagePositionY-messageHeight/2;
      // Assign the particle's new target to seek
      // newParticle.target.x = random(width/2, width/2+rightMoonSize);
      
      if(!goFree){
      int yRadius = int(map(moon.width, 2.5, 2500, 2.2, 2250))/2;
      newParticle.target.y = int(random(-yRadius, yRadius)); 
      // newParticle.target.x = random(width/2, width/2+rightMoonSize);
      
      if (!changeMoon) {
        messageRadius = int(map(maskSize, 0, fullMoonSize/2, 0, yRadius*2));
        messageRadius = int(messageRadius/2);
      } else {
        messageRadius = int(map(maskSize, 0, moonAdjust, 0, yRadius*2));
        messageRadius = int(messageRadius/2);
      }
      // I put the constrain in to stop going past the middle point
      float xRadiusSquared = messageRadius * messageRadius;
      float yRadiusSquared = yRadius * yRadius;
      float ySquared = newParticle.target.y * newParticle.target.y;
      float xValue = sqrt((1 - ySquared/yRadiusSquared)*xRadiusSquared);
      if (changeMoon) {
        xValue *= -1;
      }
      newParticle.target.x = xValue;
      newParticle.target.x += width/2;
      newParticle.target.y += heightPos; // Add the screen position
      }
      else{
      newParticle.target.x = random(moonShift, width*1.5);
      newParticle.target.y = random(-height/2, 0);; // Add the screen position
      }
      newParticle.maxSpeed = random(3.0, 8.0);
      newParticle.maxForce = newParticle.maxSpeed*0.025;
      newParticle.particleSize = 3;
      newParticle.colorBlendRate = random(0.0025, 0.03);

      particles.add(newParticle);

      // Blend it from its current color
      newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = color(235, 200, 131);
      newParticle.colorWeight = 0;
    }
  }
  sizepercent = particles.size();

  // MIGHT NEED THIS FOR DEBUGGING
  // Kill off any left over particles
  /* if (particleIndex < particleCount) {
   for (int i = particleIndex; i < particleCount; i++) {
   Particle particle = particles.get(i);
   particle.kill();
   }
   } */
}

class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);

  float closeEnoughTarget = 30;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  boolean isKilled = false;

  color startColor = color(newColor);
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;

  void move() {
    // Check if particle is close enough to its target to slow down
    float proximityMult = 1.0;
    float easing = 0.05;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      // proximityMult = distance/this.closeEnoughTarget;
    }
    this.maxSpeed = distance*easing; 
    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);

    if (distance <= 8 || this.pos.x >= width+moonShift || this.pos.x <= 0-moonShift || this.pos.y <= 0-300 || this.pos.y >= height) {
      kill();
    }
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
    if (drawAsPoints) {
      stroke(currentColor);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(currentColor);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      // PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      //  this.target.x = target.x;
      //  this.target.y = target.y;

      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;
      this.isKilled = true;
    }
  }
}