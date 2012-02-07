class PhysObj {
  int id;
  FBody p;
  
  int renderType;
  boolean drawable = true;
  int[] colour = new int[4];
  float[][] vertices;
  
  //FCIRCLE
  PhysObj(int id, float x, float y, float radius, float d, float r, float f) {
    this.id = id;
    p = new FCircle(radius);
    p.setPosition(x, y);
    p.setDensity(d);
    p.setRestitution(r);
    p.setFriction(f);
    world.add(p);
    colour[3] = 255;
    renderType = 0;
  }
  
  //FBOX
  PhysObj(int id, float x, float y, float w, float h, float d, float r, float f) {
    this.id = id;
    p = new FBox(w, h);
    p.setPosition(x, y);
    p.setDensity(d);
    p.setRestitution(r);
    p.setFriction(f);
    world.add(p);
    
    renderType = 1;
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
    
    
    renderType = 2;
    vertices = new float[3][2];
    vertices[0][0] = x1;
    vertices[0][1] = y1;
    vertices[1][0] = x2;
    vertices[1][1] = y2;
    vertices[2][0] = x3;
    vertices[2][1] = y3;
  }
  
  void update() {
    if(drawable && game.checkRender(p.getX(), p.getY(), 0)) render();
  }
  
  void render() {
    pushMatrix();
      translate(p.getX(), p.getY());
      rotate(p.getRotation());
      Vec2D scaler = getScale();
      scale(scaler.x, scaler.y);
      fill(colour[0], colour[1], colour[2], colour[3]);
      if(renderType == 0) {
        ellipse(0, 0, 100, 100);
      } else if(renderType == 1) {
        beginShape();
          vertex(-0.5, -0.5);
          vertex(-0.5, 0.5);
          vertex(0.5, 0.5);
          vertex(0.5, -0.5);
        endShape();
      } else if(renderType == 2) {
        beginShape();
          vertex(vertices[0][0], vertices[0][1]);
          vertex(vertices[1][0], vertices[1][1]);
          vertex(vertices[2][0], vertices[2][1]);
        endShape();
      }
    popMatrix();
  }
  
  void setColor(int r, int g, int b, int a) {
    drawable = true;
    colour[0] = r;
    colour[1] = g;
    colour[2] = b;
    colour[3] = a;
  }
  
  Vec2D getScale() {
    switch(renderType) {
      case 0:
        FCircle tempc = (FCircle) p;
        return new Vec2D(tempc.getSize(), tempc.getSize());
      case 1:
        FBox tempr = (FBox) p;
        return new Vec2D(tempr.getWidth(), tempr.getHeight());
      case 2:
        return new Vec2D(1.0, 1.0);
    }
    
    return new Vec2D(1.0, 1.0);
  }
}
