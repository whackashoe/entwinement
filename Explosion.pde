class Explosion {
  boolean alive;
  boolean physAlive;
  float x;
  float y;
  float radius;
  int timer;
  int damage;
  int physTimer;  //HOW LONG TO KEEP "REAL" EXPLOSION "LIT"
  FCircle c;
  
  Explosion(float x, float y, float radius, int timer) {
    alive = true;
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.timer = timer;
    damage = int(radius)*4;
    physTimer = 2;
    physAlive = true;
    c = new FCircle(radius*2);
    c.setPosition(x, y);
    c.setSensor(true);
    c.setStatic(false);
    world.add(c);
    game.particleData.add(new Particle(2, x, y, radius));
  }
  
  void update() {
    physTimer--; 
    timer--;
    if(physTimer < 1) physAlive = false;
    if(timer < 1) alive = false;
  }
}
