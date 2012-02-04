class Scenery {
  boolean shouldDraw;
  PImage p;
  String src;
  int pId;
  float x;
  float y;
  float z;
  float w;
  float h;
  float rotation;

  int r;
  int g;
  int b;
  int a;

  int[] vR;
  int[] vG;
  int[] vB;
  int[] vA;
  float[] vZ;

  float rX = 0.0;
  float rY = 0.0;
  float rZ = 0.0;

  Scenery() {
  }

  Scenery(String src_, float x_, float y_, float z_, float w_, float h_, float r_) {
    src = src_;

    x = x_;
    y = y_;
    z = z_;
    w = w_;
    h = h_;
    rotation = r_;
    r = 255;
    g = 255;
    b = 255;
    a = 255;

    vR = new int[4];
    vG = new int[4];
    vB = new int[4];
    vA = new int[4];
    vZ = new float[4];

    setColours(r, g, b, a);

    if (settings.drawScenery) {
      for (int i=0; i<4; i++) setVColours(i, r, g, b, a);

      boolean foundInstance = false;
      for (int i=0; i<game.sceneryTextureGLNameList.length; i++) {
        if (src.equals(game.sceneryTextureGLNameList[i])) {
          pId = i;
          foundInstance = true;
          break;
        }
      }

      if (!foundInstance) {
        game.sceneryTextureGLNameList = append(game.sceneryTextureGLNameList, src);
        game.sceneryTextureGL = append(game.sceneryTextureGL, loadSceneryTexture(src));
        pId = game.sceneryTextureGL.length-1;
      }
    }
  }

  void update(GL gl) {
    if (settings.drawTrippyScenery && game.meCast.health < settings.trippySceneryMaxHealth) {
      int v = int(random(0, 4));
      float hmap = map(game.meCast.health, 0, settings.trippySceneryMaxHealth, settings.trippySceneryMaxDistortion, 0);
      setVColours(v, vR[v]+=int(random(-hmap, hmap)), vG[v]+=int(random(-hmap, hmap)), vB[v]+=int(random(-hmap, hmap)), vA[v]+=int(random(-hmap, hmap)));
    }
    if (w < width && h < height) {
      if (game.checkRender(x, y, z) || game.checkRender(x+w, y, z)|| game.checkRender(x+w, y+h, z) || game.checkRender(x, y+h, z)) render(gl);
    } 
    else {
      render(gl);
    }
  }

  void setColours(int r_, int g_, int b_, int a_) {
    r = r_;
    g = g_;
    b = b_;
    a = a_;

    for (int i=0; i<4; i++) {
      vR[i] = r;
      vG[i] = g;
      vB[i] = b;
      vA[i] = a;
      vZ[i] = 0;
    }
  }

  void setVColours(int v_, int r_, int g_, int b_, int a_) {
    vR[v_] = r_;
    vG[v_] = g_;
    vB[v_] = b_;
    vA[v_] = a_;
  }

  void setZ(float z_) { 
    z = z_;
  }

  void setDepth(int n_, float z_) { 
    vZ[n_] = z_;
  }

  void render(GL gl) {
    gl.glPushMatrix();
    gl.glTranslatef(x, y+h, z);
    gl.glRotatef(rotation, 0.0, 0.0, 1.0);
    gl.glScalef(w, h, 0.0);
    gl.glBindTexture(GL.GL_TEXTURE_2D, game.sceneryTextureGL[pId]);

    gl.glBegin(GL.GL_QUADS);

    gl.glColor4f(vR[0]/255.0, vG[0]/255.0, vB[0]/255.0, vA[0]/255.0);
    gl.glTexCoord3f(0.0, 1.0, 0.0);
    gl.glVertex3f(0.0, 0.0, 0.0);

    gl.glColor4f(vR[1]/255.0, vG[1]/255.0, vB[1]/255.0, vA[1]/255.0);
    gl.glTexCoord3f(1.0, 1.0, 0.0);
    gl.glVertex3f(1.0, 0.0, 0.0);

    gl.glColor4f(vR[2]/255.0, vG[2]/255.0, vB[2]/255.0, vA[2]/255.0);
    gl.glTexCoord3f(1.0, 0.0, 0.0);
    gl.glVertex3f(1.0, -1.0, 0.0);

    gl.glColor4f(vR[3]/255.0, vG[3]/255.0, vB[3]/255.0, vA[3]/255.0);
    gl.glTexCoord3f(0.0, 0.0, 0.0);
    gl.glVertex3f(0.0, -1.0, 0.0);

    gl.glEnd();

    gl.glPopMatrix();
  }
}

