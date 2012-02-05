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
  }
  
  void set(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void set(Vec2D a) {
    this.x = a.x;
    this.y = a.y;
  }
}
