Gun[] loadGuns(String gunList_) {
  XMLElement xmlGuns = new XMLElement(this, sketchPath+"//weapons/lists/"+gunList_);

  int lineCount = xmlGuns.getChildCount();  //how many lines/types their are
  XMLElement[] lineName = xmlGuns.getChildren();

  Gun[] tempGData = new Gun[1];  //ADD FISTS
  tempGData[0] = new Gun("Fists", 5, 1000, 2, 20, 0.0, 0.0, 20, 10, 25, false);
  tempGData[0].setLifeSpan(3);

  for (int i=0; i < lineCount; i++) {  //runs through once for each gun
    XMLElement curse = xmlGuns.getChild(i);
    String pieceName = lineName[i].getName();

    if (pieceName.equals("gun") && loadIndividualGun(curse.getContent(), boolean(curse.getStringAttribute("choice"))) != null) {
      tempGData = (Gun[]) append(tempGData, loadIndividualGun(curse.getContent(), boolean(curse.getStringAttribute("choice"))));
    }
  }

  return tempGData;
}

Gun loadIndividualGun(String src, boolean choice) {
  XMLElement xmlTempGun = null;
  try {
    xmlTempGun = new XMLElement(this, sketchPath+"//weapons/guns/"+src);  //load gun file
  } 
  catch(Exception e) {
    System.err.println("Error Loading: "+src);
    return null;
  }

  if (xmlTempGun == null) return null;

  Gun tempGun = null;

  int gunLines = xmlTempGun.getChildCount();  //how many lines in each gun file
  XMLElement[] tagName = xmlTempGun.getChildren();
  println(src);
  for (int g=0; g<gunLines; g++) {
    XMLElement innerCurse = xmlTempGun.getChild(g);
    String innerTagName = tagName[g].getName();  //grabs the name of tag for each line
    
    if (innerTagName.equals("gun")) {
      tempGun = new Gun(innerCurse.getContent(), innerCurse.getIntAttribute("ammo"), innerCurse.getIntAttribute("speed"), innerCurse.getFloatAttribute("radius"), innerCurse.getFloatAttribute("density"), innerCurse.getFloatAttribute("restitution"), innerCurse.getFloatAttribute("friction"), innerCurse.getIntAttribute("reloadtime"), innerCurse.getIntAttribute("delaytime"), innerCurse.getIntAttribute("damage"), choice);
      //println("LOAD GUN: "+innerCurse.getContent());
    } 
    else if (innerTagName.equals("setSniper")) {
      tempGun.setSniper(true, innerCurse.getFloatAttribute("sightMult"));
    } 
    else if (innerTagName.equals("setSniperLine")) {
      tempGun.setSniperLine(true);
    } 
    else if (innerTagName.equals("setAutomatic")) {
      tempGun.setAutomatic(true);
    } 
    else if (innerTagName.equals("setShotgun")) {
      tempGun.setShotgun(true, innerCurse.getIntAttribute("shells"));
    } 
    else if (innerTagName.equals("setBoom")) {
      tempGun.setBoom(true, innerCurse.getIntAttribute("radius"), innerCurse.getIntAttribute("timer"));
    }
    else if (innerTagName.equals("setDelayExplode")) {
      tempGun.setDelayExplode(true, innerCurse.getIntAttribute("delay"), innerCurse.getIntAttribute("radius"), innerCurse.getIntAttribute("timer"), boolean(innerCurse.getStringAttribute("explodeOnSoldierImpact")));
    }
    else if (innerTagName.equals("setSpeedMultBasedOnMouse")) {
      tempGun.setSpeedMultBasedOnMouse(true, innerCurse.getFloatAttribute("xMult"), innerCurse.getFloatAttribute("yMult"));
    }
    else if (innerTagName.equals("setBullet")) {
      tempGun.setBullet(innerCurse.getContent());
    } 
    else if (innerTagName.equals("setSound")) {
      tempGun.setSound(innerCurse.getContent(), innerCurse.getFloatAttribute("distance"));
    } 
    else if (innerTagName.equals("setGun")) {
      tempGun.setGun(innerCurse.getContent());
    } 
    else if (innerTagName.equals("setFlame")) {
      tempGun.setFlame(true);
    } 
    else if (innerTagName.equals("setNoMoveAcc")) {
      tempGun.setNoMoveAcc(true);
    } 
    else if (innerTagName.equals("setControllable")) {
      tempGun.setControllable(true, innerCurse.getFloatAttribute("strength"));
    } 
    else if (innerTagName.equals("setFollow")) {
      tempGun.setFollow(true, innerCurse.getFloatAttribute("returnRadius"), innerCurse.getFloatAttribute("zDepth"), innerCurse.getFloatAttribute("zDepthMinus"));
    } 
    else if (innerTagName.equals("setLifespan")) {
      tempGun.setLifeSpan(Integer.parseInt(innerCurse.getContent()));
    } 
    else if (innerTagName.equals("setParticle")) {
      tempGun.setParticle(true, innerCurse.getIntAttribute("type"), innerCurse.getFloatAttribute("radius_min"), innerCurse.getFloatAttribute("radius_max"));
    } 
    else if (innerTagName.equals("setBink")) {
      tempGun.setBink(innerCurse.getFloatAttribute("amount"));
    } 
    else if (innerTagName.equals("setRecoil")) {
      tempGun.setRecoil(innerCurse.getFloatAttribute("amount"));
    } 
    else if (innerTagName.equals("setAccuracy")) {
      tempGun.setAccuracy(innerCurse.getFloatAttribute("amount"));
    }
  }

  return tempGun;
}

void loadRagdoll(String src) {
  Ragdoll ragCast = null;
  Ragdoll.Animation ragAnimCast;
  Ragdoll.Animation.Frame ragAnimFrameCast;
  XMLElement xmlRag;
  int lineCount;  //how many lines/types their are
  XMLElement[] lineName;

  //load base creature
  xmlRag = new XMLElement(this, "mods/"+settings.mod+"/gfx/animations/"+src+"/base.xml");
  lineCount = xmlRag.getChildCount();  //how many lines/types their are
  lineName = xmlRag.getChildren();

  baseRagdollData.add(new Ragdoll(src));
  ragCast = (Ragdoll) baseRagdollData.get(baseRagdollData.size()-1);

  for (int i=0; i < lineCount; i++) {  //runs through once for each poly
    XMLElement curse = xmlRag.getChild(i);
    String pieceName = lineName[i].getName();  //grabs the nagame.meCast of tag for each line
    if (pieceName.equals("part")) {
      ragCast.addPart(curse.getIntAttribute("connect"));
      Ragdoll.Part pCast = (Ragdoll.Part) ragCast.parts.get(ragCast.parts.size()-1);
      pCast.setType(curse.getIntAttribute("type"));
      pCast.setSize(curse.getFloatAttribute("size"));
      pCast.setColour(curse.getIntAttribute("r"), curse.getIntAttribute("g"), curse.getIntAttribute("b"), curse.getIntAttribute("a"));
    }
  }
  //load animations(for now only walk, add run, reload, squat, jump, shoot, etc later)
  //(always use walk for fallback when dealing with missing shit)
  for (int f=0; f<1; f++) {
    String tempAnimName = null;

    switch(f) {
    case 0: 
      tempAnimName = "walk"; 
      break;
      //case 1: tempAnimName = "run"; break;
    }
    xmlRag = new XMLElement(this, "mods/"+settings.mod+"/gfx/animations/"+src+"/"+tempAnimName+".xml");
    lineCount = xmlRag.getChildCount();  //how many lines/types their are
    lineName = xmlRag.getChildren();

    ragCast.addAnimation(tempAnimName);
    ragAnimCast = (Ragdoll.Animation) ragCast.animations.get(ragCast.animations.size()-1);

    float[] tempFrameX = new float[ragCast.parts.size()];
    float[] tempFrameY = new float[ragCast.parts.size()];

    for (int i=0; i < lineCount; i++) {  //runs through once for each poly
      XMLElement curse = xmlRag.getChild(i);
      String pieceName = lineName[i].getName();  //grabs the nagame.meCast of tag for each line
      if (pieceName.equals("part")) {
        tempFrameX[curse.getIntAttribute("id")] = curse.getFloatAttribute("x");
        tempFrameY[curse.getIntAttribute("id")] = curse.getFloatAttribute("y");
      } 
      else if (pieceName.equals("newframe")) {
        ragAnimCast.addFrame(tempFrameX, tempFrameY);
      }
    }
  }


  println("Ragdoll: "+src+" loaded");
}



void loadVehicle(String src_) {
  if (src_ == null) {
    System.err.println("No source was specified for loading vehicle, please check map file");
    return;
  }

  if (game.jython != null) game.jython.onBaseVehicleAdd(src_);

  XMLElement xmlVehicles = new XMLElement(this, "vehicles/"+src_);
  baseVehicleData.add(new Vehicle(true));
  Vehicle vh = (Vehicle) baseVehicleData.get(baseVehicleData.size()-1);

  int lineCount = xmlVehicles.getChildCount();  //how many lines/types their are
  XMLElement[] lineName = xmlVehicles.getChildren();

  for (int i=0; i < lineCount; i++) {  //runs through once for each poly
    XMLElement curse = xmlVehicles.getChild(i);
    String pieceName = lineName[i].getName();  //grabs the nagame.meCast of tag for each line

      if (pieceName.equals("basic")) {
      vh.setHealth(curse.getFloatAttribute("health"), curse.getFloatAttribute("fireHealth"));
      vh.setMinParts(curse.getIntAttribute("minParts"));
      vh.setExplodeMult(curse.getFloatAttribute("explosionMult"));
      vh.setScale(curse.getFloatAttribute("scale"));
      if (curse.getFloatAttribute("maxVelo") < 1) vh.setMaxVelo(1000.0);
      else vh.setMaxVelo(curse.getFloatAttribute("maxVelo"));
      vh.setName(src_);
    } 
    else if (pieceName.equals("forces")) {
      vh.setForces(curse.getFloatAttribute("xi"), curse.getFloatAttribute("yi"), curse.getFloatAttribute("xd"), curse.getFloatAttribute("yd"));
    } 
    else if (pieceName.equals("grapple")) {
      vh.setGrapple(curse.getFloatAttribute("x"), curse.getFloatAttribute("y"));
    } 
    else if (pieceName.equals("exits")) {
      vh.setExits(curse.getFloatAttribute("x1"), curse.getFloatAttribute("y1"), curse.getFloatAttribute("x2"), curse.getFloatAttribute("y2"));
    } 
    else if (pieceName.equals("part")) {
      vh.addPart(curse.getFloatAttribute("x"), curse.getFloatAttribute("y"), curse.getFloatAttribute("w"), curse.getFloatAttribute("h"), curse.getFloatAttribute("d"));
    } 
    else if (pieceName.equals("wheel")) {
      vh.addPart(curse.getFloatAttribute("x"), curse.getFloatAttribute("y"), curse.getFloatAttribute("r"), curse.getFloatAttribute("d"));
    } 
    else if (pieceName.equals("poly")) {
      vh.addPart(curse.getFloatAttribute("x1"), curse.getFloatAttribute("y1"), curse.getFloatAttribute("x2"), curse.getFloatAttribute("y2"), curse.getFloatAttribute("x3"), curse.getFloatAttribute("y3"), curse.getFloatAttribute("de"));
    } 
    else if (pieceName.equals("setPropellor")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setPropellor(true, curse.getFloatAttribute("xf"), curse.getFloatAttribute("yf"), curse.getFloatAttribute("lift"));
    } 
    else if (pieceName.equals("setMissile")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setMissile(true, curse.getFloatAttribute("x"), curse.getFloatAttribute("y"), curse.getFloatAttribute("strength"));
    } 
    else if (pieceName.equals("setCockpit")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setCockpit(true);
    } 
    else if (pieceName.equals("setFrame")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setFrame(true);
    } 
    else if (pieceName.equals("setWheel")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setWheel(true, curse.getFloatAttribute("xStrength"), curse.getFloatAttribute("rotateStrength"), curse.getFloatAttribute("rotateMax"));
    } 
    else if (pieceName.equals("setRotateByKeys")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setRotateByKeys(boolean(curse.getContent()));
    } 
    else if (pieceName.equals("setLandingGear")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setLandingGear(true);
    } 
    else if (pieceName.equals("setCollider")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setCollider(true);
    } 
    else if (pieceName.equals("setGun")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setGunPos(true, curse.getFloatAttribute("gunX"), curse.getFloatAttribute("gunY"));
      if (boolean(curse.getStringAttribute("custom"))) {
        ph.customGun = true;
        game.gunData = (Gun[]) append(game.gunData, loadIndividualGun(curse.getContent(), false));
        ph.setCustomGun(true, game.gunData.length-1);
      }
    } 
    else if (pieceName.equals("setHealth")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setHealth(curse.getFloatAttribute("startingHealth"), curse.getFloatAttribute("fireHealth"));
    } 
    else if (pieceName.equals("setCollideId")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setCollideId(int(curse.getContent()));
    } 
    else if (pieceName.equals("setImage")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.setImage(curse.getStringAttribute("src"), curse.getFloatAttribute("scale"));
    } 
    else if (pieceName.equals("addPoly")) {
      Vehicle.Part ph = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      ph.addPoly(curse.getFloatAttribute("x1"), curse.getFloatAttribute("y1"), curse.getFloatAttribute("z1"), curse.getFloatAttribute("x2"), curse.getFloatAttribute("y2"), curse.getFloatAttribute("z2"), curse.getFloatAttribute("x3"), curse.getFloatAttribute("y3"), curse.getFloatAttribute("z3"), curse.getIntAttribute("r"), curse.getIntAttribute("g"), curse.getIntAttribute("b"), curse.getIntAttribute("a"));
    } 
    else if (pieceName.equals("polycustomvertex")) {
      Vehicle.Part parth = (Vehicle.Part) vh.parts.get(curse.getIntAttribute("id"));
      Polygon ph = (Polygon) parth.polyData.get(curse.getIntAttribute("pId"));
      ph.setVColours(0, curse.getIntAttribute("r0"), curse.getIntAttribute("g0"), curse.getIntAttribute("b0"), curse.getIntAttribute("a0"));
      ph.setVColours(1, curse.getIntAttribute("r1"), curse.getIntAttribute("g1"), curse.getIntAttribute("b1"), curse.getIntAttribute("a1"));
      ph.setVColours(2, curse.getIntAttribute("r2"), curse.getIntAttribute("g2"), curse.getIntAttribute("b2"), curse.getIntAttribute("a2"));
    } 
    else if (pieceName.equals("connection")) {
      vh.addConnection(curse.getIntAttribute("type"), curse.getIntAttribute("p1"), curse.getIntAttribute("p2"));
    } 
    else if (pieceName.equals("joint")) {
      vh.addJoint(curse.getIntAttribute("cId"), curse.getFloatAttribute("x1"), curse.getFloatAttribute("y1"), curse.getFloatAttribute("x2"), curse.getFloatAttribute("y2"), curse.getFloatAttribute("freq"));
    } 
    else if (pieceName.equals("prismatic")) {
      vh.addJoint(curse.getIntAttribute("cId"), curse.getFloatAttribute("anchorX"), curse.getFloatAttribute("anchorY"), curse.getFloatAttribute("axisX"), curse.getFloatAttribute("axisY"), boolean(curse.getStringAttribute("limitTranslation")), curse.getFloatAttribute("lowerTranslation"), curse.getFloatAttribute("upperTranslation"));
    } 
    else if (pieceName.equals("revolute")) {
      vh.addJoint(curse.getIntAttribute("cId"), curse.getFloatAttribute("anchorX"), curse.getFloatAttribute("anchorY"), boolean(curse.getStringAttribute("limitTranslation")), curse.getFloatAttribute("lowerTranslation"), curse.getFloatAttribute("upperTranslation"), curse.getFloatAttribute("motorSpeed"), curse.getFloatAttribute("motorTorque"), boolean(curse.getStringAttribute("runningAlways")));
    }
  }
}

void loadMapRepo(String src) {
  XMLElement xmlMap = new XMLElement(this, sketchPath+"/maps/"+src);  //defines xml string loads map xml dat
  int lineCount = xmlMap.getChildCount();  //how many lines/types their are
  XMLElement[] lineName = xmlMap.getChildren();

  Gun[] tempGuns = null;

  String[] tempScriptSrc = new String[0];
  String[] tempScriptVer = new String[0];
  String tempScriptAdditional = "";

  //PARSE MAP TO CREATE OBJECTS AND POPULATE ARRAYLISTS
  for (int i=0; i < lineCount; i++) {  //runs through once for each poly
    XMLElement curse = xmlMap.getChild(i);
    String pieceName = lineName[i].getName();  //grabs the name of tag for each line

      if (pieceName.equals("worldData")) {
      initPhysics(curse.getFloatAttribute("width"), curse.getFloatAttribute("height"), curse.getFloatAttribute("gravityX"), curse.getFloatAttribute("gravityY"));
    } 
    else if (pieceName.equals("gunList")) {
      tempGuns = loadGuns(curse.getStringAttribute("src"));
    } 
    else if (pieceName.equals("mapData")) {
      loadMap(sketchPath+"/maps/data/"+curse.getStringAttribute("src"), curse.getFloatAttribute("xOffset"), curse.getFloatAttribute("yOffset"), curse.getFloatAttribute("scaleW"), curse.getFloatAttribute("scaleH"));
    } 
    else if (pieceName.equals("script")) {
      if (curse.getStringAttribute("src") != null && curse.getStringAttribute("version") != null) {
        tempScriptSrc = append(tempScriptSrc, curse.getStringAttribute("src"));
        tempScriptVer = append(tempScriptVer, curse.getStringAttribute("version"));
      } 
      else if (curse.getStringAttribute("src") != null || curse.getStringAttribute("version") != null) {
        System.err.println("Both 'src' and 'version' attributes need to be set when loading script");
      }
      if (curse.getContent() != null) tempScriptAdditional += curse.getContent();
    }
  }
  
  if (!playingOnline) {
    if (tempScriptSrc.length > 0) {
      println("Compiling ...");
      game.jython = new JyInt(tempScriptSrc, tempScriptVer);
    }

    if (!tempScriptAdditional.equals("")) {
      if (game.jython == null) game.jython = new JyInt(tempScriptSrc, tempScriptVer);
      game.jython.interp.exec(tempScriptAdditional);
    }
  } 
  else {
    println("Script Ignored");
  }
  
  if(game.gunData == null)  game.setGuns(loadGuns("list1.xml"));
  if(game.ragdollData == null) loadRagdoll("test");
  game.mapLoaded = true;
  if(game.mapBounds == null) game.mapBounds = game.calcMapBounds();
  if(game.soldierData == null) {
    Spawn meTempSpawn = game.getSoldierSpawn();
    game.soldierData.add(new Soldier(meTempSpawn.x, meTempSpawn.y));
    game.meCast = (Soldier) game.soldierData.get(game.soldierData.size()-1);
    game.meCast.setMe(true);
    game.meCast.respawn(meTempSpawn.x, meTempSpawn.y);
  }
  
  playing = true;

  if (game != null) {
    if (tempGuns != null) game.setGuns(tempGuns);
    loadRagdoll("test");
    game.mapLoaded = true;
    game.mapBounds = game.calcMapBounds();
  }
  
  if(settings.drawMinimap) {
    
    NodeMap nm = new NodeMap(width-200, 200, 200/mapW, 200/mapH);
    game.hud.minimap = nm.loadFromCurrent();
  }
  
  Spawn meTempSpawn = game.getSoldierSpawn();
  game.soldierData.add(new Soldier(meTempSpawn.x, meTempSpawn.y));
  game.meCast = (Soldier) game.soldierData.get(game.soldierData.size()-1);
  game.meCast.setMe(true);
  game.meCast.respawn(meTempSpawn.x, meTempSpawn.y);
}

void loadMap(String src, float xOff, float yOff, float scaleW, float scaleH) {
  int curPolyId = game.polyData.size();

  String[] delimet = split(src, '.');
  if (delimet[delimet.length-1].equals("xml") || delimet[delimet.length-1].equals("Xml") || delimet[delimet.length-1].equals("XML")) loadXMLMap(src, xOff, yOff, scaleW, scaleH);
  else if (delimet[delimet.length-1].equals("pms") || delimet[delimet.length-1].equals("Pms") || delimet[delimet.length-1].equals("PMS")) loadPMSMap(src, xOff, yOff, scaleW, scaleH);

  if (game.mapTextureGL.length > 0) {
    for (int i=curPolyId; i<game.polyData.size(); i++) {
      Polygon ph = (Polygon) game.polyData.get(i);
      ph.setTextureId(game.mapTextureGL.length-1);
    }
  }
}

void loadXMLMap(String src, float xOff, float yOff, float scaleW, float scaleH) {
  XMLElement xmlMap = new XMLElement(this, src);  //defines xml string loads map xml data
  int lineCount = xmlMap.getChildCount();  //how many lines/types their are
  XMLElement[] lineName = xmlMap.getChildren();
  //PARSE MAP TO CREATE OBJECTS AND POPULATE ARRAYLISTS

  int previousPolyCount = game.polyData.size();
  int previousSceneryCount = game.sceneryData.size();

  for (int i=0; i < lineCount; i++) {  //runs through once for each poly
    XMLElement curse = xmlMap.getChild(i);
    String pieceName = lineName[i].getName();  //grabs the name of tag for each line

      if (pieceName.equals("mapdata")) {
      game.setBGColors(curse.getIntAttribute("bgR"), curse.getIntAttribute("bgG"), curse.getIntAttribute("bgB"), curse.getIntAttribute("bg2R"), curse.getIntAttribute("bg2G"), curse.getIntAttribute("bg2B"));
      game.addMapData(curse.getContent(), 5, 5, 5, 200);
    } 
    else if (pieceName.equals("force2d")) {
      println("Force 2d");
      game.force2d = true;
    } 
    else if (pieceName.equals("texture")) {
      game.mapTextureGL = append(game.mapTextureGL, loadMapTexture(curse.getContent()));
    } 
    else if (pieceName.equals("leveldata")) {
      game.addLevelData(curse.getStringAttribute("name"), curse.getStringAttribute("summary"));
    } 
    else if (pieceName.equals("gunlist")) {
      game.setGuns(curse.getStringAttribute("src"));
    } 
    else if (pieceName.equals("vehicle")) {
      loadVehicle(curse.getStringAttribute("src"));
    } 
    else if (pieceName.equals("poly")) {
      game.addPoly(curse.getIntAttribute("type"), xOff+(curse.getFloatAttribute("x1")*scaleW), yOff+(curse.getFloatAttribute("y1")*scaleH), xOff+(curse.getFloatAttribute("x2")*scaleW), yOff+(curse.getFloatAttribute("y2")*scaleH), xOff+(curse.getFloatAttribute("x3")*scaleW), yOff+(curse.getFloatAttribute("y3")*scaleH), curse.getFloatAttribute("de"), curse.getFloatAttribute("re"), curse.getFloatAttribute("fr"), curse.getIntAttribute("r"), curse.getIntAttribute("g"), curse.getIntAttribute("b"), curse.getIntAttribute("a"));
    } 
    else if (pieceName.equals("polycustomvertex")) {
      Polygon ph = (Polygon) game.polyData.get(previousPolyCount+curse.getIntAttribute("id"));
      ph.setTextureId(curse.getIntAttribute("textureId"));
      ph.setVColours(0, curse.getIntAttribute("r0"), curse.getIntAttribute("g0"), curse.getIntAttribute("b0"), curse.getIntAttribute("a0"));
      ph.setVColours(1, curse.getIntAttribute("r1"), curse.getIntAttribute("g1"), curse.getIntAttribute("b1"), curse.getIntAttribute("a1"));
      ph.setVColours(2, curse.getIntAttribute("r2"), curse.getIntAttribute("g2"), curse.getIntAttribute("b2"), curse.getIntAttribute("a2"));
      ph.setUV(curse.getFloatAttribute("u0"), curse.getFloatAttribute("v0"), curse.getFloatAttribute("u1"), curse.getFloatAttribute("v1"), curse.getFloatAttribute("u2"), curse.getFloatAttribute("v2"));
      ph.setRHW(curse.getFloatAttribute("rhw0"), curse.getFloatAttribute("rhw1"), curse.getFloatAttribute("rhw2"));
    } 
    else if (pieceName.equals("earth")) {
      game.addEarth(xOff+(curse.getFloatAttribute("x"))*scaleW, yOff+(curse.getFloatAttribute("y")*scaleH), curse.getFloatAttribute("radius"), curse.getFloatAttribute("gravity"), curse.getFloatAttribute("distance"), curse.getFloatAttribute("size"), curse.getIntAttribute("detail"));
    } 
    else if (pieceName.equals("spawn")) {
      game.spawnData.add(new Spawn(xOff+(curse.getFloatAttribute("x")*scaleW), yOff+(curse.getFloatAttribute("y")*scaleH), curse.getIntAttribute("type"), curse.getIntAttribute("subType"), curse.getIntAttribute("amount")));
    } 
    else if (pieceName.equals("spawnonearth")) {
      Spawn ph = (Spawn) game.spawnData.get(curse.getIntAttribute("id"));
      ph.setEarth(curse.getIntAttribute("id"), curse.getFloatAttribute("distance"));
    } 
    else if (pieceName.equals("spawninvehicle")) {
      Spawn sh = (Spawn) game.spawnData.get(curse.getIntAttribute("spawnid"));
      sh.setSpawnInVehicle(true, curse.getIntAttribute("type"));
    } 
    else if (pieceName.equals("spawnwithattachment")) {
      Spawn sh = (Spawn) game.spawnData.get(curse.getIntAttribute("spawnid"));
      sh.setSpawnWithAttachment(true, curse.getIntAttribute("type"), curse.getIntAttribute("amount"), curse.getIntAttribute("amount2"));
    } 
    else if (pieceName.equals("astar")) {
      game.addPathfinder(int(xOff+(curse.getIntAttribute("x")*scaleW)), int(yOff+(curse.getIntAttribute("y")*scaleH)), int(curse.getIntAttribute("w")*scaleW), int(curse.getIntAttribute("h")*scaleH), curse.getIntAttribute("rows"), curse.getIntAttribute("cols"), curse.getContent(), boolean(curse.getStringAttribute("draw")));
    } 
    else if ((pieceName.equals("scenery")) && (settings.drawScenery || mainMenu)) {
      game.sceneryData.add(new Scenery(curse.getStringAttribute("src"), xOff+(curse.getFloatAttribute("x")*scaleW), yOff+(curse.getFloatAttribute("y")*scaleH), curse.getFloatAttribute("z"), curse.getFloatAttribute("w")*scaleW, curse.getFloatAttribute("h")*scaleH, curse.getFloatAttribute("rotate")));
      Scenery ph = (Scenery) game.sceneryData.get(game.sceneryData.size()-1);
      ph.setColours(curse.getIntAttribute("r"), curse.getIntAttribute("g"), curse.getIntAttribute("b"), curse.getIntAttribute("a"));
    } 
    else if ((pieceName.equals("scenerycustomvertex")) && (settings.drawScenery || mainMenu)) {
      Scenery sh = (Scenery) game.sceneryData.get(previousSceneryCount+curse.getIntAttribute("id"));
      sh.setVColours(0, curse.getIntAttribute("r0"), curse.getIntAttribute("g0"), curse.getIntAttribute("b0"), curse.getIntAttribute("a0"));
      sh.setVColours(1, curse.getIntAttribute("r1"), curse.getIntAttribute("g1"), curse.getIntAttribute("b1"), curse.getIntAttribute("a1"));
      sh.setVColours(2, curse.getIntAttribute("r2"), curse.getIntAttribute("g2"), curse.getIntAttribute("b2"), curse.getIntAttribute("a2"));
      sh.setVColours(3, curse.getIntAttribute("r3"), curse.getIntAttribute("g3"), curse.getIntAttribute("b3"), curse.getIntAttribute("a3"));
      sh.setDepth(0, curse.getFloatAttribute("z0"));
      sh.setDepth(1, curse.getFloatAttribute("z1"));
      sh.setDepth(2, curse.getFloatAttribute("z2"));
      sh.setDepth(3, curse.getFloatAttribute("z3"));
    }
  }
}

void loadPMSMap(String src, float xOff, float yOff, float scaleW, float scaleH) {
  println(src);
  Map smap = new Map(src);
  String[] allScenery = smap.getAllSceneryNames();
  PMS_Polygon[] allPolys = smap.getAllPolys();
  PMS_Spawn[] allSpawns = smap.getAllSpawns();
  PMS_Prop[] allProps = smap.getAllProps();

  game.setBGColors(smap.getTopColor().getColor().getRed(), smap.getTopColor().getColor().getGreen(), smap.getTopColor().getColor().getBlue(), smap.getBottomColor().getColor().getRed(), smap.getBottomColor().getColor().getGreen(), smap.getBottomColor().getColor().getBlue());
  game.addMapData(smap.getTitle(), smap.getMedKits(), smap.getGrenades(), 5, int(smap.getJets()/2*1.34));
  game.force2d = true;
  game.mapTextureGL = append(game.mapTextureGL, loadMapTexture(smap.getTexture()));
  game.addLevelData(smap.getTitle(), "Read using iDante's PMS Parser");

  for (int i=0; i < allPolys.length; i++) {
    PMS_Polygon ph = (PMS_Polygon) allPolys[i];

    PMS_Vertex ph1 = (PMS_Vertex) ph.getVertex(0);
    PMS_Vertex ph2 = (PMS_Vertex) ph.getVertex(1);
    PMS_Vertex ph3 = (PMS_Vertex) ph.getVertex(2);

    PMS_Color ch1 = (PMS_Color) ph1.getPMS_Color();
    PMS_Color ch2 = (PMS_Color) ph2.getPMS_Color();
    PMS_Color ch3 = (PMS_Color) ph3.getPMS_Color();

    if (ph.getPolyType() == 4) game.addPoly(ph.getPolyType(), xOff+(ph1.getX()*scaleW), yOff+(ph1.getY()*scaleH), xOff+(ph2.getX()*scaleW), yOff+(ph2.getY()*scaleH), xOff+(ph3.getX()*scaleW), yOff+(ph3.getY()*scaleH), 0, 0.1, 0, 0, 0, 0, 255);
    else game.addPoly(ph.getPolyType(), xOff+(ph1.getX()*scaleW), yOff+(ph1.getY()*scaleH), xOff+(ph2.getX()*scaleW), yOff+(ph2.getY()*scaleH), xOff+(ph3.getX()*scaleW), yOff+(ph3.getY()*scaleH), 0, 0.1, 0.5, 0, 0, 0, 255);

    //TRANSPARANCY FIX
    int[] alphaTrans = new int[3];
    alphaTrans[0] = int(ch1.getColor().getAlpha());
    alphaTrans[1] = int(ch2.getColor().getAlpha());
    alphaTrans[2] = int(ch3.getColor().getAlpha());
    //for(int t=0; t<alphaTrans.length; t++) if(alphaTrans[t] == 0) alphaTrans[t] = 255;



    Polygon sh = (Polygon) game.polyData.get(game.polyData.size()-1);
    sh.setVColours(0, ch1.getColor().getRed(), ch1.getColor().getGreen(), ch1.getColor().getBlue(), ch1.getColor().getAlpha());
    sh.setVColours(1, ch2.getColor().getRed(), ch2.getColor().getGreen(), ch2.getColor().getBlue(), ch2.getColor().getAlpha());
    sh.setVColours(2, ch3.getColor().getRed(), ch3.getColor().getGreen(), ch3.getColor().getBlue(), ch3.getColor().getAlpha());
    sh.setUV(ph1.getTU(), -ph1.getTV(), ph2.getTU(), -ph2.getTV(), ph3.getTU(), -ph3.getTV());
    sh.setRHW(ph1.getRHW(), ph2.getRHW(), ph3.getRHW());
    
  }

  for (int i=0; i<allProps.length; i++) {
    PMS_Prop ph = (PMS_Prop) allProps[i];
    PMS_Color ch = (PMS_Color) ph.getPMS_Color();

    float realSceneryDepth = 0;
    switch(ph.getDrawBehind()) {
    case 0: 
      realSceneryDepth = -1.0;
      break;
    case 1: 
      realSceneryDepth = 0.9;
      break;
    case 2: 
      realSceneryDepth =  1.1;
      break;

    default: 
      realSceneryDepth = 666;
      break;
    }
    int scenAlpha = constrain(ph.getAlpha()+128, 0, 255);
    if(ph.getAlpha() == -1) scenAlpha = 255;

    game.sceneryData.add(new Scenery(allScenery[ph.getPropStyle()-1], xOff+(ph.getX()*scaleW), yOff+(ph.getY()*scaleH), realSceneryDepth, ph.getScaleX()*ph.getWidth()*scaleW, ph.getScaleY()*ph.getHeight()*scaleH, ph.getRotation()));
    Scenery sh = (Scenery) game.sceneryData.get(game.sceneryData.size()-1);
    sh.setColours(ch.getColor().getRed(), ch.getColor().getGreen(), ch.getColor().getBlue(), 255);
  }

  boolean hasStatguns = false;
  for (int i=0; i < allSpawns.length; i++) {  //CHECK FOR STATGUNS
    PMS_Spawn ph = (PMS_Spawn) allSpawns[i];
    if (ph.getSpawnType() == 16) {
      hasStatguns = true;
      loadVehicle("statgun.xml");
      break;
    }
  }

  for (int i=0; i < allSpawns.length; i++) {
    PMS_Spawn ph = (PMS_Spawn) allSpawns[i];
    int realSpawnType = 0;
    switch(ph.getSpawnType()) {
    case 0: 
      realSpawnType = 0;
      break;
    case 1: 
      realSpawnType = 0;
      break;
    case 2: 
      realSpawnType = 6;
      break;
    case 3: 
      realSpawnType = 6;
      break;
    case 4: 
      realSpawnType = 6;
      break;
    case 8: 
      realSpawnType = 2;
      break;
    case 16: 
      realSpawnType = 10;
      break;
    default: 
      realSpawnType = -1;
      break;
    }
    if (realSpawnType == 0 || realSpawnType == 6) {  //MYSELF OF SOLDIER
      game.spawnData.add(new Spawn(xOff+(ph.getX()*scaleW), yOff+(ph.getY()*scaleH), realSpawnType, ph.getSpawnType(), 0));
    } 
    else if (realSpawnType == 2) {  //HEALTHPACK
      game.spawnData.add(new Spawn(xOff+(ph.getX()*scaleW), yOff+(ph.getY()*scaleH), realSpawnType, 0, 100));
    } 
    else if (realSpawnType == 10) {  //STATGUN
      game.spawnData.add(new Spawn(xOff+(ph.getX()*scaleW), yOff+(ph.getY()*scaleH), 5, 0, 0));
    } 
    else if (ph.getSpawnType() == 5 || ph.getSpawnType() == 6) {
      int flagTeam = 0;
      if (ph.getSpawnType() == 5) flagTeam = 0;
      if (ph.getSpawnType() == 6) flagTeam = 1;
      game.spawnData.add(new Spawn(xOff+(ph.getX()*scaleW), yOff+(ph.getY()*scaleH), 8, flagTeam, 0));
    }
  }
}

int loadTextureGL(String src, boolean wrap) {
  pgl = (PGraphicsOpenGL) g;
  GL gl = (GL) pgl.beginGL();
  game.glu = new GLU();

  gl.glClearColor(0.0, 0.0, 0.0, 0.0);
  gl.glColor3f(0.0, 0.0, 1.0);
  gl.glMatrixMode(GL.GL_MODELVIEW);
  gl.glLoadIdentity();
  if (settings.antialiasing) gl.glEnable(GL.GL_SMOOTH);
  gl.glEnable(GL.GL_BLEND);
  gl.glEnable(GL.GL_TEXTURE_2D);
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);

  int mtgl = game.mapTextureGL.length+game.sceneryTextureGL.length;

  PImage mapTexture = null;
  ByteBuffer byteBuffer = null;
  try {
    //println(sketchPath+"/"+src);

    mapTexture = maskGreen(loadImage(sketchPath+"/"+src));
    mapTexture.loadPixels();
    byteBuffer = ByteBuffer.allocate(mapTexture.width*mapTexture.height*4);
    
    for(int i=0; i<mapTexture.width*mapTexture.height; i++) {
       mapTexture.pixels[i] = (mapTexture.pixels[i] << 8) | (mapTexture.pixels[i] >>> (32-8));
    }

    IntBuffer intBuffer = byteBuffer.asIntBuffer();
    intBuffer.put(mapTexture.pixels);
  } 
  catch(Exception e) {
    e.printStackTrace();
    exit();
  }

  int[] tmpT = new int[1];
  tmpT[0] = mtgl;

  gl.glGenTextures(1, tmpT, 0);
  gl.glBindTexture(GL.GL_TEXTURE_2D, mtgl);
  gl.glTexEnvf(GL.GL_TEXTURE_ENV, GL.GL_TEXTURE_ENV_MODE, GL.GL_MODULATE);

  if (settings.textureMagNearest) {
    gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST);
    gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST);
  } 
  else {
    gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR);
    gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR);
  }
  gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT);
  gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT);

  if (settings.anisotropic && gl.isExtensionAvailable("GL_EXT_texture_filter_anisotropic") ) {
    float max[] = new float[1];
    gl.glGetFloatv(GL.GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, max, 0);
    gl.glTexParameterf(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAX_ANISOTROPY_EXT, max[0]);
  }

  try {
    game.glu.gluBuild2DMipmaps(GL.GL_TEXTURE_2D, GL.GL_RGBA, mapTexture.width, mapTexture.height, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, byteBuffer);
  } 
  catch(GLException e) {
    System.err.println("Textures failed to bind");
  } 
  catch(BufferUnderflowException e) {
    System.err.println("Textures failed to bind due to underflow");
  }
  pgl.endGL();

  return mtgl;
}

int loadSceneryTexture(String src) {
  src = getCorrectSceneryName(src);
  File f = new File(sketchPath+"/scenery/"+src);
  
  if (f.exists()) {
    return loadTextureGL("scenery/"+src, false);
  } 
  else {  //WORK AROUND FOR LINUX BUG WHERE IT EXISTS BUT .EXISTS RETURNS FALSE  
    PImage img = null;
    try {
      img = loadImage("scenery/"+src);
    } 
    catch(NullPointerException e) {
      System.err.println(sketchPath+"/scenery/"+src+" is MISSING");
      return 0;
    }

    if (img == null) return 0;
    else return loadTextureGL("scenery/"+src, false);
  }
}

int loadMapTexture(String src) {
  game.textureMap = true;
  game.force2d = true;

  File f = new File(sketchPath+"/textures/"+src);

  if (f.exists()) {
    return loadTextureGL("textures/"+src, false);
  } 
  else {  //WORK AROUND FOR LINUX BUG WHERE IT EXISTS BUT .EXISTS RETURNS FALSE  
    PImage img = null;
    try {
      img = loadImage("textures/"+src);
    } 
    catch(NullPointerException e) {
      System.err.println(sketchPath+"/textures/"+src+" is MISSING");
      return 0;
    }

    if (img == null) {
      if(game.mapTextureGL.length == 0) game.textureMap = false;
      return 0;
    } 
    else {
      return loadTextureGL("textures/"+src, false);
    }
  }
}

String[] loadSceneryList() {
  File dir = new File(sketchPath+"/scenery");
  return dir.list();
}

//THIS IS CALLED WHEN MAP FILES ARE DROPPED ONTO GAME
void dropEvent(DropEvent theDropEvent) {
  String path = null;
  String[] delimet = null;  

  game.paused = true;
  clearAllEngineData();

  if (theDropEvent.isFile()) {
    path = theDropEvent.filePath();
    delimet = split(path, '.');
  } 
  else if (theDropEvent.isURL()) {
    String[] sp = split(theDropEvent.url(), "file://");
    path = sp[sp.length-1];
    delimet = split(path, '.');
  }

  if (path != null) {
    if (delimet[delimet.length-1].equals("xml") || delimet[delimet.length-1].equals("Xml") || delimet[delimet.length-1].equals("XML") || delimet[delimet.length-1].equals("pms") || delimet[delimet.length-1].equals("Pms") || delimet[delimet.length-1].equals("PMS")) {
      //String[] shortFilePath = split(theDropEvent.url(), "/");
      int[] idata = new int[0];
      String[] sdata = new String[1];
      //sdata[0] = shortFilePath[shortFilePath.length-1];
      sdata[0] = path;
      addGameCom(-3, idata, sdata);
    } 
    else {
      System.err.println("Filetype not recognized (xml, Xml, XML, pms, Pms, PMS");
    }
  } 
  else {
    System.err.println("Incorrect file type");
  }
}

/*
Soldat PMS Parser by iDante
 Use and abuse it however you want, just leave this here.
 
 I'll just go ahead and define the other classes I use here as well as this one:
 
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 Map
 	String getTitle()
 	String getTexture()
 	PMS_Color getTopColor()
 	PMS_Color getBottomColor()
 	int getJets()
 	int getGrenades()
 	int getMedKits()
 	int getWeather()
 	int getStepType()
 	
 	int getPolyCount()
 	PMS_Polygon getPoly(int)
 	PMS_Polygon[] getAllPolys()
 	
 	int getPropCount()
 	PMS_Prop getProp(int)
 	PMS_Prop[] getAllProps()
 	
 	int getSceneryCount()
 	String getSceneryName(int)
 	String[] getAllSceneryNames()
 	int getDOSTime(int i)
 	int[] getAllDOSTime()
 	int getDOSDate(int i)
 	int[] getAllDOSDate()
 	
 	int getColliderCount()
 	PMS_Collider getCollider(int)
 	PMS_Collider[] getAllColliders()
 	
 	int getSpawnCount()
 	PMS_Spawn getSpawn(int i)
 	PMS_Spawn[] getAllSpawns()
 	
 	int getWayPointCount()
 	PMS_Waypoint getWayPoint(int)
 	PMS_Waypoint[] getAllWayPoints()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Color
 	Color getColor()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Collider
 	boolean getActive()
 	float getX()
 	float getY()
 	float getRadius()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Prop
 	boolean getActive()
 	int getPropStyle()
 	int getWidth()
 	int getHeight()
 	float getX()
 	float getY()
 	float getRotation()
 	float getScaleX()
 	float getScaleY()
 	int getAlpha()
 	PMS_Color getPMS_Color()
 	int getDrawBehind()
 	String getDrawBehindString()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Vertex
 	float getX()
 	float getY()
 	float getZ()
 	float getRHW()
 	PMS_Color getPMS_Color();
 	float getTU()
 	float getTV()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Vector
 	float getX()
 	float getY()
 	float getZ()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Polygon
 	PMS_Vertex getVertex(int)
 	PMS_Vector getPerp(int)
 	int getPolyType()
 	String getPolyTypeString()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Spawn
 	boolean getActive()
 	int getX()
 	int getY()
 	int getSpawnType()
 	String getSpawnTypeString()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 PMS_Waypoint
 	boolean getActive()
 	int getX()
 	int getY()
 	int getID()
 	boolean getLeft()
 	boolean getRight()
 	boolean getUp()
 	boolean getDown()
 	boolean getJet()
 	int getPath()
 	int getSpecialAction()
 	String getSpecialActionString()
 	int getC2()
 	int getC3()
 	int getNumConnections()
 //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
 
 	
 */

import java.io.*;
import java.nio.*;
public class Map {

  // Options
  private String Title = ""; // The short description of the map.
  private String Texture = "";
  private PMS_Color TopColor;
  private PMS_Color BottomColor;
  private int Jets;
  private int Grenades;
  private int MedKits;
  private int Weather; // 0=None, 1=Rain, 2=Sandstorm, 3=Snow
  private int StepType; // 0=Hard,1=Soft,2=None

    public String getTitle() { 
    return Title;
  }
  public String getTexture() { 
    return Texture;
  }
  public PMS_Color getTopColor() { 
    return TopColor;
  }
  public PMS_Color getBottomColor() { 
    return BottomColor;
  }
  public int getJets() { 
    return Jets;
  }
  public int getGrenades() { 
    return Grenades;
  }
  public int getMedKits() { 
    return MedKits;
  }
  public int getWeather() { 
    return Weather;
  }
  public int getStepType() { 
    return StepType;
  }

  // Poly Data
  private int PolyCount;
  private PMS_Polygon[] Polys;

  public int getPolyCount() { 
    return PolyCount;
  }
  public PMS_Polygon getPoly(int i) { 
    return Polys[i];
  }
  public PMS_Polygon[] getAllPolys() { 
    return Polys;
  }

  // Prop Data
  private int PropCount;
  private PMS_Prop[] Props;

  public int getPropCount() { 
    return PropCount;
  }
  public PMS_Prop getProp(int i) { 
    return Props[i];
  }
  public PMS_Prop[] getAllProps() { 
    return Props;
  }

  // Scenery
  private int SceneryCount;
  private String[] SceneryNames;
  private int[] DOSTime;
  private int[] DOSDate;

  public int getSceneryCount() { 
    return SceneryCount;
  }
  public String getSceneryName(int i) { 
    return SceneryNames[i];
  }
  public String[] getAllSceneryNames() { 
    return SceneryNames;
  }
  public int getDOSTime(int i) { 
    return DOSTime[i];
  }
  public int[] getAllDOSTime() { 
    return DOSTime;
  }
  public int getDOSDate(int i) { 
    return DOSDate[i];
  }
  public int[] getAllDOSDate() { 
    return DOSDate;
  }

  // Collider
  private int ColliderCount;
  private PMS_Collider[] Colliders;

  public int getColliderCount() { 
    return ColliderCount;
  }
  public PMS_Collider getCollider(int i) { 
    return Colliders[i];
  }
  public PMS_Collider[] getAllColliders() { 
    return Colliders;
  }

  // SpawnPoints
  private int SpawnpointCount;
  private PMS_Spawn[] Spawns;

  public int getSpawnCount() { 
    return SpawnpointCount;
  }
  public PMS_Spawn getSpawn(int i) { 
    return Spawns[i];
  }
  public PMS_Spawn[] getAllSpawns() { 
    return Spawns;
  }

  // Waypoints
  private int WayPointCount;
  private PMS_Waypoint[] wpts;

  public int getWayPointCount() { 
    return WayPointCount;
  }
  public PMS_Waypoint getWayPoint(int i) { 
    return wpts[i];
  }
  public PMS_Waypoint[] getAllWayPoints() { 
    return wpts;
  }

  // Non-important fields
  private int SceneryLength;
  private int TitleLength;
  private int TextureLength;
  private int SectorCount;
  private int SectorPolyCount;

  // Constructors
  public Map(String Path) {
    this(new File(Path));
  }
  public Map(File map) {
    try {
      ByteBuffer buf = ByteBuffer.wrap(getBytesFromFile(map));
      buf.order(ByteOrder.LITTLE_ENDIAN);
      this.read(buf);
    } 
    catch(IOException e) {
      System.err.println(e);
    }
  }

  private void read(ByteBuffer reader) throws IOException {
    reader.getInt();

    // TitleLength and Title
    this.TitleLength = reader.get();
    for (int i=0;i<this.TitleLength;i++) {
      this.Title = this.Title + (char)reader.get();
    }
    for (int i=0;i<38-this.TitleLength;i++) {
      reader.get(); // Padding
    }

    // TextureLength and Texture
    TextureLength = reader.get();
    for (int i=0;i<this.TextureLength;i++) {
      this.Texture = this.Texture + (char)reader.get();
    }
    for (int i=0;i<24-this.TextureLength;i++) {
      reader.get(); // Padding
    }

    // Top and bottom colors
    this.TopColor = new PMS_Color(reader.get(), reader.get(), reader.get(), reader.get());
    this.BottomColor = new PMS_Color(reader.get(), reader.get(), reader.get(), reader.get());		

    this.Jets = reader.getInt();
    this.Grenades = reader.get();
    this.MedKits = reader.get();
    this.Weather = reader.get();
    this.StepType = reader.get();

    // Random ID, evidently used to be used to check for wrong map version, now useless
    reader.getInt();

    this.PolyCount = reader.getInt();
    this.Polys = new PMS_Polygon[this.PolyCount];
    // Read the polygons
    for (int i=0;i<this.PolyCount;i++) {
      PMS_Vertex[] TVert = new PMS_Vertex[3];
      PMS_Vector[] TVect = new PMS_Vector[3];
      TVert[0] = new PMS_Vertex(reader.getFloat(), reader.getFloat(), reader.getFloat(), reader.getFloat(), new PMS_Color(reader.get(), reader.get(), reader.get(), reader.get()), reader.getFloat(), reader.getFloat());
      TVert[1] = new PMS_Vertex(reader.getFloat(), reader.getFloat(), reader.getFloat(), reader.getFloat(), new PMS_Color(reader.get(), reader.get(), reader.get(), reader.get()), reader.getFloat(), reader.getFloat());
      TVert[2] = new PMS_Vertex(reader.getFloat(), reader.getFloat(), reader.getFloat(), reader.getFloat(), new PMS_Color(reader.get(), reader.get(), reader.get(), reader.get()), reader.getFloat(), reader.getFloat());
      TVect[0] = new PMS_Vector(reader.getFloat(), reader.getFloat(), reader.getFloat());
      TVect[1] = new PMS_Vector(reader.getFloat(), reader.getFloat(), reader.getFloat());
      TVect[2] = new PMS_Vector(reader.getFloat(), reader.getFloat(), reader.getFloat());
      this.Polys[i] = new PMS_Polygon(TVert, TVect, reader.get());
    }

    reader.getInt(); // Padding

    // SectorCount
    this.SectorCount = reader.getInt();
    // Each Individual Sector
    for (int i=0;i<((SectorCount*2)+1)*((SectorCount*2)+1);i++) {
      this.SectorPolyCount = reader.getShort();
      if (this.SectorPolyCount > 0) {
        for (int p=0;p<this.SectorPolyCount;p++) {
          // Save this to an array if you need it.
          reader.getShort();
        }
      }
    }

    // Prop Count
    this.PropCount = reader.getInt();
    this.Props = new PMS_Prop[this.PropCount];

    for (int i=0;i<this.PropCount;i++) {

      this.Props[i] = new PMS_Prop(reader.get(), reader.get(), reader.getShort(), reader.getInt(), reader.getInt(), reader.getFloat(), reader.getFloat(), reader.getFloat(), reader.getFloat(), reader.getFloat(), reader.get(), reader.getShort()+reader.get(), new PMS_Color(reader.get(), reader.get(), reader.get(), reader.get()), reader.get());
      reader.getShort();
      reader.get();
    }

    // Scenerys
    this.SceneryCount = reader.getInt();

    SceneryNames = new String[this.SceneryCount];
    DOSTime = new int[this.SceneryCount];
    DOSDate = new int[this.SceneryCount];

    for (int i=0;i<this.SceneryCount;i++) {
      this.SceneryNames[i] = "";
      this.SceneryLength = (int)reader.get();
      for (int p=0;p<this.SceneryLength;p++) {
        this.SceneryNames[i] = this.SceneryNames[i] + (char)reader.get();
      }
      for (int p=0;p<50-this.SceneryLength;p++) {
        reader.get();
      }
      // I still don't know what this is for. Best just leave it.
      DOSTime[i] = reader.getShort();
      DOSDate[i] = reader.getShort();
    }

    // Colliders... One knows the drill...
    this.ColliderCount = reader.getInt();
    Colliders = new PMS_Collider[this.ColliderCount];

    for (int i=0;i<this.ColliderCount;i++) {

      Colliders[i] = new PMS_Collider(reader.get(), reader.getShort()+reader.get(), reader.getFloat(), reader.getFloat(), reader.getFloat());
    }

    // Spawnpoints...
    this.SpawnpointCount = reader.getInt();
    Spawns = new PMS_Spawn[this.SpawnpointCount];

    for (int i=0;i<this.SpawnpointCount;i++) {

      Spawns[i] = new PMS_Spawn(reader.get(), reader.getShort()+reader.get(), reader.getInt(), reader.getInt(), reader.get());
      reader.getShort();
      reader.get();
    }

    // Waypoints
    this.WayPointCount = reader.getInt();
    this.wpts = new PMS_Waypoint[this.WayPointCount];
    for (int i=0;i<this.WayPointCount;i++) {

      wpts[i] = new PMS_Waypoint(reader.get(), reader.getShort()+reader.get(), reader.getInt(), reader.getInt(), reader.getInt(), reader.get(), reader.get(), reader.get(), reader.get(), reader.get(), reader.get(), reader.get(), reader.get(), reader.get(), reader.getShort()+reader.get(), reader.getInt());
      for (int p=0;p<20;p++) {
        // Connections. Save to an array if you need
        reader.getInt();
      }
    }
  }

  // I didn't actually write this function. The author didn't give any
  // 	info as to liscensing, so... to be safe heres the URL
  //		http://www.exampledepot.com/egs/java.io/File2ByteArray.html
  // Returns the contents of the file in a byte array.
  public byte[] getBytesFromFile(File file) throws IOException {
    InputStream is = new FileInputStream(file);

    // Get the size of the file
    long length = file.length();

    if (length > Integer.MAX_VALUE) {
      System.out.println("File too large");
    }

    // Create the byte array to hold the data
    byte[] bytes = new byte[(int)length];

    int offset = 0;
    int numRead = 0;
    while (offset < bytes.length
      && (numRead=is.read(bytes, offset, bytes.length-offset)) >= 0) {
      offset += numRead;
    }
    is.close();
    return bytes;
  }
}

public class PMS_Collider {

  private boolean Active;
  private float x;
  private float y;
  private float radius;

  public PMS_Collider(int Active, int filler, float x, float y, float radius) {
    this.Active = Active == 0 ? false : true;
    this.x = x;
    this.y = y;
    this.radius = radius;
  }

  public boolean getActive() { 
    return Active;
  }
  public float getX() { 
    return x;
  }
  public float getY() { 
    return y;
  }
  public float getRadius() { 
    return radius;
  }
}

import java.awt.Color;
public class PMS_Color {

  private int r;
  private int g;
  private int b;
  private int a;

  public PMS_Color(int b, int g, int r, int a) {
    this.r = unSign(r);
    this.g = unSign(g);
    this.b = unSign(b);
    this.a = unSign(a);
  }

  public Color getColor() {
    return new Color(r, g, b, a);
  }

  private int unSign(int i) {
    if (i<0) {
      i += 256;
    }
    return i;
  }
}

public class PMS_Polygon {
  PMS_Vertex[] vert;
  PMS_Vector[] perpendicular;
  int PolyType;
  String PolyTypeString;

  public PMS_Polygon(PMS_Vertex[] vert, PMS_Vector[] perpendicular, int PolyType) {
    this.vert = vert;
    this.perpendicular = perpendicular;
    this.PolyType = PolyType;

    switch(PolyType) {
    case 0: 
      this.PolyTypeString = "Normal";
      break;
    case 1: 
      this.PolyTypeString = "Only Bullets Collide";
      break;
    case 2: 
      this.PolyTypeString = "Only Players Collide";
      break;
    case 3: 
      this.PolyTypeString = "No Collide";
      break;
    case 4: 
      this.PolyTypeString = "Ice";
      break;
    case 5: 
      this.PolyTypeString = "Deadly";
      break;
    case 6: 
      this.PolyTypeString = "Bloody Deadly";
      break;
    case 7: 
      this.PolyTypeString = "Hurts";
      break;
    case 8: 
      this.PolyTypeString = "Regenerates";
      break;
    default: 
      this.PolyTypeString = "Invalid";
      break;
    }
  }

  public PMS_Vertex getVertex(int i) { 
    return vert[i];
  }
  public PMS_Vector getPerp(int i) { 
    return perpendicular[i];
  }
  public int getPolyType() { 
    return PolyType;
  }
  public String getPolyTypeString() { 
    return PolyTypeString;
  }
}

public class PMS_Prop {

  private boolean Active;
  private int PropStyle;
  private int Width;
  private int Height;
  private float x;
  private float y;
  private float rotation;
  private float sx;
  private float sy;
  private int alpha;
  private PMS_Color c;
  private int DrawBehind;
  private String DrawBehindString;

  public PMS_Prop(int Active, int filler, int style, int w, int h, float x, float y, float r, float sx, float sy, int alpha, int filler2, PMS_Color c, int d) {
    this.Active = Active == 0 ? false : true;
    this.PropStyle = style;
    this.Width = w;
    this.Height = h;
    this.x = x;
    this.y = y;
    this.rotation = r;
    this.sx = sx;
    this.sy = sy;
    this.alpha = alpha;
    this.c = c;
    this.DrawBehind = d;

    switch(d) {
    case 0: 
      this.DrawBehindString = "Behind All";
      break;
    case 1: 
      this.DrawBehindString = "Behind Map";
      break;
    case 2: 
      this.DrawBehindString = "Behind None";
      break;
    default: 
      this.DrawBehindString = "Invalid";
      break;
    }
  }

  public boolean getActive() { 
    return Active;
  }
  public int getPropStyle() { 
    return PropStyle;
  }
  public int getWidth() { 
    return Width;
  }
  public int getHeight() { 
    return Height;
  }
  public float getX() { 
    return x;
  }
  public float getY() { 
    return y;
  }
  public float getRotation() { 
    return rotation;
  }
  public float getScaleX() { 
    return sx;
  }
  public float getScaleY() { 
    return sy;
  }
  public int getAlpha() { 
    return alpha;
  }
  public PMS_Color getPMS_Color() { 
    return c;
  }
  public int getDrawBehind() { 
    return DrawBehind;
  }
  public String getDrawBehindString() { 
    return DrawBehindString;
  }
}

public class PMS_Spawn {

  private boolean Active;
  private int x;
  private int y;
  private int Spawn;
  private String SpawnString;

  public PMS_Spawn(int Active, int filler, int x, int y, int Spawn) {
    this.Active = Active == 0 ? false : true;
    this.x = x;
    this.y = y;
    this.Spawn = Spawn;

    switch(Spawn) {
    case 0: 
      SpawnString = "General";
      break;
    case 1: 
      SpawnString = "Alpha";
      break;
    case 2: 
      SpawnString = "Bravo";
      break;
    case 3: 
      SpawnString = "Charlie";
      break;
    case 4: 
      SpawnString = "Delta";
      break;
    case 5: 
      SpawnString = "Alpha Flag";
      break;
    case 6: 
      SpawnString = "Bravo Flag";
      break;
    case 7: 
      SpawnString = "Grenades";
      break;
    case 8: 
      SpawnString = "Medkits";
      break;
    case 9: 
      SpawnString = "Clusters";
      break;
    case 10: 
      SpawnString = "Vest";
      break;
    case 11: 
      SpawnString = "Flamer";
      break;
    case 12: 
      SpawnString = "Berserker";
      break;
    case 13: 
      SpawnString = "Predator";
      break;
    case 14: 
      SpawnString = "Yellow Flag";
      break;
    case 15: 
      SpawnString = "Rambo Bow";
      break;
    case 16: 
      SpawnString = "Stat Gun";
      break;
    default: 
      SpawnString = "Invalid";
      break;
    }
  }

  public boolean getActive() { 
    return Active;
  }
  public int getX() { 
    return x;
  }
  public int getY() { 
    return y;
  }
  public int getSpawnType() { 
    return Spawn;
  }
  public String getSpawnTypeString() { 
    return SpawnString;
  }
}

public class PMS_Vector {

  private float x;
  private float y;
  private float z;

  public PMS_Vector(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public float getX() { 
    return x;
  }
  public float getY() { 
    return y;
  }
  public float getZ() { 
    return z;
  }
}

public class PMS_Vertex {

  private float x;
  private float y;
  private float z;
  private float rhw;
  private PMS_Color c;
  private float tu;
  private float tv;

  public PMS_Vertex(float x, float y, float z, float rhw, PMS_Color c, float tu, float tv) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.rhw = rhw;
    this.c = c;
    this.tu = tu;
    this.tv = tv;
  }

  public float getX() { 
    return x;
  }
  public float getY() { 
    return y;
  }
  public float getZ() { 
    return z;
  }
  public float getRHW() { 
    return rhw;
  }
  public PMS_Color getPMS_Color() { 
    return c;
  }
  public float getTU() { 
    return tu;
  }
  public float getTV() { 
    return tv;
  }
}

public class PMS_Waypoint {

  private boolean Active;
  private int ID;
  private int x;
  private int y;
  private boolean left;
  private boolean right;
  private boolean up;
  private boolean down;
  private boolean jet;
  private int path;
  private int SpecialAction;
  private String SpecialActionString;
  private int c2;
  private int c3;
  private int numConnections;
  private int[] Connections;

  public PMS_Waypoint(int a, int filler, int id, int x, int y, int l, int r, int u, int d, int j, int p, int s, int c2, int c3, int filler2, int nc) {
    this.Active = a == 0 ? false : true;
    this.x = x;
    this.y = y;
    this.ID = id;
    this.left = l == 0 ? false : true;
    this.right = r == 0 ? false : true;
    this.up = u == 0 ? false : true;
    this.down = d == 0 ? false : true;
    this.jet = j == 0 ? false : true;
    this.path = unSign(p);
    this.SpecialAction = s;
    this.c2 = unSign(c2);
    this.c3 = unSign(c3);
    this.numConnections = nc;

    switch(this.SpecialAction) {
    case 0: 
      SpecialActionString = "None";
      break;
    case 1: 
      SpecialActionString = "Stop and Camp";
      break;
    case 2: 
      SpecialActionString = "Wait 1 Second";
      break;
    case 3: 
      SpecialActionString = "Wait 5 Seconds";
      break;
    case 4: 
      SpecialActionString = "Wait 10 Seconds";
      break;
    case 5: 
      SpecialActionString = "Wait 15 Seconds";
      break;
    case 6: 
      SpecialActionString = "Wait 20 Seconds";
      break;
    default: 
      SpecialActionString = "Invalid";
      break;
    }
  }

  public void setConnections(int[] c) {
    this.Connections = c;
  }

  public boolean getActive() { 
    return Active;
  }
  public int getX() { 
    return x;
  }
  public int getY() { 
    return y;
  }
  public int getID() { 
    return ID;
  }
  public boolean getLeft() { 
    return left;
  }
  public boolean getRight() { 
    return right;
  }
  public boolean getUp() { 
    return up;
  }
  public boolean getDown() { 
    return down;
  }
  public boolean getJet() { 
    return jet;
  }
  public int getPath() { 
    return path;
  }
  public int getSpecialAction() { 
    return SpecialAction;
  }
  public String getSpecialActionString() { 
    return SpecialActionString;
  }
  public int getC2() { 
    return c2;
  }
  public int getC3() { 
    return c3;
  }
  public int getNumConnections() { 
    return numConnections;
  }
  public int[] getConnections() { 
    return Connections;
  }

  private int unSign(int i) {
    if (i<0) {
      i += 256;
    }
    return i;
  }
}

