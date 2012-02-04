class Polygon {
  FPoly p;
  int type;

  float x[];
  float y[];
  float z[];
  float tz[];
  
  int textureId;
  float[] u;
  float[] v;
  float[] rhw;
  
  int[] vR;
  int[] vG;
  int[] vB;
  int[] vA;
  
  int[] tvR;
  int[] tvG;
  int[] tvB;
  int[] tvA;
  
  private boolean vehicle;
  
  Polygon(int type_, float x1_, float y1_, float x2_, float y2_, float x3_, float y3_, float de_, float re_, float fr_, int r_, int g_, int b_, int a_) {
    p = new FPoly();
    p.vertex(x1_, y1_);
    p.vertex(x2_, y2_);
    p.vertex(x3_, y3_);
    p.setStatic(true);
    p.setRestitution(re_);
    p.setFriction(fr_);
    if(type_ == 1) p.setGroupIndex(-1);  //bullet collide
    else if(type_ == 2) p.setGroupIndex(-2);  //player collide
    else if(type_ == 3) p.setSensor(true);  //graphical only
    world.add(p);
    
    type = type_;

    x = new float[3];
    x[0] = x1_;
    x[1] = x2_;
    x[2] = x3_;
    
    y = new float[3];
    y[0] = y1_;
    y[1] = y2_;
    y[2] = y3_;
    
    setZAxis(1, 1, 1);
    
    vR = new int[3];
    vG = new int[3];
    vB = new int[3];
    vA = new int[3];
    
    tvR = new int[3];
    tvG = new int[3];
    tvB = new int[3];
    tvA = new int[3];
    for(int i=0; i<3; i++) setVColours(i, r_, g_, b_, a_);
    
    tvR = vR;
    tvG = vG;
    tvB = vB;
    tvA = vA;
    
    float test = getClockularArea(x[0], y[0], x[1], y[1], x[2], y[2]);
    if(test == 0.0) println("STRAIGHT LINE");
    if(test < 0) println("anticlockwise");
  }

  
  Polygon(float x1_, float y1_, float z1_, float x2_, float y2_, float z2_, float x3_, float y3_, float z3_, int r_, int g_, int b_, int a_) {
    type = 0;

    x = new float[3];
    x[0] = x1_;
    x[1] = x2_;
    x[2] = x3_;
    
    y = new float[3];
    y[0] = y1_;
    y[1] = y2_;
    y[2] = y3_;
    
    setZAxis(1, 1, 1);
    
    vR = new int[3];
    vG = new int[3];
    vB = new int[3];
    vA = new int[3];
    for(int i=0; i<3; i++) setVColours(i, r_, g_, b_, a_);
    
    vehicle = true;
  }
  
  void update(GL gl, int pos) {
    if(settings.debugMode) {
      fill(255);
      strokeWeight(1);
      stroke(0);
      beginShape();
        vertex(x[0], y[0], z[0]);
        vertex(x[1], y[1], z[1]);
        vertex(x[2], y[2], z[2]);
      endShape();
      noStroke();
      return;
    }

    if(gl != null) {
      
      if(game.checkRender(x, y, z)) {
        if(settings.drawBrokenPolygons && game.meCast.health < settings.brokenPolygonsMaxHealth) {
          float tempZDistortion = noise(pos)*map(constrain(game.meCast.health, -100, settings.brokenPolygonsMaxHealth), -100, settings.brokenPolygonsMaxHealth, settings.brokenPolygonsMaxDistortion, 0);
          setTempZAxis(tempZDistortion, tempZDistortion, tempZDistortion);
        }
        
        if(settings.drawTrippyPolygons && game.meCast.health < settings.trippyPolygonsMaxHealth) {
          int v = int(random(0, 3));
          float hmap = map(game.meCast.health, 0, settings.trippyPolygonsMaxHealth, settings.trippyPolygonsMaxDistortion, 0);
          setTempVColours(v, tvR[v]+=int(random(-hmap, hmap)), tvG[v]+=int(random(-hmap, hmap)), tvB[v]+=int(random(-hmap, hmap)), tvA[v]+=int(random(-hmap, hmap)));
        }
        
        render(gl, pos);
      } else {
        /*for(int i=0; i<3; i++) {
          float d = dist(screenX(x[i], y[i], z[i]), screenY(x[i], y[i], z[i]), width/2, height/2);
          if(d < width || d < height) {
            render(gl, pos);
            break;
          }
        }*/
      }
    }
  }
  
  void update(GL gl) {
    update(gl, 0);
  }
  
  void render(GL gl, int pos) {
    if (!settings.debugMode && settings.drawTextures && game.textureMap && game.mapTextureGL.length > 0) gl.glBindTexture(GL.GL_TEXTURE_2D, game.mapTextureGL[textureId]);
    gl.glBegin(gl.GL_TRIANGLES);
     if(settings.drawBrokenPolygons && game.meCast.health < settings.brokenPolygonsMaxHealth) {
         for(int m=0; m<3; m++) {
          gl.glColor4f(tvR[m]/255.0, tvG[m]/255.0, tvB[m]/255.0, tvA[m]/255.0);
          if(game != null && game.textureMap && !vehicle && settings.drawTextures && game.mapTextureGL.length > 0) {
            if(u != null && v != null && rhw != null) gl.glTexCoord3f(u[m], v[m], 1.0/rhw[m]);
          }
          gl.glVertex3f(x[m], y[m], tz[m]);
        }
      } else {
        for(int m=0; m<3; m++) {
          gl.glColor4f(vR[m]/255.0, vG[m]/255.0, vB[m]/255.0, vA[m]/255.0);
          if(game != null && game.textureMap && !vehicle && settings.drawTextures && game.mapTextureGL.length > 0) {
            if(u != null && v != null && rhw != null) gl.glTexCoord3f(u[m], v[m], 1.0/rhw[m]);
          }
          gl.glVertex3f(x[m], y[m], z[m]);
        }
      }
    gl.glEnd();
  }
  
  void setVColours(int v_, int r_, int g_, int b_, int a_) {
    vR[v_] = r_;
    vG[v_] = g_;
    vB[v_] = b_;
    vA[v_] = a_;
  }
  
  void setTempVColours(int v_, int r_, int g_, int b_, int a_) {
    tvR[v_] = r_;
    tvG[v_] = g_;
    tvB[v_] = b_;
    tvA[v_] = a_;
  }
  
  void setTextureId(int textureId) { this.textureId = textureId; }
  
  void setUV(float u1_, float v1_, float u2_, float v2_, float u3_, float v3_) {
    u = new float[3];
    v = new float[3];
    u[0] = u1_;
    v[0] = v1_;
    u[1] = u2_;
    v[1] = v2_;
    u[2] = u3_;
    v[2] = v3_;
  }
  
  void setRHW(float r1_, float r2_, float r3_) {
    rhw = new float[3];
    rhw[0] = r1_;
    rhw[1] = r2_;
    rhw[2] = r3_;
  }
  
  void setZAxis(float z1_, float z2_, float z3_) {
    z = new float[3];
    z[0] = z1_;
    z[1] = z2_;
    z[2] = z3_;
    
    setTempZAxis(z1_, z2_, z3_);
  }
  
  void setTempZAxis(float z1_, float z2_, float z3_) {
    tz = new float[3];
    tz[0] = z1_;
    tz[1] = z2_;
    tz[2] = z3_;
  }
  
  float getXPos() { return (x[0]+x[1]+x[2])/3; }
  float getYPos() { return (y[0]+y[1]+y[2])/3; }
  
  //use this for checking if pointinside
  float getAbsoluteTriangleArea(float x1_, float y1_, float x2_, float y2_, float x3_, float y3_) {
    return (0.5*abs(((x1_-x3_)*(y2_-y3_))-((y1_-y3_)*(x2_-x3_))));
  }
  
  //use this for finding if it is clockwise
  float getClockularArea(float x1, float y1, float x2, float y2, float x3, float y3) { 
    return ((x1 - x3) * (y2 - y3) - (y1 - y3) * (x2 - x3))/2;
  }
  
  boolean pointInside(float x_, float y_) {
    float total = getAbsoluteTriangleArea(x[0], y[0], x[1], y[1], x[2], y[2]);
    float t1 = getAbsoluteTriangleArea(x_, y_, x[1], y[1], x[2], y[2]);
    float t2 = getAbsoluteTriangleArea(x_, y_, x[0], y[0], x[1], y[1]);
    float t3 = getAbsoluteTriangleArea(x_, y_, x[0], y[0], x[2], y[2]);
    
    if((t1+t2+t3) == total) return true;
    return false;
  }
}
