class Bullet {
  FCircle b;
  boolean alive;
  int type;
  float radius;  //MULTIPLIER OF REAL BULLET RADIUS(SCALED)
  int id;  //who shot it
  int lifeSpan;
  int curExplode = 0;
  int explodeAmount = 3;
  char letter;
  boolean airStrike = false;
  
  int delayExplodeCount;
  
  float px;
  float py;
  float x;
  float y;
  float trailAngle;
  
  Particle particleCast;
  AudioSample aSamp;
  
  
  

  Bullet(float x_, float y_, float xf_, float yf_, int type_, int id_) {
    alive = true;
    type = type_;
    id = id_;
    
    if(game.gunData[type_].delayExplode) delayExplodeCount = game.gunData[type_].delayExplodeTimer;
    
    b = new FCircle(game.gunData[type_].radius);
    b.setDensity(game.gunData[type_].density);
    b.setRestitution(game.gunData[type_].restitution);
    b.setFriction(game.gunData[type_].friction);
    b.setFill(200);
    b.setBullet(true);
    b.setStatic(false);
    b.setDrawable(false);
    b.setPosition(x_, y_);
    b.setGroupIndex(-2);
    world.add(b);
    b.addForce(xf_, yf_);

    lifeSpan = game.gunData[type].lifeSpan;
    
    trailAngle = game.getSoldierById(id).gunAngle;
    
    if(game.gunData[type].particle) {
      game.particleData.add(new Particle(game.gunData[type].particleType, x_, y_, game.gunData[type].getParticleRadius()));
      particleCast = (Particle) game.particleData.get(game.particleData.size()-1);
      particleCast.setDirection(trailAngle);
    }
    
    if( game.gunData[type].sound) {
      float v = game.checkSoundRender(b.getX(), b.getY(), game.gunData[type].soundDistance);
      if(v < 0) return;
      
      aSamp = game.gunData[type].asShoot;
      
      if(settings.useVolume) aSamp.setVolume(v*map(constrain(settings.soundVolume, 0, 100), 0, 100, 0, 1.0));
      else if(settings.useGain) aSamp.setGain(-80+(v*map(constrain(settings.soundVolume, 0, 100), 0, 100, 0, 86)));
      
      if(settings.useBalance) aSamp.setBalance(game.checkSoundBalance(b.getX(), width));
      
      aSamp.trigger();
    }
  }
  
  //FOR AIRSTRIKES AND OTHER CUSTOM SHIT
  Bullet(float x_, float y_, float xf_, float yf_, int id_, Gun gun_) {
    alive = true;
    type = 0;
    id = id_;
    airStrike = true;

    if(gun_.delayExplode) delayExplodeCount = gun_.delayExplodeTimer;
    
    b = new FCircle(gun_.radius);
    b.setDensity(gun_.density);
    b.setBullet(true);
    b.setStatic(false);
    b.setDrawable(false);
    b.setPosition(x_, y_);
    b.setGroupIndex(-2);
    world.add(b);
    b.addForce(xf_, yf_);
    
    if(gun_.sound) {
      aSamp = gun_.asShoot;
      aSamp.trigger();
    }
    radius = gun_.radius;
    lifeSpan = gun_.lifeSpan;
  }
  
  void setRadius(int radius_) { radius = radius_; }
  
  void setLetter(char letter_) { letter = letter_; }
  
  void blowUp() {
    if(curExplode < explodeAmount) {
      game.explosionData.add(new Explosion(b.getX(), b.getY(), game.gunData[type].explosionRadius, game.gunData[type].explosionTime));  //MAKE EXPLOSION IF ITS EXPLODABLE
      curExplode++;
    }
  }
  
  void addMoveAcc(float x, float y) { b.adjustVelocity(x, y); }
    
  
  void update() {
    px = x;
    py = y;
    x = b.getX();
    y = b.getY();
    
    lifeSpan--;
    if(lifeSpan < 1) alive = false;
    
    trailAngle = atan2(py-y, px-x);
    
    if(game.gunData[type].delayExplode) {
      delayExplodeCount--;
      if(delayExplodeCount < 1) {
        blowUp();
        alive = false;
      }
    }
    if(game.checkRender(x, y, 1.0)) render();
  }
  
  
  
  void applyForce(int amount) {
    b.addForce(sin(trailAngle)*amount*game.gunData[type].controlStrength, -cos(trailAngle)*amount*game.gunData[type].controlStrength);
  }
  
  void render() {
    pushMatrix();
      translate(b.getX(), b.getY(), 1);
      scale(game.gunData[type].radius);
      
      if(!settings.drawBullets || settings.debugMode) {
        fill(0, 255, 0);
        stroke(0);
        strokeWeight(1);
        ellipse(0, 0, 1, 1);
        popMatrix();
        noStroke();
        return;
      }
      
      rotate(trailAngle);
      if((game.gunData[type].bulletImg) && (px != x || py != y)) {
        noStroke();
        tint(255, 255);
        image(game.gunData[type].bullet, 0, 0);
      } else if(!game.gunData[type].bulletImg) {
        fill(0, 255, 0);
        stroke(0);
        strokeWeight(1);
        ellipse(0, 0, 1, 1);
        noStroke();
      }
    popMatrix();
  }
}
