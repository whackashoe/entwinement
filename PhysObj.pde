class PhysObj {
  int id;
  FBody p;
  
  //FBOX
  PhysObj(float x, float y, float w, float h, int id) {
    this.id = id;
    p = new FBox(w, h);
    p.setPosition(x, y);
    world.add(p);
  }
  
  //FCIRCLE
  PhysObj(float x, float y, float r, int id) {
    this.id = id;
    p = new FCircle(r);
    p.setPosition(x, y);
    world.add(p);
  }
  
  //FPOLY
  PhysObj(float x1, float y1, float x2, float y2, float x3, float y3, float r, int id) {
    this.id = id;
    p = new FPoly();
   // p.vertex(x1, y1);
  //  p.vertex(x2, y2);
   // p.vertex(x3, y3);
    world.add(p);
  }
}
