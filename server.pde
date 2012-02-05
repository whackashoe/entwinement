void receive(byte[] message_, String ip_, int port_) {
  byte[] b;
  
  if(settings.lobbyIp.equals(ip_) && settings.lobbyPort == port_) {
    serverList.updateList(message_);
    return;
  }
  if(gameMenu.servers) {
    if(!playing) {
      switch(message_[0]) {
        case -4: downloadLargeMapFile(removeFirstBytes(message_, 1)); break;
        //case -3: sendFileRequest(removeFirstBytes(message_, 1)); break;
        case -2: downloadMapFile(removeFirstBytes(message_, 1)); break;
        case -1: checkMapVersion(removeFirstBytes(message_, 1)); break;
        case 0: mapHandshake(removeFirstBytes(message_, 1)); break;
        case 1: addMeToGame(removeFirstBytes(message_, 1)); break;    
      }
    } else if(playing) {
      switch(message_[0]) {
        case 2: updateHealth(removeFirstBytes(message_, 1)); break;
        case 3: changeSelfState(removeFirstBytes(message_, 1)); break;
        case 4: addBulletFromServer(removeFirstBytes(message_, 1)); break;
        case 5: updatePlayerById(removeFirstBytes(message_, 1)); break;
        case 6: setAttachment(removeFirstBytes(message_, 1)); break;
        case 7: addExplosionFromServer(removeFirstBytes(message_, 1)); break;
        case 8: setGun(removeFirstBytes(message_, 1)); break;
        case 9: addGrappleFromServer(removeFirstBytes(message_, 1)); break;
        case 10: addAirStrikeFromServer(removeFirstBytes(message_, 1)); break;
        case 11: addPlayerFromServer(removeFirstBytes(message_, 1)); break;
        case 12: receivePingTest(); break;
        case 13: updatePing(); break;
        case 14: addPickupsFromServer(removeFirstBytes(message_, 1)); break;
        case 15: removePlayerFromGame(removeFirstBytes(message_, 1)); break;
        case 16: removeGrapple(removeFirstBytes(message_, 1)); break;
        case 17: removePickup(removeFirstBytes(message_, 1)); break;
        case 18: addVehicleFromServer(removeFirstBytes(message_, 1)); break;
        case 19: updateVehicleFromServer(removeFirstBytes(message_, 1)); break;
        case 20: removeVehicleFromServer(removeFirstBytes(message_, 1)); break;
        case 21: playerEnterVehicle(removeFirstBytes(message_, 1)); break;
        case 22: playerExitVehicle(removeFirstBytes(message_, 1)); break;
        case 23: updateVehiclePartHealth(removeFirstBytes(message_, 1)); break;
        case 24: updateGrappleById(removeFirstBytes(message_, 1)); break;
        case 25: updatePickupById(removeFirstBytes(message_, 1)); break;
        case 26: addDataFromServerScript(removeFirstBytes(message_, 1)); break;
      }
    }
  }
}

void addPickupsFromServer(byte[] b_) {
  if(b_[0] == 0) {
    addHealthBox(removeFirstBytes(b_, 1));
  } else if(b_[0] == 1) {
    addAttachmentBox(removeFirstBytes(b_, 1));
  } else if(b_[0] == 2) {
    addGunBox(removeFirstBytes(b_, 1));
  } else {
    System.err.println("Add Pickup Malformed error");
  }
}

void changeSelfState(byte[] b_) {
  if(b_[0] == 0) {
    game.meCast.alive = false;
  } else {
    b_ = removeFirstBytes(b_, 1);
    byte[] px = new byte[4];
    px[0] = b_[0];
    px[1] = b_[1];
    px[2] = b_[2];
    px[3] = b_[3];
    
    byte[] py = new byte[4];
    py[0] = b_[4];
    py[1] = b_[5];
    py[2] = b_[6];
    py[3] = b_[7];
    float fpx = toFloat(px);
    float fpy = toFloat(py);
    println("respawn f:"+fpx+"-"+fpy);
    game.meCast.respawn(fpx, fpy);
  }
}

void receivePingTest() {
  byte[] p = new byte[1];
  p[0] = 8;
  client.send(p, serverIp, serverPort);
}

void mapHandshake(byte[] b_) {
  byte[] mapNameLength_ = new byte[4];
  mapNameLength_[0] = b_[0];
  mapNameLength_[1] = b_[1];
  mapNameLength_[2] = b_[2];
  mapNameLength_[3] = b_[3];
  int mapNameLength = toInt(mapNameLength_);
  b_ = removeFirstBytes(b_, 4);
  
  serverMapName = "";
  for(int i=0; i<mapNameLength; i++) serverMapName += char(b_[i]);
  b_ = removeFirstBytes(b_, mapNameLength);
  
  String tempHash ="";
  for(int i=0; i<b_.length; i++) tempHash += char(b_[i]);
  println(serverMapName);
  //println(tempHash+"-"+createHash("maps/"+serverMapName));

  if(!checkHash("maps/"+serverMapName, tempHash)) {
    println(serverMapName+" is not current version");
    //DOWNLOAD MAP
    byte[] b = new byte[1];
    b[0] = 1;
    dlMap = true;
    client.send(b, serverIp, serverPort);
  } else {
    println(serverMapName+" is same version as server");
    byte[] b = new byte[1];
    b[0] = 2;
    client.send(b, serverIp, serverPort);
  }
}

void downloadMapFile(byte[] b_) {
  String fileHash = createHash(b_);
  if(fileHash.equals(mapFilesHashes[mapFilesHashes.length-1])) {
    saveBytes(mapFilesNeeded[mapFilesNeeded.length-1], b_);
    println(mapFilesNeeded[mapFilesNeeded.length-1]+" saved");
    mapFilesNeeded = shorten(mapFilesNeeded);
    mapFilesHashes = shorten(mapFilesHashes);
  } else {
    //REQUEST AGAIN
    println(mapFilesNeeded[mapFilesNeeded.length-1]+" was corrupt");
  }
  if(mapFilesNeeded.length > 0) {
    sendFileRequest(mapFilesNeeded[mapFilesNeeded.length-1]);
  } else {
    byte[] b = new byte[1];
    b[0] = 2;
    client.send(b, serverIp, serverPort);
  }
}

void downloadLargeMapFile(byte[] b_) {
  byte[] len_ = new byte[4];  //AMOUNT OF PACKETS NEEDED FOR TRANSFER
  len_[0] = b_[0];
  len_[1] = b_[1];
  len_[2] = b_[2];
  len_[3] = b_[3];
  
  byte[] cur_ = new byte[4];  //CURRENT PACKET RECEIVED
  cur_[0] = b_[4];
  cur_[1] = b_[5];
  cur_[2] = b_[6];
  cur_[3] = b_[7];
  
  int len = toInt(len_);
  int cur = toInt(cur_);
  b_ = removeFirstBytes(b_, 8);
  
  println("Received part:"+cur+" of "+len);
  
  if(cur == 0) largePartialFile = new byte[0];  //IF FIRST PACKET THEN WE RESET
  largePartialFile = concat(largePartialFile, b_);
  
  if(cur == len-1) {
    String fileHash = createHash(largePartialFile);
    if(fileHash.equals(mapFilesHashes[mapFilesHashes.length-1])) {
      saveBytes(mapFilesNeeded[mapFilesNeeded.length-1], largePartialFile);
      println(mapFilesNeeded[mapFilesNeeded.length-1]+" saved");
      mapFilesNeeded = shorten(mapFilesNeeded);
      mapFilesHashes = shorten(mapFilesHashes);
    } else {
      //REQUEST AGAIN
      println(mapFilesNeeded[mapFilesNeeded.length-1]+" was corrupt");
    }
    if(mapFilesNeeded.length > 0) {
      sendFileRequest(mapFilesNeeded[mapFilesNeeded.length-1]);
    } else {
      byte[] b = new byte[1];
      b[0] = 2;
      client.send(b, serverIp, serverPort);
    }
  }
}

void sendFileRequest(String path_) {
  //println("Requesting "+mapFilesNeeded[mapFilesNeeded.length-1]);
  println("Requesting "+path_);
  byte[] b = new byte[1];
  b[0] = -2;
  b = concat(b, path_.getBytes());
  client.send(b, serverIp, serverPort);
}

void sendFileRequest(byte[] data_) {
  //println("Requesting "+mapFilesNeeded[mapFilesNeeded.length-1]);
  println("Requesting "+data_.toString());
  byte[] b = new byte[1];
  b[0] = -2;
  b = concat(b, data_);
  client.send(b, serverIp, serverPort);
}

void checkMapVersion(byte[] b_) {
  String[] v = splitTokens(new String(b_), "\n");
  
  mapFilesNeeded = new String[0];
  mapFilesHashes = new String[0];
  
  for(int i=0; i<v.length; i++) {
    String[] piece = split(v[i], " ");  //BREAKS INTO FILENAME, HASH
    
    if(!stringArrayContains(mapFilesNeeded, piece[0])) {
      if(createHash(piece[0]) == null) {
        mapFilesNeeded = append(mapFilesNeeded, piece[0]);
        mapFilesHashes = append(mapFilesHashes, piece[1]);
      } else if(!checkHash(piece[0], piece[1])) {
        if(!createHash(piece[0]).equals(piece[1])) {
          mapFilesNeeded = append(mapFilesNeeded, piece[0]);
          mapFilesHashes = append(mapFilesHashes, piece[1]);
        } else {
           System.err.println(">>>>>>"+piece[0]+"..."+piece[1]+"--"+createHash(piece[0]));
        }
      }
    }
    
    /*
    if(!createHash(piece[0]).equals(piece[1]) && !stringArrayContains(mapFilesNeeded, piece[0])) {
      if(checkHash(piece[0], piece[1])) {
        mapFilesNeeded = append(mapFilesNeeded, piece[0]);
        mapFilesHashes = append(mapFilesHashes, piece[1]);
        println("Adding "+piece[0]+"..."+piece[1]+"--"+createHash(piece[0]));
      } else {
        System.err.println(">>>>>>"+piece[0]+"..."+piece[1]+"--"+createHash(piece[0]));
      }
    }
    */
  }

  println("=====YOU NEED TO DOWNLOAD "+mapFilesNeeded.length+" FILES=====");
  for(int i=0; i<mapFilesNeeded.length; i++) println(i+"--"+mapFilesNeeded[i]);
  if(mapFilesNeeded.length > 0) {
    sendFileRequest(mapFilesNeeded[mapFilesNeeded.length-1]);
  } else {
    byte[] b = new byte[1];
    b[0] = 2;
    client.send(b, serverIp, serverPort);
  }
}

void removePlayerFromGame(byte[] data_) {
  //TODO
}

void removeGrapple(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  
  int id = toInt(id_);
  for(int i=0; i<game.grappleData.size(); i++) {
    Grapple sh = (Grapple) game.grappleData.get(i);
    if(id == sh.id) {
      if(sh.alive) {
        sh.kill();
      }
    }
  }
}

void removePickup(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  
  int id = toInt(id_);
  for(int i=0; i<game.pickupData.size(); i++) {
    Pickups ph = (Pickups) game.pickupData.get(i);
    if(id == ph.id) { ph.alive = false; }
  }
}

void updatePing() {
  /*byte[] ping_ = new byte[4];
  ping_[0] = data_[0];
  ping_[1] = data_[1];
  ping_[2] = data_[2];
  ping_[3] = data_[3];
  game.meCast.setPing(toInt(ping_));
  */
}

void updateHealth(byte[] data_) {
  byte[] h_ = new byte[4];
  h_[0] = data_[0];
  h_[1] = data_[1];
  h_[2] = data_[2];
  h_[3] = data_[3];
  game.meCast.setHealth(toFloat(h_));
}

void addMeToGame(byte[] data_) {
  playingOnline = true;
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  int id = toInt(id_);
  
  onlineId = id;
  println("Your Online ID:"+onlineId);
  
  //LOADMAP
  File f = new File("maps/"+serverMapName);
  /* 
  if(f.exists()) {  //!!!!!for some reason it works when exported but not when running from ide?
    playing = true;

    if(mainMenu) {
      game.exterminateJoints();
      world.clear();
      clearAllEngineData();
      mainMenu = false;
    }
    
    game = new Engine(serverMapName);
    loadMapRepo(serverMapName);
    game.meCast.setOnlineDude(onlineId, game.meCast.name);
    
    byte[] b = new byte[1];
    b[0] = -1;
    client.send(b, serverIp, serverPort);
    playing = true;
  } else {
    System.err.println("Map was never downloaded");
  }
  */

  mainMenu = false;
  int[] idata = new int[1];
  idata[0] = onlineId;
  String[] sdata = new String[1];
  sdata[0] = serverMapName;
  
  addGameCom(-2, idata, sdata);
  
  byte[] b = new byte[1];
  b[0] = -1;
  client.send(b, serverIp, serverPort);
}

void addPlayerFromServer(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  int id = toInt(id_);
  
  byte[] name_ = new byte[data_.length-id_.length];
  for(int i=0; i<name_.length; i++) { name_[i] = data_[id_.length+i]; }
  /*char[] cname = new char[name_.length];
  for(int i=0; i<name_.length; i++) { cname[i] = char(name_[i]); }*/
  
  String sName = new String(name_);
  
  
  println("ADD PLAYER: "+id+""+sName);
  
  for(int i=0; i<game.soldierData.size(); i++) {  //DONT ADD IF PLAYER ALREADY EXISTS
    Soldier sh = (Soldier) game.soldierData.get(i);
    if(id == sh.id) {
      println("ALREADY ADDED ERROR");
      return;
    }
  }
  
  if(id != onlineId) {
    game.soldierData.add(new Soldier(0, 0));
    //println(game.soldierData.size());
    Soldier sh = (Soldier) game.soldierData.get(game.soldierData.size()-1);
    sh.setOnlineDude(id, sName);
  } else {
    game.meCast.setOnlineDude(onlineId, game.meCast.name);
    playing = true;
    //println("me added");
  }
}

void addBulletFromServer(byte[] data_) {
  byte[] x_ = new byte[4];
  x_[0] = data_[0];
  x_[1] = data_[1];
  x_[2] = data_[2];
  x_[3] = data_[3];
  
  byte[] y_ = new byte[4];
  y_[0] = data_[4];
  y_[1] = data_[5];
  y_[2] = data_[6];
  y_[3] = data_[7];

  byte[] gunAngle_ = new byte[4];
  gunAngle_[0] = data_[8];
  gunAngle_[1] = data_[9];
  gunAngle_[2] = data_[10];
  gunAngle_[3] = data_[11];
  
  byte[] xVelo_ = new byte[4];
  xVelo_[0] = data_[12];
  xVelo_[1] = data_[13];
  xVelo_[2] = data_[14];
  xVelo_[3] = data_[15];
  
  byte[] yVelo_ = new byte[4];
  yVelo_[0] = data_[16];
  yVelo_[1] = data_[17];
  yVelo_[2] = data_[18];
  yVelo_[3] = data_[19];
  
  byte[] type_ = new byte[4];
  type_[0] = data_[20];
  type_[1] = data_[21];
  type_[2] = data_[22];
  type_[3] = data_[23];
  
  byte[] id_ = new byte[4];
  id_[0] = data_[24];
  id_[1] = data_[25];
  id_[2] = data_[26];
  id_[3] = data_[27];
  
  float x = toFloat(x_);
  float y = toFloat(y_);
  float gunAngle = toFloat(gunAngle_);
  float xVelo = toFloat(xVelo_);
  float yVelo = toFloat(yVelo_);
  int type = toInt(type_);
  int id = toInt(id_);
  
  if(game.gunData[type].shotgun) {
    for(int i=-game.gunData[type].shotgunShots; i<game.gunData[type].shotgunShots/2; i++) {
      game.bulletData.add(new Bullet(x+(cos(gunAngle+(i/game.gunData[type].shotgunShots))*15), y+(sin(gunAngle+(i/game.gunData[type].shotgunShots))*15), (game.gunData[type].speed*cos(gunAngle+(i*(0.25/game.gunData[type].shotgunShots)))), (game.gunData[type].speed*sin(gunAngle+(i*(0.25/game.gunData[type].shotgunShots)))), type, id)); 

      Bullet bCast = (Bullet) game.bulletData.get(game.bulletData.size()-1);
      bCast.addMoveAcc(xVelo, yVelo);
    
      if(id == game.meCast.id) {
        if(game.gunData[type].follow) game.setFollowBullet((Bullet) game.bulletData.get(game.bulletData.size()-1));
        if(game.gunData[type].controllable) game.addControlBullet();
      }
    } 
  } else {
    game.bulletData.add(new Bullet(x, y, (game.gunData[type].speed*cos(gunAngle)), (game.gunData[type].speed*sin(gunAngle)), type, id)); 
    Bullet bCast = (Bullet) game.bulletData.get(game.bulletData.size()-1);
    bCast.addMoveAcc(xVelo, yVelo);
    
    if(id == game.meCast.id) {
      if(game.gunData[type].follow) game.setFollowBullet((Bullet) game.bulletData.get(game.bulletData.size()-1));
      if(game.gunData[type].controllable) game.addControlBullet();
    }
  }
}

void addExplosionFromServer(byte[] data_) {
  byte[] x_ = new byte[4];
  x_[0] = data_[0];
  x_[1] = data_[1];
  x_[2] = data_[2];
  x_[3] = data_[3];
  
  byte[] y_ = new byte[4];
  y_[0] = data_[4];
  y_[1] = data_[5];
  y_[2] = data_[6];
  y_[3] = data_[7];
  
  byte[] radius_ = new byte[4];
  radius_[0] = data_[8];
  radius_[1] = data_[9];
  radius_[2] = data_[10];
  radius_[3] = data_[11];
  
  byte[] timer_ = new byte[4];
  timer_[0] = data_[12];
  timer_[1] = data_[13];
  timer_[2] = data_[14];
  timer_[3] = data_[15];
  
  float x = toFloat(x_);
  float y = toFloat(y_);
  float radius = toFloat(radius_);
  int timer = toInt(timer_);
  
  game.explosionData.add(new Explosion(x, y, radius, timer)); 
}

void addAirStrikeFromServer(byte[] data_) {
  byte[] mpX_ = new byte[4];
  mpX_[0] = data_[0];
  mpX_[1] = data_[1];
  mpX_[2] = data_[2];
  mpX_[3] = data_[3];
  
  byte[] id_ = new byte[4];
  id_[0] = data_[4];
  id_[1] = data_[5];
  id_[2] = data_[6];
  id_[3] = data_[7];
  
  int mpX = toInt(mpX_);
  int id = toInt(id_);
  
  if(id != onlineId) {
    Soldier sh = (Soldier) game.getSoldierById(id);
    int airStrikeAmount = 8;
    for(int i=0; i<airStrikeAmount; i++) {
      game.AirStrike.setBoom(true, int(random(20, 80)), 50);
      if(mpX > 400) {
        game.bulletData.add(new Bullet(sh.self.getX()+((mpX-400)*2)-(i*70), sh.self.getY()-1000-(airStrikeAmount*50)+i*50, 400000, i*1000, id, game.AirStrike)); 
      } else {
        game.bulletData.add(new Bullet(sh.self.getX()+((mpX-400)*2)+(i*70), sh.self.getY()-1500+i*50, -400000, i*1000, id, game.AirStrike)); 
      }
    }
  }
}

void addGrappleFromServer(byte[] data_) {
  byte[] x_ = new byte[4];
  x_[0] = data_[0];
  x_[1] = data_[1];
  x_[2] = data_[2];
  x_[3] = data_[3];
  
  byte[] y_ = new byte[4];
  y_[0] = data_[4];
  y_[1] = data_[5];
  y_[2] = data_[6];
  y_[3] = data_[7];
  
  byte[] xf_ = new byte[4];
  xf_[0] = data_[8];
  xf_[1] = data_[9];
  xf_[2] = data_[10];
  xf_[3] = data_[11];
  
  byte[] yf_ = new byte[4];
  yf_[0] = data_[12];
  yf_[1] = data_[13];
  yf_[2] = data_[14];
  yf_[3] = data_[15];
  
  byte[] id_ = new byte[4];
  id_[0] = data_[16];
  id_[1] = data_[17];
  id_[2] = data_[18];
  id_[3] = data_[19];
  
  
  float x = toFloat(x_);
  float y = toFloat(y_);
  float xf = toFloat(xf_);
  float yf = toFloat(yf_);
  
  Soldier sh = (Soldier) getSoldierById(toInt(id_));
  if(!sh.driving) {
    game.grappleData.add(new Grapple(sh.self, new Vec2D(x, y), new Vec2D(xf, yf)));
  } else {
    game.grappleData.add(new Grapple(sh.curCar.getCockpit(), new Vec2D(x, y), new Vec2D(xf, yf)));
  }
  sh.grappleCast = (Grapple) game.grappleData.get(game.grappleData.size()-1);
  sh.grappleCast.setId(toInt(id_));
}

void updatePlayerById(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  
  byte[] time_ = new byte[4];
  time_[0] = data_[4];
  time_[1] = data_[5];
  time_[2] = data_[6];
  time_[3] = data_[7];
  int time = toInt(time_);
  
  byte[] x_ = new byte[4];
  x_[0] = data_[8];
  x_[1] = data_[9];
  x_[2] = data_[10];
  x_[3] = data_[11];
  
  byte[] y_ = new byte[4];
  y_[0] = data_[12];
  y_[1] = data_[13];
  y_[2] = data_[14];
  y_[3] = data_[15];
  
  byte[] xf_ = new byte[4];
  xf_[0] = data_[16];
  xf_[1] = data_[17];
  xf_[2] = data_[18];
  xf_[3] = data_[19];
  
  byte[] yf_ = new byte[4];
  yf_[0] = data_[20];
  yf_[1] = data_[21];
  yf_[2] = data_[22];
  yf_[3] = data_[23];
  
  if(lastSoldierPVTime < time) {
    lastSoldierPVTime = time;
    int[] idata = new int[1];
    idata[0] = toInt(id_);
    
    float[] fdata = new float[4];
    fdata[0] = toFloat(x_);
    fdata[1] = toFloat(y_);
    fdata[2] = toFloat(xf_);
    fdata[3] = toFloat(yf_);
    
    if(game != null) addGameCom(0, idata, fdata);
  } else {
    println("received old packet-"+time+"::"+lastSoldierPVTime);
  }
}

void updateGrappleById(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  
  byte[] x_ = new byte[4];
  x_[0] = data_[4];
  x_[1] = data_[5];
  x_[2] = data_[6];
  x_[3] = data_[7];
  
  byte[] y_ = new byte[4];
  y_[0] = data_[8];
  y_[1] = data_[9];
  y_[2] = data_[10];
  y_[3] = data_[11];
  
  byte[] xf_ = new byte[4];
  xf_[0] = data_[12];
  xf_[1] = data_[13];
  xf_[2] = data_[14];
  xf_[3] = data_[15];
  
  byte[] yf_ = new byte[4];
  yf_[0] = data_[16];
  yf_[1] = data_[17];
  yf_[2] = data_[18];
  yf_[3] = data_[19];
  
  int[] idata = new int[1];
  idata[0] = toInt(id_);
  
  float[] fdata = new float[4];
  fdata[0] = toFloat(x_);
  fdata[1] = toFloat(y_);
  fdata[2] = toFloat(xf_);
  fdata[3] = toFloat(yf_);
  
  if(game != null) addGameCom(2, idata, fdata);
}

void updatePickupById(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  
  byte[] x_ = new byte[4];
  x_[0] = data_[4];
  x_[1] = data_[5];
  x_[2] = data_[6];
  x_[3] = data_[7];
  
  byte[] y_ = new byte[4];
  y_[0] = data_[8];
  y_[1] = data_[9];
  y_[2] = data_[10];
  y_[3] = data_[11];
  
  byte[] xf_ = new byte[4];
  xf_[0] = data_[12];
  xf_[1] = data_[13];
  xf_[2] = data_[14];
  xf_[3] = data_[15];
  
  byte[] yf_ = new byte[4];
  yf_[0] = data_[16];
  yf_[1] = data_[17];
  yf_[2] = data_[18];
  yf_[3] = data_[19];
  
  int[] idata = new int[1];
  idata[0] = toInt(id_);
  
  float[] fdata = new float[4];
  fdata[0] = toFloat(x_);
  fdata[1] = toFloat(y_);
  fdata[2] = toFloat(xf_);
  fdata[3] = toFloat(yf_);
  
  if(game != null) addGameCom(1, idata, fdata);
}

void setAttachment(byte[] data_) {
  if(data_.length == 12) {
    byte[] type_ = new byte[4];
    type_[0] = data_[0];
    type_[1] = data_[1];
    type_[2] = data_[2];
    type_[3] = data_[3];
    
    byte[] ammo_ = new byte[4];
    ammo_[0] = data_[4];
    ammo_[1] = data_[5];
    ammo_[2] = data_[6];
    ammo_[3] = data_[7];
    
    byte[] strength_ = new byte[4];
    strength_[0] = data_[8];
    strength_[1] = data_[9];
    strength_[2] = data_[10];
    strength_[3] = data_[11];
    
    int type = toInt(type_);
    int ammo = toInt(ammo_);
    int strength = toInt(strength_);
    
    game.meCast.setAttachment(type, ammo);
  }
}

void setGun(byte[] data_) {
  if(data_.length == 17) {
    byte[] type_ = new byte[4];
    type_[0] = data_[0];
    type_[1] = data_[1];
    type_[2] = data_[2];
    type_[3] = data_[3];
    
    byte[] ammo_ = new byte[4];
    ammo_[0] = data_[4];
    ammo_[1] = data_[5];
    ammo_[2] = data_[6];
    ammo_[3] = data_[7];
    
    byte[] delayTime_ = new byte[4];
    delayTime_[0] = data_[8];
    delayTime_[1] = data_[9];
    delayTime_[2] = data_[10];
    delayTime_[3] = data_[11];
    
    byte[] reloadTime_ = new byte[4];
    reloadTime_[0] = data_[12];
    reloadTime_[1] = data_[13];
    reloadTime_[2] = data_[14];
    reloadTime_[3] = data_[15];
    
    int type = toInt(type_);
    int ammo = toInt(ammo_);
    int delayTime = toInt(delayTime_);
    int reloadTime = toInt(reloadTime_);
    boolean reloading = boolean(data_[16]);
    
    game.meCast.setGun(type, ammo, delayTime, reloadTime);
  }
}


void addHealthBox(byte[] data_) {
  if(data_.length == 16) {
    byte[] x_ = new byte[4];
    x_[0] = data_[0];
    x_[1] = data_[1];
    x_[2] = data_[2];
    x_[3] = data_[3];
    
    byte[] y_ = new byte[4];
    y_[0] = data_[4];
    y_[1] = data_[5];
    y_[2] = data_[6];
    y_[3] = data_[7];
    
    byte[] amount_ = new byte[4];
    amount_[0] = data_[8];
    amount_[1] = data_[9];
    amount_[2] = data_[10];
    amount_[3] = data_[11];
    
    byte[] id_ = new byte[4];
    id_[0] = data_[12];
    id_[1] = data_[13];
    id_[2] = data_[14];
    id_[3] = data_[15];
    
    game.pickupData.add(new Pickups(toFloat(x_), toFloat(y_), toInt(amount_)));
    Pickups ph = (Pickups) game.pickupData.get(game.pickupData.size()-1);
    ph.setId(toInt(id_));
  }
}

void addAttachmentBox(byte[] data_) {
  if(data_.length == 20) {
    byte[] x_ = new byte[4];
    x_[0] = data_[0];
    x_[1] = data_[1];
    x_[2] = data_[2];
    x_[3] = data_[3];
    
    byte[] y_ = new byte[4];
    y_[0] = data_[4];
    y_[1] = data_[5];
    y_[2] = data_[6];
    y_[3] = data_[7];
    
    byte[] type_ = new byte[4];
    type_[0] = data_[8];
    type_[1] = data_[9];
    type_[2] = data_[10];
    type_[3] = data_[11];
    
    byte[] amount_ = new byte[4];
    amount_[0] = data_[12];
    amount_[1] = data_[13];
    amount_[2] = data_[14];
    amount_[3] = data_[15];
    
    byte[] id_ = new byte[4];
    id_[0] = data_[16];
    id_[1] = data_[17];
    id_[2] = data_[18];
    id_[3] = data_[19];
    
    game.pickupData.add(new Pickups(toFloat(x_), toFloat(y_), toInt(type_), toInt(amount_)));
    Pickups ph = (Pickups) game.pickupData.get(game.pickupData.size()-1);
    ph.setId(toInt(id_));
  }
}

void addGunBox(byte[] data_) {
  if(data_.length == 25) {
    byte[] x_ = new byte[4];
    x_[0] = data_[0];
    x_[1] = data_[1];
    x_[2] = data_[2];
    x_[3] = data_[3];
    
    byte[] y_ = new byte[4];
    y_[0] = data_[4];
    y_[1] = data_[5];
    y_[2] = data_[6];
    y_[3] = data_[7];
  
    byte[] gunType_ = new byte[4];
    gunType_[0] = data_[8];
    gunType_[1] = data_[9];
    gunType_[2] = data_[10];
    gunType_[3] = data_[11];
    
    byte[] curAmmo_ = new byte[4];
    curAmmo_[0] = data_[12];
    curAmmo_[1] = data_[13];
    curAmmo_[2] = data_[14];
    curAmmo_[3] = data_[15];
    
    byte[] reloadTimeR_ = new byte[4];
    reloadTimeR_[0] = data_[16];
    reloadTimeR_[1] = data_[17];
    reloadTimeR_[2] = data_[18];
    reloadTimeR_[3] = data_[19];
    
    boolean reloading_ = false;
    if(data_[20] == 1) { reloading_ = true; }
    
    byte[] id_ = new byte[4];
    id_[0] = data_[21];
    id_[1] = data_[22];
    id_[2] = data_[23];
    id_[3] = data_[24];
    
    
    
    //game.pickupData.add(new Pickups(toFloat(x_), toFloat(y_), toInt(gunType_), toInt(curAmmo_), toInt(reloadTimeR_), reloading_));
    //Pickups ph = (Pickups) game.pickupData.get(game.pickupData.size()-1);
    //ph.setId(toInt(id_));
  }
}

void addVehicleFromServer(byte[] data_) {
  if(data_.length == 16) {
    byte[] x_ = new byte[4];
    x_[0] = data_[0];
    x_[1] = data_[1];
    x_[2] = data_[2];
    x_[3] = data_[3];
    
    byte[] y_ = new byte[4];
    y_[0] = data_[4];
    y_[1] = data_[5];
    y_[2] = data_[6];
    y_[3] = data_[7];
    
    byte[] type_ = new byte[4];
    type_[0] = data_[8];
    type_[1] = data_[9];
    type_[2] = data_[10];
    type_[3] = data_[11];
    
    byte[] id_ = new byte[4];
    id_[0] = data_[12];
    id_[1] = data_[13];
    id_[2] = data_[14];
    id_[3] = data_[15];
    
    Vehicle ph = new Vehicle(new Vec2D(toFloat(x_), toFloat(y_)), toInt(type_));
    ph.setId(toInt(id_));
    game.vehicleData.add(ph);
    println("vehicle "+toInt(id_)+" added");
  }
}

void updateVehicleFromServer(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  data_ = removeFirstBytes(data_, 4);  //TO REMOVE ID DATA NOW THAT IT IS UNNEEDED
  
  Vehicle vCast = getVehicleById(toInt(id_));
  if(vCast != null) {
    if(data_.length == (vCast.parts.size()*21)) {
      int[] idata = new int[1];
      idata[0] = toInt(id_);
      float[] fdata = new float[vCast.parts.size()*5];
      boolean[] bdata = new boolean[vCast.parts.size()];
      
      for(int i=0; i<vCast.parts.size(); i++) {
        Vehicle.Part ph = (Vehicle.Part) vCast.parts.get(i);
        
        byte[] x_ = new byte[4];
        x_[0] = data_[(i*21)+0];
        x_[1] = data_[(i*21)+1];
        x_[2] = data_[(i*21)+2];
        x_[3] = data_[(i*21)+3];
        fdata[i*5+0] = toFloat(x_);
        
        byte[] y_ = new byte[4];
        y_[0] = data_[(i*21)+4];
        y_[1] = data_[(i*21)+5];
        y_[2] = data_[(i*21)+6];
        y_[3] = data_[(i*21)+7];
        fdata[i*5+1] = toFloat(y_);
        
        byte[] xf_ = new byte[4];
        xf_[0] = data_[(i*21)+8];
        xf_[1] = data_[(i*21)+9];
        xf_[2] = data_[(i*21)+10];
        xf_[3] = data_[(i*21)+11];
        fdata[i*5+2] = toFloat(xf_);
        
        byte[] yf_ = new byte[4];
        yf_[0] = data_[(i*21)+12];
        yf_[1] = data_[(i*21)+13];
        yf_[2] = data_[(i*21)+14];
        yf_[3] = data_[(i*21)+15];
        fdata[i*5+3] = toFloat(yf_);
        
        byte[] r_ = new byte[4];
        r_[0] = data_[(i*21)+16];
        r_[1] = data_[(i*21)+17];
        r_[2] = data_[(i*21)+18];
        r_[3] = data_[(i*21)+19];
        fdata[i*5+4] = toFloat(r_);
        bdata[i] = toBoolean(data_[(i*21)+20]);
      }
      if(game != null) addGameCom(0, idata, fdata, bdata);
    } else {
      System.err.println("Invalid size block specified for vehicle update");
    }
  } else {
    System.err.println("Bad ID specified for vehicle update");
  }
}

void removeVehicleFromServer(byte[] data_) {
  if(data_.length == 4) {
    byte[] id_ = new byte[4];
    id_[0] = data_[0];
    id_[1] = data_[1];
    id_[2] = data_[2];
    id_[3] = data_[3];
    
    //LOOKUP VEHICLE
    for(int i=0; i<game.vehicleData.size(); i++) {
      Vehicle ph = (Vehicle) game.vehicleData.get(i);
      if(toInt(id_) == ph.id) ph.alive = false;
    }
  }
}

void playerEnterVehicle(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  int id = toInt(id_);
  
  byte[] vid_ = new byte[4];
  vid_[0] = data_[4];
  vid_[1] = data_[5];
  vid_[2] = data_[6];
  vid_[3] = data_[7];
  int vid = toInt(vid_);
  
  getSoldierById(id).enterVehicle(getVehicleById(vid));
}

void playerExitVehicle(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  boolean door = boolean(data_[4]);
  
  getSoldierById(toInt(id_)).exitVehicle(door);
}

void updateVehiclePartHealth(byte[] data_) {
  byte[] id_ = new byte[4];
  id_[0] = data_[0];
  id_[1] = data_[1];
  id_[2] = data_[2];
  id_[3] = data_[3];
  
  byte[] pn_ = new byte[4];
  pn_[0] = data_[4];
  pn_[1] = data_[5];
  pn_[2] = data_[6];
  pn_[3] = data_[7];
  
  byte[] health_ = new byte[4];
  health_[0] = data_[8];
  health_[1] = data_[9];
  health_[2] = data_[10];
  health_[3] = data_[11];
  
  Vehicle.Part ph = (Vehicle.Part) getVehicleById(toInt(id_)).parts.get(toInt(pn_));
  ph.setHealthFromServer(toFloat(health_));
  
}

void addDataFromServerScript(byte[] data_) {
  if(game.jython != null) game.jython.toGame(new String(data_));
}

