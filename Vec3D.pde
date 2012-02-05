class Vec3D {
  float x;
  float y;
  float z;
  
  Vec3D(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  void add(Vec3D a) {
    this.x += a.x;
    this.y += a.y;
    this.z += a.z;
  }
  
  void set(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  void set(Vec3D a) {
    this.x = a.x;
    this.y = a.y;
    this.z = a.z;
  }
}
