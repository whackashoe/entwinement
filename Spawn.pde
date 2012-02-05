class Spawn {
  float x;
  float y;
  float w;
  float h;
  int type;
  int subType;
  int amount;
  boolean spawning;
  private int delayTime;
  
  boolean spawnInVehicle;
  int spawnVID;
  
  boolean spawnWithAttachment;
  int spawnAttachType;
  int spawnAttachAmount;
  int spawnAttachAmount1;
  
  boolean spawnOnEarth;
  int earth;
  float distance;
    
  //FOR CAPTURE POINT
  int[] team;
  
  Object childCast;
  
  Spawn() { /*SHOULD ONLY BE CREATED WHEN STATIC METHODS NEED TO BE CALLED*/ }
  
  Spawn(float x_, float y_, int type_, int subType_, int amount_) {
    x = x_;
    y = y_;
    w = 100;
    h = 100;

    type = type_;
    subType = subType_;
    amount = amount_;
    spawning = false;
    spawnInVehicle = false;
    spawnWithAttachment = false;
    spawnOnEarth = false;
    team = setArrayToZero(4);
    
     if(game.jython != null) game.jython.onSpawnAdd(x_, y_, type_, subType_, amount_);
  }
  
  void setSpawnInVehicle(boolean set_, int vId_) {
    spawnInVehicle = set_;
    spawnVID = vId_;
  }
  
  void setSpawnWithAttachment(boolean set_, int type_, int amount_, int amount1_) {
    spawnWithAttachment = set_;
    spawnAttachType = type_;
    spawnAttachAmount = amount_;
    spawnAttachAmount1 = amount1_;
  }
    
  void setEarth(int earth_, float dist_) {
    spawnOnEarth = true;
    earth = earth_;
    distance = dist_;
  }
  
  void update() {
    if(spawning) {
      if(delayTime > 0) delayTime--;
      
      if(delayTime == 0) {
        float tX = x-(w/2)+(random(0, w));
        float tY = y-(h/2)+(random(0, h));
        
        if(spawnOnEarth) {
          tX = getEarthSpawnPos().x;
          tY = getEarthSpawnPos().y;
        }
        
        switch(type) {
          /*case 0:
            //if(!game.meCast.alive) spawnMe(tX, tY);
            break;*/
          case 1:
            spawnGun(tX, tY);
            break;
          case 2:
            spawnHealthpack(tX, tY); 
            break;
          case 3:
            spawnAttachment(tX, tY);
            break;
          /*case 4:
            //NOTHING
            break;*/
          case 5:
            spawnVehicle(tX, tY);
            break;
          /*case 6:
            //if(game.soldierData.size() < game.maxSoldiers) spawnSoldier(tX, tY);
            break;
            */
          /*case 7:  //KING OF THE HILL SPAWN TYPE-- JUST FOR GAME MODE NO SPAWN
            break;*/
          /*case 8: //CTF FLAG SPAWN, subtype determines team(0 is alpha, 1 is bravo etc)
            break;
          */
        }
        
        spawning = false;
      }
    }
    
    if(!spawning) {
      //PREPARSE ALL PICKUPS TO SEE AMOUNT CURRENTLY IN MAP
      int tempGunCount = 0;
      int tempHealthCount = 0;
      int tempAttachmentCount = 0;    
      for(int i=0; i<game.pickupData.size(); i++) {
        Pickups ph = (Pickups) game.pickupData.get(i);
        if(!ph.alive || ph.type == null) continue;
        if(ph.type[0] == 0) tempGunCount++;
        if(ph.type[0] == 1) tempHealthCount++;
        if(ph.type[0] == 2) tempAttachmentCount++;
      }
      
      if(type == 0 && !game.meCast.alive && checkSpawn()) {
        spawning = true;
        delayTime = int(random(90, 150));
      }
      
      if(type == 1 && tempGunCount < game.soldierData.size()) {
        spawning = true;
        delayTime = 200+int(random(0, 200));
      }
      
      if(type == 2 && tempHealthCount < game.maxHealthPacks) {
        spawning = true;
        delayTime = 100+int(random(0, 200));
      }
      
      if(type == 3 && tempAttachmentCount < game.maxAttachments) {
        spawning = true;
        delayTime = 100+int(random(0, 200));
      }
      
      if(type == 5 && game.vehicleData.size() < game.maxVehicles && checkSpawn()) {
        spawning = true;
        delayTime = int(random(100, 200));
      }
  
      if(type == 6 && game.soldierData.size() < game.maxSoldiers && checkSpawn()) {
        spawning = true;
        delayTime = int(random(40, 80));
      }
    }
    
    if(game.getGameType() == 3 && frameCount % 15 == 0) {  //CAPTURE POINT
      for(int i=0; i<game.soldierData.size(); i++) {
        Soldier ph = (Soldier) game.soldierData.get(i);
        if(!ph.driving && dist(ph.self.getX(), ph.self.getY(), x, y) < 50 && subType != 0) {  //CLOSE, NOT GENERAL SPAWN, NOT ALREADY OWNED BY SOLDIERS TEAM
          for(int t=0; t<4; t++) {
            if(t != ph.team) team[t] = constrain(team[t]-10, 0, 255);  //IF OTHER TEAM MINUS POINTS
            else team[t] = constrain(team[t]+20, 0, 255);  //IF OTHER TEAM MINUS POINTS
          }
          
          if(subType-1 != ph.team && isBiggestInArray(team, ph.team)) switchSubType(ph.team);
        }
      }
    }
    
    if(game.getGameType() == 4 && type == 7) {  //KING OF THE HILL
      int[] playerAmount = setArrayToZero(4);
      
      for(int i=0; i<game.soldierData.size(); i++) {
        Soldier ph = (Soldier) game.soldierData.get(i);
        if(!ph.driving && dist(ph.self.getX(), ph.self.getY(), x, y) < 150) playerAmount[ph.team]++;
      }
      
      if(arrayDataLargerThanZero(playerAmount)) team[getBiggestInArray(playerAmount)]++;
    }
    
    if(game.checkRender(x, y, 1.0) && ((game.getGameType() == 3 && type == 6) || (game.getGameType() == 4 && type == 7))) render();
  }
  
  void switchSubType(int to) {
    subType = to+1;  //CHANGE SUBTYPE TO REFLECT TEAM
  }
  
  
  boolean checkSpawn() {
    for(int i=0; i<game.vehicleData.size(); i++) {
      Vehicle vh = (Vehicle) game.vehicleData.get(i);
      for(int p=0; p<vh.parts.size(); p++) {
        Vehicle.Part ph = (Vehicle.Part) vh.parts.get(p);
        if(ph.square) {
          if(ph.p.getX() > x-w && ph.p.getX() < x+w && ph.p.getY() > y-h && ph.p.getY() < y+h) return false;
        } else if(ph.wheel) {
          if(ph.w.getX() > x-w && ph.w.getX() < x+w && ph.w.getY() > y-h && ph.w.getY() < y+h) return false; 
        }
      }
    }
    
    for(int i=0; i<game.soldierData.size(); i++) {
      Soldier sh = (Soldier) game.soldierData.get(i);
      if(sh.self.getX() > x-w && sh.self.getX() < x+w && sh.self.getY() > y-h && sh.self.getY() < y+h) return false;
    }
    
    return true;
  }
  
  void spawnMe(float tX_, float tY_) {
    if(!spawnInVehicle || game.maxVehicles <= game.vehicleData.size()) {
      game.meCast.respawn(tX_, tY_);
    } else {
      spawnVehicle(tX_, tY_, spawnVID);
      Vehicle vh = (Vehicle) game.vehicleData.get(game.vehicleData.size()-1);
      game.meCast.respawn(tX_, tY_);
      game.meCast.enterVehicle(vh);
    }
    
    if(spawnWithAttachment) {
      game.meCast.curAttachment = spawnAttachType;
      game.meCast.curAttachmentAmmo = spawnAttachAmount;
    }
    
    //if(game.showLevelInfo) game.showLevelInfo = false;
    
    childCast = (Object) game.meCast;
  }
  
  //FOR RESPAWNING- CALLED FROM SOLDIER CLASS
  void spawnSoldier(Soldier sh_) {
    float tx;
    float ty;
    
    if(!spawnOnEarth) {
      tx = x;
      ty = y;
    } else {
      PVector xy = getEarthSpawnPos();
      tx = xy.x;
      ty = xy.y;
    }
    
    if(!spawnInVehicle || game.maxVehicles <= game.vehicleData.size()) {
      sh_.respawn(tx, ty);
    } else {
      spawnVehicle(tx, ty, spawnVID);
      Vehicle vh = (Vehicle) game.vehicleData.get(game.vehicleData.size()-1);
      sh_.enterVehicle(vh);
    }
    
    childCast = (Object) sh_;
  }
  
  //FOR CREATING NEW SOLDIERS, THIS IS CALLED FROM HERE UNTIL AI IN MAP IS POPULATED
  void spawnSoldier(float tX_, float tY_) {
    if(!spawnInVehicle || game.maxVehicles <= game.vehicleData.size()) {
      game.soldierData.add(new Soldier(tX_, tY_));
    } else {
      spawnVehicle(x, y, spawnVID);
      Vehicle vh = (Vehicle) game.vehicleData.get(game.vehicleData.size()-1);
      game.soldierData.add(new Soldier(tX_, tY_));
      Soldier sh = (Soldier) game.soldierData.get(game.soldierData.size()-1);
      sh.enterVehicle(vh);
    }
    
    Soldier sh = (Soldier) game.soldierData.get(game.soldierData.size()-1);
    if(game.getGameType() != 2) sh.setAi(true);
    else sh.setAi(true, int(random(0, 3)));
    
    childCast = (Object) game.soldierData.get(game.soldierData.size()-1);
  }
  
  void spawnGun(float x, float y) {
    HoldGun temp = new HoldGun(subType);
    game.pickupData.add(new Pickups(x, y, temp));
  }
  
  void spawnHealthpack(float tX_, float tY_) { game.pickupData.add(new Pickups(tX_, tY_, amount)); }
  
  void spawnAttachment(float tX_, float tY_) { game.pickupData.add(new Pickups(tX_, tY_, subType, amount)); }
  
  //void spawnVehicle(float tX_, float tY_) { game.vehicleData.add(new Vehicle(tX_, tY_, subType)); }
  
  //for new vehicle loaded from file
  void spawnVehicle(float tX_, float tY_) {
    game.vehicleData.add(new Vehicle(new Vec2D(tX_, tY_), subType));
    childCast = (Object) game.vehicleData.get(game.vehicleData.size()-1);
  }
  
  void spawnVehicle(float x_, float y_, int vId_) {
    game.vehicleData.add(new Vehicle(new Vec2D(x_, y_), vId_));
    childCast = (Object) game.vehicleData.get(game.vehicleData.size()-1);
  }

  PVector getEarthSpawnPos() {
    Earth ph = (Earth) game.earthData.get(earth);
    float rAngle = random(TWO_PI);
    return new PVector(ph.earth.getX()+(cos(rAngle)*(ph.radius+distance)), ph.earth.getY()+(sin(rAngle)*(ph.radius+distance)));
  }
  
  //int getTime() { return delayTime; }
  int getTime() { return int(random(150, 250)); }
  
  
  Spawn findSoldierSpawn(int team_) {
    int[] ss = new int[0];
    
    for(int i=0; i<game.spawnData.size(); i++) {
      Spawn sh = (Spawn) game.spawnData.get(i);
      if(sh.type == 0 || sh.type == 6) {
        if(game.getGameType() != 2 && game.getGameType() != 3 && game.getGameType() != 4) ss = append(ss, i);
        else if(sh.subType == 0 || team_ == sh.subType-1) ss = append(ss, i);
      }
    }
    
    if(ss.length > 0) return (Spawn) game.spawnData.get(ss[int(random(0, ss.length))]);
    else return null;
  }
  
  Spawn findFlagSpawn(int team) {
    int[] ss = new int[0];
    
    for(int i=0; i<game.spawnData.size(); i++) {
      Spawn sh = (Spawn) game.spawnData.get(i);
      if(sh.type == 8 && sh.subType == team) ss = append(ss, i);
    }
    
    if(ss.length > 0) return (Spawn) game.spawnData.get(ss[int(random(0, ss.length))]);
    else return null;
  }
  
  void render() {
    pushMatrix();
      translate(x, y, -10);
      /*
      //UNCOMMENT TO SHOW ALL SPAWNS
      if(type == 0) { fill(200, 0, 0, 100); stroke(100, 0, 0, 200); }
      else if(type == 1) { fill(150, 150, 150, 100); stroke(75, 75, 75, 200); }
      else if(type == 2) { fill(240, 240, 240, 100); stroke(120, 120, 120, 200); }
      else if(type == 3) { fill(20, 20, 20, 100); stroke(10, 10, 10, 200); }
      else if(type == 5) { fill(250, 215, 10, 100); stroke(125, 210, 5, 200); }
      else if(type == 6) { fill(0, 200, 0, 100); stroke(0, 100, 0, 200); }
      */
      /*
      //SHOW SPAWNS BY TEAM
      if(type == 1 || type == 6) {
        if(subType == 0) {  //GENERAL
          fill(255, 30);
          stroke(0, 30);
        } else if(subType == 1) {  //ALPHA
          fill(255, 200);
          stroke(255, 30);
        } else if(subType == 2) {  //BRAVO
          fill(255, 0, 0, 200);
          stroke(255, 30);
        } else if(subType == 3) {  //CHARLIE
          fill(0, 255, 0, 200);
          stroke(255, 30);
        } else if(subType == 4) {  //DELTA
          fill(0, 0, 255, 200);
          stroke(255, 30);
        }
      }
      */
      if(game.getGameType() == 3) {  //CAPTURE POINT
        scale(20);
        sphereDetail(3);
        strokeWeight(1);
      
        fill(constrain(team[0]+team[1], 0, 255), constrain(team[0]+team[2], 0, 255), constrain(team[0]+team[3], 0, 255), constrain(team[3], 100, 255));
        stroke(constrain(team[0]+team[3], 0, 255), constrain(team[3], 0, 255));
      } else if(game.getGameType() == 4) { //KING OF THE HILL
        scale(100);
        sphereDetail(7);
        strokeWeight(10);
        
        int normalizer = team[getBiggestInArray(team)];
        fill(map(team[0]+team[1], 0, normalizer, 0, 255), map(team[0]+team[2], 0, normalizer, 0, 255), map(team[0]+team[3], 0, normalizer, 0, 255), constrain(map(team[3], 0, normalizer, 0, 255), 50, 100));
        stroke(map(team[0]+team[3], 0, normalizer, 0, 255), map(team[3], 0, normalizer, 20, 80));
      }
      
      sphere(1);
    popMatrix();
    noStroke();
  }
}

