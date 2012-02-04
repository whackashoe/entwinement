class Vehicle {
  int id;
  int type;
  String name;
  boolean justData;
  boolean alive;
  boolean isInhabited = false;
  boolean landed = false;
  boolean ai = false;  
  boolean correctSpeed = true;
  float health = 300;
  float startingHealth;
  float fireHealth;
  int minParts;
  ArrayList parts;
  ArrayList connections;
  int[] partType = new int[0];  //0 is box, 1 is circle, 2 is tri-poly
  int[] connectType = new int[0];  //0 is dist, 1 is pris, 2 is revo
  
  float xForce = 0;  //between -1 and 1 (0 is not moving)
  float yForce = 0;  //between -1 and 1
  
  float xfDecrement = 0.01;  //WHATS DECREASED from xforce
  float yfDecrement = 0.01;  //WHATS DECREASED
  
  float xIncrement = 0.02;  //whats added to xforce
  float yIncrement = 0.02;  //should keep quite tiny(0.01?)
  
  float maxVelo = 300;
  
  float exitX1;
  float exitY1;
  float exitX2;
  float exitY2;
  
  float grappleX;
  float grappleY;
  
  float explosionMult = 1;
  float scale = 1;
  float x;
  float y;
  
  Soldier soldierCast;
  
  Vehicle(boolean justData_) {
    justData = true;
    parts = new ArrayList();
    connections = new ArrayList();
  }
  
  Vehicle(PVector pos_, int type_) {
    type = type_;
    Vehicle loadCast = (Vehicle) baseVehicleData.get(type_);
    
    float tX = pos_.x;
    float tY = pos_.y;
    
    alive = true;
    id = int(random(0, Integer.MAX_VALUE));
    if(game.jython != null) game.jython.onVehicleAdd(id, type_, pos_.x, pos_.y);
    
    parts = new ArrayList();
    connections = new ArrayList();
    
    setHealth(loadCast.health, loadCast.fireHealth);
    setName(loadCast.name);
    setMinParts(loadCast.minParts);
    setExplodeMult(loadCast.explosionMult);
    setScale(loadCast.scale);
    setExits(loadCast.exitX1, loadCast.exitY1, loadCast.exitX2, loadCast.exitY2);
    setForces(loadCast.xIncrement, loadCast.yIncrement, loadCast.xfDecrement, loadCast.yfDecrement);
    setGrapple(loadCast.grappleX, loadCast.grappleY);
    setCorrectSpeed(loadCast.correctSpeed);
    setMaxVelo(loadCast.maxVelo);
    
    isInhabited = loadCast.isInhabited;
    landed = loadCast.landed;
    ai = loadCast.ai;  
    partType = loadCast.partType;
    connectType = loadCast.partType;

    for(int i=0; i<loadCast.parts.size(); i++) {
      /***********************8
      * FIX WITH GETBODY() 
      * 
      *
      *
      **********************/
      Vehicle.Part partCast = (Vehicle.Part) loadCast.parts.get(i);
      if(partCast.square) {
        if(!game.upsideDownMode) {
          parts.add(new Part(tX+partCast.xOff, tY+partCast.yOff, partCast.p.getWidth(), partCast.p.getHeight(), partCast.den, this));
        } else {
          parts.add(new Part(tX+partCast.xOff, tY-partCast.yOff, partCast.p.getWidth(), partCast.p.getHeight(), partCast.den, this));
        }
        //parts.add(new Part(tX+partCast.xOff, tY+partCast.yOff, partCast.p.getWidth(), partCast.p.getHeight(), partCast.den, this));
      } else if(partCast.wheel) {
        if(!game.upsideDownMode) {
          parts.add(new Part(tX+partCast.xOff, tY+partCast.yOff, partCast.w.getSize(), partCast.den, this));
        } else {
          parts.add(new Part(tX+partCast.xOff, tY-partCast.yOff, partCast.w.getSize(), partCast.den, this));
        }
        //parts.add(new Part(tX+partCast.xOff, tY+partCast.yOff, partCast.w.getSize(), partCast.den, this));
      } else if(partCast.polygon) {
        if(!game.upsideDownMode) {
          parts.add(new Part(tX+partCast.polyVertexX1, tY+partCast.polyVertexY1, tX+partCast.polyVertexX2, tY+partCast.polyVertexY2, tX+partCast.polyVertexX3, tY+partCast.polyVertexY3, partCast.den, this));
        } else {
          parts.add(new Part(tX+partCast.polyVertexX1, tY-partCast.polyVertexY1, tX+partCast.polyVertexX2, tY-partCast.polyVertexY2, tX+partCast.polyVertexX3, tY-partCast.polyVertexY3, partCast.den, this));
        }
        //parts.add(new Part(tX+partCast.xOff, tY+partCast.yOff, partCast.w.getSize(), partCast.den, this));
      }
      
      Vehicle.Part curPartCast = (Vehicle.Part) parts.get(parts.size()-1);
      curPartCast.health = partCast.health;
      curPartCast.fireHealth = partCast.fireHealth;
      curPartCast.startingHealth = partCast.startingHealth;
      curPartCast.propellor = partCast.propellor;
      curPartCast.cockpit = partCast.cockpit;
      curPartCast.missile = partCast.missile;
      curPartCast.square = partCast.square;
      curPartCast.wheel = partCast.wheel;
      curPartCast.polygon = partCast.polygon;
      curPartCast.collider = partCast.collider;
      curPartCast.frame = partCast.frame;
      curPartCast.touchingPoly = partCast.touchingPoly;
      curPartCast.landingGear = partCast.landingGear;
      curPartCast.gun = partCast.gun;
      curPartCast.drawImage = partCast.drawImage;
      curPartCast.keyRotatable = partCast.keyRotatable;
      curPartCast.scaleImage = partCast.scaleImage;
      curPartCast.img = partCast.img;
      curPartCast.xStrength = partCast.xStrength;
      curPartCast.yStrength = partCast.yStrength;
      curPartCast.propellorLift = partCast.propellorLift;
      curPartCast.missileX = partCast.missileX;
      curPartCast.missileY = partCast.missileY;
      curPartCast.missileStrength = partCast.missileStrength;
      curPartCast.rotateStrength = partCast.rotateStrength;
      curPartCast.rotateMax = partCast.rotateMax;
      curPartCast.gunX = partCast.gunX;
      curPartCast.gunY = partCast.gunY;
      curPartCast.customGun = partCast.customGun;
      curPartCast.curGun = partCast.curGun;
      curPartCast.den = partCast.den;
      curPartCast.xOff = partCast.xOff;
      curPartCast.yOff = partCast.yOff;
      
      for(int k=0; k<partCast.polyData.size(); k++) {
        Polygon polyCast = (Polygon) partCast.polyData.get(i);
        curPartCast.addPoly(polyCast.x[0], polyCast.y[0], polyCast.z[0], polyCast.x[1], polyCast.y[1], polyCast.z[1], polyCast.x[2], polyCast.y[2], polyCast.z[2], 255, 255, 255, 255);
        Polygon curPolyCast = (Polygon) curPartCast.polyData.get(curPartCast.polyData.size()-1);  //THE POLY WE JUST ADDED SO WE CAN ADD VERTICE SPECIFIC COLORS
        for(int v=0; v<3; v++) {
          curPolyCast.vR[v] = polyCast.vR[v];
          curPolyCast.vG[v] = polyCast.vG[v];
          curPolyCast.vB[v] = polyCast.vB[v];
          curPolyCast.vA[v] = polyCast.vA[v];
        }
      }
      
      if(curPartCast.collider) curPartCast.getBody().setSensor(true);
    }
    
    for(int i=0; i<loadCast.connections.size(); i++) {
      Vehicle.Connector connectCast = (Vehicle.Connector) loadCast.connections.get(i);  //loadedconnector
      connections.add(new Connector(connectCast.type, connectCast.idA, connectCast.idB, this));
      Vehicle.Connector curConnectCast = (Vehicle.Connector) connections.get(connections.size()-1);  //thisvehicle
      for(int j=0; j<connectCast.joints.size(); j++) {
        if(connectCast.type == 0) {
          FDistanceJoint jointCast = (FDistanceJoint) connectCast.joints.get(j);
          curConnectCast.addDJoint(jointCast.getAnchor1X(), jointCast.getAnchor1Y(), jointCast.getAnchor2X(), jointCast.getAnchor2Y(), connectCast.freq);
        } else if(connectCast.type == 1) {
          FPrismaticJoint jointCast = (FPrismaticJoint) connectCast.joints.get(j);
          curConnectCast.addPJoint(jointCast.getAnchorX(), jointCast.getAnchorY(), connectCast.axisX, connectCast.axisY, connectCast.limitTranslation, connectCast.lowerLimit, connectCast.upperLimit);
        } else if(connectCast.type == 2) {
          FRevoluteJoint jointCast = (FRevoluteJoint) connectCast.joints.get(j);
          curConnectCast.addRJoint(jointCast.getAnchorX(), jointCast.getAnchorY(), connectCast.limitTranslation, connectCast.lowerLimit, connectCast.upperLimit, connectCast.motorSpeed, connectCast.motorTorque, connectCast.runningAlways);
        }
      }
    }
    
    if(game.jython != null) game.jython.onVehicleAdd(id, type, pos_.x, pos_.y);
  }
  
  void setId(int id_) { id = id_; }
  
  Part getPart(int id_) {
    Part ph = (Part) parts.get(id_);
    return(ph);
  }
  
  boolean hasPropellor() {
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.propellor) return true;
    }
    return false;
  }
  
  PVector getCockpitPos() {
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.cockpit) return new PVector(ph.getBody().getX(), ph.getBody().getY());
    }
    return null;
  }
  
  PVector getCockpitVelo() {
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.cockpit) return new PVector(ph.getBody().getVelocityX(), ph.getBody().getVelocityY()); 
    }
    return null;
  }
  
  FBody getCockpit() {
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.cockpit) return ph.getBody();
    }
    return null;
  }
  
  void setHealth(float health_, float fireHealth_) { startingHealth = health_; health = health_; fireHealth = fireHealth_; }
  
  void setMinParts(int mp_) { minParts = mp_; }
  
  void setExplodeMult(float em_) { explosionMult = em_; }
  
  void setScale(float scale_) { scale = scale_; }
  
  void setCorrectSpeed(boolean set_) { correctSpeed = set_; }
  
  void setMaxVelo(float mv_) { maxVelo = mv_; }
  
  void setName(String name) { this.name = name; }
  
  float exitX1() { return exitX1; }
  float exitY1() { return exitY1; }
  float exitX2() { return exitX2; }
  float exitY2() { return exitY2; }
  
  void startFire() {
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.alive) ph.fire = true;
    }
  }
  
  void addMovement(int dx_, int dy_) {
    if(getCockpit() == null) return;
    if(correctSpeed) {
      if(abs(getCockpitVelo().x) > maxVelo) {
        if((getCockpitVelo().x < 0 && dx_ > 0) || (getCockpitVelo().x > 0 && dx_ < 0)) {  //DOES STOPS
          getCockpit().setVelocity(getCockpitVelo().x*0.9, getCockpitVelo().y);
          xForce = 0;
          return;
        }
       xForce = 0;
       getCockpit().setVelocity(getCockpitVelo().x*0.98, getCockpitVelo().y);
      }
      if(abs(getCockpitVelo().y) > maxVelo) {
        if((getCockpitVelo().y < 0 && dy_ > 0) || (getCockpitVelo().y > 0 && dy_ < 0)) {  //DOES STOPS
          getCockpit().setVelocity(getCockpitVelo().x, getCockpitVelo().y*0.9);
          yForce = 0;
          return;
        }
        yForce = 0;
        getCockpit().setVelocity(getCockpitVelo().x, getCockpitVelo().y*0.98);
      }
    }
    
    if(yForce < 0) { landed = false; }
    xForce += (dx_*xIncrement);
    yForce += (dy_*yIncrement);
    
    /*if(dx_ == 0) {
      if(xForce > 0) xForce -= xfDecrement;
      if(xForce < 0) xForce += xfDecrement;
    }
    if(dy_ == 0) {
      if(yForce > 0) yForce -= yfDecrement;
      if(yForce < 0) yForce += yfDecrement;
    }
      if(xForce > 0) xForce -= xfDecrement;
      if(xForce < 0) xForce += xfDecrement;
      if(yForce > 0) yForce -= yfDecrement;
      if(yForce < 0) yForce += yfDecrement;
    */
  } 
  
  void setDriver(boolean set_, boolean ai_, int id_) {
    isInhabited = set_;
    ai = ai_;
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.gun) { id = id_; }
    }
    setSoldierCast(getSoldierById(id_));
    
    if(isInhabited) {
      for(int i=0; i<parts.size(); i++) {
        Part ph = (Part) parts.get(i);
        if(!ph.customGun) {
          ph.curGun = soldierCast.curGun.gun;
          ph.curAmmo = soldierCast.curGun.ammo;
          ph.curBink = soldierCast.curGun.bink;
          ph.delayCount = soldierCast.curGun.delayCount;
          ph.reloadCount = soldierCast.curGun.reloadCount;
        }
      }
    }
    println("setd"+id_);
  }
  
  void setSoldierCast(Soldier sh_) { soldierCast = (Soldier) sh_; }
  
  void setExits(float x1_, float y1_, float x2_, float y2_) {
    exitX1 = x1_;
    exitY1 = y1_;
    exitX2 = x2_;
    exitY2 = y2_;
  }
  
  void setBasics(int health_, int minParts_, float explodeMult_, float scale_) {
    health = health_;
    minParts = minParts_;
    explosionMult = explodeMult_;
    scale = scale_;
  }
  
  void setForces(float xi_, float yi_, float xd_, float yd_) {
    xIncrement = xi_;
    yIncrement = yi_;
    xfDecrement = xd_;  //WHATS DECREASED from xforce
    yfDecrement = yd_;  //WHATS DECREASED
  }
  
  void setGrapple(float x_, float y_) {
    grappleX = x_;
    grappleY = y_;
  }
  
  boolean cockpitFire() {
    boolean fire = false;
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if(ph.cockpit && ph.fire) { fire = true; }
    }
    return fire;
  }
  
  PVector someoneExiting(boolean door_) {
    
    //IF ENTIRE VEHICLE IS ENGULFED THEN BE ON FIRE NO MATTER WHAT, OTHERWISE IF COCKPIT MAKE IT PERCENTAGE?
    if(health < fireHealth || cockpitFire()) soldierCast.startFire();
    
    setDriver(false, false, 0); //SHOWS YOUR out
    if(!door_) startFire(); //HAVE TO BE DONE NOW AFTER SO WE ARENT ON FIRE FROM STARTING IT
    xForce = 0;
    yForce = 0;
    
    if(door_) return new PVector(getCockpitPos().x+exitX1, getCockpitPos().y+exitY1);  //FIX:::CAUSES CRASH ON EXPLOSION WITH MOONBUG
    else return new PVector(getCockpitPos().x+exitX2, getCockpitPos().y+exitY2);
  }
  
  PVector exitForce(boolean door_) {
    if(door_) return new PVector(0, -400);
    else return new PVector(0, -3000);
  }
  
  
  //BOX
  void addPart(float x_, float y_, float w_, float h_, float d_) { parts.add(new Part(x_, y_, w_, h_, d_, this)); partType = append(partType, 0); }
  //WHEEL
  void addPart(float x_, float y_, float r_, float d_) { parts.add(new Part(x_, y_, r_, d_, this)); partType = append(partType, 1); }
  //WHEEL
  void addPart(float x1_, float y1_, float x2_, float y2_, float x3_, float y3_, float d_) { parts.add(new Part(x1_, y1_, x2_, y2_, x3_, y3_, d_, this)); partType = append(partType, 2); }
  
  void addConnection(int type_, int p1_, int p2_) {
    connections.add(new Connector(type_, p1_, p2_, this));
    Vehicle.Connector ch = (Vehicle.Connector) connections.get(connections.size()-1);
    Vehicle.Part p1 = (Vehicle.Part) parts.get(p1_);
    Vehicle.Part p2 = (Vehicle.Part) parts.get(p2_);
    p1.addConnectCast(ch);
    p2.addConnectCast(ch);
  }
  
  void addJoint(int id_, float x1_, float y1_, float x2_, float y2_, float freq_) {
    Vehicle.Connector ch = (Vehicle.Connector) connections.get(id_);
    ch.addDJoint(x1_, y1_, x2_, y2_, freq_);
  }

  void addJoint(int id_, float anchorX_, float anchorY_, float axisX_, float axisY_, boolean limitTranslation_, float lowerTranslation_, float upperTranslation_) {
    Vehicle.Connector ch = (Vehicle.Connector) connections.get(id_);
    ch.addPJoint(anchorX_, anchorY_, axisX_, axisY_, limitTranslation_, lowerTranslation_, upperTranslation_);
  }
  
  void addJoint(int id_, float anchorX_, float anchorY_, boolean limitTranslation_, float lowerTranslation_, float upperTranslation_, float motorSpeed_, float motorTorque_, boolean runningAlways_) {
    Vehicle.Connector ch = (Vehicle.Connector) connections.get(id_);
    ch.addRJoint(anchorX_, anchorY_, limitTranslation_, lowerTranslation_, upperTranslation_, motorSpeed_, motorTorque_, runningAlways_);
  }
  
  void update(GL gl) {
    if(!playingOnline) {
      if(health < 0) alive = false;
      //TO NORMALIZE FORCES
      if(xForce > 0) xForce -= xfDecrement;
      else if(xForce < 0) xForce += xfDecrement;
      if(yForce > 0) yForce -= yfDecrement;
      else if(yForce < 0) yForce += yfDecrement;
      if(correctSpeed) correctSpeed();
    }  
    if(game.jython != null) game.jython.onVehicleMove(id, getCockpit().getX(), getCockpit().getY(), getCockpit().getVelocityX(), getCockpit().getVelocityY());
    
    for(int i=0; i<connections.size(); i++) {
      Connector ch = (Connector) connections.get(i);
      ch.update();
    }
    
    int deadparts = 0;
    for(int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      ph.update(gl);
      if(!ph.alive) deadparts++;
    }
    if(parts.size()-deadparts < minParts) { alive = false; }
    
    if(!alive) {
      if(isInhabited && ai) soldierCast.alive = false;
      
      for(int i=0; i<connections.size(); i++) {
        Connector ch = (Connector) connections.get(i);
        for(int c=0; c<ch.joints.size(); c++) world.remove(ch.getJoint(c));
        
        for(int j=0; j<ch.joints.size(); j++) ch.joints.remove(0);
      }
      
      for(int i=0; i<connections.size(); i++) connections.remove(0);
      
      
      for(int i=0; i<parts.size(); i++) {
        Part ph = (Part) parts.get(i);
        if(!playingOnline) {
          if(ph.square) {
            if(alive) game.explosionData.add(new Explosion(ph.p.getX()+int(random(-10, 10)), ph.p.getY()+int(random(-10, 10)), constrain(ph.p.getWidth()/4+ph.p.getHeight()/4, 0, 75), int(random(30, 60))));
          } else if(ph.wheel) {
            if(alive) game.explosionData.add(new Explosion(ph.w.getX()+int(random(-10, 10)), ph.w.getY()+int(random(-10, 10)), ph.w.getSize(), int(random(30, 60))));
          } else if(ph.polygon) {
            
          }
        }
        world.remove(ph.getBody());
        //println("part: "+i);
      }
      
      while(parts.size() > 0) parts.remove(0);
    }
  }
  
  void correctSpeed() {
    FBody tempCock = getCockpit();
    if(abs(getCockpitVelo().x) > maxVelo) {
      if(getCockpitVelo().x > 0) {
        tempCock.setVelocity(maxVelo, getCockpitVelo().y);
      } else {
        tempCock.setVelocity(-maxVelo, getCockpitVelo().y);
      }
    }
    if(abs(getCockpitVelo().y) > maxVelo) {
      if(getCockpitVelo().y > 0) {
        tempCock.setVelocity(getCockpitVelo().x, maxVelo);
      } else {
        tempCock.setVelocity(getCockpitVelo().x, -maxVelo);
      }
    }
    /*println(getCockpitVelo().x+"--"+getCockpitVelo().y);
    if(abs(getCockpitVelo().x) > maxVelo) {
     getCockpit().setVelocity(getCockpitVelo().x*0.99, getCockpitVelo().y);
    }
    if(abs(getCockpitVelo().y) > maxVelo) {
      getCockpit().setVelocity(getCockpitVelo().x, getCockpitVelo().y*0.99);
    }*/
  }
  
  void shoot() {
    for(int i=0; i<parts.size(); i++) {
      Vehicle.Part ph = (Vehicle.Part) parts.get(i);
      if(ph.gun) {
        if(!ph.reloading && ph.curAmmo > 0 && ph.delayCount == 0) {
          game.shootGun(ph.getBody().getX() + ph.gunX, ph.getBody().getY() + ph.gunY, soldierCast.gunAngle, getCockpit().getVelocityX(), getCockpit().getVelocityY(), ph.curGun, soldierCast.id);
          ph.curBink += game.gunData[ph.curGun].recoil;
          ph.delayCount = game.gunData[ph.curGun].delayTime;
          ph.curAmmo -= 1;
          if(ph.curAmmo == 0) ph.reloading = true;
        } else if(!ph.reloading && ph.curAmmo == 0) {
          ph.reloading = true;  //SAFEGUARD RELOADING
        }
      }
    }
  }
  
  class Part {
    boolean alive;
    boolean fire = false;
    boolean explodedYet = false;
    float fireHealth;
    float health;
    float startingHealth;
    ArrayList connectCasts;
    ArrayList polyData;
    FBox p;
    FCircle w;
    FPoly poly;
    Vehicle fv;
    boolean propellor = false;
    boolean missile = false;
    boolean cockpit = false;
    boolean square = false;
    boolean wheel = false;
    boolean polygon = false;
    boolean collider = false;
    boolean frame = false;
    boolean touchingPoly = false;
    boolean landingGear = false;
    boolean keyRotatable = false;
    boolean gun = false;
    boolean drawImage = false;
    float scaleImage;
    PImage img;
    float xStrength;
    float yStrength;
    float propellorLift;
    float missileX;
    float missileY;
    float missileStrength;
    float rotateStrength;
    float rotateMax;
    boolean customGun;
    float gunX;  //gun offset
    float gunY;  //gun offset
    //float gunR;  //radius for aiming
    int curGun;
    int curAmmo;
    int delayCount;
    int reloadCount;
    float curBink;
    boolean reloading;
  
    float den;
    float xOff;
    float yOff;
    
    float z;  //FOR AFTER PART DEATH RENDERING
    float width;
    float height;
    float radius;
    float polyVertexX1;
    float polyVertexY1;
    float polyVertexX2;
    float polyVertexY2;
    float polyVertexX3;
    float polyVertexY3;
      
    
    Part(float x_, float y_, float width_, float height_, float density_, Vehicle fv_) {
      xOff = x_;
      yOff = y_;
      width = width_;
      height = height_;
      den = density_;
      
      alive = true;
      square = true;
      fv = (Vehicle) fv_;
      setHealth(1000);
      connectCasts = new ArrayList();
      polyData = new ArrayList();

      p = new FBox(width_, height_);
      p.setPosition(fv.x+x_, fv.y+y_);
      p.setDensity(density_);
      p.setFriction(0.5);
      p.setRestitution(0.1);
      p.setDrawable(true);
      if(!justData) world.add(p);
    }
    
    Part(float x_, float y_, float radius_, float density_, Vehicle fv_) {
      xOff = x_;
      yOff = y_;
      radius = radius_;
      den = density_;
      
      alive = true;
      wheel = true;
      fv = (Vehicle) fv_;
      setHealth(1000);
      connectCasts = new ArrayList();
      polyData = new ArrayList();

      w = new FCircle(radius_);
      w.setPosition(fv.x+x_, fv.y+y_);
      w.setDensity(density_);
      w.setFriction(0.5);
      w.setRestitution(0.1);
      w.setDrawable(true);
      if(!justData) world.add(w);
    }
    
    Part(float x1_, float y1_, float x2_, float y2_, float x3_, float y3_, float density_, Vehicle fv_) {
      xOff = (x1_+x2_+x3_)/3;
      yOff = (y1_+y2_+y3_)/3;
      den = density_;
      
      polyVertexX1 = x1_;
      polyVertexY1 = y1_;
      polyVertexX2 = x2_;
      polyVertexY2 = y2_;
      polyVertexX3 = x3_;
      polyVertexY3 = y3_;
      
      alive = true;
      polygon = true;
      fv = (Vehicle) fv_;
      setHealth(1000);
      connectCasts = new ArrayList();
      polyData = new ArrayList();
      poly = new FPoly();
      poly.setDensity(density_);
      poly.setFriction(1.5);
      poly.setRestitution(0.1);
      poly.setDrawable(true);
      
      poly.vertex(fv.x+x1_, fv.y+y1_);
      poly.vertex(fv.x+x2_, fv.y+y2_);
      poly.vertex(fv.x+x3_, fv.y+y3_);
      if(!justData) world.add(poly);
    }
    
    void updateFromServer(float x_, float y_, float xf_, float yf_, float r_, boolean alive_) {
      try {
        getBody().setPosition(x_, y_);
        getBody().setVelocity(xf_, yf_);
        getBody().setRotation(r_);
      } catch(NullPointerException e_) {
        e_.printStackTrace();
      } catch(AssertionError e_) {
        //e_.printStackTrace();
        /*
        System.err.println("Vehicle Part Assertion Error");
        println(x_ +"-"+ y_ +"-"+ xf_ +"-"+ yf_ +"-"+ r_);
        */
      }
      alive = alive_;
    }
    
    void setPropellor(boolean set_, float xStrength_, float yStrength_, float pLift_) {
      propellor = set_;
      xStrength = xStrength_; 
      yStrength = yStrength_;
      propellorLift = pLift_;
    }
    
    void setMissile(boolean set_, float missileX_, float missileY_, float missileStrength_) {
      missile = set_;
      missileX = missileX_; 
      missileY = missileY_;
      missileStrength = missileStrength_;
    }
    
    void setCockpit(boolean set_) { cockpit = set_; }
    
    void setCollider(boolean set_) {
      collider = set_;
      getBody().setSensor(set_);
    }
    
    void setWheel(boolean set_, float xStrength_, float rotateStrength_, float rotateMax_) {
      wheel = set_;
      xStrength = xStrength_; 
      rotateStrength = rotateStrength_;
      rotateMax = rotateMax_;
      keyRotatable = true;
    }
    
    void setWheel(boolean set_) {
      wheel = set_;
      xStrength = 0;
      rotateStrength = 0;
      rotateMax = 0;
      keyRotatable = false;
    }
    
    void setTouchingPoly(boolean set_) {
      touchingPoly = set_;
      if(landingGear && set_ == true) { landed = set_; }
    }
    
    void setLandingGear(boolean set_) { landingGear = true; }
    
    void setGunPos(boolean set_, float offX_, float offY_) {
      gun = set_;
      gunX = offX_;
      gunY = offY_;
      //gunR = gunR_;
      curGun = 0;
      curAmmo = 0;
      delayCount = 10;
      reloading = true;
      id = 0;
    }
    
    void setCustomGun(boolean set_, int gId) {
      customGun = true;
      curGun = gId;
      curAmmo = game.gunData[curGun].ammo;
      delayCount = game.gunData[curGun].delayTime;
      reloadCount = game.gunData[curGun].reloadTime;
      reloading = false;
    }
    
    void setFrame(boolean set_) { frame = set_; }
    
    void setCollideId(int set_) { getBody().setGroupIndex(set_); }
    
    void setRotateByKeys(boolean set_) { keyRotatable = set_; }
    
    void setHealth(float set_) { startingHealth = set_; health = set_; fireHealth = set_/2; }
    
    void setHealth(float set_, float fireHealth_) { startingHealth = set_; health = set_; fireHealth = fireHealth_; }
    
    
    void setImage(String src_, float scaleImage_) {
      try {
        img = loadImage(sketchPath+"/data/vehicles/gfx/"+src_);
      } catch(NullPointerException nu) {
        nu.printStackTrace();
        return;
      }
      scaleImage = scaleImage_;
      drawImage = true;
    }
    
    void addConnectCast(Connector connectCast_) {
      Connector ph = (Connector) connectCast_;
      connectCasts.add(ph);
    }
    
    void addPoly(float x1_, float y1_, float z1_, float x2_, float y2_, float z2_, float x3_, float y3_, float z3_, int r_, int g_, int b_, int a_) {
      polyData.add(new Polygon(x1_, y1_, z1_, x2_, y2_, z2_, x3_, y3_, z3_, r_, g_, b_, a_));
    }
    
    void hurt(float damage_) {
      health -= damage_;
      fv.health -= damage_;
      if(cockpit && isInhabited) soldierCast.health -= damage_/10;
    }
    
    void setHealthFromServer(float health_) {
      if(cockpit && isInhabited && health > health_) soldierCast.health -= (health-health_)/10;
      fv.health -= health-health_;
      health = health_;
    }
    
    PVector getPos() { return new PVector(getBody().getX(), getBody().getY()); }
    
    void update(GL gl) {
      if(!fv.alive || health < 0 || connectCasts.size() == 0) alive = false;
      if(health < fireHealth) fire = true;
      
      for(int i=0; i<connectCasts.size(); i++) {
        Connector ch = (Connector) connectCasts.get(i);
        if(ch.alive) ch.update();
        else connectCasts.remove(i); 
      }
      
      if(alive) {
        if(getBody().getY() > mapH/2-100 || getBody().getY() < -mapH/2+100 || getBody().getX() > mapW/2-100 || getBody().getX() < -mapW/2+100) fire = true;
        
        if(fire && random(1) < 0.2) {
          //game.particleData.add(new Particle(getBody().getX(), getBody().getY(), int(random(30, 60)), int(random(20, 105)), 1));
          if(game.checkRender(getBody().getX(), getBody().getY(), 1.0)) game.particleData.add(new Particle(0, getBody().getX(), getBody().getY(), random(20, 105)));
          hurt(2);
        }
        
        if(touchingPoly) {
          if(landingGear) fv.landed = true;
          if(!wheel && !landingGear && !fv.landed && !collider) hurt(3);
        }
        
        if(gun) {
          if(reloading) reload();
          if(delayCount > 0) delayCount--;
        }
        
        if(propellor && !fire) {
          getBody().addForce(0, propellorLift+(fv.yForce*yStrength));
          getBody().addForce(fv.xForce*xStrength, 0);
        }
        
        if(missile) {
          getBody().addTorque(xStrength*yStrength);
          getBody().addForce(xStrength, (sin(getBody().getRotation())*missileStrength)*yForce, missileX, missileY);
          //println(p.getRotation());
          //println(cos(p.getRotation())+" :: "+sin(p.getRotation()));
        }
        
        if(wheel && !collider && !fire) {
          //if(touchingPoly) {
            if(abs(getBody().getRotation()) < rotateMax) { 
              getBody().adjustRotation(fv.xForce*rotateStrength);
            } else {
              if(getBody().getRotation() > 0) getBody().setRotation(rotateMax);
              else getBody().setRotation(-rotateMax);
            }
            getBody().addForce(fv.xForce*xStrength, 0);
            //FOR BRAKES
            if(fv.yForce > 0.15) { getBody().setRotation(getBody().getRotation()*-1); }
          //}
        }
        
        if(frame) { 
          int tempWheelCount = 0;
          int tempWNTouchCount = 0;

          for(int i=0; i<fv.parts.size(); i++) {
            Vehicle.Part partCast = (Vehicle.Part) fv.parts.get(i);
            if(partCast.wheel && !partCast.collider) tempWheelCount++;
            if(partCast.wheel && !partCast.touchingPoly) tempWNTouchCount++;
          }
          
          if(tempWheelCount == tempWNTouchCount && !ai) getBody().addTorque(fv.yForce*2);
        }
        
        if(landingGear && !touchingPoly) { fv.landed = false;  }
        
        touchingPoly = false;
      } else {
        if(!explodedYet) {
          if(square) { game.explosionData.add(new Explosion(p.getX()+int(random(-10, 10)), p.getY()+int(random(-10, 10)), constrain(p.getWidth()/4+p.getHeight()/4, 0, 75), int(random(30, 60)))); }
          if(wheel) { game.explosionData.add(new Explosion(w.getX()+int(random(-10, 10)), w.getY()+int(random(-10, 10)), w.getSize(), int(random(30, 60)))); }
          if(cockpit) {
            fv.startFire();
            fv.alive=false;
            if(isInhabited) {
              soldierCast.alive = false;
              isInhabited = false;
              ai = false;
            }
          }
          getBody().setSensor(true);
          
          for(int i=0; i<connectCasts.size(); i++) {
            Connector ch = (Connector) connectCasts.get(i);
            ch.alive = false;
            connectCasts.remove(i);
          }
          explodedYet = true;
        }
        z -= 10;
      }
      if(settings.drawVehicles && game.checkRender(getBody().getX(), getBody().getY(), 1.0)) render(gl);
    }
    
    void reload() {
      if(game.bitchMode && ai) return;
      if(reloadCount == 0) { 
        curAmmo = game.gunData[curGun].ammo;
        delayCount = 0;
        reloadCount = game.gunData[curGun].reloadTime;
        reloading = false;
      } else { reloadCount--; }
    }
    
    FBody getBody() {
      if(square) return p;
      else if(polygon) return poly;
      else return w;
    }
    
    PVector getBodyScale() {
      if(square) return new PVector(p.getWidth(), p.getHeight(), 1);
      else if(polygon) return new PVector(1, 1, 1);
      else return new PVector(w.getSize(), w.getSize(), 1);
    }
	
    void render(GL gl) {
      pushMatrix();
        if(collider) {
          fill(19, 150, 200, 50);
          if(isInhabited) {
            popMatrix();
            return;  //DONT RENDER THIS COLLIDER PIECE IF SOLDIER INSIDE
          }
        } else {
          //fill(199, 200, 11, 255);
          fill(map(health, 0, startingHealth, 0, 255), map(health, 0, startingHealth, 0, 255)/2, map(health, 0, startingHealth, 0, 255)/10, 255);
        }
        
        translate(getBody().getX(), getBody().getY(), 2);
        rotate(getBody().getRotation());
        
        if(drawImage) {
          fill(255);
          tint(255);
          //scaleByBody();
          PVector s = getBodyScale();
          scale(s.x, s.y, s.z);
          
          beginShape();
            texture(img);
            vertex(-0.5, -0.5, 0, 0, 0);
            vertex(0.5, -0.5, 0, 1, 0);
            vertex(0.5, 0.5, 0, 1, 1);
            vertex(-0.5, 0.5, 0, 0, 1);
          endShape();
        } else {
          if(square) {
            //scaleByBody();
            PVector s = getBodyScale();
            scale(s.x, s.y, s.z);
            
            beginShape();
              vertex(-0.5, -0.5);
              vertex(-0.5, 0.5);
              vertex(0.5, 0.5);
              vertex(0.5, -0.5);
            endShape();
          } else if(wheel) {
            //scaleByBody();
            PVector s = getBodyScale();
            scale(s.x, s.y, s.z);
          
            ellipse(0, 0, 1, 1);
          } else if(polygon) {
            beginShape();
              vertex(polyVertexX1, polyVertexY1);
              vertex(polyVertexX2, polyVertexY2);
              vertex(polyVertexX3, polyVertexY3);
            endShape();
          }
        }
      popMatrix();
      
      //DRAW POLYS
      pushMatrix();
        translate(getBody().getX(), getBody().getY(), z);
        rotate(getBody().getRotation());
        
        for(int i=0; i<polyData.size(); i++) {
          Polygon ph = (Polygon) polyData.get(i);
          ph.update(gl);
        }
      popMatrix();
      
      if(isInhabited && gun) {
        pushMatrix();
          translate(getBody().getX()+gunX, getBody().getY()+gunY, z);
          if(soldierCast.curGun.reloadCount < 1) {
            fill(20, 255, 40, 255);
            beginShape();
              vertex(0, 0);
              fill(20, 255, 40, 0);
              vertex(50*cos(soldierCast.gunAngle-0.02), 50*sin(soldierCast.gunAngle-0.02));
              vertex(50*cos(soldierCast.gunAngle+0.02), 50*sin(soldierCast.gunAngle+0.02));
            endShape();
          }
        popMatrix();
      }
    }
  }
  
  class Connector {
    boolean alive;
    boolean removedItem = false;
    Vehicle fv;
    ArrayList joints;
    int idA;
    int idB;
    Part aId;
    Part bId;
    int type;
    
    float freq;
    
    boolean limitTranslation;
    float lowerLimit;
    float upperLimit;
    
    //pris
    float axisX;
    float axisY;
    
    //revo
    float motorSpeed;
    float motorTorque;
    boolean runningAlways;
    
    Connector(int type_, int aId_, int bId_, Vehicle fv_) {
      alive = true;
      type = type_;
      fv = (Vehicle) fv_;
      joints = new ArrayList();
      idA = aId_;
      idB = bId_;
      aId = (Part) fv.parts.get(aId_);
      bId = (Part) fv.parts.get(bId_);
      aId.addConnectCast(this);
      bId.addConnectCast(this);
    }
    
    void addDJoint(float x1_, float y1_, float x2_, float y2_, float freq_) {
      FBody bha = aId.p;
      FBody bhb = bId.p;
      if(aId.wheel) { bha = aId.w; }
      if(bId.wheel) { bhb = bId.w; }
      if(aId.polygon) { bha = aId.poly; }
      if(bId.polygon) { bhb = bId.poly; }
      
      //IF NO FREQUENCY IS SPECIFIED WE SET DEFAULT
      freq = (freq_ == 0) ? 30 : freq_;
      
      joints.add(new FDistanceJoint(bha, bhb));
      FDistanceJoint fh = (FDistanceJoint) joints.get(joints.size()-1);
      fh.setAnchor1(x1_, y1_);
      fh.setAnchor2(x2_, y2_);
      fh.setDrawable(true);
      fh.calculateLength();
      fh.setFrequency(freq);
      fh.setStroke(255, 0, 0);
      fh.setCollideConnected(false);
      if(!justData) world.add(fh);
    }
    
    void addPJoint(float anchorX_, float anchorY_, float axisX_, float axisY_, boolean limitTranslation_, float lowerLimit_, float upperLimit_) {
      FBody bha = aId.p;
      FBody bhb = bId.p;
      if(aId.wheel) { bha = aId.w; }
      if(bId.wheel) { bhb = bId.w; }
      if(aId.polygon) { bha = aId.poly; }
      if(bId.polygon) { bhb = bId.poly; }
      
      joints.add(new FPrismaticJoint(bha, bhb));
      FPrismaticJoint fh = (FPrismaticJoint) joints.get(joints.size()-1);
      fh.setAnchor(anchorX_, anchorY_);
      fh.setAxis(axisX_, axisY_);
      
      if(limitTranslation) {
        fh.setEnableLimit(true);
        fh.setLowerTranslation(lowerLimit_);
        fh.setUpperTranslation(upperLimit_);
      }
      
      axisX = axisX_;
      axisY = axisY_;
      limitTranslation = limitTranslation_;
      lowerLimit = lowerLimit_;
      upperLimit = upperLimit_;
      
      fh.setDrawable(true);

      fh.setStroke(255, 0, 0);
      if(!justData) world.add(fh);
    }
    
      void addRJoint(float anchorX_, float anchorY_, boolean limitTranslation_, float lowerLimit_, float upperLimit_, float motorSpeed_, float motorTorque_, boolean runningAlways_) {
        FBody bha = aId.p;
        FBody bhb = bId.p;
        if(aId.wheel) { bha = aId.w; }
        if(bId.wheel) { bhb = bId.w; }
        if(aId.polygon) { bha = aId.poly; }
        if(bId.polygon) { bhb = bId.poly; }
        
        //joints.add(new FRevoluteJoint(bha, bhb, anchorX_, anchorY_));
        joints.add(new FRevoluteJoint(bha, bhb, bhb.getX()+anchorX_, bhb.getY()+anchorY_));
        FRevoluteJoint fh = (FRevoluteJoint) joints.get(joints.size()-1);
        if(limitTranslation) {
          fh.setEnableLimit(true);
          fh.setLowerAngle(lowerLimit_);
          fh.setUpperAngle(upperLimit_);
        }
        fh.setMotorSpeed(motorSpeed_);
        fh.setMaxMotorTorque(motorTorque_);
        fh.setEnableMotor(runningAlways_);

        limitTranslation = limitTranslation_;
        lowerLimit = lowerLimit_;
        upperLimit = upperLimit_;
        motorSpeed = motorSpeed;
        motorTorque = motorTorque;
        runningAlways = runningAlways_;
        
        if(!justData) world.add(fh);
      }
    
    void update() {
      if(!alive || !aId.alive || !bId.alive || !fv.alive) { alive = false; }
    }
    
    FJoint getJoint(int n_) {
      if(type == 0) return (FJoint) joints.get(n_);
      else if(type == 1) return (FJoint) joints.get(n_);
      else if(type == 2) return (FJoint) joints.get(n_);
      return null;
    }
  }
}

