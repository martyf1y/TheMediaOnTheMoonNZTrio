
class Fireflies {
  float x, y, r, fx, fy;
  color c;
//  int i=1, j=1;
  color t = color(0, 0, 0); 
  ;
  Fireflies(int rX)
  {
    x = random(0, width);
    y = random(0, height-100);
    r = rX;
    fx = random(-0.9, 0.9);
    fy = random(-0.9, 0.9);
  }

  void display()
  {

    //color t = color(0,0,0); 
    int ik = (int)random(0, 60*r);
      if (ik==1*r) t= color(255, 201, 201, 255);
      if (ik==2*r) t= color(192, 209, 255, 255);
      if (ik==3*r) t= color(237, 238, 255, 255);
      if (ik==4*r) t= color(255, 249, 249, 255);
      if (ik==5*r) t= color(255, 241, 223, 255);
      if (ik==6*r) t= color(255, 215, 224, 255);
      if (ik==7*r) t= color(255, 221, 197, 255);
      if (ik==8*r) t= color(240, 230, 140, 255);
      if (ik==8*r) t= color(255, 255, 102, 255);

    //---------------blur/glow ----------
    float h = 3;
    for (float r1 = r*4; r1 > 0; --r1) {
      fill(t, h);
      noStroke();
      ellipse(x, y, r1, r1);
      h=(h+2);
    }
    noStroke();

    fill(t);
    ellipse(x, y, r, r);
  }

  /*void update() {
    if (r>3) {
      x = x + j*fx;
      y = y + i*fy;
    }
    if (y > height-200-r) i=-1;
    if (y < 0+r) i=1;
    if (x > width-r) j=-1;
    if (x < 0+r) j=1;
  }*/
}