class Gravitron {
  float x;
  float y;
  float gravity;
  float distance;
  
  Gravitron(float x_, float y_, float gravity_, float distance_) {
    x = x_;
    y = y_;
    gravity = gravity_;
    distance = distance_;
  }
  
  Vec2D calcPull(FBody b, float distanceHome) {
    float angleToHome = atan2(y - b.getY(), x - b.getX());
    float mappedDistance = map(distanceHome, 0, distance, gravity, 0);
    
    return new Vec2D(cos(angleToHome)*mappedDistance*(b.getMass()), sin(angleToHome)*mappedDistance*(b.getMass()));
  }
}
