class Vec2D {
  float x;
  float y;
  
  Vec2D(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void add(Vec2D a) {
    this.x += a.x;
    this.y += a.y;
    //return new Vec2D(this.x += a.x, this.y += a.y);
  }
}
