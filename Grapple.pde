class Grapple {
  boolean alive;
  boolean attached;
  FBody body1;  //ORIGIN BODY THAT SHOT GRAPPLE
  FBody body2;  //BODY THAT GRAPPLE CONNECTS TO
  FDistanceJoint mainJoint;
  FDistanceJoint attachJoint;
  FCircle body;  //GRAPPLE BODY
  int id;
  int health;
  
  Grapple(FBody body1_, PVector pos_, PVector force_) {
    alive = true;
    health = 30;
    body1 = (FBody) body1_;
    body = new FCircle(10);
    body.setPosition(pos_.x, pos_.y);
    body.setDensity(1);
    body.setRestitution(0.01);
    body.setBullet(true);
    body.setStatic(false);
    body.setDrawable(false);
    world.add(body);
    body.addForce(force_.x, force_.y);
    println("p:"+pos_.x+"x"+pos_.y);
  }
  
  void setId(int id_) { id = id_; }
  
  void update() {
    if(health < 0) {
      alive = false;
      game.explosionData.add(new Explosion(body.getX(), body.getY(), body.getSize()*3.5, int(random(30, 60))));
    }
    
    if(alive && !playingOnline && !attached && !isVisible(body1.getX(), body1.getY(), body.getX(), body.getY()) && dist(body1.getX(), body1.getY(), body.getX(), body.getY()) > 800) alive = false;
    if(!alive) kill();
    render();
  }
  
  void setPV(float x_, float y_, float xf_, float yf_) {
    if(alive) {
      try {
        body.setPosition(x_, y_);
        body.setVelocity(xf_, yf_);
      } catch(NullPointerException e) {
        System.err.println("Grapple Set P/V NullPointerException");
      } catch(AssertionError e) {
        System.err.println("Pickups Set P/V AssertionError");
      }
    }
  }
  
  void foundConnect(FBody body2_, float x_, float y_) {
    attached = true;
    body2 = body2_;
    
   // if(settings.debugMode) {
      println("spot to place:"+int(x_)+"-"+int(y_));
      println("body 2:"+int(body2_.getX())+"-"+int(body2_.getY()));
      println("grapple:"+int(body.getX())+"-"+int(body.getY()));
   // }
    
    attachJoint = new FDistanceJoint(body, body2);
    attachJoint.setAnchor2(x_, y_);
    attachJoint.calculateLength();
    attachJoint.setFrequency(20.0);
    world.add(attachJoint);
    
    mainJoint = new FDistanceJoint(body, body1);
    mainJoint.setFrequency(1.0);
    mainJoint.setLength(10.0);
    world.add(mainJoint);
  }
  
  void switchBody(FBody body1_) {
    world.remove(mainJoint);
    mainJoint = new FDistanceJoint(body, body1_);
    mainJoint.setLength(10);
    mainJoint.setFrequency(1.0);
    world.add(mainJoint);
  }
  
  void kill() {
    if(attached) {
      world.remove(attachJoint);
      world.remove(mainJoint);
    }
    world.remove(body);
    alive = false;
    attached = false;
  }
  
  void render() {
    pushMatrix();
      translate(body.getX(), body.getY());
      fill(255-map(health, 30, 0, 0, 255), 255);
      ellipse(0, 0, body.getSize(), body.getSize());
    popMatrix();
    
    if(dist(body1.getX(), body1.getY(), body.getX(), body.getY()) < 800 && !attached) {
      stroke(0, 100);
    } else if(!attached) {
      stroke(100, 100);
    }  else {
      stroke(255, 100);
    }
    
    strokeWeight(constrain(5-(dist(body1.getX(), body1.getY(), body.getX(), body.getY())/300), 1, 5));
    line(body1.getX(), body1.getY(), body.getX(), body.getY());
    noStroke();
  }
}
