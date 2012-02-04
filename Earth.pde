class Earth {
  FCircle earth;
  float radius;
  int initTime;
  boolean created;
  float size;
  int detail;
  
  int sDetail;
  int sWeight;
  
  Earth(float x_, float y_, float radius_, float size_, int detail_) {
    initTime = 3;
    created = false;
    radius = radius_;
    earth = new FCircle(radius*2);
    earth.setPosition(x_, y_);
    earth.setSensor(true);
    earth.setDensity(0);
    earth.setRestitution(0);
    earth.setFriction(0);
    //world.add(earth);
    
    sDetail = 20;
    sWeight = 50;
    size = size_;
    detail = detail_;
  }
  
  void update() {
    if(initTime > 0) initTime--;
    else if(!created) createEdge(size, detail);
    if(settings.drawEarths) render();
  }
  
  void render() {
    pushMatrix();
      translate(earth.getX(), earth.getY());
      scale(earth.getSize()/2);
      sphereDetail(sDetail);
      //strokeWeight(sWeight);
      //stroke(map(game.meCast.health, 0, 100, 255, 0), game.meCast.gunAngle+PI*(512/TWO_PI), game.meCast.earthAngle+PI*(512/TWO_PI));
      //stroke(map(game.meCast.health, 0, 100, 255, 0), 0, 0, 10);
      fill(getRedAmount(), game.meCast.gunAngle+PI*(255/TWO_PI), game.meCast.earthAngle+PI*(256/TWO_PI), 100);
      sphere(1);
      noStroke();
    popMatrix();
  }
  
  int getRedAmount() {  //RETURNS RED VALUE FOR EARTH BASED ON SHIT HAPPENIN
    float distance = 1000;  //HOW FAR AWAY TO LOOK
    int r = 0;
    for(int i=0; i<game.bulletData.size(); i++) {
      Bullet ph = (Bullet) game.bulletData.get(i);
      if(dist(game.meCast.self.getX(), game.meCast.self.getY(), ph.b.getX(), ph.b.getY()) < distance) r += 2;
      r += 1;
    }
    for(int i=0; i<game.explosionData.size(); i++) {
      Explosion ph = (Explosion) game.explosionData.get(i);
      if(dist(game.meCast.self.getX(), game.meCast.self.getY(), ph.x, ph.y) < distance) r += 15;
      r += 5;
    }
    return r;
  }
  
  void createEdge(float size_, int detail_) {
    if(detail_ < 3) detail_ = 3; 
    PVector[] pData = new PVector[detail_];  //HOLDS ALL POINT DATA
    float[][] tData = new float[detail_][6];  //HOLDS ALL POLY DATA
    float step =((PI*2)/detail_);
    float current = 0;
    //GENERATE POINTS
    for(int i=0; i<detail_; i++) {
      pData[i] = new PVector(sin(current) * radius, cos(current) * radius);
      current += step;
    }
    //TURN POINTS INTO TRIANGLES
    for(int i=0; i<detail_; i++) {
      tData[i][0] = earth.getX();  //SET IN CENTER X
      tData[i][1] = earth.getY();  //SET IN CENTER Y
      tData[i][2] = tData[i][0]+pData[i].x;  //SET AS POINT X
      tData[i][3] = tData[i][1]+pData[i].y;  //SET AS POINT Y
      if(i != detail_-1) {  //SET AS NEXT POINT
        tData[i][4] = tData[i][0]+pData[i+1].x;
        tData[i][5] = tData[i][1]+pData[i+1].y;
      } else {  //SET AS FIRST POINT
        tData[i][4] = tData[i][0]+pData[0].x;
        tData[i][5] = tData[i][1]+pData[0].y;
      }
      
      //SET FIRST POINTS TO SIZE_ AWAY FROM OTHER POINTS DEEP
      float cAngle = atan2(tData[i][1]-(tData[i][3]+tData[i][5])/2, tData[i][0]-(tData[i][2]+tData[i][4])/2);  //SETS ANGLE FROM CENTER OF TWO OUTERMOST POINTS TO EARTH CENTER
      tData[i][0] -= cos(cAngle)*(map(size_, 0, radius, radius, 0)-radius/2);
      tData[i][1] -= sin(cAngle)*(map(size_, 0, radius, radius, 0)-radius/2);
    }
    //CREATE PHYSICAL POLYGONS FROM DATA
    for(int i=0; i<detail_; i++) {
      addPoly(tData[i][0], tData[i][1], tData[i][2], tData[i][3], tData[i][4], tData[i][5], 0, 0.2, 0.01, 0, 0, 0, 100);
      
      if(i != detail_-1) addPoly(tData[i][0], tData[i][1], tData[i+1][0], tData[i+1][1], tData[i][4], tData[i][5], 0, 1, 0.01, i*25, i*30, i*10, 50);
      else addPoly(tData[i][0], tData[i][1], tData[0][0], tData[0][1], tData[i][4], tData[i][5], 0, 1, 0.01, i*25, i*30, i*10, 50);
    }
    created = true;
  }
  
  void addPoly(float x1_, float y1_, float x2_, float y2_, float x3_, float y3_, float de_, float re_, float fr_, int r_, int g_, int b_, int a_) {
    game.polyData.add(new Polygon(0, x1_, y1_, x2_, y2_, x3_, y3_, de_, re_, fr_, r_, g_, b_, a_));
  }
  
  void delete() {
    world.remove(earth);
  }
}
