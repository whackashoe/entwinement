class Gun {
  String name;
  int ammo;
  int speed;
  float radius;  //SIZE OF BULLET
  float density;
  float restitution;
  float friction;
  int reloadTime;  //TIME IN TICS
  int delayTime;  //TIME IN TICS
  int damage;
  int lifeSpan;
  boolean choice;  //DOES IT SHOW UP IN MENU?
  
  int explosionRadius;
  int explosionTime;
  int shotgunShots;
  
  boolean boom;
  boolean sniper;
  float sightMult;
  boolean sniperLine;
  boolean automatic;
  boolean shotgun;
  boolean flame;
  boolean moveAcc;
  boolean delayExplode;
  int delayExplodeTimer;
  boolean explodeOnSoldierImpact;
  boolean controllable;
  float controlStrength;
  boolean follow;
  
  boolean speedMultBasedOnMouse;
  float speedMultX;
  float speedMultY;
  
  float returnRadius;
  float zDepthMinus;
  float zDepth;
  
  float recoil = 0.0;
  float bink = 0.0;
  float accuracy = 0.0;
 
  boolean bulletImg;
  boolean weaponImg;
  boolean sound;
  float soundDistance;
  boolean particle;
  int particleType;
  float particleRadius_Min;
  float particleRadius_Max;
  
  PImage bullet;
  PImage weapon;
  AudioSample asShoot;
  
  //FOR LOADING GUNS
  Gun(String name_, int ammo_, int speed_, float radius_, float density_, float restitution_, float friction_, int reloadTime_, int delayTime_, int damage_, boolean choice_) {
    name = name_;
    ammo = ammo_;
    speed = speed_;
    radius = radius_;
    density = density_;
    restitution = restitution_;
    friction = friction_;
    speed = speed_;
    reloadTime = reloadTime_;
    delayTime = delayTime_;
    damage = damage_;
    choice = choice_;
    lifeSpan = 180;
    moveAcc = true;
  }
  
  void setSniper(boolean set_, float mult_) {
    sniper = set_;
    sightMult = (mult_ == 0) ? 1.5 : mult_;
  }
  
  void setSniperLine(boolean set_) { sniperLine = set_; }
  
  void setAutomatic(boolean set_) { automatic = set_; }
  
  void setShotgun(boolean set_, int shotgunShots_) {
    shotgun = set_;
    shotgunShots = shotgunShots_;
  }
  
  void setFlame(boolean set_) { flame = set_; }
  
  void setBoom(boolean set_, int radius_, int time_) {
    boom = set_;
    explosionRadius = radius_;
    explosionTime = time_;
  }
  
  void setDelayExplode(boolean set_, int delay_, int radius_, int time_, boolean explodeOnSoldierImpact_) {
    delayExplode = set_;
    delayExplodeTimer = delay_;
    explosionRadius = radius_;
    explosionTime = time_;
    explodeOnSoldierImpact = explodeOnSoldierImpact_;
  }
  
  void setSpeedMultBasedOnMouse(boolean set_, float xMult, float yMult) {
    speedMultBasedOnMouse = set_;
    speedMultX = xMult;
    speedMultY = yMult;
  }

  
  void setNoMoveAcc(boolean set_) { moveAcc = false; }
  
  void setLifeSpan(int lifeSpan) { this.lifeSpan = lifeSpan; }
  
  void setControllable(boolean set_, float strength_) {
    controllable = set_;
    controlStrength = strength_;
  }
  
  void setFollow(boolean set_, float returnRadius, float zDepth, float zDepthMinus) {
    follow = set_;
    this.returnRadius = returnRadius;
    this.zDepth = zDepth;
    this.zDepthMinus = zDepthMinus;
  }
  
  void setRecoil(float recoil) { this.recoil = (delayTime*game.BINK_MINUS)+recoil; }
  
  void setBink(float bink) { this.bink = bink; }
  
  void setAccuracy(float accuracy) { this.accuracy = accuracy; }
  
  void setParticle(boolean set_, int particleType, float particleRadius_Min, float particleRadius_Max) {
    this.particle = set_;
    this.particleType = particleType;
    this.particleRadius_Min = particleRadius_Min;
    this.particleRadius_Max = particleRadius_Max;
  }
  
  void setSound(String soundSrc_, float soundDistance) {
    println(soundSrc_);
    sound = true;
    try {
      asShoot = minim.loadSample("mods/"+settings.mod+"/sfx/guns/"+soundSrc_);
    } catch(NullPointerException e_) {
      System.err.println("Sound: "+"mods/"+settings.mod+"/sfx/guns/"+soundSrc_+" not found!");
    }
    if(asShoot == null) {
      try {
        asShoot = minim.loadSample("mods/default/sfx/guns/"+soundSrc_);
      } catch(NullPointerException e_) {
        System.err.println("Sound: "+"mods/default/sfx/guns/"+soundSrc_+" not found!");
      }
    }
    if(asShoot == null) sound = false;
    
    if(sound) {
      this.soundDistance = soundDistance;
    }
  }
  
  void setGun(String weaponSrc_) {
    weaponImg = true;
    weapon = loadImage(sketchPath+"/mods/"+settings.mod+"/gfx/guns/weapons/"+weaponSrc_);
    
    if(weapon == null) {
      weapon = loadImage(sketchPath+"/mods/default/gfx/guns/weapons/"+weaponSrc_);
      if(weapon == null) {
        weaponImg = false;
        return;
      }
    }
    
    String[] p = splitTokens(weaponSrc_, ".");
    if(p[1].equals("bmp") || p[1].equals("BMP")) {
      weapon.loadPixels();
      weapon = maskGreen(weapon);
      weapon.updatePixels();
    }
  }
  
  void setBullet(String bulletSrc_) {
    bulletImg = true;
    bullet = loadImage(sketchPath+"/mods/"+settings.mod+"/gfx/guns/bullets/"+bulletSrc_);
    
    if(bullet == null) {
      bullet = loadImage(sketchPath+"/mods/default/gfx/guns/bullets/"+bulletSrc_);
      if(weapon == null) {
        bulletImg = false;
        return;
      }
    }
    
    String[] p = splitTokens(bulletSrc_, ".");
    if(p[1].equals("bmp") || p[1].equals("BMP")) {
      bullet.loadPixels();
      bullet = maskGreen(bullet);
      bullet.updatePixels();
    }
  }
  
  float getParticleRadius() { return random(particleRadius_Min, particleRadius_Max); }

}
