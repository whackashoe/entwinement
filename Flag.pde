class Flag {
  FBox flag;
  FDistanceJoint fJoint;
  int team;
  float x;
  float y;
  
  boolean held;
  boolean attached;
  Soldier sCast;
  
  Flag(float x_, float y_, int team_) {
    x = x_;
    y = y_;
    team = team_;
    held = false;
    
    respawn();
  }
  
  void update() {
    if(!held && frameCount % 90 == 0) {
      checkInsidePoly();
    } else if(sCast != null) {
      if(!sCast.alive) drop();
      
      for(int i=0; i<game.spawnData.size(); i++) {
        Spawn ph = (Spawn) game.spawnData.get(i);
        if(ph.type == 8 && ph.subType == sCast.team && dist(flag.getX(), flag.getY(), ph.x, ph.y) < 100 && !flagHeld(sCast.team) && held) {  //RIGHT KIND, IN OTHER TEAMS FLAG SPAWN POINT, AND OUR FLAG IS NOT CURRENTLY HELD
          Spawn sh = new Spawn();
          sh = sh.findFlagSpawn(sCast.team);
          sh.amount++;
          //TODO: ADD POINTS TO SOLDIER
          respawn();
        }
      }
    }
    
    render();
  }
  
  void respawn() {
    if(flag != null) drop();
    flag = new FBox(20, 20);
    Spawn curSpawnCast = new Spawn();
    curSpawnCast = (Spawn) curSpawnCast.findFlagSpawn(team);
    x = curSpawnCast.x;
    y = curSpawnCast.y;
    flag.setPosition(x, y);
    flag.setDensity(0.001);
    flag.setRotatable(true);
    world.add(flag);
  }
  
  void pickup(Soldier s_) {
    if(s_.team == team && dist(flag.getX(), flag.getY(), x, y) > 100) {
      respawn();
    } else {
      if(held == true) world.remove(fJoint);
      held = true;
      sCast = (Soldier) s_;
      s_.pickupFlag();
      flag.setSensor(true);
      fJoint = new FDistanceJoint(s_.self, flag);
      fJoint.setLength(5);
      fJoint.setFrequency(10);
      world.add(fJoint);
    }
  }
  
  void drop() {
    if(held) world.remove(fJoint);
    if(sCast != null) {
      sCast.carryingFlag = false;
      flag.addForce(sCast.self.getVelocityX(), sCast.self.getVelocityY());
    }
    held = false;
  }
  
  void render() {
    //RENDER POINTS
    pushMatrix();
      translate(x, y);
      scale(200);
      
      if(game.meCast.team != team) fill(200, 60, 40, 130);
      else fill(40, 200, 60, 130);
      
      ellipse(0, 0, 1, 1);
    popMatrix();
    
    pushMatrix();
      translate(flag.getX(), flag.getY(), 0);
      scale(20);
      if(team == 0) {
        fill(255);
      } else if(team == 1) {
        fill(255, 0, 0);
      } else if(team == 2) {
        fill(0, 255, 0);
      } else {
        fill(0, 0, 255);
      }
      
      beginShape();
        vertex(-0.5, -0.5);
        vertex(0.5, -0.5);
        vertex(0.5, 0.5);
        vertex(-0.5, 0.5);
      endShape();
    popMatrix();
  }
  
  void checkInsidePoly() {
    for(int i=0; i<game.polyData.size(); i++) {
      Polygon ph = (Polygon) game.polyData.get(i);
      if(ph.pointInside(flag.getX(), flag.getY())) {
        FPoly fp = (FPoly) game.polyData.get(i);
        respawn();
      }
    }
  }
  
  boolean flagHeld(int team) {
    for(int i=0; i<game.flagData.size(); i++) {
      Flag ph = (Flag) game.flagData.get(i);
      if(ph.team == team && ph.held) return true;
    }
    return false;
  }
  
  void remove() {
    world.remove(flag);
  }
}
