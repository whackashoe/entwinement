class Pickups {
  int[] type;
  FBox p;
  FCircle collide;
  boolean alive;
  int lifeSpan = 900;  //FOR IF THEY SPAWN IN UNREACHABLE SPOT
  int id = 0;

  //FOR WEAPON PICKUP
  Pickups(float x_, float y_, HoldGun gun) {
    type = new int[5];
    type[0] = 0;  //0 FOR GUN
    type[1] = gun.gun;  //0 FOR GUNTYPE
    type[2] = gun.ammo;  //0 FOR CURAMMO
    type[3] = gun.delayCount;  //0 FOR RELOADTIMEREMAINING
    type[4] = gun.reloadCount;  //0 FOR RELOADTIMEREMAINING

    p = new FBox(10.0, 10.0);
    p.setDensity(0.5);
    p.setRestitution(0.15);
    p.setFill(220, 200, 180);
    p.setBullet(false);
    p.setDrawable(false);
    p.setStatic(false);
    p.setPosition(x_, y_);
    p.addForce((random(1)-0.5)*200, -1000);
    world.add(p);
    addCollide(25);

    alive=true;
  }

  //FOR HEALTH PICKUP
  Pickups(float x, float y, int healthAmount) {
    type = new int[2];
    type[0] = 1;  //0 FOR HEALTH
    type[1] = healthAmount;  //usually 50-100?

    p = new FBox(10.0, 10.0);
    p.setDensity(0.05);
    p.setRestitution(0.3);
    p.setFill(220, 100, 100);
    p.setBullet(false);
    p.setStatic(false);
    p.setDrawable(false);
    p.setPosition(x, y);
    world.add(p);
    addCollide(25);

    alive = true;
  }

  Pickups(float x, float y, int attachmentType, int amount) {
    if (attachmentType == 0) {
      type = new int[4];
      type[0] = 2;  //FOR ATTACHMENT
      type[1] = attachmentType;  //FOR SUBTYPE-JETPACK
      type[2] = amount;
      type[3] = -70;
    } 
    else if (attachmentType == 1) {
      type = new int[3];
      type[0] = 2;  //FOR ATTACHMENT
      type[1] = attachmentType;  //FOR SUBTYPE-GRAPPLE
      type[2] = amount;
    } 
    else if (attachmentType == 2) {
      type = new int[5];
      type[0] = 2;  //FOR ATTACHMENT
      type[1] = attachmentType;  //FOR SUBTYPE-GRAVITY DISPLACER
      type[2] = amount;
      type[3] = amount;  //STRENGTH
      type[4] = 1000;  //TIME ALIVE
    }

    p = new FBox(10.0, 10.0);
    p.setDensity(0.7);
    p.setRestitution(0.6);
    p.setFill(100, 100, 120);
    p.setBullet(false);
    p.setStatic(false);
    p.setDrawable(false);
    p.setPosition(x, y);
    world.add(p);
    addCollide(25);
    alive = true;
  }

  void update(GL gl) {
    lifeSpan--;
    if (game.checkInsidePoly(p)) {
      if (settings.debugMode) println("pickup inside:"+int(p.getX())+"/"+int(p.getY()));
      lifeSpan -= 20;
    }
    if (lifeSpan < 1) alive = false;


    try {
      collide.setPosition(p.getX(), p.getY());
    } 
    catch(Exception e) {
      e.printStackTrace();
    } 
    catch(Error  e) {
      e.printStackTrace();
    }

    if (!game.checkInsidePoly(p) && game.checkRender(p.getX(), p.getY(), 1.0) && type != null && alive) render(gl);
  }

  void kill() {
    world.remove(p);
    world.remove(collide);
  }

  void setId(int id) { 
    this.id = id;
  }

  void render(GL gl) {
    gl.glPushMatrix();
    gl.glTranslatef(p.getX(), p.getY(), 3);
    gl.glRotatef(p.getRotation(), 0.0, 0.0, 1.0);
    gl.glScalef(p.getWidth(), p.getHeight(), 0.0);

    gl.glBegin(GL.GL_QUADS);

    addGLColor(gl, 0);
    gl.glTexCoord3f(0.0, 1.0, 0.0);
    gl.glVertex3f(-0.5, -0.5, 0.0);

    addGLColor(gl, 1);
    gl.glTexCoord3f(1.0, 1.0, 0.0);
    gl.glVertex3f(0.5, -0.5, 0.0);

    addGLColor(gl, 2);
    gl.glTexCoord3f(1.0, 0.0, 0.0);
    gl.glVertex3f(0.5, 0.5, 0.0);

    addGLColor(gl, 3);
    gl.glTexCoord3f(0.0, 0.0, 0.0);
    gl.glVertex3f(-0.5, 0.5, 0.0);

    gl.glEnd();

    gl.glPopMatrix();
  }

  void addGLColor(GL gl, int corner) {
    switch(type[0]) {
    case 0: 
      gl.glColor4f(0, 0, 0, 1.0); 
      break;
    case 1: 
      gl.glColor4f(1.0, 0, 0, 1.0); 
      break;
    case 2: 
      gl.glColor4f(0, 1.0, 0, 1.0); 
      break;
    }
  }

  void addCollide(int radius_) {
    collide = new FCircle(radius_);
    collide.setPosition(p.getX(), p.getY());
    collide.setSensor(true);
    collide.setStatic(true);
    collide.setFill(255, 255, 255, 100);
    collide.setDrawable(false);
    world.add(collide);
  }
}

