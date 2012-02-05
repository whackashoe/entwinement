class Particle {
  	/*
	TODO:
	MAKE XML LOADER FOR PARTICLES SIMILAR TO HOW VEHICLES ARE MADE EXCEPT WE'LL TRY TO IMPLEMENT THE CLONABLE INTERFACE 
	*/
  boolean alive;
  int type;
  /*
  0-fire
  1-blood
  TODO:
  2-explosions
  3-jetpack
  4-vehicles
  5-ambience?
  
  */
  float x;
  float y;
  float z;
  float radius;
  
  float zMinus;  //amount to minus from z
  
  int aliveTimer;
  int colour;  //used for main ellipse background draw
  int alphaT;  //static base alpha transparency- tAlpha is based from this
  float tAlphaTimer;  //countdown to death, gets mapped
  float tAlpha;  //set on a per update basis in regards to talphatimer
  //int tAlphaTimerMap;  //start of countdown
  float alphaTimerMinus;
  
  boolean drawEllipse;
  float ellipseScale;
  boolean drawStroke;
  
  int[] strokeColor;
  int[] ellipseColor;
  int[] fillColorDivisor;
  
  float particles[][];  //HOLDS ALL PARTICLE DATA
  
  
  
  Particle(int type, float x, float y, float radius) {
    alive = true;
    this.type = type;
    this.x = x;
    this.y = y;
    this.radius = radius;
    particles = new float[0][8];  //initialize array
    
    //SET THE FOLLOWING BASED ON TYPE
    if(type == 0) setAsFire();
    else if(type == 1) setAsBlood();
    else if(type == 2) setAsExplosion();
    else if(type == 3) setAsJetfuel();
  }
  
  void setDirection(float angle) {
    for(int i=0; i<particles.length; i++) particles[i][5] = angle;
  }
  
  void update() {
    tAlphaTimer--;
    aliveTimer -= alphaTimerMinus;
    if(aliveTimer < 1 || tAlphaTimer < 1) alive = false;  //it will be time fo dead
    
    z -= zMinus;
    tAlpha = map(tAlphaTimer, 100, 0, 255, 0);
    
    for(int i=0; i<particles.length; i++) {
      particles[i][0] += cos(particles[i][5])*particles[i][7];
      particles[i][1] += sin(particles[i][5])*particles[i][7];
      
      if(particles[i][2] < 0) particles[i][2] -= particles[i][6];  //z -= zspeed
      else particles[i][2] += particles[i][6];  //z+= zspeed
    }
    
    //CHECK FOR MORE TYPES
     render();
  }
  
  void render() {
    pushMatrix();
      translate(x, y, z);
      
      if(drawEllipse) {
        fill(ellipseColor[0], ellipseColor[1], ellipseColor[2], tAlphaTimer);
        ellipse(0, 0, radius*2*ellipseScale, radius*2*ellipseScale);
      }
      
      strokeWeight(1);
           if(drawStroke) {
             stroke(strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]);
           } else {
             stroke(particles[0][4]/7, particles[0][4]/2, particles[0][4], tAlpha);
           }
      
      for(int i=0; i<particles.length; i++) {
        //if(!game.checkRender(x, y, z)) continue;
        pushMatrix();
          translate(particles[i][0], particles[i][1], particles[i][2]+abs(z));
          scale(particles[i][3], particles[i][3]);
          
          if(type == 0) fill(particles[i][4], 0, particles[i][4]/2, tAlpha);
          if(type == 1) fill(particles[i][4]/2+random(particles[i][4]/2), particles[i][4]/2-random(0, 50), particles[i][4]/2-random(0, 50), tAlpha);
          if(type == 2) fill(particles[i][4]/7, particles[i][4]/2, particles[i][4], tAlpha);
          if(type == 3) fill(particles[i][4]/7, particles[i][4], particles[i][4]/2, tAlpha);
          //CHECK FOR MORE TYPES
          if(drawStroke) {
            strokeWeight(1);
            stroke(strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]);
          }
          
          float r = noise(particles[i][5])*2;  //generate radius from movement direction
          ellipse(0, 0, r, r);
          
          //point(particles[i][0], particles[i][1], particles[i][2]+abs(z));
        popMatrix();
      }
    popMatrix();
    noStroke();
  }
  
  void setAsFire() {
    if(radius == -1) radius = random(20, 30);
    z = 2;
    aliveTimer = 60;
    tAlphaTimer = int(random(40, 60));
    
    colour = int(random(100, 255));
    alphaT = int(random(10, 50));
    alphaTimerMinus = 1;
    zMinus = 5;
    
    drawEllipse = true;
    ellipseColor = new int[3];
    ellipseColor[0] = colour;
    ellipseColor[1] = 0;
    ellipseColor[2] = 0;
    ellipseScale = random(1, 2);
    
    particles = new float[int(random(5, 7))][8];
    for(int i=0; i<particles.length; i++) {
      particles[i][0] = random(-radius, radius);  //X
      particles[i][1] = random(-radius, radius);  //Y
      particles[i][2] = random(-5, 10);  //Z
      particles[i][3] = random(radius/5, radius);  //RADIUS
      particles[i][4] = random(colour);  
      particles[i][5] = atan2(particles[i][1]-y, particles[i][0]-x);  //movement direction
      particles[i][6] = random(3, 8);  //zspeed
      particles[i][7] = random(3, 7);  //xyspeed
      
      if(particles[i][2] < 0) particles[i][4] /= 2.5;
    }
  }
  
  void setAsBlood() {
    radius = random(1, 3);
    z = -1;
    aliveTimer = int(random(10, 20));
    tAlphaTimer = int(random(50, 100));
    
    colour = int(random(100, 255));
    alphaT = int(random(10, 50));
    alphaTimerMinus = 3;
    zMinus = random(0, 1);
    
    drawEllipse = false;
  
    particles = new float[int(random(3, 5))][8];
    for(int i=0; i<particles.length; i++) {
      particles[i][0] = 0;  //X
      particles[i][1] = 0;  //Y
      particles[i][2] = random(-5, 2);  //Z
      particles[i][3] = random(radius/5, radius);  //RADIUS
      particles[i][4] = random(colour);  
      particles[i][5] = atan2(particles[i][1]-y, particles[i][0]-x);  //movement direction
      particles[i][6] = 0;  //zspeed
      particles[i][7] = random(-1, 1);  //xyspeed
      
    }
  }
  
  void setAsExplosion() {
    /*if(radius == -1) radius = random(20, 30);
    z = 2;
    aliveTimer = int(random(30, 45));
    tAlphaTimer = int(random(20, 40));
    
    colour = int(random(100, 255));
    alphaT = int(random(10, 50));
    alphaTimerMinus = 1;
    zMinus = 5;
    
    drawEllipse = false;
    ellipseScale = random(2);
    
    drawStroke = true;
    strokeColor = new int[4];
    strokeColor[0] = 255;
    strokeColor[1] = int(random(240, 255));
    strokeColor[2] = int(random(240, 255));
    strokeColor[3] = 50;
    
    particles = new float[int(random(100, 200))][8];
    for(int i=0; i<particles.length; i++) {
      particles[i][0] = random(-radius/10, radius/10);  //X
      particles[i][1] = random(-radius/10, radius/10);  //Y
      particles[i][2] = random(0, -1);  //Z
      particles[i][3] = random(radius*0.8, radius*1.2);  //RADIUS
      particles[i][4] = random(colour);  
      particles[i][5] = atan2(particles[i][1]-y, particles[i][0]-x);  //movement direction
      particles[i][6] = random(0.0, 0.0);  //zspeed
      particles[i][7] = random(5);  //xyspeed
      
      if(particles[i][2] < 0) particles[i][4] /= 2.5;
    }
    */
    if(radius == -1) radius = random(20, 30);
    z = 2;
    aliveTimer = int(random(75, 120));
    tAlphaTimer = int(random(20, 40));
    
    colour = int(random(100, 255));
    alphaT = int(random(10, 50));
    alphaTimerMinus = .4;
    zMinus = 5;
    
    drawEllipse = false;
    ellipseScale = random(2);
    
    drawStroke = true;
    strokeColor = new int[4];
    strokeColor[0] = 255;
    strokeColor[1] = int(random(120, 155));
    strokeColor[2] = int(random(120, 155));
    strokeColor[3] = 50;
    
    particles = new float[int(random(10, 20))][8];
    for(int i=0; i<particles.length; i++) {
      particles[i][0] = random(-radius, radius);  //X
      particles[i][1] = random(-radius, radius);  //Y
      particles[i][2] = random(-5, 10);  //Z
      particles[i][3] = random(radius*0.8, radius*1.2);  //RADIUS
      particles[i][4] = random(colour);  
      particles[i][5] = atan2(particles[i][1]-y, particles[i][0]-x);  //movement direction
      particles[i][6] = random(3, 8);  //zspeed
      particles[i][7] = random(1);  //xyspeed
      
      if(particles[i][2] < 0) particles[i][4] /= 2.5;
    }
  }
  
  void setAsJetfuel() {
    if(radius == -1) radius = random(20, 30);
    z = 2;
    aliveTimer = int(random(30, 45));
    tAlphaTimer = int(random(20, 40));
    
    colour = int(random(100, 255));
    alphaT = int(random(10, 50));
    alphaTimerMinus = 4.4;
    zMinus = 5;
    
    drawEllipse = false;
    ellipseScale = random(2);
    
    drawStroke = true;
    strokeColor = new int[4];
    strokeColor[0] = 255;
    strokeColor[1] = int(random(120, 155));
    strokeColor[2] = int(random(120, 155));
    strokeColor[3] = 50;
    
    particles = new float[int(random(10, 20))][8];
    for(int i=0; i<particles.length; i++) {
      particles[i][0] = random(-radius, radius);  //X
      particles[i][1] = random(-radius, radius);  //Y
      particles[i][2] = random(-5, 10);  //Z
      particles[i][3] = random(radius*0.8, radius*1.2);  //RADIUS
      particles[i][4] = random(colour);  
      particles[i][5] = atan2(particles[i][1]-y, particles[i][0]-x);  //movement direction
      particles[i][6] = random(3, 8);  //zspeed
      particles[i][7] = random(1);  //xyspeed
      
      if(particles[i][2] < 0) particles[i][4] /= 2.5;
    }
  }
}
