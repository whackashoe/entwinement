class Engine { 
  boolean mapLoaded = false;

  boolean menuMode;
  int menuPolyFollow;
  PVector menuCurrentFollowPos;

  boolean paused;
  boolean pausePush;
  boolean textureMap;
  boolean showInputBox;
  boolean overrideCameraPos = false;
  float overrideCameraTime;
  float[] overrideCameraData;
  Menu.TextBox inputBox;
  String scriptDrawData;

  final float BINK_MINUS = 0.005;

  int[] mapTextureGL;
  int[] sceneryTextureGL;
  String[] sceneryTextureGLNameList;
  GLU glu;
  PImage mapTexture;
  int[] frameRateOverLastFew;
  String levelName;
  String levelSummary;
  boolean mapComplete;

  Gun[] gunData;
  Gun AirStrike;
  int jetpackMax;
  PImage[] attachmentImageList;
  PImage healthpackImage;
  ArrayList bulletData;
  ArrayList explosionData;
  ArrayList ragdollData;
  ArrayList grappleData;
  JyInt jython;

  Soldier meCast;
  Bullet curFollowBullet;
  ArrayList controlBullets;
  boolean watchingFollowBullet;
  float followBulletZDepth;

  ArrayList earthData;
  ArrayList gravitronData;
  ArrayList polyData;
  ArrayList spawnData;
  ArrayList pickupData;
  ArrayList vehicleData;
  ArrayList soldierData;
  ArrayList flagData;

  ArrayList sceneryData;
  String[] scenerySrc;
  //ArrayList spriteData;
  PImage[][] spriteData;

  ArrayList catData;
  ArrayList particleData;
  ArrayList animData;
  ArrayList worldJointData;
  KillConsole kConsole;
  HUD hud;
  
  float[][] mapBounds;

  //AI INFO
  Pathfinder pf;
  boolean pfEnabled = false;
  boolean drawPf = true;
  int pf_x;
  int pf_y;
  int pf_w;
  int pf_h;
  int pf_rows;
  int pf_cols;

  int[][] bgColor;

  int maxHealthPacks;
  int maxAttachments;
  int maxVehicles;
  int maxSoldiers;

  String nextMap;
  //boolean drawPickupInfo;
  //boolean drawSoldierNames = true;

  //CHARACTER STATS SECTION
  float timePlayedInMap;
  float timeAlive;
  int helisDowned;
  int vehiclesDowned;
  int enemySoldiersDowned;

  //MODES
  int gameType;
  boolean zombieMode;
  boolean bitchMode;
  boolean completionMode;
  boolean upsideDownMode;
  boolean force2d;
  boolean friendlyFire;

  //BUTTON PUSHERS
  boolean aPush = false;
  boolean dPush = false;
  boolean wPush = false;
  boolean sPush = false;
  boolean xPush = false;
  boolean fPush = false;
  boolean rPush = false;
  boolean rmbPush = false;
  boolean lmbPush = false;
  boolean cmbPush = false;
  boolean keyGunChange = false;

  Engine(String mapName_) {
    println(mapName_);
    levelName = mapName_;
    paused = false;
    pausePush = false;
    menuCurrentFollowPos = new PVector(0, 0);
    menuPolyFollow = 0;
    timePlayedInMap = 0.0;
    vehiclesDowned = 0;
    enemySoldiersDowned = 0;
    bgColor = new int[4][4];
    for(int i=0; i<bgColor.length; i++)
      for(int j=0; j<bgColor[i].length; j++)
        bgColor[i][j] = 155;
    mapTextureGL = new int[0];
    sceneryTextureGL = new int[0];
    sceneryTextureGLNameList = new String[0];

    kConsole = new KillConsole();
    hud = new HUD();
    frameRateOverLastFew = new int[4];
    frameRateOverLastFew[0] = 30;
    frameRateOverLastFew[1] = 30;
    frameRateOverLastFew[2] = 30;
    frameRateOverLastFew[3] = 30;

    //load modes
    //TODO: CLEAN THIS SHIT
    zombieMode = settings.defaultGameMode[0];
    bitchMode = settings.defaultGameMode[1];
    completionMode = settings.defaultGameMode[2];
    upsideDownMode = settings.defaultGameMode[3];
    friendlyFire = settings.defaultGameMode[4];



    gameType = 0;

    mapComplete = false;
    bulletData = new ArrayList();
    controlBullets = new ArrayList();
    explosionData = new ArrayList();
    force2d = false;
    textureMap = false;
    showInputBox = false;
    inputBox = null;
    scriptDrawData = "";

    earthData = new ArrayList();
    gravitronData = new ArrayList();
    polyData = new ArrayList();
    spawnData = new ArrayList();
    pickupData = new ArrayList();
    vehicleData = new ArrayList();
    baseVehicleData.clear();
    flagData = new ArrayList();
    soldierData = new ArrayList();
    polyData = new ArrayList();
    sceneryData = new ArrayList();
    scenerySrc = new String[0];

    particleData = new ArrayList();
    catData = new ArrayList();
    ragdollData = new ArrayList();
    worldJointData = new ArrayList();
    grappleData = new ArrayList();

    animData = new ArrayList();


    addAnims();    

    AirStrike = loadIndividualGun("airstrike.xml", false);

    //INIT ATTACHMENT SPRITES
    attachmentImageList = new PImage[3];
    attachmentImageList[0] = loadImage(sketchPath+"/data/mods/"+settings.mod+"/gfx/attachments/jetpack.png");
    attachmentImageList[1] = loadImage(sketchPath+"/data/mods/"+settings.mod+"/gfx/attachments/grappler.png");
    attachmentImageList[2] = loadImage(sketchPath+"/data/mods/"+settings.mod+"/gfx/attachments/airstrike.png");
    healthpackImage = loadImage(sketchPath+"/data/mods/"+settings.mod+"/gfx/attachments/healthpack.png");
  }
  
  String jyStringTest() {
    return "yay";
  }

  void setMenuMode(boolean set_) { 
    menuMode = set_;
  }

  void addMapData(String content_, int maxHealthPacks_, int maxAttachments_, int maxVehicles_, int jets_) {
    kConsole.addKillBoxText(content_);
    maxHealthPacks = maxHealthPacks_;
    maxAttachments = maxAttachments_;
    maxVehicles = maxVehicles_;
    jetpackMax = jets_;
    maxSoldiers = 10;  //SHIT LEGACY REASONING TO DO WITH PLAYER INITIAL SPAWNING
  }

  void addLevelData(String name_, String summary_) {
    /*
    if(!menuMode) {
     showLevelInfo = true;
     } else {
     showLevelInfo = false;
     }
     levelName = name_;
     levelSummary = summary_;
     */
    kConsole.addKillBoxText(levelName);
    kConsole.addKillBoxText(levelSummary);
  }

  void addPathfinder(int x_, int y_, int w_, int h_, int rows_, int cols_, String content_, boolean draw_) {
    pfEnabled = true;
    drawPf = draw_;
    pf_x = x_;
    pf_y = y_;
    pf_w = w_;
    pf_h = h_;
    pf_rows = rows_;
    pf_cols = cols_;

    //SEMIFIX FOR BAD DATA
    if (content_ == null) { 
      content_ = "0";
    }
    if (content_.length() != pf_rows*pf_cols) {
      if (pf_rows > 0 || pf_cols > 0) {  //IF ONE OF THEM IS JUST MISSING WE CAN DEDUCE...
        if (pf_rows == 0) { 
          pf_rows = content_.length()/pf_cols;
        }
        if (pf_cols == 0) { 
          pf_cols = content_.length()/pf_rows;
        }
      } 
      else {  //OTHERWISE JUST SAY FUCK IT
        pfEnabled = false;
        drawPf = false;
        return;  //FUCK IT
      }
    }

    pf = new Pathfinder();
    pf.setCuboidNodes(pf_rows, pf_cols, 1.0);

    //BREAK APART CONTENT AND POPULATE ZE NODES
    for (int i=0; i<content_.length(); i++) {
      if (str(content_.charAt(i)).equals("0")) {
        Node ph = (Node) pf.nodes.get(i);
        ph.walkable = false;
      }
    }
    pf.radialDisconnectUnwalkables();
  }

  void drawPathfinder() {
    pushMatrix();
    translate(pf_x, pf_y);
    for (int y=0; y<pf_rows; y++) {
      for (int x=0; x<pf_cols; x++) {
        pushMatrix();
        translate(pf_w*x, pf_h*y);
        Node ph = (Node) pf.nodes.get((pf_rows*y)+x);
        if (ph.walkable) {
          fill(200, 200, 200, 100);
        } 
        else {
          fill(0, 0, 0, 100);
        }
        ellipse(0, 0, pf_w, pf_h);
        popMatrix();
      }
    }
    popMatrix();
  }

  void setModes(boolean[] modes) {
    if (modes.length == 5) {
      zombieMode = modes[0];
      bitchMode = modes[1];
      completionMode = modes[2];
      upsideDownMode = modes[3];
      friendlyFire = modes[4];

      if (zombieMode) println("ZOMBIE MODE");
      if (bitchMode) println("BITCH MODE");
      if (friendlyFire) println("FRIENDLY FIRE MODE");
    } 
    else {
      System.err.println("SPECIFY THE RIGHT NUMBER OF FUCKING MODES");
    }
  }

  void setGuns(String src) {
    if (split(src, ".xml").length == 1) src+=".xml";
    gunData = loadGuns(src);
    if (gunData == null) {
      System.err.println("GUN LIST"+src+" LOADING FAILED, REVERTING TO KNOWN");
      gunData = loadGuns("list1.xml");
    }
  }

  void setGuns(Gun[] n) { 
    gunData = n;
  }

  void setBGColors(int br_, int bg_, int bb_, int b2r_, int b2g_, int b2b_) {
    bgColor[0] = new int[4];
    bgColor[0][0] = br_;
    bgColor[0][1] = bg_;
    bgColor[0][2] = bb_;
    bgColor[0][3] = 255;

    bgColor[1] = bgColor[0];

    bgColor[2] = new int[4];
    bgColor[2][0] = b2r_;
    bgColor[2][1] = b2g_;
    bgColor[2][2] = b2b_;
    bgColor[2][3] = 255;

    bgColor[3] = bgColor[2];
  }

  void setBGColor(int side, int r, int g, int b, int a) {
    //side is (top)left, right, (bottom) left, right
    bgColor[side][0] = r;
    bgColor[side][1] = g;
    bgColor[side][2] = b;
    bgColor[side][3] = a;
  }


  void addPoly(int type_, float x1_, float y1_, float x2_, float y2_, float x3_, float y3_, float de_, float re_, float fr_, int r_, int g_, int b_, int a_) {
    polyData.add(new Polygon(type_, x1_, y1_, x2_, y2_, x3_, y3_, de_, re_, fr_, r_, g_, b_, a_));
  }

  void addEarth(float x_, float y_, float radius_, float gravity_, float distance_, float size_, int detail_) {
    earthData.add(new Earth(x_, y_, radius_, size_, detail_));
    gravitronData.add(new Gravitron(x_, y_, gravity_, distance_));
  }

  void addAnims() {
    String[] animCastRunStr;
    Animation animCast;

    int[] marioDelay = new int[2];
    marioDelay[0] = 10;
    marioDelay[1] = 30;
    int[] pikaDelay = new int[2]; 
    pikaDelay[0] = 7;
    pikaDelay[1] = 30;
    int[] zombieDelay = new int[2];
    zombieDelay[0] = 5;
    zombieDelay[1] = 6;

    animData.add(new Animation("Self", marioDelay));
    animData.add(new Animation("Team1", marioDelay));
    animData.add(new Animation("Team2", pikaDelay));
    animData.add(new Animation("Team3", pikaDelay));
    animData.add(new Animation("Team4", marioDelay));

    animData.add(new Animation("Pikachu", pikaDelay));
    animData.add(new Animation("Mario", marioDelay));
    animData.add(new Animation("Zombie", zombieDelay));
    animData.add(new Animation("Cat", zombieDelay));
  }

  int getGameType() {
    /*****************************
     * 0:suicide
     * 1:dm
     * 2:tm
     * 3:cp
     * 4:koth
     * 5:ctf
     * 6:rambo
     * 7:inf
     ******************************/
    return gameType;
  }

  void setGameType(int n) {
    gameType = n;

    while (flagData.size () > 0) {
      Flag ph = (Flag) flagData.get(0);
      ph.drop();
      ph.remove();
      flagData.remove(0);
    }

    if (gameType == 3) setupTakeover(true, true); //TAKEOVER
    else if (gameType == 4) setupKOTH(2); //KING OF THE HILL
    else if (gameType == 5) addFlagsToMap(); //CTF

    if (jython != null) jython.onGameTypeChange(n);
  }

  void checkFramerate() {
    frameRateOverLastFew[0] = frameRateOverLastFew[1];
    frameRateOverLastFew[1] = frameRateOverLastFew[2];
    frameRateOverLastFew[2] = frameRateOverLastFew[3];
    frameRateOverLastFew[3] = int(frameRate);
    if ((frameRateOverLastFew[0]+frameRateOverLastFew[1]+frameRateOverLastFew[2]+frameRateOverLastFew[3])/4 < 25) {
      if (settings.drawTextures) {
        settings.drawTextures = false;
      } 
      else if (settings.drawScenery) {
        settings.drawTextures = false;
      }
      textFont(FONTtitle, 24);
      fill(255, 255);
      text("Trying to Fix Framerate- change settings", 20, height*.9);
    }
  }

  void updateOnline() {
    /*
    //PRINT LOCATION OF EACH SOLDIER
     if(frameCount % 100 == 0) {
     for(int i=0; i<soldierData.size(); i++) {
     Soldier sh = (Soldier) soldierData.get(i);
     //println("soldier:"+i+" "+sh.self.getX()+"/"+sh.self.getY());
     //if(sh.me) print("MEMEMEMEMEME"); 
     }
     }
     */
  }

  void update(GL gl) {
    pushMatrix();
    if (!paused) {
      if (mapLoaded) {
        try {
          world.step();
        } 
        catch (Error e) {
          e.printStackTrace();
          exitProgram();
        } 
        catch (Exception e) {
          e.printStackTrace();
          exitProgram();
        }


        timePlayedInMap += 0.1;
        if (settings.frameCheck && frameCount % 30 == 0) checkFramerate();

        if (meCast.alive) checkKeys();

        if (playingOnline) updateOnline();

        drawBG();
        cameraPos(gl);
        
        gl = (GL) pgl.beginGL();
        //DRAW SCENERY
        if (settings.drawScenery) {
          gl.glEnable(GL.GL_TEXTURE_2D);
          for (int i=0; i<sceneryData.size(); i++) {
            Scenery ph = (Scenery) sceneryData.get(i);
            if (ph.z < 1) ph.update(gl);
          }
        }
        
        for (int i=0; i<polyData.size(); i++) {
          Polygon ph = (Polygon) polyData.get(i);
          ph.update(gl, i);
        }
        if (!settings.debugMode && settings.drawTextures && game.textureMap && game.mapTextureGL.length > 0) gl.glDisable(GL.GL_TEXTURE_2D);
        pgl.endGL();
        
        for (int i=0; i<ragdollData.size(); i++) {
          Ragdoll ph = (Ragdoll) ragdollData.get(i);
          ph.update();
          if (!ph.alive) ragdollData.remove(i);
        }
        
        for (int i=0; i<soldierData.size(); i++) {
          Soldier ph = (Soldier) soldierData.get(i);
          ph.update();
          if (!ph.driving && jython != null) jython.onSoldierMove(ph.id, ph.self.getX(), ph.self.getY(), ph.self.getVelocityX(), ph.self.getVelocityY());
        }

        for (int i=0; i<bulletData.size(); i++) {
          Bullet ph = (Bullet) bulletData.get(i);
          ph.update();
          if (!ph.alive) {
            world.remove(ph.b);
            bulletData.remove(i);
          }
        }

        if(settings.drawScenery) {
          pgl.beginGL();
          //DRAW SCENERY
          if (settings.drawScenery) {
            gl.glEnable(GL.GL_TEXTURE_2D);
            for (int i=0; i<sceneryData.size(); i++) {
              Scenery ph = (Scenery) sceneryData.get(i);
              if (ph.z >= 1) ph.update(gl);
            }
            gl.glDisable(GL.GL_TEXTURE_2D);
          }
          pgl.endGL();
        }

        for (int i=0; i<flagData.size(); i++) {
          Flag ph = (Flag) flagData.get(i);
          ph.update();
        }

        for (int i=0; i<explosionData.size(); i++) {
          Explosion ph = (Explosion) explosionData.get(i);
          if (ph.alive) ph.update();
          
          if (!ph.physAlive) {
            world.remove(ph.c);
            ph.physAlive = false;
          }
          if(!ph.alive) {
            if(ph.physAlive) world.remove(ph.c);
            explosionData.remove(i);
          }
        }

        if (!playingOnline) {
          for (int i=0; i<spawnData.size(); i++) {
            Spawn ph = (Spawn) spawnData.get(i);
            ph.update();
          }
        }

        for (int i=0; i<earthData.size(); i++) {
          Earth ph = (Earth) earthData.get(i);
          ph.update();
        }

        if(gravitronData.size() > 0) {
          ArrayList gravitronBodies = world.getBodies();
          
          for(int i=0; i<gravitronBodies.size(); i++) {
            FBody gh = (FBody) gravitronBodies.get(i);
            if(!gh.isStatic()) {
              Vec2D gravAmount = new Vec2D(0, 0);
              
              for (int j=0; j<gravitronData.size(); j++) {
                Gravitron ph = (Gravitron) gravitronData.get(j);
                float d = dist(gh.getX(), gh.getY(), ph.x, ph.y);
                
                if(d < ph.distance) gravAmount.add(ph.calcPull(gh, d));
              }
              
              if(gravAmount.x != 0.0f && gravAmount.y != 0.0f) gh.addForce(gravAmount.x, gravAmount.y);
            }
          }
        }


        for (int i=0; i<vehicleData.size(); i++) {
          Vehicle ph = (Vehicle) vehicleData.get(i);
          if (ph.alive) {
            ph.update(gl);
          } else if (!ph.alive)  {
            if (jython != null) jython.onVehicleRemove(ph.id);
            vehicleData.remove(i);
            vehiclesDowned++;
          }
        }

        for (int i=0; i<grappleData.size(); i++) {
          Grapple ph = (Grapple) grappleData.get(i);
          ph.update();
          if (!ph.alive) grappleData.remove(i);
        }
        
        pgl.beginGL();
        for (int i=0; i<pickupData.size(); i++) {
          Pickups ph = (Pickups) pickupData.get(i);
          if (ph.alive) {
            ph.update(gl);
          } else {
            ph.kill();
            pickupData.remove(i);
          }
        }
        pgl.endGL();

        for (int i=0; i<catData.size(); i++) {
          Cat ph = (Cat) catData.get(i);
          ph.update();
        }

        if (settings.drawParticles) {
          if (settings.maxParticles != -1 && settings.maxParticles < particleData.size()) {
            while (settings.maxParticles < particleData.size ()) particleData.remove(0);
          }
          for (int i=0; i<particleData.size(); i++) {
            Particle ph = (Particle) particleData.get(i);
            if (ph.alive) ph.update();
            else particleData.remove(i);
            noStroke();
          }
        }

        if (drawPf) drawPathfinder();
        if (frameCount % 120 == 0) checkPickupBoxAmounts();
      }
      if (!mainMenu && !paused && game != null && meCast != null && game.gunData != null) {
        pushMatrix();
          hint(DISABLE_DEPTH_TEST);
          camera();
          //pgl.beginGL();
          hud.update(gl);
          kConsole.update(gl);
          pgl.endGL();
        popMatrix();

        /*
          if(!meCast.alive) { 
         textFont(FONTtitle, 100);
         fill(0);
         text("DEAD", width/3, height/2+50);
         text(meCast.respawnTime/30, width/2, height/2+150);
         }
         
         if(showLevelInfo) drawLevelInfo();
         */
      }
    } else {
      gameMenu.drawPauseScreen();
      popMatrix();
      return;
    }
    
    if (jython != null) {
      if (!playingOnline) {
        if (jython.alive) jython.update();
        else jython = null;
      }
      if (jython.toWorldDraw.length > 0) {
        drawFromScript(0);
      }
      if (jython.toScreenDraw.length > 0) {
        camera();
        drawFromScript(1);
      }
    }
    popMatrix();
    if (showInputBox && !paused) {
      camera();
      if (inputBox == null) inputBox = (Menu.TextBox) gameMenu.inputBox;
      inputBox.update();
      inputBox.selected = true;
    }
  }

  void parseInputBoxData(String data) {
    StringBuffer buf = null;

    if (data.length() > 1) {
      if (data.charAt(0) == '/') {  //command to game
        //FIRST WE REMOVE THE BACKSLASH CHARACTER
        buf = new StringBuffer(data.length()-1);
        buf.append(data.substring(1, data.length()));
        data = buf.toString();

        if (jython != null) {
          jython.toGame(data);
          jython.onSoldierCommand(meCast.id, data);
        }
      } 
      else if (data.charAt(0) == '\\') {  //command to script
        //FIRST WE REMOVE THE BACKSLASH CHARACTER
        buf = new StringBuffer(data.length()-1);
        buf.append(data.substring(2, data.length()));
        data = buf.toString();

        sendDataToScripts(data);
      } 
      else {  //just talking
        kConsole.addKillBoxText(meCast.name+" says "+data);
        if (jython != null) jython.onSoldierSpeak(meCast.id, data);
      }
    }
  }

  void sendDataToScripts(String n) {
    if (game.jython != null) jython.toScript(n);
  }

  void cameraPos(GL gl) {
    boolean threeD = false;
    float eyeX;
    float eyeY;
    float eyeZ;
    float targetX;
    float targetY;
    float targetZ;
    
    if(overrideCameraPos) {
      overrideCameraTime--;
      camera(overrideCameraData[0], overrideCameraData[1], overrideCameraData[2], overrideCameraData[3], overrideCameraData[4], overrideCameraData[5], overrideCameraData[6], overrideCameraData[7], overrideCameraData[8]);
      if(overrideCameraTime<0) overrideCameraPos = false;
      return;
    }

    if (menuMode && !gameMenu.instructions) {
      Polygon ph;
      if (menuPolyFollow < polyData.size()) ph = (Polygon) polyData.get(menuPolyFollow);
      else ph = null;

      if (ph != null) {
        if (menuCurrentFollowPos.x > ph.getXPos()-100 && menuCurrentFollowPos.x < ph.getXPos()+100 && menuCurrentFollowPos.y > ph.getYPos()-100 && menuCurrentFollowPos.y < ph.getYPos()+100) {
          menuPolyFollow = int(random(0, polyData.size()));
          menuCurrentFollowPos.set(ph.getXPos(), ph.getYPos(), 0);
        }

        float pAngle = atan2(ph.getYPos()-menuCurrentFollowPos.y, ph.getXPos()-menuCurrentFollowPos.x);
        float pSpeed = map(constrain(abs(dist(ph.getXPos(), ph.getYPos(), menuCurrentFollowPos.x, menuCurrentFollowPos.y)), 0, 2000), 0, 2000, 1, 10);
        menuCurrentFollowPos.x+=cos(pAngle)*pSpeed;
        menuCurrentFollowPos.y+=sin(pAngle)*pSpeed;
        transX = menuCurrentFollowPos.x;
        transY = menuCurrentFollowPos.y;


        if (threeD) camera(menuCurrentFollowPos.x+((mouseX-width/2)/3), menuCurrentFollowPos.y+((mouseY-height/2)/3), 500, menuCurrentFollowPos.x+(mouseX-width/2), menuCurrentFollowPos.y+(mouseY-height/2), 0, 0, 1, -1);
        else camera(menuCurrentFollowPos.x+((mouseX-width/2)/3), menuCurrentFollowPos.y+((mouseY-height/2)/3), 500, menuCurrentFollowPos.x+((mouseX-width/2)/3), menuCurrentFollowPos.y+((mouseY-height/2)/3), 0, 0, 1, -1);
      }
      return;
    }

    if (!meCast.driving) {
      if (threeD) {
        transX = meCast.self.getX();
        transY = meCast.self.getY();
      } 
      else {
        //transX = meCast.self.getX()+((mouseX-width/2)/2);
        //transY = meCast.self.getY()+((mouseY-height/2)/2);
        if(meCast.ragCast.ragEffect) {
          transX = meCast.ragCast.pieces[0].getX();
          transY = meCast.ragCast.pieces[0].getY();
        } else {
          transX = meCast.self.getX();
          transY = meCast.self.getY();
        }
      }
    } 
    else if (meCast.driving) {
      if (meCast.curCar.alive) {
        for (int i=0; i<meCast.curCar.parts.size(); i++) {
          Vehicle.Part partCast = (Vehicle.Part) meCast.curCar.parts.get(i);
          if (partCast.cockpit) {
            scale(meCast.curCar.scale);
            FBox pieceCast = (FBox) partCast.p;
            transX = partCast.getBody().getX();
            transY = partCast.getBody().getY();
          }
        }
      }
    }

    if (meCast.grappleAlive && meCast.grappleCast.attached && !meCast.driving) {
      eyeX = meCast.grappleCast.body.getX();
      eyeY = meCast.grappleCast.body.getY();
      eyeZ = dist(meCast.self.getX(), meCast.self.getY(), meCast.grappleCast.body.getX(), meCast.grappleCast.body.getY())/2+dist(width/2, height/2, mouseX, mouseY);

      targetX = transX+((mouseX-width/2)/2);
      targetY = transY+((mouseY-height/2)/2);
      targetZ = 0;
    } else {
      if (threeD) {
        eyeX = transX;
        eyeY = transY;
      } else {
        eyeX = transX+((mouseX-width/2)/2);
        eyeY = transY+((mouseY-height/2)/2);
      }

      eyeZ = 400+(dist(width/2, height/2, mouseX, mouseY))-constrain(map(meCast.health, 0, 100, 100, 0), 0, 100)*1.5;
      //eyeZ = 800;

      targetX = transX+((mouseX-width/2)/2);
      targetY = transY+((mouseY-height/2)/2);
      targetZ = 0;
    }

    if (watchingFollowBullet) {
      if (curFollowBullet != null && curFollowBullet.alive) {
        boolean shouldFollow = true;
        if (followBulletZDepth > 100 && followBulletZDepth < 1000) followBulletZDepth -= gunData[curFollowBullet.type].zDepthMinus;

        if (abs(dist(mouseX, mouseY, width/2, height/2)) < gunData[curFollowBullet.type].returnRadius) shouldFollow = false;

        if (shouldFollow) {
          transX = curFollowBullet.b.getX();
          transY = curFollowBullet.b.getY();
          eyeX = transX;
          eyeY = transY;
          eyeZ = followBulletZDepth;
          targetX = eyeX;
          targetY = eyeY;
        }
      } 
      else {
        watchingFollowBullet = false;
      }
    } 
    else if (gunData[meCast.curGun.gun].sniper && abs(dist(mouseX, mouseY, width/2, height/2)) > width/3) {
      transX = transX+((mouseX-width/2)*gunData[meCast.curGun.gun].sightMult);
      transY = transY+((mouseY-height/2)*gunData[meCast.curGun.gun].sightMult);
      eyeX = transX;
      eyeY = transY;
      targetX = eyeX;
      targetY = eyeY;

      if (abs(meCast.self.getVelocityX()) > 50) mouseX += random(-map(constrain(abs(meCast.self.getVelocityX()), 0, 500), 0, 500, 1, 20), map(constrain(abs(meCast.self.getVelocityX()), 0, 500), 0, 500, 1, 20));
      if (abs(meCast.self.getVelocityY()) > 50) mouseY += random(-map(constrain(abs(meCast.self.getVelocityY()), 0, 500), 0, 500, 1, 50), map(constrain(abs(meCast.self.getVelocityY()), 0, 500), 0, 500, 1, 50));
    }

    /*
    if(!meCast.alive && !meCast.driving) {
     eyeX = meCast.self.getX();
     eyeY = meCast.self.getY();
     eyeZ = constrain(500+meCast.health, 100, 500);
     
     targetX = meCast.self.getX();
     targetY = meCast.self.getY();
     targetZ = 0;
     }
     */
    camera(eyeX, eyeY, eyeZ, targetX, targetY, targetZ, 0, 1, -1);
    //ExtractFrustum(gl);
  }
  
  
  void setCamera(float time, float cameraX, float cameraY, float cameraZ, float targetX, float targetY, float targetZ) {
    overrideCameraPos = true;
    overrideCameraTime = time;
    overrideCameraData = new float[9];
    overrideCameraData[0] = cameraX;
    overrideCameraData[1] = cameraY;
    overrideCameraData[2] = cameraZ;
    overrideCameraData[3] = cameraX;
    overrideCameraData[4] = cameraY;
    overrideCameraData[5] = cameraZ;
    overrideCameraData[6] = 0;
    overrideCameraData[7] = 1;
    overrideCameraData[8] = -1;
  }
  
  void setCamera(float time, float cameraX, float cameraY, float cameraZ, float targetX, float targetY, float targetZ, float upX, float upY, float upZ) {
    overrideCameraPos = true;
    overrideCameraTime = time;
    overrideCameraData = new float[9];
    overrideCameraData[0] = cameraX;
    overrideCameraData[1] = cameraY;
    overrideCameraData[2] = cameraZ;
    overrideCameraData[3] = cameraX;
    overrideCameraData[4] = cameraY;
    overrideCameraData[5] = cameraZ;
    overrideCameraData[6] = upX;
    overrideCameraData[7] = upY;
    overrideCameraData[8] = upZ;
  }

  void addFlagsToMap() {
    for (int i=0; i<spawnData.size(); i++) {
      Spawn sh = (Spawn) spawnData.get(i);
      if (sh.type == 8) {
        flagData.add(new Flag(sh.x, sh.y, sh.subType));
        println("flag "+sh.subType+" added");
      }
    }
  }

  void setupKOTH(int minutes) {
    for (int i=0; i<game.spawnData.size(); i++) {
      Spawn sh = (Spawn) game.spawnData.get(i);
      if (sh.type == 7) sh.subType = (30*60)*minutes;  //(frameRate*seconds = minutes)*n -- minutes of control needed to win
    }
  }

  void setupTakeover(boolean changeGenerals_, boolean balance_) {
    for (int i=0; i<game.spawnData.size(); i++) {
      Spawn sh = (Spawn) game.spawnData.get(i);
      if (changeGenerals_ && sh.type == 0) {
        sh.type = 6;
        sh.subType = 1+int(random(0, 4));
      }

      if (balance_) {
        //TODO: BALANCE THE CONTROL POINTS
      }

      /*
      game.polyData.add(new FPoly());
       FPoly fp = (FPoly) game.polyData.get(game.polyData.size()-1);
       fp.vertex(sh.x-30, sh.y-30);
       fp.vertex(sh.x+30, sh.y-30);
       fp.vertex(sh.x, sh.y+30);
       fp.setStatic(true);
       fp.setName("cp");
       fp.setSensor(true);
       world.add(fp);
       */
    }
  }

  /*PImage createMinimap() {
    int[] leftmostPoly = setArrayToZero(2);
    int[] rightmostPoly = setArrayToZero(2);
    int[] highestPoly = setArrayToZero(2);
    int[] lowestPoly = setArrayToZero(2);

    for (int i=0; i<polyData.size(); i++) {
      Polygon ph = (Polygon) polyData.get(i);
      if (ph.getXPos() < leftmostPoly[1]) {
        leftmostPoly[0] = i;
        leftmostPoly[1] = int(ph.getXPos());
      }
      if (ph.getXPos() > rightmostPoly[1]) {
        rightmostPoly[0] = i;
        rightmostPoly[1] = int(ph.getXPos());
      }
      if (ph.getYPos() < highestPoly[1]) {
        highestPoly[0] = i;
        highestPoly[1] = int(ph.getYPos());
      }
      if (ph.getYPos() > lowestPoly[1]) {
        lowestPoly[0] = i;
        lowestPoly[1] = int(ph.getYPos());
      }
    }

    for (int i=0; i<earthData.size(); i++) {
      Earth ph = (Earth) earthData.get(i);
      if (ph.earth.getX()-ph.radius < leftmostPoly[1]) {
        leftmostPoly[0] = polyData.size()+i;
        leftmostPoly[1] = int(ph.earth.getX()-ph.radius);
      }
      if (ph.earth.getX()+ph.radius > rightmostPoly[1]) {
        rightmostPoly[0] = polyData.size()+i;
        rightmostPoly[1] = int(ph.earth.getX()+ph.radius);
      }
      if (ph.earth.getY()-ph.radius < highestPoly[1]) {
        highestPoly[0] = polyData.size()+i;
        highestPoly[1] = int(ph.earth.getY()-ph.radius);
      }
      if (ph.earth.getY()+ph.radius > lowestPoly[1]) {
        lowestPoly[0] = polyData.size()+i;
        lowestPoly[1] = int(ph.earth.getY()+ph.radius);
      }
    }

    if (leftmostPoly[1] == 0) leftmostPoly[1] = -1;
    if (rightmostPoly[1] == 0) rightmostPoly[1] = 1;
    if (highestPoly[1] == 0) highestPoly[1] = -1;
    if (lowestPoly[1] == 0) lowestPoly[1] = 1;

    float s = ((width/height)*width/6);
    float w = s*(rightmostPoly[1]-leftmostPoly[1]);
    float h = s*(lowestPoly[1]-highestPoly[1]);

    PGraphics img;
    try {
      img = createGraphics(int(w), int(h), P2D);
    } 
    catch(Exception e) {
      System.err.println("ERROR CREATING GRAPHICS FOR MINIMAP");
      e.printStackTrace();
      //showMinimap = false;
      return null;
    }

    img.beginDraw();
    img.background(255, 0);  //TRANSPARENT BACKGROUND, MAYBE NOT NEEDED?
    //img.ellipseMode(CENTER);
    //img.fill(255);

    for (int i=0; i<polyData.size(); i++) {
      Polygon ph = (Polygon) polyData.get(i);
      //DRAW ALL POLYS TO MINIMAP HERE
    }

    for (int i=0; i<earthData.size(); i++) {
      Earth ph = (Earth) earthData.get(i);
      img.ellipse(ph.earth.getX()/w, ph.earth.getY()/h, ph.earth.getSize()/w, ph.earth.getSize()/h);
    }

    img.endDraw();

    return img;
  }
  */

  void setFollowBullet(Bullet b_) {
    curFollowBullet = (Bullet) b_;
    watchingFollowBullet = true;
    followBulletZDepth = game.gunData[b_.type].zDepth;
  }

  void addControlBullet() { 
    controlBullets.add((Bullet) bulletData.get(bulletData.size()-1));
  }
  
  boolean checkRender(float[] x, float[] y, float[] z) {
    for(int i=0; i<x.length; i++) 
      if(checkRender(x[i], y[i], z[i])) return true;
    
    if(x.length < 3) return false;
    
    for(int i=0; i<x.length; i++) {
      if(i < x.length-1) if(checkRenderIntersect(x[i], y[i], z[i], x[i+1], y[i+1], z[i+1])) return true;
      else if(checkRenderIntersect(x[i], y[i], z[i], x[0], y[0], z[0])) return true;
    }
    
    return false;
  }
  
  boolean checkRender(float x, float y, float z) {
    float sX = screenX(x, y, z);
    float sY = screenY(x, y, z);
    
    if(sX >= 0 && sX <= width && sY >= 0 && sY <= height) return true;
    return false;
  }
  
  boolean checkRenderIntersect(float x1, float y1, float z1, float x2, float y2, float z2) {
    float sX1 = screenX(x1, y1, z1);
    float sY1 = screenY(x1, y1, z1);
    float sX2 = screenX(x2, y2, z2);
    float sY2 = screenY(x2, y2, z2);
    
    Line2D l = new Line2D.Float(sX1, sY1, sX2, sY2);
    return l.intersects(0, 0, width, height);
  }
  
  float checkSoundRender(float x, float y, float r) {
    float sX = screenX(x, y, 0.0);
    float sY = screenY(x, y, 0.0);
    
    if(sX >= -r && sX <= r*2 && sY >= -r && sY <= r*2)  return map(dist(sX, sY, r/2, r/2), 0, r, 1.0, 0.0);
    
    return -1.0;
  }
  
  float checkSoundBalance(float x, float r) {
    return map(x, -r, r, -1.0, 1.0);
  }

  void shootGun(float x_, float y_, float gunAngle_, float xVelo_, float yVelo_, int type_, int id_) {
    
    if (!playingOnline) {
      Soldier sh = getSoldierById(id_);
      gunAngle_ += random(-game.gunData[type_].accuracy, game.gunData[type_].accuracy)+random(-sh.curGun.bink, sh.curGun.bink);
      if (game.gunData[type_].shotgun) {
        for (int i=-game.gunData[type_].shotgunShots; i<game.gunData[type_].shotgunShots/2; i++) {
          game.bulletData.add(new Bullet(x_+(cos(gunAngle_+(i/game.gunData[type_].shotgunShots))*15), y_+(sin(gunAngle_+(i/game.gunData[type_].shotgunShots))*15), (game.gunData[type_].speed*cos(gunAngle_+(i*(0.25/game.gunData[type_].shotgunShots)))), (game.gunData[type_].speed*sin(gunAngle_+(i*(0.25/game.gunData[type_].shotgunShots)))), type_, id_)); 

          Bullet bCast = (Bullet) game.bulletData.get(game.bulletData.size()-1);
          bCast.addMoveAcc(xVelo_, yVelo_);

          if (id_ == meCast.id) {
            if (game.gunData[type_].follow) game.setFollowBullet((Bullet) game.bulletData.get(game.bulletData.size()-1));
            if (game.gunData[type_].controllable) game.addControlBullet();
          }
        }
      } 
      else {
        //FOR REGULAR GUNS
        game.bulletData.add(new Bullet(x_, y_, (game.gunData[type_].speed*cos(gunAngle_)), (game.gunData[type_].speed*sin(gunAngle_)), type_, id_)); 
        Bullet bCast = (Bullet) game.bulletData.get(game.bulletData.size()-1);
        bCast.addMoveAcc(xVelo_, yVelo_);

        if (id_ == meCast.id) {
          if (game.gunData[type_].follow) game.setFollowBullet((Bullet) game.bulletData.get(game.bulletData.size()-1));
          if (game.gunData[type_].controllable) game.addControlBullet();
        }
      }
    } 
    else {
      byte[] b = new byte[2];
      b[0] = 7;
      b[1] = 0;
      b = concat(b, toByte(mouseX));
      b = concat(b, toByte(mouseY));
      client.send(b, serverIp, serverPort);
    }
  }

  void pause() {
    if (!pausePush) {
      if (!paused) {
        paused = true;
        if (jython != null) jython.onGamePause();
      } 
      else {
        paused = false;
        if (jython != null) jython.onGameUnpause();
      }
      pausePush = true;
    }
  }

  void drawLevelInfo() {
    pushMatrix();
    background(255);
    fill(0);
    textFont(FONTtitle, 36);
    text(levelName, width/3, height/2);
    pushMatrix();
    translate(width*.75, height*.7);
    textFont(FONTtitle, 24);
    text(levelSummary, 0, 0, 400, 300);
    popMatrix();
    popMatrix();
  }

  void drawBG() {
    pushMatrix();
    translate(-width, -height);
    scale(width*2, height*2);
    beginShape();
    fill(bgColor[0][0], bgColor[0][1], bgColor[0][2], bgColor[0][3]);
    vertex(0, 0);
    fill(bgColor[1][0], bgColor[1][1], bgColor[1][2], bgColor[1][3]);
    vertex(1, 0);
    fill(bgColor[2][0], bgColor[2][1], bgColor[2][2], bgColor[2][3]);
    vertex(1, 1);
    fill(bgColor[3][0], bgColor[3][1], bgColor[3][2], bgColor[3][3]);
    vertex(0, 1);
    endShape();
    popMatrix();
  }


  void checkKeys() {
    switch(keyResult) {
      //ALL FOUR MOVEMENTS FOR WASD
    case keyW:
      wPush = true;
      break;

    case keyD:
      dPush = true;
      break;

    case keyS:
      sPush = true;
      break;

    case keyA:
      aPush = true;
      break;

      //DEFAULT ESCAPE/getin, THROW, RELOADS
    case keyX:
      kpX();
      break;
    case keyF:
      kpF();
      break;
    case keyR:
      kpR();
      break;

      //COMBO MOVEMENTS
    case keyW|keyD:
      wPush = true;
      dPush = true;
      break;

    case keyW|keyA:
      wPush = true;
      aPush = true;
      break;

    case keyS|keyD: 
      sPush = true;
      dPush = true;
      break;

    case keyS|keyA:
      sPush = true;
      aPush = true;
      break;

      //MOVEMENTS + ACTION
    case keyW|keyX:
      wPush = true;
      kpX();
      break;

    case keyS|keyX: 
      sPush = true;
      kpX();
      break;

    case keyA|keyX:
      aPush = true;
      kpX();
      break;

    case keyD|keyX:
      dPush = true;
      kpX();
      break;

    case keyW|keyF:
      wPush = true;
      kpF();
      break;

    case keyS|keyF: 
      sPush = true;
      kpF();
      break;

    case keyA|keyF:
      aPush = true;
      kpF();
      break;

    case keyD|keyF:
      dPush = true;
      kpF();
      break;

    case keyW|keyR:
      wPush = true;
      kpR();
      break;

    case keyS|keyR: 
      sPush = true;
      kpR();
      break;

    case keyA|keyR:
      aPush = true;
      kpR();
      break;

    case keyD|keyR:
      dPush = true;
      kpR();
      break;
    }

    int tempMoveX = 0, tempMoveY = 0;
    if (wPush) tempMoveY--;
    if (aPush) tempMoveX--;
    if (sPush) tempMoveY++;
    if (dPush) tempMoveX++;
    if (wPush || aPush || sPush || dPush) meCast.addMovement(tempMoveX, tempMoveY);
  }

  void onlineMove(int x_, int y_) {
    int data_ = 0;

    byte[] b = new byte[6];
    b[0] = 3;  //SET AS THREE SO SERVER KNOWS WERE SENDING MOVEMENT
    b[1] = byte(x_);
    b[2] = byte(y_);
    b[3] = byte(xPush);
    b[4] = byte(fPush);
    b[5] = byte(rPush);
    client.send(b, serverIp, serverPort);
  }

  void kpX() {
    if (!xPush) {
      if (!playingOnline) {
        if (!meCast.driving) {
          if (meCast.touchingPickup == true) meCast.pickup(meCast.tPickup);
          else if (meCast.touchingVehicle == true) meCast.enterVehicle(meCast.tVehicle);
        } 
        else if (meCast.driving) {
          meCast.exitVehicle(true);
        }
      }
    }

    if (game.paused) mapLoaded = false;

    xPush=true;
  }

  void kpF() {
    if (game.meCast.curGun.gun != 0) game.meCast.throwGun();
    game.fPush=true;
  }

  void kpR() {
    meCast.curGun.reload();
    game.rPush = true;
  }


  /**************************************
   * ALL GRAPHICAL FUNCTIONS GO BELOW
   *
   *
   **************************************/

  void drawFromScript(int level) {
    String[] commands = new String[0];
    if(level == 0) commands = jython.toWorldDraw;
    else if(level == 1) commands = jython.toScreenDraw;
    
    for (int i=0; i<commands.length; i++) {
      String[] piece = split(commands[i], " ");

      if (piece[0].equals("f") && piece.length == 5) {  //fill
        fill(int(piece[1]), int(piece[2]), int(piece[3]), int(piece[4]));
      } 
      else if (piece[0].equals("s") && piece.length == 5) {  //stroke
        stroke(int(piece[1]), int(piece[2]), int(piece[3]), int(piece[4]));
      } 
      else if (piece[0].equals("sw") && piece.length == 2) {  //strokeweight
        strokeWeight(int(piece[1]));
      } 
      else if (piece[0].equals("ts") && piece.length == 2) {  //textsize
        //textFont(FONTtitle);
        textSize(int(piece[1]));
      } 
      else if (piece[0].equals("t") && piece.length > 3) {  //text
        pushMatrix();
        translate(int(piece[1]), int(piece[2]));
        text(stringArrayToSentence(piece, 3), 0, 0);
        popMatrix();
      } 
      else if (piece[0].equals("bs")) {  //begin
        beginShape();
      } 
      else if (piece[0].equals("es")) {  //end
        endShape();
      } 
      else if (piece[0].equals("pum")) {  //push
        pushMatrix();
      } 
      else if (piece[0].equals("pom")) {  //pop
        popMatrix();
      } 
      else if (piece[0].equals("tr")) {  //translate
        if (piece.length == 4) translate(float(piece[1]), float(piece[2]), float(piece[3]));
      } 
      else if (piece[0].equals("sc")) {  //scale
        if (piece.length == 4) scale(float(piece[1]), float(piece[2]), float(piece[3]));
      } 
      else if (piece[0].equals("ro")) {  //scale
        if (piece.length == 2) rotate(float(piece[1]));
      } 
      else if (piece[0].equals("v")) {  //vertex
        if (piece.length == 4) vertex(float(piece[1]), float(piece[2]), float(piece[3]));
      } 
      else if (piece[0].equals("r")) {  //rect
        if (piece.length == 5) {
          pushMatrix();
          translate(float(piece[1]), float(piece[2]), 0);
          scale(float(piece[3]), float(piece[4]), 1);
          beginShape();
          vertex(0, 0);
          vertex(0, 1);
          vertex(1, 1);
          vertex(1, 0);
          endShape();
          popMatrix();
        } 
        else if (piece.length == 6) {
          pushMatrix();
          translate(float(piece[1]), float(piece[2]), float(piece[3]));
          scale(float(piece[4]), float(piece[5]), 1);
          beginShape();
          vertex(0, 0);
          vertex(0, 1);
          vertex(1, 1);
          vertex(1, 0);
          endShape();
          popMatrix();
        }
      } 
      else if (piece[0].equals("c")) {  //circle
        if (piece.length == 5) {
          pushMatrix();
          translate(float(piece[1]), float(piece[2]), 0);
          scale(float(piece[3]), float(piece[4]), 1);
          ellipse(0, 0, 1, 1);
          popMatrix();
        } 
        else if (piece.length == 6) {
          pushMatrix();
          translate(float(piece[1]), float(piece[2]), float(piece[3]));
          scale(float(piece[4]), float(piece[5]), 1);
          ellipse(0, 0, 1, 1);
          popMatrix();
        }
      } 
      else if (piece[0].equals("l")) {  //line
        if (piece.length == 5) line(float(piece[1]), float(piece[2]), float(piece[3]), float(piece[4]));
        else if (piece.length == 7) line(float(piece[1]), float(piece[2]), float(piece[3]), float(piece[4]), float(piece[5]), float(piece[6]));
      } 
      else if (piece[0].equals("p")) {  //poly
        if (piece.length == 7) {
          beginShape();
          vertex(float(piece[1]), float(piece[2]));
          vertex(float(piece[3]), float(piece[4]));
          vertex(float(piece[5]), float(piece[6]));
          endShape();
        } 
        else if (piece.length == 10) {
          beginShape();
          vertex(float(piece[1]), float(piece[2]), float(piece[3]));
          vertex(float(piece[4]), float(piece[5]), float(piece[6]));
          vertex(float(piece[7]), float(piece[8]), float(piece[9]));
          endShape();
        }
      } 
      else {
        System.err.println("*****CHECK SYNAX******");
      }
    }

    noStroke();
  }

  void setScriptDraw(String scriptDrawData) { 
    this.scriptDrawData = scriptDrawData;
  }

  boolean checkInsidePoly(FBody body) {
    for (int i=0; i<game.polyData.size(); i++) {
      Polygon ph = (Polygon) game.polyData.get(i);
      if (ph.type != 1 && ph.type != 3 && ph.pointInside(body.getX(), body.getY())) return true;
    }
    return false;
  }

  void removeSoldierById(int id) {
    for (int i=0; i<soldierData.size(); i++) {
      Soldier ph = (Soldier) soldierData.get(i);
      if (ph.id == id) {
        ph.alive = false;
        ph.update();
        soldierData.remove(i);
        break;
      }
    }

    if (jython != null) jython.onSoldierRemove(id);
  }

  Soldier getSoldierById(int id) {
    for (int i=0; i<soldierData.size(); i++) {
      Soldier ph = (Soldier) soldierData.get(i);
      if (ph.id == id) return ph;
    }
    return null;
  }

  Vehicle getVehicleById(int id) {
    for (int i=0; i<vehicleData.size(); i++) {
      Vehicle ph = (Vehicle) vehicleData.get(i);
      if (ph.id == id) return ph;
    }
    return null;
  }

  Spawn getSoldierSpawn() {
    Spawn s;
    int[] sh = new int[0];
    for (int i=0; i<spawnData.size(); i++) {  //LOOK FOR SOLDIER SPAWNS
      Spawn ph = (Spawn) spawnData.get(i);
      if (ph.type == 6 || ph.type == 0) sh = append(sh, i);
    }

    if (sh.length > 0) {
      return (Spawn) spawnData.get(int(random(0, sh.length)));
    } 
    else {
      for (int i=0; i<spawnData.size(); i++) {
        Spawn ph = (Spawn) spawnData.get(i);
        sh = append(sh, i);
      }
      if (sh.length > 0) {
        return (Spawn) spawnData.get(int(random(0, sh.length)));
      } 
      else {
        return new Spawn(0, 0, 0, 0, 0);
      }
    }
  }
  
  boolean checkSoldierAIById(int id) {
    Soldier sh = (Soldier) getSoldierById(id);
    if(sh.ai) return true;
    return false;
  }

  int getAnimIdByName(String n_) {
    for (int i=0; i<animData.size(); i++) {
      Animation ph = (Animation) animData.get(i);
      if (n_.equals(ph.name)) return i;
    }
    return 0;
  }

  void checkPickupBoxAmounts() {
    if (getGunBoxAmount() > soldierData.size()) removePickupsBox(0, 1);
    if (getHealthpackAmount() > maxHealthPacks) removePickupsBox(1, 1);
    if (getAttachmentAmount() > maxAttachments) removePickupsBox(2, 1);
  }

  void removePickupsBox(int type_, int amount_) {
    for (int i=0, a=0; i<pickupData.size() && a<amount_; i++) {
      Pickups ph = (Pickups) pickupData.get(i);
      if (ph.type[0] == type_) {
        ph.alive = false;
        a++;
      }
    }
  }

  int getAttachmentAmount() {
    int a = 0;
    for (int i=0; i<pickupData.size(); i++) {
      Pickups ph = (Pickups) pickupData.get(i);
      if (ph.type[0] == 2) a++;
    }
    return a;
  }

  int getHealthpackAmount() {
    int a = 0;
    for (int i=0; i<pickupData.size(); i++) {
      Pickups ph = (Pickups) pickupData.get(i);
      if (ph.type[0] == 1) a++;
    }
    return a;
  }

  int getGunBoxAmount() {
    int a = 0;
    for (int i=0; i<pickupData.size(); i++) {
      Pickups ph = (Pickups) pickupData.get(i);
      if (ph.type[0] == 0) a++;
    }
    return a;
  }

  int[] getTMScores() {
    int[] teamScores = setArrayToZero(4);

    for (int i=0; i<game.soldierData.size(); i++) {
      Soldier ph = (Soldier) game.soldierData.get(i);
      teamScores[ph.team] += ph.kills*2-ph.deaths;
    }

    return teamScores;
  }

  int[] getTakeoverScores() {
    int teamSpawns[] = new int[4];
    for (int i=0; i<spawnData.size(); i++) {
      Spawn ph = (Spawn) spawnData.get(i);
      if (ph.type == 6 && ph.subType > 0 && ph.subType < 5) teamSpawns[ph.subType-1]++;
    }
    return teamSpawns;
  }

  String[] getTakeoverScoresText(int[] n) {
    String[] scores = new String[4];
    for (int i=0; i<4; i++) scores[i] = int(float(n[i])*(100.0/float(getSoldierSpawnAmount())))+"%";
    return scores;
  }

  int[] getKOTHScores() {
    Spawn sh = null;

    for (int i=0; i<game.spawnData.size(); i++) {
      Spawn ph = (Spawn) game.spawnData.get(i);
      if (ph.type == 7) sh = (Spawn) game.spawnData.get(i);
    }

    if (sh != null) {
      int teamScores[] = new int[5];
      teamScores[0] = sh.amount;
      for (int i=0; i<sh.team.length; i++) teamScores[i+1] = sh.team[i];
      return teamScores;
    } 
    else {
      return null;
    }
  }

  String[] getKOTHScoresText(int[] n) {
    if (n == null) return new String[0];
    String[] scores = new String[n.length-1];
    for (int i=0; i<n.length-1; i++) scores[i] = int(float(n[i+1])*(100.0/float(30*60*n[0])))+"%";
    return scores;
  }

  int[] getCTFScores() {
    int[] teamScores = setArrayToZero(2);

    for (int i=0; i<game.spawnData.size(); i++) {
      Spawn ph = (Spawn) game.spawnData.get(i);
      if (ph.type == 8) teamScores[ph.subType] += ph.amount;
    }

    return teamScores;
  }

  String[] getTeamScoresText(int[] n) {
    String[] scores = new String[n.length];
    for (int i=0; i<n.length; i++) scores[i] = str(n[i]);
    return scores;
  }

  String[] getScoresText() {
    if (getGameType() == 2) return getTeamScoresText(getTMScores());
    else if (getGameType() == 3) return getTakeoverScoresText(getTakeoverScores());
    else if (getGameType() == 4) return getKOTHScoresText(getKOTHScores());
    else if (getGameType() == 5) return getTeamScoresText(getCTFScores());
    return null;
  }

  int getSoldierSpawnAmount() {
    int n = 0;
    for (int i=0; i<game.spawnData.size(); i++) {
      Spawn ph = (Spawn) game.spawnData.get(i);
      if (ph.type == 6 && ph.subType > 0 && ph.subType < 5) n++;
    }
    return n;
  }

  int[] getSoldierColorByTeam(int team) {
    int[] c = setArrayToZero(4);
    c[3] = 255;
    if (team == 0) {
      c[0] = 255;
      c[1] = 255;
      c[2] = 255;
    } 
    else if (team == 1) {
      c[0] = 255;
    } 
    else if (team == 2) {
      c[1] = 255;
    } 
    else if (team == 3) {
      c[2] = 255;
    }
    return c;
  }
  
  float[][] calcMapBounds() {
    float[][] bounds = new float[4][2];  //top left, top right, bot left, bright//x,y
    for(int i=0; i<bounds.length; i++) bounds[i] = new float[2];
    
    for(int i=0; i<game.polyData.size(); i++) {
      Polygon ph = (Polygon) game.polyData.get(i);
      if(i == 0) {
          bounds[0][0] = ph.x[0];
          bounds[0][1] = ph.y[0];
          bounds[1][0] = ph.x[0];
          bounds[1][1] = ph.y[0];
          bounds[2][0] = ph.x[0];
          bounds[2][1] = ph.y[0];
          bounds[3][0] = ph.x[0];
          bounds[3][1] = ph.y[0];
        }
      for(int j=0; j<3; j++) {  
        if(bounds[0][0] > ph.x[j]) bounds[0][0] = ph.x[j];
        if(bounds[0][1] > ph.y[j]) bounds[0][1] = ph.y[j];
        
        if(bounds[1][0] < ph.x[j]) bounds[1][0] = ph.x[j];
        if(bounds[1][1] > ph.y[j]) bounds[1][1] = ph.y[j];
        
        if(bounds[2][0] > ph.x[j]) bounds[2][0] = ph.x[j];
        if(bounds[2][1] < ph.y[j]) bounds[2][1] = ph.y[j];
        
        if(bounds[3][0] < ph.x[j]) bounds[3][0] = ph.x[j];
        if(bounds[3][1] < ph.y[j]) bounds[3][1] = ph.y[j];
      }
    }
    
    println(bounds);
    return bounds;
  }
}

