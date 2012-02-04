class Cat {
  FCircle self;
  Animation animCast;
  int animType;  //tracker of type(0-running, 1-stand etc)
  int animCount;  //tracker of frame(0, 1, 2, 3 etc)
  int animTimeCount;  //trancker of time added 1 to each iteration
  float targetX;
  int direction = 1;
  int lifeCount = 0;
  
  Cat(float x_, float y_) {
    self = new FCircle(15);
    self.setGroupIndex(-1);
    self.setDensity(0.01);
    self.setFriction(1);
    self.setRestitution(0.5);
    self.setFill(255, 0, 0);
    self.setStatic(false);
    self.setBullet(true);
    self.setRotatable(true);
    self.setDrawable(false);
    self.setPosition(x_, y_);
    world.add(self);
    self.addForce(0, -50);
    animType = -1;
  }
  
  void update() {
    lifeCount++;
    if(animType == -1) {
      animCast = (Animation) game.animData.get(game.getAnimIdByName("Cat"));  //cast to your type of animation(Pikachu)
      animType = 0;  //tracker of type(0-running, 1-stand etc)
      animCount = 0;  //tracker of frame(0, 1, 2, 3 etc)
      animTimeCount = 0;  //trancker of time added 1 to each iteration
    }
    
   /* int tempSelfContacts = 0;
    try {
      tempSelfContacts = self.getContacts().size();
    } catch(NullPointerException n_) {
      n_.printStackTrace();
      println("catjumperror");
      tempSelfContacts = 0;
    }
    
    if(random(1) < 0.01 && tempSelfContacts > 0) {
      self.addForce(0, random(-50, -100));
    }

    self.addForce(direction*3.2, 0);
    if(lifeCount % int(random(10, 20)) == 0) direction = int(random(-1, 1)); */
    render();
  }
  
  void render() {
    animTimeCount++;
    if(animCount != animCast.getId(animType, animCount, animTimeCount)) {
      animCount = animCast.getId(animType, animCount, animTimeCount);
      animTimeCount = 0;
    }
    pushMatrix();
      translate(self.getX(), self.getY());
      tint(255, 255);
      if(self.getVelocityX() > 0) { scale(-1, 1); }
      if(animType == 0) {
        image(animCast.running[animCount], -animCast.running[animCount].width/2, -animCast.running[animCount].height/2, animCast.running[animCount].width, animCast.running[animCount].height);
      }
    popMatrix();
  }
  
  float findTargetXBySoldier() {
    if(game.soldierData.size() > 0) {
      Soldier sh = (Soldier) game.soldierData.get(int(random(0, game.soldierData.size())));
      return sh.self.getX();
    } else if(game.spawnData.size() > 0) {
      Spawn sh = (Spawn) game.spawnData.get(int(random(0, game.spawnData.size())));
      return sh.x;
    }
    return 0.0;
  }
}
