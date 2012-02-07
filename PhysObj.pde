class PhysObj {
  int id;
  FBody p;
  
  //FBOX
  PhysObj(int id, float x, float y, float w, float h, float d, float r, float f) {
    this.id = id;
    p = new FBox(w, h);
    p.setPosition(x, y);
    p.setDensity(d);
    p.setRestitution(r);
    p.setFriction(f);
    world.add(p);
  }
  
  //FCIRCLE
  PhysObj(int id, float x, float y, float radius, float d, float r, float f) {
    this.id = id;
    p = new FCircle(radius);
    p.setPosition(x, y);
    p.setDensity(d);
    p.setRestitution(r);
    p.setFriction(f);
    world.add(p);
  }
  
  //FPOLY
  PhysObj(int id, float x1, float y1, float x2, float y2, float x3, float y3, float d, float r, float f) {
    this.id = id;
    FPoly t = new FPoly();
    p = (FPoly) new FPoly();
    t.vertex(x1, y1);
    t.vertex(x2, y2);
    t.vertex(x3, y3);
    t.setDensity(d);
    t.setRestitution(r);
    t.setFriction(f);
    p = t;
    world.add(p);
  }
  
  void update() {
    if(game.checkRender(p.getX(), p.getY(), 0)) render();
  }
  
  void render() {
    pushMatrix();
      translate(p.getX(), p.getY());
      fill(0);
      ellipse(0, 0, 100, 100);
    popMatrix();
    
  }
}
