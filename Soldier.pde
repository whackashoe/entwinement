class Soldier {
  FCircle self;

  boolean alive;
  boolean me;
  boolean ai;
  boolean jetpack;
  boolean zombie;
  
  int id = -1;  //setup by id register unless myself as of now
  String name = settings.playerName;  //set up by id manager
  int team;
  int kills = 0;
  int deaths = 0;
  
  float health;
  
  ArrayList gunHolds;
  HoldGun curGun;
  
  int curAttachment;
  int curAttachmentAmmo;
  
  float gunAngle;
  int timeSinceLastShot;  //time since last hit--for double kiklls and such
  int idOfLastShot = -1;  //id of who shot the bullet hitting me
  int bulletIdOfLastShot; //TYPE OF BULLET HIT ME
  
  int curLetter = 0;
  
  int fireTime;
  int jumpTimer;
  boolean fire;
  boolean crouch;
  boolean hasMoved = false;
  boolean canJump;
  boolean touchingVehicle;
  boolean touchingPickup;
  
  boolean driving;
  boolean carryingFlag;
  
  Vehicle tVehicle;
  Pickups tPickup;
  
  Vehicle curCar;
  
  boolean chooseGun;

  int shoeAmount;
  
  int timeAlive;
  boolean keepDeadBody;
  boolean removedSelf;
  boolean addedZombies;
  
  boolean isInvincible;
  int invincibleTimer;
  int curInvincibleTimer;
  boolean backFlipping;
  
  int curJetpack;
  int damageFilter;
  
  boolean addedToKillList;
  boolean showKills;  //IN SHOWS WHO YOU KILL... OR MULTIKILL
  int showKillsTimer;
  int killsAmount;
  String lastKilledName;
  
  int nadeAmount = 5;
  boolean throwingNade;
  int nadeThrowCount = 0;
  
  boolean grappleAlive;
  Grapple grappleCast;
  
  boolean onEarth;  //only on if earths are present and nearest one is curearth
  Earth curEarth;
  float earthAngle;
  
  boolean foundSpawn;
  int respawnTime;
  int initialRespawnTime;
  Spawn curSpawnCast;
  
  Animation animCast;  //cast to your type of animation(Pikachu)
  Ragdoll ragCast;
  int animType;  //tracker of type(0-running, 1-stand etc)
  int animCount;  //tracker of frame(0, 1, 2, 3 etc)
  int animTimeCount;  //trancker of time added 1 to each iteration
  ArrayList deathTrailPoints;
  color deathColor;
  
  ArrayList path = new ArrayList();
  Soldier target;
  boolean targetIsVisible;
  int visibleTargetCountdown;
  
  int ping;
  
  
 Soldier(float x_, float y_) {
   showKills = false;
   onEarth = false;
   showKillsTimer = 0;
   killsAmount = 0;
   alive = true;
   me = false;
   ai = true;
   name = settings.botNames[int(random(settings.botNames.length))];
   targetIsVisible = false;
   visibleTargetCountdown = 5;
   chooseGun = true;
   zombie = false;
   showKills = false;
   newSelf(x_, y_);
   health = 100;
   touchingVehicle = false;
   touchingPickup = false;
   driving = false;
   fire = false;
   backFlipping = false;
   carryingFlag = false;
   fireTime = 0;
   jumpTimer = 0;
   crouch = false;
   timeAlive = 0;
   removedSelf = false;
   keepDeadBody = true;
   isInvincible = false;
   addedZombies = false;
   addedToKillList = false;
   damageFilter = 0;
   grappleAlive = false;
   
   gunHolds = new ArrayList();
   gunHolds.add(new HoldGun());
   curGun = (HoldGun) gunHolds.get(gunHolds.size()-1);

   curAttachment = 0;
   curAttachmentAmmo = game.jetpackMax;
   
   animType = -1;
   setupAnim();
   
   deathTrailPoints = new ArrayList();
   deathColor = color(random(0, 255), random(0, 255), random(0, 255), 50);
   ping = 0;
   
   if(!playingOnline) id = int(random(0, Integer.MAX_VALUE));
   
   if(game.jython != null) game.jython.onSoldierAdd(id, name, team);
  }
  
  void setName(String name_) {
    name = name_;
    if(game.jython != null) game.jython.changeSoldierName(id, name);
  }
  
  void setZombie(boolean set_, int health_) {
    zombie = set_;
    health = health_;
    team = -1;
    setName("A ZOMBIE");
  }
  
  void setMe(boolean set_) {
    me = set_;
    ai = !set_;
    setName(settings.playerName);
  }
  
  void setMe(boolean set_, int team_) {
    me = set_;
    ai = !set_;
    team = team_;
    setName(settings.playerName);
  }
  
  void setAi(boolean set_) { ai = set_; setAICurGun(); }
  void setAi(boolean set_, int team_) { ai = set_; team = team_; setAICurGun(); }
  
  void setOnlineDude(int id_, String name_) {
    id = id_;
    name = name_;
    ai = false;
  }
  
  void setTeam(int team_) { team = team_; }
  
  /*void setId(int id_) {
    id = id;
  }*/
  
  void setPing(int ping_) { ping = ping_; }
  
  void setHealth(float health_) { health = health_; }
  
  void setGun(int gun, int ammo, int delayCount, int reloadCount) {
    int hgpos = findGunHoldPos(gun);
    if(hgpos >= 0) {
      curGun = (HoldGun) gunHolds.get(hgpos);
      curGun.ammo += ammo;
      return;
    }
    
    gunHolds.add(new HoldGun(gun, ammo, delayCount, reloadCount));
    curGun = (HoldGun) gunHolds.get(gunHolds.size()-1);
    if(game.jython != null) game.jython.changeSoldierGun(id, curGun.gun);
  }
  
  void setAttachment(int type, int ammo) {
    curAttachment = type;
    curAttachmentAmmo = ammo*2;
  }
  
  void setAICurGun() {  //USE FOR WHEN AI SPAWNS FOR THEM TO CHOOSE NEW WEP
    int[] g = new int[0];
    for(int i=0; i<game.gunData.length; i++) if(game.gunData[i].choice) g = append(g, i);
    if(g.length > 0) {
      
      gunHolds = new ArrayList();
      gunHolds.add(new HoldGun(int(random(0, g.length))));
      curGun = (HoldGun) gunHolds.get(gunHolds.size()-1);
    }
  }
  
  void removeSelf() {
    if(!driving) {
      if(curGun.gun != 0) game.pickupData.add(new Pickups(self.getX(), self.getY()-20, curGun));  //ADD GUN
      world.remove(self);
      if(curAttachment != 0 && curAttachmentAmmo > 0) game.pickupData.add(new Pickups(self.getX(), self.getY()-20, curAttachment, curAttachmentAmmo));  //ADD ATTACHMENT
    }
  }
  
  void startNadeThrow() {
    if(nadeAmount > 0) {
      throwingNade = true;
    } else {
      throwingNade = false;
    }
  }
  
  void throwNade() {
    if(throwingNade = true) {
      //throw///
      nadeAmount--;
      nadeThrowCount = 0;
      throwingNade = false;
    }
  }
  
  void update() {
    setPing(ping+1);
    
    if(settings.debugMode && game.checkInsidePoly(self)) println("soldier inside:"+int(self.getX())+"/"+int(self.getY()));
    
    if(alive) {
      if(me) gunAngle =  atan2(mouseY-height/2, mouseX-width/2);
      else if(target != null) gunAngle =  atan2(target.self.getY()-self.getY(), target.self.getX()-self.getX());
  
      if(jumpTimer > 0) jumpTimer--;
            
      if(fire && fireTime > 0) {
        game.particleData.add(new Particle(0, self.getX(), self.getY(), random(5, 20)));
        getShot(0.5);
        killLogging(-2);
        fireTime--;
      }
      timeAlive += 1;
      
      if(health < 1 || self.getY() > mapH/2-50 || self.getY() < -mapH/2+50 || (driving && !curCar.alive)) { alive = false; chooseGun = true; }
      if(health > 200) health -= ((health-200)/100)*0.1;
      //if(timeAlive % 120 == 0 && checkInsidePoly(true)) copySelfFromInsidePoly();
      curGun.update();
      if(game.earthData.size() > 0) checkEarths();
      if(me) checkMyself();
      if(ai) AI();
      if((!mousePressed || mouseButton != RIGHT) && curAttachment == 0 && curAttachmentAmmo < game.jetpackMax) {
        curAttachmentAmmo++;
        if(canJump) curAttachmentAmmo++;
      }
      
      if(zombie) {
        game.particleData.add(new Particle(1, self.getX(), self.getY(), random(5, 10)));
        health--;
      }
      
      if(isInvincible) {
        curInvincibleTimer--;
        if(curInvincibleTimer < 1) isInvincible = false;
      }
      if(showKills) {
        if(showKillsTimer > 0) showKillsTimer--;
        if(showKillsTimer < 1) {
          killsAmount = 0;
          showKills = false;
        }
      }
      touchingVehicle = false;
      touchingPickup = false;
      canJump = false;
    } else if(!removedSelf) {
      if(grappleAlive) {
        grappleCast.kill();
        grappleAlive = false;
      }
      
      if(driving && curCar.isInhabited && curCar.alive) {
        exitVehicle(true);
        driving=false;
        curCar.setDriver(false, false, 0);
      }
      
      if(game.zombieMode && !addedZombies && !zombie && frameRate >= 28) {
        game.soldierData.add(new Soldier(self.getX(), self.getY()-20));
        Soldier sh = (Soldier) game.soldierData.get(game.soldierData.size()-1);
        sh.setZombie(true, 1000);
        addedZombies = true;
      } else if(game.zombieMode && !addedZombies && !zombie && frameRate < 28) {
        addedZombies = true;
        println("Your computer couldn't handle any more zombies"+game.soldierData.size());
      }
      
      
      if(!addedToKillList) {
        if(game.jython != null) game.jython.onSoldierDie(id);
        
        if(playingOnline) {
          byte[] b = new byte[1];
          b[0] = 4;
          client.send(b, serverIp, serverPort);
        }
        
        game.kConsole.addKillData(idOfLastShot, id, bulletIdOfLastShot);
   
        if(idOfLastShot >= 0) addKills(idOfLastShot);
        deaths++;
        if(bulletIdOfLastShot >= 0 && idOfLastShot >= 0) game.getSoldierById(idOfLastShot).kills++;
        ragCast.createEffect(self, self.getSize(), gunAngle);
        addedToKillList = true;
      }
     
      if(!foundSpawn) {
        curSpawnCast = new Spawn();
        curSpawnCast = (Spawn) curSpawnCast.findSoldierSpawn(team);
        if(curSpawnCast != null) {
          respawnTime = curSpawnCast.getTime();
          initialRespawnTime = respawnTime;
          foundSpawn = true;
        }
      }  
      respawnTime--;
      if(respawnTime < 1 && foundSpawn) curSpawnCast.spawnSoldier(this);
    }

    hasMoved = false;
    if(!driving && game.checkRender(getPosition().x, getPosition().y, 1.0)) render();
  }
  
  void checkDeathTrail() {
    //if(frameCount % 3 == 0) deathTrailPoints.add(new Vec2D(self.getX(), self.getY(), noise(self.getX())*10));  //random
    if(frameCount % 3 == 0) deathTrailPoints.add(new Vec3D(self.getX(), self.getY(), map(constrain(abs(self.getVelocityX())+abs(self.getVelocityY()), 0, 700), 700, 1, 1, 8)));
    stroke(deathColor);
    if(!alive) stroke(deathColor >> 16 & 0xFF, deathColor >> 8 & 0xFF, deathColor & 0xFF, 150);
    float pre = 0;
    
    for(int i=1; i<deathTrailPoints.size(); i++) {
     Vec3D p1 = (Vec3D) deathTrailPoints.get(i);
     Vec3D p2 = (Vec3D) deathTrailPoints.get(i-1);     
     //strokeWeight(map(health, 100, 0, 1, self.getSize()));
     strokeWeight(p2.z);
     line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
    }
    
    noStroke();
  }
  
  void setupAnim() {
    if(animType == -1) {
      game.ragdollData.add(new Ragdoll(0));
      ragCast = (Ragdoll) game.ragdollData.get(game.ragdollData.size()-1);
      animType = 0;  //tracker of type(0-running, 1-stand etc)
      animCount = 0;  //tracker of frame(0, 1, 2, 3 etc)
      animTimeCount = 0;  //trancker of time added 1 to each iteration
      
      if(zombie) {
        animCast = (Animation) game.animData.get(game.getAnimIdByName("Zombie"));
      } else {
        if(game.getGameType() == 0 || game.getGameType() == 1) {
          animCast = (Animation) game.animData.get(game.getAnimIdByName("Mario"));  //cast to your type of animation(Pikachu)
        } else {
          if(team == 0) animCast = (Animation) game.animData.get(game.getAnimIdByName("Team1"));
          if(team == 1) animCast = (Animation) game.animData.get(game.getAnimIdByName("Team2"));
          if(team == 2) animCast = (Animation) game.animData.get(game.getAnimIdByName("Team3"));
          if(team == 3) animCast = (Animation) game.animData.get(game.getAnimIdByName("Team4"));
        }
        
        if(me) animCast = (Animation) game.animData.get(game.getAnimIdByName("Team1"));
      }
    }
  }
  
  void checkMyself() {
    if(game.lmbPush) shoot();
    if(game.rmbPush) useAttachment();
    
    for(int i=0; i<game.controlBullets.size(); i++) {
      Bullet ph = (Bullet) game.controlBullets.get(i);
      if(ph == null && !ph.alive) game.controlBullets.remove(i);
      else ph.applyForce(mouseX-width/2);
    }
  }
  
  void AI_findNewTarget() {
    if(game.getGameType() == 0) {  //ALL AGAINST YOU, GOOD LUCK
      target = (Soldier) game.soldierData.get(0);
    } else if(game.getGameType() == 1) {  //DEATHMATCH
      target = (Soldier) findClosestToMe(self.getX(), self.getY(), -1);  //THE -1 SPECIFIES ANY TEAM
    } else {  //PLAYING TEAM BASED GAME
      target = (Soldier) findClosestToMe(self.getX(), self.getY(), team);
    }
    
    //FIND WHICH NODE SELF AND TARGET (A, B) BELONG TO
    if(game.pfEnabled) {
      try {
        Node a = (Node) game.pf.nodes.get(int(((self.getY()-game.pf_y+(game.pf_h/2))/game.pf_h)*game.pf_rows)+int((self.getX()-game.pf_x+(game.pf_w/2))/game.pf_w));
        Node b = (Node) game.pf.nodes.get(int(((target.self.getY()-game.pf_y+(game.pf_h/2))/game.pf_h)*game.pf_rows)+int((target.self.getX()-game.pf_x+(game.pf_w/2))/game.pf_w));
        path = game.pf.bfs(a, b);
      } catch(ArrayIndexOutOfBoundsException e_) {
        e_.printStackTrace();
      }
    }
  }
  
  void AI() {
    if(timeAlive % 30 == 0 || timeAlive < 5 || !target.alive) AI_findNewTarget();
    
    if(game.pfEnabled) {
      if(path != null && path.size() >= 2) {
        Node tempNode = (Node) path.get(path.size()-1);  //CURRENT NODE
        Node nextNode = (Node) path.get(path.size()-2);  //NEXT IN LINE
        
        if(self.getVelocityX() < 0 && (nextNode.x-tempNode.x) > 0 || self.getVelocityX() > 0 && (nextNode.x-tempNode.x) < 0) {
          addMovement(int(nextNode.x-tempNode.x), -1);  //MOVE TOWARDS NEXT WITH HOPS CUS WE HAVIN TROUBLE
        } else {
          addMovement(int(nextNode.x-tempNode.x), int(nextNode.y-tempNode.y));  //MOVE TOWARDS NEXT NORMALLY
        }
        //if(nextNode.y-tempNode.y < 0 && pAttachments[0][0] != 2) { useAttachment(); }  //IF MOVING UP AND NOT GONNA AIRSTRIKE 
        
        //CHECK TP SEE IF WE SHOULD REMOVE PIECE THAT WERE ON IF WE'RE PAST IT
        if(int((self.getX()-game.pf_x+(game.pf_w/2))/game.pf_w) != tempNode.x || int((self.getY()-game.pf_y+(game.pf_h/2))/game.pf_h) != tempNode.y) {
          path.remove(path.size()-1);
        }
      }
      
      if(visibleTargetCountdown > 0) visibleTargetCountdown--;
      if(visibleTargetCountdown == 0) {
        targetIsVisible = isVisible(self.getX(), self.getY(), target.self.getX(), target.self.getY());
        visibleTargetCountdown += int(random(4, 8));
      }
      
      if(targetIsVisible && !game.bitchMode) {
        gunAngle += random(-0.1, 0.1);
        if((game.getGameType() == 0 || game.getGameType() == 1)) {
          shoot();
        } else if(target.team != team) {
          shoot();
        }
      }
    } else {  //IF MAP DOESN'T HAVE PATHFINDING SETUP WELL FALL BACK TO THIS SYSTEM
      if(random(1)<0.02) addMovement(0, -1); //RANDOM JUMPS
      if(!driving) {
        Soldier sh = null;
        if(game.getGameType() == 1) findClosestToMe(self.getX(), self.getY(), -1);
        else findClosestToMe(self.getX(), self.getY(), team);
        
        if(sh != null && abs(dist(sh.self.getX(), sh.self.getY(), self.getX(), self.getY())) < 200) {
          int mvX = 0, mvY = 0;
          
          if(sh.self.getVelocityX() > 0) mvX++;
          else mvX--;
          
          if(sh.self.getVelocityY() < 0) mvY--;
          
          addMovement(mvX, 0);
        } else {
          if(target.self.getX()>self.getX()) addMovement(1, 0);
          else addMovement(-1, 0);
        }
        if(!game.bitchMode) shoot();
        
        
      } else {
        //IF DRIVING
      }
    }
  }
  
  void checkEarths() {
    if(game.earthData.size() == 1) {
      curEarth = (Earth) game.earthData.get(0);
      onEarth = true;
    } else if(game.earthData.size() > 1) {
      float[] earthDists = new float[game.earthData.size()];
      
      for(int i=0; i<game.earthData.size(); i++) {
        Earth eh = (Earth) game.earthData.get(i);
        earthDists[i] = dist(eh.earth.getX(), eh.earth.getY(), self.getX(), self.getY());
      }
      
      float smallestD = min(earthDists);
      int whichOne = 0;
      
      for(int i=0; i<earthDists.length; i++) {
        if(smallestD == earthDists[i]) {
          whichOne = i;
          break;
        }
      }
      
      curEarth = (Earth) game.earthData.get(whichOne);
      onEarth = true;
      
    }
    if(onEarth) earthAngle = atan2(self.getY()-curEarth.earth.getY(), self.getX()-curEarth.earth.getX());
  }
  
  void addKills(int id_) {
    kills++;
    if(!playingOnline) {
      //IDRegister.REG ph = (IDRegister.REG) game.idReg.IDS.get(game.idReg.regLookup(id_)); 
      //lastKilledName = ph.name;
      showKills=true;
      showKillsTimer = (showKillsTimer/2)+120;
      killsAmount++;
    }
    
    if(game.jython != null) game.jython.onSoldierKill(id, id_);
  }
  
  void pickupFlag() { carryingFlag = true; }
  
  void switchGun(int id_) {
    gunHolds = new ArrayList();
    gunHolds.add(new HoldGun(id_));
    curGun = (HoldGun) gunHolds.get(gunHolds.size()-1);
    
    
    if(playingOnline) {
      byte[] b = new byte[1];
      b[0] = 5;
      b = concat(b, toByte(id_));
      client.send(b, serverIp, serverPort);
      println("GUN cHOOSE send");
    }
  }
  
  void useAttachment() {
    if(driving == false) {
      if(curAttachment == 0) {
        useJetpack();
      }
    } else if(driving == true && curAttachment == 0 && curAttachmentAmmo > 50) {
      exitVehicle(false);
      curAttachmentAmmo -= 50;
    }
    
    if(curAttachment == 1 && game.rmbPush) {
      useGrapple();
      game.rmbPush = false;  //SWITCH IT SO WE DONT HAVE QUICK FIRING GRAPPLES
    }
    
    if(curAttachment == 2 && game.rmbPush) {
      useAirStrike();
      game.rmbPush = false;
    }
  }
  
  void sendAttachmentData() {
    byte[] b = new byte[2];
    b[0] = 7;
    b[1] = 1;
    b = concat(b, toByte(mouseX));
    b = concat(b, toByte(mouseY));
    client.send(b, serverIp, serverPort);
  }
  
  void useJetpack() {
    if(curAttachmentAmmo > 3) {
      if(!onEarth) self.addForce(0, -120);
      else self.addForce(-cos(earthAngle)*-120, -sin(earthAngle)*-120);
      
      game.particleData.add(new Particle(3, self.getX()-(self.getSize()/2*-getDirectionFacing()), self.getY()+self.getSize()/2, random(1, 5)));
      curAttachmentAmmo -= 3;
    }
    //JUST TO MAKE SURE ON SWITCH IT DOES NOT REMAIN
    if(grappleAlive) {
      grappleCast.kill();
      grappleAlive = false;
    }
    if(playingOnline) sendAttachmentData();
  }
  
  void useGrapple() {
    if(grappleCast == null || !grappleCast.alive) grappleAlive = false;  //incase grapple has done itself in
    
    if(grappleAlive) {
      grappleCast.kill();
      grappleAlive = false;
    } else if(curAttachmentAmmo > 0) {
      if(!playingOnline) {
        grappleAlive = true;
        Vec2D grapplePos;
        Vec2D grappleForce;
        
         if(!driving) {
           grapplePos = new Vec2D(self.getX()+cos(gunAngle)*self.getSize()*2, self.getY()+sin(gunAngle)*self.getSize()*2);
        } else {
          grapplePos = new Vec2D(curCar.getCockpitPos().x+curCar.grappleX, curCar.getCockpitPos().y+curCar.grappleY);
        }
        
        float gxf = cos(gunAngle)*(20000/(width/2));
        float gyf = sin(gunAngle)*(20000/(height/2));
        //println(gxf+" "+gyf);
        grappleForce = new Vec2D(gxf*abs(mouseX-width/2), gyf*abs(mouseY-height/2));
        
        if(!driving) {
          game.grappleData.add(new Grapple(self, grapplePos, grappleForce));
        } else {
          game.grappleData.add(new Grapple(curCar.getCockpit(), grapplePos, grappleForce));
        }
        grappleCast = (Grapple) game.grappleData.get(game.grappleData.size()-1);
      } else {
        //sendAttachmentData();
      }
      curAttachmentAmmo--;
    }
    if(playingOnline) sendAttachmentData();
  }
  
  void useAirStrike() {
    if(curAttachmentAmmo > 0) {
      int airStrikeAmount = 8;
      
      for(int i=0; i<airStrikeAmount; i++) {
        if(!playingOnline) game.AirStrike.setBoom(true, int(random(20, 80)), 5);
        if(mouseX > width/2) {
          game.bulletData.add(new Bullet(self.getX()+((mouseX-width/2)*2)-(i*70), self.getY()-1000-(airStrikeAmount*50)+i*50, 400000, i*1000, id, game.AirStrike)); 
        } else {
          game.bulletData.add(new Bullet(self.getX()+((mouseX-width/2)*2)+(i*70), self.getY()-1500+i*50, -400000, i*1000, id, game.AirStrike)); 
        }
        if(i == round(airStrikeAmount/2) && me) game.setFollowBullet((Bullet) game.bulletData.get(game.bulletData.size()-1));
      }
      
      curAttachmentAmmo--;
    }
    if(playingOnline) sendAttachmentData();
  }
  
  void jump(int xMotionPush_) {
    ArrayList checkMeContacts;
    try {
      checkMeContacts = self.getContacts();
    } catch(NullPointerException e) {
      e.printStackTrace();
      return;
    }
    
    if(jumpTimer == 0 && checkMeContacts.size() > 0) {
      float xAdd = 0;
      if(game.aPush) xAdd -= 380;
      else if(game.dPush) xAdd += 380;
      if(!onEarth) {
        self.addForce(xAdd, -1500+abs(xAdd));
      } else {
        self.addForce(cos(earthAngle)*1500, sin(earthAngle)*1500);
      }
      //if(playingOnline) { game.onlineMove(0); }
      jumpTimer += 10;
      canJump = false;
    }
  }
  
 void render() {
    animTimeCount++;
    if(animCount != animCast.getId(animType, animCount, animTimeCount)) {
      animCount = animCast.getId(animType, animCount, animTimeCount);
      animTimeCount = 0;
    }
    
    //checkDeathTrail();
    
    
    pushMatrix();
      if(alive) {
        if(!driving || !curCar.alive) translate(self.getX(), self.getY(), 0.5);
        else translate(curCar.getCockpitPos().x, curCar.getCockpitPos().y, 0.5);
      } else {
        translate(ragCast.pieces[0].getX(), ragCast.pieces[1].getY(), 0.5);
      }
      
      if(settings.debugMode) {
        fill(255, 0, 0);
        stroke(0);
        strokeWeight(1);
        ellipse(0, 0, self.getSize(), self.getSize());
        noStroke();
        popMatrix();
        return;
      }
      
      if(isInvincible) {
        fill(200, map(curInvincibleTimer, invincibleTimer, 0, 200, 0));
        ellipse(0, 0, self.getSize()*2, self.getSize()*2);
        for(int z=0; z<int(random(5, 10)); z++) {
          stroke(random(0, 255), random(0, 255), random(0, 255));
          strokeWeight(3);
          point(random(-self.getSize()*.66, self.getSize()*.66), random(-self.getSize()*.66, self.getSize()*.66), self.getSize());
        }
        noStroke();
      }
      
      
      pushMatrix();
      
        if(onEarth) rotate(earthAngle+HALF_PI);
        if(settings.drawSoldierNames && !me) {
          pushMatrix();
            if(alive) fill(255, 100);
            else fill(255, int(map(constrain(respawnTime, 0, 120), 0, 120, 0, 100)));
            textFont(FONTframeRate, 12);
            text(name, -10, -10);
          popMatrix();
          //text(self.getX()+"/"+self.getY(), -30, 0);
        } else if(me) {
          //DRAW WHITE ARROW
          fill(255);
          if(!carryingFlag) {
            fill(255, 100);
          } else {
            fill(255, 0, 0, 100);
          }
          beginShape();
            vertex(-4, -20);
            vertex(4, -20);
            vertex(0, -10);
          endShape();
        }

        //TURN TO SIDE
        scale(getDirectionFacing(), 1);
        
        if(!alive || backFlipping) rotate(self.getRotation());
        
        
        int[] sColor = null;
        if(game.getGameType() == 0 || game.getGameType() == 1) {
          sColor = game.getSoldierColorByTeam(0);
        } else if(!zombie) {
          sColor = game.getSoldierColorByTeam(team);
        } else {
          sColor = game.getSoldierColorByTeam(team);
        }
        if(!alive) sColor[3] = int(map(constrain(respawnTime, 0, 120), 0, 120, 0, 255));
        tint(sColor[0], sColor[1], sColor[2], sColor[3]);

        int gunOffsetY = 0;
        int gunOffsetX = 0;
        
        /*if(animType == 0) {
          image(animCast.running[animCount], -animCast.running[animCount].width/2, -animCast.running[animCount].height/2, animCast.running[animCount].width, animCast.running[animCount].height);
          gunOffsetY = -animCast.running[animCount].height/4;
        }*/

      popMatrix();
      
      if(game.gunData[curGun.gun].weaponImg) {
        pushMatrix();
          rotate(gunAngle);
          scale(1, getDirectionFacing());
          
          tint(255, 255);
          if(!alive) {
            rotate(self.getRotation());
            tint(255, int(map(constrain(respawnTime, 0, 120), 0, 120, 0, 255)));
          }
          image(game.gunData[curGun.gun].weapon, 0, gunOffsetY);
        popMatrix();
      }
      if(game.gunData[curGun.gun].sniperLine) {
        stroke(200, 0, 0, 150);
        strokeWeight(2);
        
        Vec2D point1 = new Vec2D(self.getX(), self.getY());
        Vec2D point2 = new Vec2D(self.getX()+(game.gunData[curGun.gun].speed*cos(gunAngle)*3), self.getY()+(game.gunData[curGun.gun].speed*sin(gunAngle)*3));
        
        line(0, 0, game.gunData[curGun.gun].speed*cos(gunAngle)*3, game.gunData[curGun.gun].speed*sin(gunAngle)*3);  //REMOVE AND BELOW IS SEMIFIX
        noStroke();
      }
      
    popMatrix();
    ragCast.render(self, self.getSize(), gunAngle);
  }
  
  void startFire() {
    fireTime += 100;
    if(!fire) {
      fire = true;
    } else {
      health -= 20;
      killLogging(-2);
    }
  }
  
  void respawn(float x_, float y_) {
    if(me) {
      colorMode(RGB);
      game.enemySoldiersDowned = 0;
    }
    if(grappleAlive) {
      grappleCast.kill();
      grappleAlive = false;
    }
    if(!removedSelf) removeSelf();
    
    removedSelf = true;
    newSelf(x_, y_);
    curAttachment = 0;
    curAttachmentAmmo = game.jetpackMax;
    showKills = false;
    showKillsTimer = 0;
    killsAmount = 0;
    health = 100;
    shoeAmount = 2;
    touchingVehicle = false;
    touchingPickup = false;
    driving = false;
    fire = false;
    fireTime = 0;
    jumpTimer = 0;
    alive = true;
    jetpack = false;
    crouch = false;
    carryingFlag = false;
    foundSpawn = false;
    removedSelf = false;
    isInvincible = true;
    invincibleTimer = 60;
    curInvincibleTimer = invincibleTimer;
    timeAlive = 0;
    addedZombies = false;
    addedToKillList = false;
    if(grappleAlive) {
      grappleCast.kill();
      grappleAlive = false;
    }
    
    idOfLastShot = -1;
    bulletIdOfLastShot = -1;
    deathTrailPoints.clear();
    //if(me) game.curFollowBullet = null;
    if(ragCast.ragEffect) ragCast.endRagEffect();
      
    if(ai) setAICurGun();
    
    if(game.jython != null) game.jython.onSoldierRespawn(id);
  }
 
 void newSelf(float x_, float y_) {
   self = new FCircle(20);
   self.setDensity(0.1);
   self.setFriction(0.5);
   self.setRestitution(0.1);
   self.setFill(255, 0, 0);
   self.setStatic(false);
   self.setBullet(true);
   self.setRotatable(true);
   self.setAngularDamping(0.5);
   self.setDrawable(false);
   self.setPosition(x_, y_);
   self.setGroupIndex(-1);
   //self.setAsCircle(25);
   world.add(self);
   self.addForce(0, -1500);
 }
  
  void throwGun() {
    game.pickupData.add(new Pickups(self.getX()+(cos(gunAngle)*15), self.getY()+(sin(gunAngle)*15), curGun));
    Pickups ph = (Pickups) game.pickupData.get(game.pickupData.size()-1);
    FBody bh = (FBody) ph.p;
    bh.addForce(cos(gunAngle)*2000, sin(gunAngle)*2000);
    
    int curPos = findGunHoldPos(curGun.gun);
    gunHolds.remove(curPos);
    if(gunHolds.size() == 0) {  //set to fists
      gunHolds.add(new HoldGun(0));
      curGun = (HoldGun) gunHolds.get(0); 
    } else if(curPos >= gunHolds.size()) {
      curGun = (HoldGun) gunHolds.get(0); 
    }
  }
  
  void getShot(float damage_) {
    health = health-damage_;
    damageFilter += damage_*2;
  }
  
  void enterVehicle(Vehicle vId_) {
    if(game.jython != null) game.jython.onSoldierEnterVehicle(id, vId_.id);
    driving = true;
    if(!playingOnline && grappleAlive && grappleCast.attached) {
      grappleCast.kill();
      grappleAlive = false;
    } else if(grappleAlive && grappleCast.attached) {
      grappleCast.kill();
      grappleAlive = false;
    }
    world.remove(self);
    curCar = (Vehicle) vId_;
    curCar.setDriver(true, false, id); //SHOWS YOUR IN
  }
  
  void pickup(Pickups pId_) {
    Pickups pick = (Pickups) pId_;
    FBox pickBox = (FBox) pick.p;
    
    if(pick.type[0] == 0) setGun(pick.type[1], pick.type[2], pick.type[3], pick.type[4]);
    if(pick.type[0] == 1) health = health+pick.type[1];
    if(pick.type[0] == 2) setAttachment(pick.type[1], pick.type[2]);
     
    pick.alive = false;
    touchingPickup = false;
  }
  
  void exitVehicle(boolean door_) {
    if(game.jython != null) game.jython.onSoldierExitVehicle(id);
    driving = false;
    touchingVehicle = false;
    if(!playingOnline && grappleAlive && grappleCast.attached) {
      grappleCast.kill();
      grappleAlive = false;
    } else if(grappleAlive && grappleCast.attached) {
      grappleCast.kill();
      grappleAlive = false;
    }
    Vec2D aVelo = curCar.getCockpitVelo();
    Vec2D pos = curCar.someoneExiting(door_);
    newSelf(pos.x, pos.y);
    //if(grappleAlive && grappleCast.attached) { grappleCast.switchBody(self); }
    Vec2D leaveForce = curCar.exitForce(door_);
    self.addForce(leaveForce.x, leaveForce.y);
    self.adjustVelocity(aVelo.x, aVelo.y);
  }
  
  void shoot() {
    if(game.bitchMode && ai) return;
    if(!driving) {
      if(curGun.canShoot()) {
        if(!game.gunData[curGun.gun].moveAcc) game.shootGun(self.getX()+(cos(gunAngle)*self.getSize()), (self.getY()+sin(gunAngle)*self.getSize()), gunAngle, 0, 0, curGun.gun, id);
        else game.shootGun(self.getX()+(cos(gunAngle)*self.getSize()), (self.getY()+sin(gunAngle)*self.getSize()), gunAngle, self.getVelocityX(), self.getVelocityY(), curGun.gun, id);
        curGun.shoot();
        timeSinceLastShot = 0;
        if(game.gunData[curGun.gun].speedMultBasedOnMouse) {
          Bullet bCast = (Bullet) game.bulletData.get(game.bulletData.size()-1);
          bCast.addMoveAcc(
            map(mouseX, 0, width, -game.gunData[curGun.gun].speedMultX, game.gunData[curGun.gun].speedMultX), 
            map(mouseY, 0, height, -game.gunData[curGun.gun].speedMultY, game.gunData[curGun.gun].speedMultY)
          );
        }
      }
    } else {
      curCar.shoot();
    }
  }
  
  int findGunHoldPos(int gun) {
    for(int i=0; i<gunHolds.size(); i++) {
      HoldGun hg = (HoldGun) gunHolds.get(i);
      if(hg.gun == gun) return i;
    }
    return -1;
  }
  
  void changeGunUp() {
    if(findGunHoldPos(curGun.gun) < gunHolds.size()-1) curGun = (HoldGun) gunHolds.get(findGunHoldPos(curGun.gun)+1);
    else curGun = (HoldGun) gunHolds.get(0);
  }
  
  void changeGunDown() {
    if(findGunHoldPos(curGun.gun) > 0) curGun = (HoldGun) gunHolds.get(findGunHoldPos(curGun.gun)-1);
    else curGun = (HoldGun) gunHolds.get(gunHolds.size()-1);
  }
  
  void addMovement(int x_, int y_) {
    if(chooseGun) {
      chooseGun = false;
      switchGun(curGun.gun);
    }
    
    if(alive) {
      if(playingOnline) game.onlineMove(x_, y_);

      if(!driving) {
        try {          
          if(x_ == 0 && y_ == 0) {
            

          } else {
            if(!backFlipping) self.adjustRotation(0.5*x_);
            
            if(self.getVelocityX() > 0 && x_ < 0 || self.getVelocityX() < 0 && x_ > 0) x_ *= 2;
            if(!onEarth) {
              self.addForce(25*x_, -5);
            } else {
              self.addForce(25*x_*-sin(earthAngle), 25*x_*cos(earthAngle));
            }
          }
        
          if(y_ == -1 && alive && canJump) {
            jump(x_);
          } else if(y_ == 1 && canJump) {
            crouch = true;
          }
        } catch (NullPointerException e_) {
          e_.printStackTrace();
        }  catch (AssertionError e_) {
          e_.printStackTrace();
        }
      } else if(!playingOnline) { curCar.addMovement(x_, y_); }
      
      if(crouch) {
        self.setRotation(0);
        if(!onEarth && canJump) self.setVelocity(self.getVelocityX()*0.6, self.getVelocityY());
      }
      
    }
    hasMoved = true;
  }
  
  void killLogging(Bullet b_) {  //USE THIS WHEN HIT BY BULLET
    idOfLastShot = b_.id;
    bulletIdOfLastShot = b_.type;
  }
  
  void killLogging(int b_) {  //USE THIS WHEN HURT OTHERWISE
    bulletIdOfLastShot = b_;
    /*
    -1 = GROUND/COLLISION
    -2 = FIRE
    -3 = EXPLOSION
    -4 = 
    */
  }

  
  Soldier findClosestToMe(float x_, float y_, int team_) {
    int cId = -1;
    float[] closestDistance = new float[3];
    closestDistance[0] = 100000;
    closestDistance[1] = 100000;
    closestDistance[2] = 100000;
    int[] closestId = new int[3];
    closestId[0] = 0;
    closestId[1] = 0;
    closestId[2] = 0;
    boolean[] closestVisible = new boolean[3];
    
    for(int i=0; i<game.soldierData.size(); i++) {
      Soldier sh = (Soldier) game.soldierData.get(i);
      if(sh.self.getX() != x_ && sh.self.getY() != y_ && sh.alive && sh.team != team_) {  //MAKE SURE ITS NOT SELF CHECKING and there alive
        float d = dist(x_, y_, sh.self.getX(), sh.self.getY());
        
        for(int j=0; j<closestId.length; j++) {
          if(d < closestDistance[j]) {
            closestVisible[j] = isVisible(x_, y_, sh.self.getX(), sh.self.getY());
            closestId[j] = i;
            closestDistance[j] = d;
            break;
          }
        }
      }
    }
    
    cId = closestId[0];
    if(closestVisible[0] == false) {
      if(closestVisible[1] && closestDistance[0] < closestDistance[1]/.66) {
        cId = closestId[1];
      } else if(closestVisible[2] && closestDistance[0] < closestDistance[1]/.66) {
        cId = closestId[2];
      }
    }
    
    if(cId != -1) {
      return (Soldier) game.soldierData.get(cId);
    } else {
      return (Soldier) game.soldierData.get(int(random(0, game.soldierData.size())));
    }
  }
  
  int getDirectionFacing() {
    if(me) {
      if(!onEarth) {
        if(mouseX < width/2) return 1;
      } else {
        //  TODO
      }
    } else if(ai) {
      if(target != null) {
        if(target.self.getX() < self.getX()) return 1;
      }
    }
      
    return -1;  //FACE RIGHT
  }
  
  Vec2D getVelocity() {
    Vec2D v = new Vec2D(0, 0);
    if(!driving) {
      v.set(self.getVelocityX(), self.getVelocityY());
    } else {
      //GET VELOCITY OF VEHICLE
      Vec2D vehV = curCar.getCockpitVelo();
      v.set(vehV.x, vehV.y);
    }
    return v;
  }
  
  Vec2D getPosition() {
    Vec2D p = new Vec2D(0, 0);
    if(!driving) {
      p.set(self.getX(), self.getY());
    } else {
      //GET VELOCITY OF VEHICLE
      if(curCar == null || curCar.getCockpitPos() == null) return p;  //helps with bug of after veh exploding causing nullpointer
      p.set(curCar.getCockpitPos());
    }
    return p;
  }
  
  /*byte[] getPV() {
    byte[] b = new byte[0];
    byte[] fpx = toByte(getPosition().x);
    byte[] fpy = toByte(getPosition().y);
    byte[] fvx = toByte(getVelocity().x);
    byte[] fvy = toByte(getVelocity().y);
    b = concat(b, fpx);
    b = concat(b, fpy);
    b = concat(b, fvx);
    b = concat(b, fvy);
    return b;
  }
  
  void setPV(byte[] b_) {
    if(b_.length == 16) {
     byte[] px = new byte[4];
     px[0] = b_[0];
     px[1] = b_[1];
     px[2] = b_[2];
     px[3] = b_[3];
     
     byte[] py = new byte[4];
     py[0] = b_[4];
     py[1] = b_[5];
     py[2] = b_[6];
     py[3] = b_[7];
     
     byte[] vx = new byte[4];
     vx[0] = b_[8];
     vx[1] = b_[9];
     vx[2] = b_[10];
     vx[3] = b_[11];
     
     byte[] vy = new byte[4];
     vy[0] = b_[12];
     vy[1] = b_[13];
     vy[2] = b_[14];
     vy[3] = b_[15];
     
     //println("PX");
     //println(px);
      float fpx = toFloat(px);
      float fpy = toFloat(py);
      float fvx = toFloat(vx);
      float fvy = toFloat(vy);
     
      if(alive) {
        if(!driving) {
          try {
            self.setPosition(fpx, fpy);
            self.setVelocity(fvx, fvy);
          } catch(AssertionError e_) {
            //e_.printStackTrace();
            System.err.println("Soldier Pos/Velo Error");
          }
        }
      }
    }
  }
  */
}
