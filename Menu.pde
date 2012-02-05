class Menu {
  public boolean maps;
  public boolean choosingMaps;
  public boolean servers;
  public boolean options;
  public boolean credits;
  public boolean instructions;
  
  private float offsetY;
  private int backButtonCountDown;
  private ArrayList rsTrays;
  public TextBox inputBox;
  
  final String[] mmOptions;
  final String[] amountToggle;
  final String[] onOffToggle;
  final String[] types;
  final String[] modes;
  
  Menu() {
    maps = false;
    choosingMaps = false;
    servers = false;
    options = false;
    credits = false;
    instructions = false;
    offsetY = 0;
    inputBox = new TextBox(int(width*0.6), int(height*0.7), int(width*0.4), 15, 100, "");
    rsTrays = new ArrayList();
    
    
    String tempRandomMap = getRandomMap();
    //game = new Engine(tempRandomMap);
    //loadMapRepo(tempRandomMap);
    int[] idata = new int[1];
    String[] sdata = new String[1];
    sdata[0] = tempRandomMap;
    addGameCom(-1, idata, sdata);
    
    mmOptions = new String[5];
    mmOptions[0] = "One Player";
    mmOptions[1] = "Multiplayer";
    mmOptions[2] = "Options";
    mmOptions[3] = "Credits";
    mmOptions[4] = "Instructions";
    
    amountToggle = new String[32];
    amountToggle[0] = "0";
    for(int m=1; m<amountToggle.length; m++) amountToggle[m] = str(amountToggle.length-m);
    
    onOffToggle = new String[2];
    onOffToggle[0] = "ON";
    onOffToggle[1] = "OFF";
    
    types = new String[6];
    types[0] = "Brutality(SOLO)";
    types[1] = "Deathmatch(DM)";
    types[2] = "Warfare(TM)";
    types[3] = "Takeover(CP)";
    types[4] = "King of the Hill(KOTH)";
    types[5] = "Baby Tag(CTF)";
    
    modes = new String[5];
    modes[0] = "Zombie";
    modes[1] = "Bitch";
    modes[2] = "Completion";
    modes[3] = "DownsUp?";
    modes[4] = "Friendly Fire";
  }
  
  void update(GL gl) {
    if(game == null) return;
    if(!maps && !servers && !options && !credits && !instructions) {
      background(0);
      pushMatrix();
        game.update(gl);
      popMatrix();
      hint(DISABLE_DEPTH_TEST);
      camera();
      showMain();
    } else {
      if(maps) {
        if(choosingMaps) {
          showMaps();
        } else {
          background(0);
          pushMatrix();
            game.update(gl);
          popMatrix();
          hint(DISABLE_DEPTH_TEST);
          camera();
          showMapOptions();
        }
      } else if(servers) {
        showServers();
      } else if(options) {
        showOptions();
      } else if(credits) {
        showCredits();
      } else if(instructions) {
        background(0);
        pushMatrix();
          game.update(gl);
        popMatrix();
        pushMatrix();
          game.hud.update(gl);
        popMatrix();
        hint(DISABLE_DEPTH_TEST);
        camera();
        showInstructions();
      }
      showBackButton();
    }
  }
  
  void showMain() {
    float x = width/2;
    float y = 100;
    float w = 400;
    float h = 60;
    
    rectMode(CORNER);
    noStroke();
   
    beginShape();
      fill(0);
      vertex(0, 0);
      fill(0, 0);
      vertex(0, height);
      fill(0, 0);
      vertex(50, height);
      fill(0, 0);
      vertex(50, 0);
    endShape();
    textFont(FONTtitle, 30);
    fill(255);
    text("E\nn\nt\nw\ni\nn\ne\nm\ne\nn\nt\n", 0, 30);
    
    pushMatrix();
      translate(x, y);
      for(int i=0; i<5; i++) {
        fill(255, 150);
        if(mouseX > x && mouseX < x+w && mouseY > y+(h*i) && mouseY < y+(h*i)+h) {
          fill(255, 255);
          if(mousePressed && mouseButton == LEFT) {
            background(0);  //CLEAR SCREEN
            switch(i) {
              case 0 :
                maps = true;
                choosingMaps = true;
                break;
              case 1 :
                servers = true;
                requestServerList();
                break;
              case 2 :
                options = true;
                addOptionsMenuData();
                break;
              case 3 :
                credits = true;
                break;
              case 4 :
                instructions = true;
                String tempLevelName = game.levelName;
                game = new Engine(tempLevelName);
                loadMapRepo(tempLevelName); 
                String[] instructionsSrc = new String[1];
                instructionsSrc[0] = "instructions";
                String[] instructionsVer = new String[1];
                instructionsVer[0] = "1";
                game.jython = new JyInt(instructionsSrc, instructionsVer);
                game.jython.interp.eval("int_onSoldierAdd("+game.meCast.id+", \""+game.meCast.name+"\", "+game.meCast.team+")");
                Spawn sw = (Spawn) findClosestSpawn(game.menuCurrentFollowPos.x, game.menuCurrentFollowPos.y);
                game.meCast.respawn(sw.x, sw.y);
                break;
            }
          }
        }
        pushMatrix();
          translate(0, i*h);
          beginShape();
            vertex(0, 0);
            vertex(w, 0);
            fill(255, 150);
            vertex(w, h);
            vertex(0, h);
          endShape();
        popMatrix();
        textFont(FONTtitle, 24);
        fill(0);
        text(mmOptions[i], 20+i*20, i*h+20);
      }
    popMatrix();
  }
  
  void showMaps() {
    background(0);
    
    float x = 200;
    float y = 15;
    
    pushMatrix();
      translate(x, y);
      
      //LOAD DIRECTORY AND DISCARD UNWANTED FILES
      File dir = new File(sketchPath+"/maps");
      String[] mapChildren = dir.list();
      String[] tmapC = new String[0];
      for(int s=0; s<mapChildren.length; s++) {
        String[] mapSplit = split(mapChildren[s], ".");
        if(mapSplit.length > 1 && mapSplit[mapSplit.length-1].equals("xml")) {
          tmapC = append(tmapC, mapChildren[s]);
        }
      }
      mapChildren = tmapC; 
      mapChildren = sort(mapChildren);  //ALPHABATIZED SORTING
      
      //DRAW ALL MAPTEXT TO SCREEN(AND CHECK FOR CLICKS)
      if(mapChildren == null){
        text("An Error Loading Maps Occured", width/7, height/24, width/32+width/13*6, height/24+height/12*11);
      } else {
        textFont(FONTmaps, 12);
        for(int i=0; i<mapChildren.length; i++) {
          // Get filenagame.meCast of file or directory
          String filenameCast = mapChildren[i];
          fill(255);
          //CHECK MOUSE POS
          if(mouseX > x && mouseX < width/2 && mouseX<x+width/3 && mouseY<height/24+62+i*18+offsetY && mouseY>height/24+50+i*18+offsetY) {
            fill(i*18, 255-(i*10), i*i);
            if(mousePressed && (mouseButton == LEFT)) {
              game = new Engine(mapChildren[i]);
              
              game.setMenuMode(false);
              mainMenu = false;
              
              choosingMaps = false;
              loadMapRepo(mapChildren[i]);
              return;
              
              
              /*
              rsTrays.clear();
              RSelectionTray ph = null;  //POINTER FOR SELECTING TRAYS TO ADD ELEMENTS
              
              ArrayList modeBoxes = new ArrayList();
              ArrayList typeToggle = new ArrayList();
              
              for(int m=0; m<modes.length; m++) {
                modeBoxes.add(new RadioBox(60+85*m, 180, false));
                RadioBox rb = (RadioBox) modeBoxes.get(modeBoxes.size()-1);
                rb.on = settings.defaultGameMode[m];
              }
              typeToggle.add(new ArrowToggle((modes.length*85)/2, 130, types));
              ArrowToggle ar = (ArrowToggle) typeToggle.get(typeToggle.size()-1);
              ar.curSelect = settings.defaultGameType;
              
              rsTrays.add(new RSelectionTray(0, 100, 100+modes.length*85, 100, "MODES:", color(0, 200)));
              ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
              ph.addRadioBoxes(modeBoxes, modes);
              ph.addArrowToggles(typeToggle);

              String[] wepLists = {"DEFAULT"};  //WEAPON LISTS
              File wListDir = new File(sketchPath+"/weapons/lists");  //LOAD ALL WEAPON LISTS FROM 
              String[] wListChildren = wListDir.list();
              for(int s=0; s<wListChildren.length; s++) {
                String[] wListSplit = split(wListChildren[s], ".");
                if(wListSplit.length > 1 && wListSplit[wListSplit.length-1].equals("xml")) wepLists = append(wepLists, wListSplit[0]);
              }
              ArrayList wepToggle = new ArrayList();
              wepToggle.add(new ArrowToggle(100, 280, wepLists));
              rsTrays.add(new RSelectionTray(0, 250, 250, 50, "WEAPON LIST:", color(0, 200)));
              ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
              ph.addArrowToggles(wepToggle);
              
              
              ArrayList vehicleToggle = new ArrayList();
              vehicleToggle.add(new ArrowToggle(100, 380, onOffToggle));
              rsTrays.add(new RSelectionTray(0, 350, 250, 50, "Vehicles:", color(0, 200)));
              ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
              ph.addArrowToggles(vehicleToggle);
              
              ArrayList pickupToggle = new ArrayList();
              pickupToggle.add(new ArrowToggle(100, 480, onOffToggle));
              rsTrays.add(new RSelectionTray(0, 450, 250, 50, "Pickups:", color(0, 200)));
              ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
              ph.addArrowToggles(pickupToggle);
              
              ArrayList powerupToggle = new ArrayList();
              powerupToggle.add(new ArrowToggle(100, 580, onOffToggle));
              rsTrays.add(new RSelectionTray(0, 550, 250, 50, "Powerups:", color(0, 200)));
              ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
              ph.addArrowToggles(powerupToggle);


              ArrowToggle atogCast = null;  //SET POINTER TO NULL SO WE CAN REASSIGN IT ON EACH BOT NUMBER TOGGLE
              
              ArrayList botToggle = new ArrayList();
              botToggle.add(new ArrowToggle(400, 280, amountToggle));  //ALL BOTS
              atogCast = (ArrowToggle) botToggle.get(botToggle.size()-1);
              atogCast.curSelect = Integer.parseInt(amountToggle[game.maxSoldiers]);
              
              for(int m=0; m<4; m++) botToggle.add(new ArrowToggle(400, 330+(m*50), amountToggle));
              
              //EVENS GAME.MAXSOLDIERS THROUGHOUT THE TEAMS
              int curSoldiersAdded = 0;  //USED TO EVEN OUT ROUNDING ERRORS, NEEDS FIXING...
              int curTeamTrack = 0;
              int[] teamSoldierAmount = setArrayToZero(4);
              
              while(curSoldiersAdded < game.maxSoldiers) {
                teamSoldierAmount[curTeamTrack]++;
                curSoldiersAdded++;
                curTeamTrack++;
                if(curTeamTrack == 4) curTeamTrack = 0;
              }
              for(int m=0; m<4; m++) {
                atogCast = (ArrowToggle) botToggle.get(botToggle.size()-1-m);
                atogCast.curSelect = Integer.parseInt(amountToggle[teamSoldierAmount[m]]);
              }
              
              rsTrays.add(new RSelectionTray(300, 250, 500, 350, "Bots:", color(0, 200)));
              ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
              ph.addArrowToggles(botToggle);
              ph.setBotTray(true);
              */
            //  choosingMaps = false;
              
            }
          }
          text(mapChildren[i], 0, height/24+50+i*18+offsetY);  //FINALLY DRAW NAME OF MAP
        }
      }
    popMatrix();
    
    fill(0);
    rect(0, 0, width/2, height/10);
    textFont(FONTmaps, 24);
    fill(255);
    text("Choose Map", 200, height/18);
    
    fill(255);
    text("Load From File", width*0.75, 50);
    if(mousePressed && mouseButton == LEFT && mouseX > width*0.75 && mouseY < 50) {
      String s = selectInput();
      if(s != null) loadMap(s, 0, 0, 1, 1);
    }
    
    showOffset(150);
  }
  
  void showMapOptions() {
    pushMatrix();
      translate(width*0.7, 0);
      fill(0);
      rect(0, 0, width*0.34, 200);
      textFont(FONTtitle);
      fill(255);
      text("Start\nGame", 50, 80);
    popMatrix();
    
    if(mousePressed && mouseButton == LEFT && mouseX > width*0.7 && mouseY < 200) {  //CLICKED ON START GAME
      String tempLevelName = game.levelName;
      game = new Engine(tempLevelName);
      loadMapRepo(tempLevelName);      
      
      game.setMenuMode(false);
      mainMenu = false;
      
      //INIT POINTERS
      RSelectionTray bh = null;
      TextBox tbCast = null;
      ArrowToggle atCast = null;
      RadioBox rbCast = null;
      
      bh = (RSelectionTray) rsTrays.get(0);
      boolean[] gameModes = new boolean[5];
      
      for(int i=0; i<bh.boxes.size(); i++) {
        rbCast = (RadioBox) bh.boxes.get(i);
        gameModes[i] = rbCast.on;
      }
      game.setModes(gameModes);
      
      atCast = (ArrowToggle) bh.arrows.get(0);
      game.setGameType(atCast.curSelect);
      
      bh = (RSelectionTray) rsTrays.get(1);
      atCast = (ArrowToggle) bh.arrows.get(0);
      if(atCast.curSelect != 0) game.setGuns(atCast.options[atCast.curSelect]);
      
      
      bh = (RSelectionTray) rsTrays.get(5);  //SET SOLDIERS TO RIGHT TEAMS
      atCast = (ArrowToggle) bh.arrows.get(0);  //GETS AMOUNT OF PLAYERS OVERALL
      //CORRECT OVERAGE OR UNDERAGE WITH THESE WHILES
      while(game.soldierData.size() < Integer.parseInt(atCast.options[atCast.curSelect])) {
        game.soldierData.add(new Soldier(0, 0));
        Soldier sh = (Soldier) game.soldierData.get(game.soldierData.size()-1);
        sh.setupAnim();
        Spawn curSpawnCast = new Spawn();
        curSpawnCast = (Spawn) curSpawnCast.findSoldierSpawn(sh.team);
        if(curSpawnCast != null) sh.respawn(curSpawnCast.x, curSpawnCast.y);
      }
        
      while(game.soldierData.size() > Integer.parseInt(atCast.options[atCast.curSelect])) {
        Soldier sh = (Soldier) game.soldierData.get(game.soldierData.size()-1);
        if(sh.driving) sh.exitVehicle(false);
        world.remove(sh.self);
        game.soldierData.remove(game.soldierData.size()-1);
      }
      
      if(game.getGameType() != 0 && game.getGameType() != 1) {  //CHANGE TO REFLECT ALL TEAM BASED MODES
        int[] teamSoldierAmount = new int[4];
        for(int i=1; i<5; i++) {  //ONE FOR ALL BOTS THEN 4 FOR EACH TEAM TYPE
          atCast = (ArrowToggle) bh.arrows.get(i);
          teamSoldierAmount[i-1] = Integer.parseInt(atCast.options[atCast.curSelect]);
        }
        
        if(game.getGameType() == 5) {  //FOR CTF, (or any 2 team modes) WE BALANCE CHARLIE AND DELTA BETWEEN ALPHA AND BRAVO
          int extraPlayers = teamSoldierAmount[2]+teamSoldierAmount[3];
          
          int abTeam = 0;
          while(extraPlayers > 1) {
            teamSoldierAmount[abTeam]++;
            if(abTeam == 1) abTeam--;
            else abTeam++;
            extraPlayers--;
          }
        }
        
        int curTeamSelect = 0;
        for(int i=0; i<teamSoldierAmount[curTeamSelect]; i++) {
          Soldier sh = (Soldier) game.soldierData.get(i);
          sh.setTeam(curTeamSelect);
        }
        curTeamSelect++;
        
        for(int i=teamSoldierAmount[curTeamSelect-1]; i<teamSoldierAmount[curTeamSelect-1]+teamSoldierAmount[curTeamSelect]; i++) {
          Soldier sh = (Soldier) game.soldierData.get(i);
          sh.setTeam(curTeamSelect);
        }
        curTeamSelect++;
        
        if(game.getGameType() != 5) {
          for(int i=teamSoldierAmount[curTeamSelect-2]+teamSoldierAmount[curTeamSelect-1]; i<teamSoldierAmount[curTeamSelect-2]+teamSoldierAmount[curTeamSelect-1]+teamSoldierAmount[curTeamSelect]; i++) {
            Soldier sh = (Soldier) game.soldierData.get(i);
            sh.setTeam(curTeamSelect);
          }
          curTeamSelect++;
          for(int i=teamSoldierAmount[curTeamSelect-3]+teamSoldierAmount[curTeamSelect-2]+teamSoldierAmount[curTeamSelect-1]; i<teamSoldierAmount[curTeamSelect-3]+teamSoldierAmount[curTeamSelect-2]+teamSoldierAmount[curTeamSelect-1]+teamSoldierAmount[curTeamSelect]; i++) {
            Soldier sh = (Soldier) game.soldierData.get(i);
            sh.setTeam(curTeamSelect);
          }
        }
      }
    }
    
    for(int i=0; i<rsTrays.size(); i++) {
      RSelectionTray ph = (RSelectionTray) rsTrays.get(i);
      ph.update();
    }
    
    RSelectionTray bh = null;
    pushMatrix();
      translate(330, 280);
      textFont(FONTframeRate, 12);
      fill(255);
      text("Bot Amount", 0, 0);
      fill(255);
      text("Alpha", 0, 50);
      fill(255, 0, 0);
      text("Bravo", 0, 100);
      fill(0, 255, 0);
      text("Charlie", 0, 150);
      fill(0, 0, 255);
      text("Delta", 0, 200);
      
      fill(0, 150);
      bh = (RSelectionTray) rsTrays.get(0);
      ArrowToggle gh = (ArrowToggle) bh.arrows.get(0);
      if(gh.curSelect == 0 || gh.curSelect == 1) rect(-20, 30, 200, 250);
      else if(gh.curSelect == 5) rect(-20, 30, 200, 100);
    popMatrix();
 
    if(baseVehicleData.size() < 2) {
      bh = (RSelectionTray) rsTrays.get(2);
      rect(bh.x, bh.y, bh.w, bh.h);
    }
  }

  void showServers() {
    if(lastConnectAttemptCountDown > 0) lastConnectAttemptCountDown--;
    
    background(0);
    
    fill(255);
    textFont(FONTtitle, 16);
    text("Update Server List", width/3, 30);
    text("Name", width/10, 60);
    text("current", width/10+200, 60);
    text("max", width/10+300, 60);
    text("Password", width/10+350, 60);
    text("Gametype", width/10+450, 60);
    text("IP:Port", width/10+600, 60);
    
    textFont(FONTtitle, 12);
    for(int i=0; i<serverList.servers.size(); i++) {
      if(mouseY>84+i*16 && mouseY<100+i*16) {
        fill(255, 0, 0);
        if(mousePressed && mouseButton == LEFT) {
          ServerList.Server ph = (ServerList.Server) serverList.servers.get(i);
          connectToServer(ph.ip, ph.port);
        }
      } else {
        fill(255);
      }
      
      ServerList.Server ph = (ServerList.Server) serverList.servers.get(i);
      text(ph.name, width/10, 100+i*20);
      text(ph.curPlayers, width/10+200, 100+i*20);
      text(ph.maxPlayers, width/10+300, 100+i*20);
      if(ph.passworded) rect(width/10+350, 100+i*20, 20, 20);
      if(ph.gameType == 1) { text("DM", width/10+450, 100+i*20); }
      if(ph.gameType == 2) { text("TM", width/10+450, 100+i*20); }
      if(ph.gameType == 3) { text("CTF", width/10+450, 100+i*20); }
      text(ph.ip+":"+ph.port, width/10+600, 100+i*20);
    }
    
    if(mousePressed && mouseButton == LEFT && mouseX > width/4 && mouseX < width/4*3 && mouseY < 60) requestServerList();
    showOffset(width/25);    
  }
  
  void showOptions() {
    background(0);
    textFont(FONTtitle);
    fill(255);
    text("Options", width/3, 50);
    textFont(FONTtitle, 16);
    
    for(int i=0; i<rsTrays.size(); i++) {
      RSelectionTray ph = (RSelectionTray) rsTrays.get(i);
      ph.update();
    }
    
    pushMatrix();
      translate(width*0.7, height*0.85);
      beginShape();
        fill(0, 255, 0, 100);
        vertex(0, height*0.15);
        vertex(0, 0);
        vertex(width*0.3, 0);
        fill(0, 150, 0, 100);
        vertex(width*0.3, height*0.15);
      endShape();
      textFont(FONTtitle);
      fill(255);
      text("Save", 60, 60);
    popMatrix();
    
    if(mousePressed && mouseButton == LEFT && mouseX > width*0.7 && mouseY > height*0.85) {  //CLICKED ON SAVE
      //INIT POINTERS
      RSelectionTray ph = null;
      TextBox tbCast = null;
      ArrowToggle atCast = null;
      RadioBox rbCast = null;
      //GET NAME
      ph = (RSelectionTray) rsTrays.get(0);
      tbCast = (TextBox) ph.textboxes.get(0);
      settings.playerName = tbCast.data;
      //GET DEFAULT MODES
      ph = (RSelectionTray) rsTrays.get(1);
      atCast = (ArrowToggle) ph.arrows.get(0);
      settings.defaultGameType = atCast.curSelect;
      for(int i=0; i<ph.boxes.size(); i++) {
        rbCast = (RadioBox) ph.boxes.get(i);
        settings.defaultGameMode[i] = rbCast.on;
      }
      //GET GFX SETTINGS
      ph = (RSelectionTray) rsTrays.get(2);
      for(int i=0; i<ph.boxes.size(); i++) {
        rbCast = (RadioBox) ph.boxes.get(i);
        if(i == 0) settings.drawTextures = rbCast.on;
        if(i == 1) settings.drawScenery = rbCast.on;
        if(i == 2) settings.frameCheck = rbCast.on;
      }
      
    
      /*PrintWriter map_file = createWriter("settings/base.xml"); 
      map_file.println("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>");
      map_file.println("<settings>");
      
      map_file.println("<playerName>"+defaultName+"</playerName>");
      map_file.println("<defaultModesSelected gameType=\""+defaultGameType+"\" zombie=\""+defaultGameMode[0]+"\" bitch=\""+defaultGameMode[1]+"\" completion=\""+defaultGameMode[3]+"\"></defaultModesSelected>");
      map_file.println("<killConsole x=\"0\" y=\"0\" w=\"250\" h=\"100\" cap=\"6\">true</killConsole>");
      map_file.println("<drawPretty>"+defaultDrawPretty+"</drawPretty>");
      map_file.println("<drawScenery>"+defaultDrawScenery+"</drawScenery>");
      map_file.println("<disableFrameCheck>"+defaultDisableFixFrameRate+"</disableFrameCheck>");
      map_file.println("<lobby ip=\"127.0.0.1\" port=\"12300\"></lobby>");
      
      map_file.println("</settings>");
      map_file.flush();
      map_file.close(); 
      */
      
      println("Done Saving.");
      options = false;  //BACK TO MAIN MENU
    }
  }
  
  void showCredits() {
    background(0);
    //showOffset();
    textFont(FONTtitle);
    fill(255);
    text("Credits", width/3, 50);
    textFont(FONTtitle, 16);
    
    text("Programming: Jett", width/5, 200);
    text("Levels: VirtualTT, Monsteri, Smiluu, Jett", width/5, 250);
  }
  
  void showInstructions() {
    //MAYBE SOME INSTRUCTION-SCRIPT SPECIFIC CODE AT SOME POINT
  }
  
  void showBackButton() {
    float x = 0;
    float y = 0;
    float w = 100;
    float h = 100;
    
    if(backButtonCountDown > 0) backButtonCountDown--;
    if(dist(x, y, mouseX, mouseY) < w && mousePressed && mouseButton == LEFT && backButtonCountDown < 1) {
      backButtonCountDown += 10;
      if(maps && !choosingMaps) {
        choosingMaps = true;
        return;
      }
      maps = false;
      servers = false;
      options = false;
      credits = false;
      instructions = false;
      choosingMaps = false;
      offsetY = 0;
      playingOnline = false;
    }
    
    pushMatrix();
      translate(x, y);
      smooth();
      beginShape();
        if(dist(x, y, mouseX, mouseY) < w) fill(0, 160, 40, 255);
        else fill(0, 120, 30, 170);
        vertex(0, 0);
        vertex(w, 0);
        if(dist(x, y, mouseX, mouseY) < w) fill(0, 200, 50, 255);
        else fill(0, 200, 50, 170);
        vertex(0, h);
      endShape();
      noSmooth();
      fill(0);
      textFont(FONTframeRate);
      text("Back", 0, 0);
    popMatrix();
  }
  
  void showOffset(int x) {
    fill(255);
    stroke(255);
    
    line(x, 0, x, height);
    triangle(x, 0, x-15, 15, x+15, 15);
    triangle(x, height, x-15, height-15, x+15, height-15);
    
    if(mouseX < x+15 && mouseX > x-15) {
      if(mouseY > height*0.8) offsetY -= map(height*0.8-mouseY, 0, height*0.2, 8, 0);
      if(mouseY < height*0.2) offsetY += map(mouseY, 0, height*0.2, 8, 0);
    }
    
    noStroke();
  }
  
  String getRandomMap() {
    File dir = new File(sketchPath+"/maps");
    String[] mapChildren = dir.list();
    String[] tmapC = new String[0];
    
    for(int s=0; s<mapChildren.length; s++) {
      String[] mapSplit = split(mapChildren[s], ".");
      if(mapSplit.length > 1 && mapSplit[mapSplit.length-1].equals("xml")) tmapC = append(tmapC, mapChildren[s]);
    }
    
    mapChildren = tmapC; 
    return mapChildren[int(random(0, mapChildren.length))];
  }
  
  Spawn findClosestSpawn(float x_, float y_) {
    float d = 10000;
    int n = 0;
    
    for(int i=0; i<game.spawnData.size(); i++) {
      Spawn ph = (Spawn) game.spawnData.get(i);
      if(ph.type == 6) {
        if(dist(x_, y_, ph.x, ph.y) < d) {
          n = i;
          d = dist(x_, y_, ph.x, ph.y);
        }
      }
    }
    
    return (Spawn) game.spawnData.get(n);
  }
  
  void addOptionsMenuData() {
    rsTrays.clear();
    RSelectionTray ph = null;  //POINTER FOR SELECTING TRAYS TO ADD ELEMENTS
    
    //ADD NAME BOX
    rsTrays.add(new RSelectionTray(50, 150, 250, 50, "NAME:", color(0, 0, 200, 100)));
    ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
    ArrayList tBoxes = new ArrayList();
    tBoxes.add(new TextBox(55, 155, 240, 40, 15, settings.playerName));
    ph.addTextBoxes(tBoxes);
    
    //ADD MODE BOX
    ArrayList modeBoxes = new ArrayList();
    ArrayList typeToggle = new ArrayList();
    
    for(int m=0; m<modes.length; m++) {
      modeBoxes.add(new RadioBox(75+85*m, 320, false));
      RadioBox rb = (RadioBox) modeBoxes.get(modeBoxes.size()-1);
      rb.on = settings.defaultGameMode[m];
    }
    typeToggle.add(new ArrowToggle((modes.length*85)/2+50, 280, types));
    ArrowToggle ar = (ArrowToggle) typeToggle.get(typeToggle.size()-1);
    ar.curSelect = settings.defaultGameType;
    rsTrays.add(new RSelectionTray(50, 250, 100+modes.length*85, 100, "DEFAULT MODES:", color(200, 0, 0, 100)));
    ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
    ph.addRadioBoxes(modeBoxes, modes);
    ph.addArrowToggles(typeToggle);
    
    //ADD GRAPHICS BOX
    rsTrays.add(new RSelectionTray(50, 400, 320, 50, "GRAPHICS:", color(0, 0, 200, 100)));
    ph = (RSelectionTray) rsTrays.get(rsTrays.size()-1);
    String[] gfxToggles = {"Texture", "Scenery", "Disable Frame-Check"};  //GAME MODES
    ArrayList gBoxes = new ArrayList();
    
    for(int m=0; m<gfxToggles.length; m++) {
      gBoxes.add(new RadioBox(75+85*m, 420, false));
      RadioBox rb = (RadioBox) gBoxes.get(gBoxes.size()-1);
      if(m == 0) rb.on = settings.drawTextures;
      else if(m == 1) rb.on = settings.drawScenery;
      else if(m == 2) rb.on = settings.frameCheck;
    }
    ph.addRadioBoxes(gBoxes, gfxToggles);
    
  }
  
  
  void drawPauseScreen() {
    int cBoxX = width/2-width/8;
    int cBoxY = height/2-height/8;
    int cBoxW = width/4;
    int cBoxH = height/4;
    
    int[] colour = new int[4];
    for(int i=0; i<colour.length; i++) colour[i] = 0;
    colour[3] = 100;
    
    beginShape(QUADS);
      //CENTER
      fill(colour[0], colour[1], colour[2], colour[3]);
      vertex(cBoxX, cBoxY);
      vertex(cBoxX+cBoxW, cBoxY);
      vertex(cBoxX+cBoxW, cBoxY+cBoxH);
      vertex(cBoxX, cBoxY+cBoxH);
      //TOP
      fill(colour[0], colour[1], colour[2], 10);
      vertex(0, 0);
      vertex(width, 0);
      fill(colour[0], colour[1], colour[2], colour[3]);
      vertex(cBoxX+cBoxW, cBoxY);
      vertex(cBoxX, cBoxY);
      //Bottom
      fill(colour[0], colour[1], colour[2], 10);
      vertex(0, height);
      vertex(width, height);
      fill(colour[0], colour[1], colour[2], colour[3]);
      vertex(cBoxX+cBoxW, cBoxY+cBoxH);
      vertex(cBoxX, cBoxY+cBoxH);
      //LEFT
      fill(colour[0], colour[1], colour[2], 10);
      vertex(0, 0);
      vertex(0, height);
      fill(colour[0], colour[1], colour[2], colour[3]);
      vertex(cBoxX, cBoxY+cBoxH);
      vertex(cBoxX, cBoxY);
      //RIGHT
      fill(colour[0], colour[1], colour[2], 10);
      vertex(width, 0);
      vertex(width, height);
      fill(colour[0], colour[1], colour[2], colour[3]);
      vertex(cBoxX+cBoxW, cBoxY+cBoxH);
      vertex(cBoxX+cBoxW, cBoxY);
    endShape();
    
    pushMatrix();
      translate(width/3, height/4);
      textFont(FONTtitle, 36);
      fill(255);
      text("PAUSED", 0, 36);
      textFont(FONTtitle, 24);
      text("Press 'M' for main menu", width/7, 60);
      text("Press 'P' to continue", width/7, 60+24);
    popMatrix();
    
    textFont(FONTframeRate, 16);    
    fill(255);
    for(int i=0; i<game.soldierData.size(); i++) {
      Soldier ph = (Soldier) game.soldierData.get(i);
      if(game.getGameType() != 0 || game.getGameType() != 1) {
        if(ph.team == 0) fill(255, 255, 255, 255);
        else if(ph.team == 1) fill(255, 200, 200, 255);
        else if(ph.team == 2) fill(200, 255, 200, 255);
        else if(ph.team == 3) fill(200, 200, 255, 255);
      }
      text(ph.name, width/10, 100+i*20);
      text(ph.kills+"/"+ph.deaths, width/4, 100+i*20);
    }
      
    textFont(FONTtitle, 24);
    if(game.getGameType() != 0 || game.getGameType() != 1) {
      pushMatrix();
        translate(width/2, 35);
        String[] teamScores = game.getScoresText();
        fill(0);
        if(teamScores != null) {
          for(int i=0; i<teamScores.length; i++) {
            if(i == 0) fill(255, 255, 255, 255);
            else if(i == 1) fill(255, 200, 200, 255);
            else if(i == 2) fill(200, 255, 200, 255);
            else if(i == 3) fill(200, 200, 255, 255);
            text(teamScores[i], i*100, 0);
          }
        }
      popMatrix();
    }
  }
  
  
  /*
  class List {
    float x;
    float y;
    float w;
    float h;
    boolean scrollable;
    int scrollSide;  //0 is left, 1 is bottom
    String data[];
    
    List(float x_, float y_, float w_, float h_) {
      x = x_;
      y = y_;
      w = w_;
      h = h_;
      scrollable = true;
      scrollSide = 0;
    }
    
    void setScroll(boolean set_, int side_) {
      scrollable = set_;
      scrollSide = side_;
    }
    
    void setData(String[] data_) { data = data_; }
    
    int update() {
      pushMatrix();
        translate(x, y+offsetY);
        textFont(FONTmaps, 12);
        for(int i=0; i<data.length; i++) {
          text(data[i], 0, i*18);
          if(mousePressed && mouseButton == LEFT && mouseX > x && mouseX < x+w && mouseY > y+(i*18) && mouseY < y+(i*18)+20) return i;
        }
      popMatrix();

      return 0;
    }
    
    
    void showOffset() {
      pushMatrix();
        translate(x, y);
        fill(255);
        stroke(255);
        
        line(0, 0, 0, h);
        triangle(0, 0,-15, 15, 15, 15);
        triangle(0, h, -15, h-15, 15, h-15);
        
        if(mouseX < width/10) {
          if(mouseY > height*0.8) offsetY -= map(height*0.8-mouseY, 0, height*0.2, 8, 0);
          if(mouseY < height*0.2) offsetY += map(mouseY, 0, height*0.2, 8, 0);
        }
        
        noStroke();
    }
  }
  */
  
  class RSelectionTray {
    int x;
    int y;
    int w;
    int h;
    String title;
    ArrayList boxes;
    ArrayList arrows;
    ArrayList textboxes;
    String[] names;
    color bgColor;
    boolean bots;
    
    RSelectionTray(int x, int y, int w, int h, String title, color bgColor) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.title = title;
      this.bgColor = bgColor;
      bots = false;
      
      boxes = new ArrayList();
      arrows = new ArrayList();
      textboxes = new ArrayList();
    }
    
    void addRadioBoxes(ArrayList boxes, String[] names) {
      this.boxes = boxes;
      this.names = names;
    }
    
    void addArrowToggles(ArrayList arrows) { this.arrows = arrows; }
    
    void addTextBoxes(ArrayList textboxes) { this.textboxes = textboxes; }
    
    void setBotTray(boolean bots) { this.bots = bots; }
    
    void update() {
      pushMatrix();
        translate(x, y);
        textFont(FONTframeRate, 12);
        fill(bgColor);
        rect(0, 0, w, h);
        
        pushMatrix();
          translate(w/2-50, 0);
          rect(-20, -20, 20+title.length()*10, 20);
          fill(255);
          text(title, 0, 0);
        popMatrix();
      popMatrix();
      
      for(int i=0; i<boxes.size(); i++) {
        RadioBox ph = (RadioBox) boxes.get(i);
        ph.update();
        fill(255);
        text(names[i], ph.x-15, ph.y-5);
      }
      
      for(int i=0; i<arrows.size(); i++) {
        ArrowToggle ph = (ArrowToggle) arrows.get(i);
        ph.update();
      }
      
      for(int i=0; i<textboxes.size(); i++) {
        TextBox ph = (TextBox) textboxes.get(i);
        ph.update();
      }
      
      if(bots) {  //IF THIS IS THE BOT LIST WE NEED TO BALANCE IT OUT
        int maxSoldiers = 0;
        int[] teamSoldierAmount = new int[4];
        
        for(int i=0; i<5; i++) {  //ONE FOR ALL BOTS THEN 4 FOR EACH TEAM TYPE
          ArrowToggle ph = (ArrowToggle) arrows.get(i);
          if(i == 0) maxSoldiers = Integer.parseInt(ph.options[ph.curSelect]);
          else teamSoldierAmount[i-1] = Integer.parseInt(ph.options[ph.curSelect]);
        }
        
        ArrowToggle[] allSoldiersArrowCast = new ArrowToggle[5];
        for(int i=0; i<5; i++) allSoldiersArrowCast[i] = (ArrowToggle) arrows.get(i);
        if(allSoldiersArrowCast[0].countDown > 0) {
          while(maxSoldiers > (teamSoldierAmount[0]+teamSoldierAmount[1]+teamSoldierAmount[2]+teamSoldierAmount[3])) {  //UPDATE TO REFLECT INCREASE
            int tId = 0;  //ID OF TEAM
            int tN = 32;  //VALUE TO COMPARE
            
            for(int i=0; i<teamSoldierAmount.length; i++) {  //ITERATE AND FIND SMALLEST
              if(teamSoldierAmount[i] < tN) {
                tId = i;
                tN = teamSoldierAmount[i];
              }
            }
            
            teamSoldierAmount[tId]++;  //UPDATE SMALLEST TEAM
          }
          
          while(maxSoldiers < (teamSoldierAmount[0]+teamSoldierAmount[1]+teamSoldierAmount[2]+teamSoldierAmount[3])) {  //UPDATE TO REFLECT DECREASE
            int tId = 0;  //ID OF TEAM
            int tN = 0;  //VALUE TO COMPARE
            
            for(int i=0; i<teamSoldierAmount.length; i++) {  //ITERATE AND FIND LARGEST
              if(teamSoldierAmount[i] > tN) {
                tId = i;
                tN = teamSoldierAmount[i];
              }
            }
            
            teamSoldierAmount[tId]--;  //UPDATE LARGEST TEAM
          }
          
          for(int m=0; m<4; m++) {
            ArrowToggle atogCast = (ArrowToggle) arrows.get(m+1);
            atogCast.curSelect = Integer.parseInt(amountToggle[teamSoldierAmount[m]]);
          }
        } else if(allSoldiersArrowCast[1].countDown > 0 || allSoldiersArrowCast[2].countDown > 0 || allSoldiersArrowCast[3].countDown > 0 || allSoldiersArrowCast[4].countDown > 0) {
          ArrowToggle atogCast = (ArrowToggle) arrows.get(0);
          atogCast.curSelect = constrain(Integer.parseInt(amountToggle[teamSoldierAmount[0]+teamSoldierAmount[1]+teamSoldierAmount[2]+teamSoldierAmount[3]]), 0, 32);
        }
      }
    }
  }
  
  class RadioBox {
    int x;
    int y;
    boolean on;
    int countDown;
    
    RadioBox(int x, int y, boolean on) {
      this.x = x;
      this.y = y;
      this.on = on;
      countDown = 0;
    }
    
    void update() {
      if(!on) fill(255);
      else fill(random(0, 255), random(0, 255), random(0, 255), 255);
      //else fill(50, 185, 225);
      
      rect(x, y, 10, 10);
      
      if(countDown > 0) countDown--;
      if(mousePressed && mouseButton == LEFT && dist(x, y, mouseX, mouseY) < 20 && countDown == 0) {
        if(on) on = false;
        else on = true;
        countDown += 10;
      }
    }
  }
  
  class TextBox {
    int x;
    int y;
    int w;
    int h;
    boolean selected;
    String data;
    int maxLength;
    
    boolean alphabet;
    boolean numeric;
    boolean special;
    
    TextBox(int x, int y, int w, int h, int maxLength, String content) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.maxLength = maxLength;
      selected = false;
      data = content;
      
      alphabet = true;
      numeric = true;
      special = true;
    }
    
    void setInputType(boolean alphabet, boolean numeric, boolean special) {
      this.alphabet = alphabet;
      this.numeric = numeric;
      this.special = special;
    }
    
    void update() {
      fill(255);
      if(selected) {
        stroke(20, 50, 190, 100);
        strokeWeight(3);
      }
      rect(x, y, w, h);
      noStroke();
      
      fill(0);
      textFont(FONTframeRate, h);
      text(data, x, y+h);
      
      if(mousePressed && mouseButton == LEFT) {
        if(mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) selected = true;
        else selected = false;
      }
      
      if(keyPressed && keyHeld && selected) {
        if(key == BACKSPACE && data.length() > 0 && key != CODED) {
          StringBuffer buf = new StringBuffer(data.length()-1);
          buf.append(data.substring(0,data.length()-1));
          data = buf.toString();
        } else if(data.length() < maxLength) {
          if((!alphabet && checkAlphabet(key)) || (!numeric && checkNumeric(key)) || (!special && checkSpecial(key))) {
            return;
          } else if(checkAlphabet(key) || checkNumeric(key) || checkSpecial(key)) { 
            StringBuffer buf = new StringBuffer(data.length());
            buf.append(data);
            buf.append(Character.toString(key));
            data = buf.toString();
          }
        }
        keyHeld = false;
      }
    }
    
    boolean checkAlphabet(char d) {
      if(d == 'a' || d == 'A' || d == 'b' || d == 'B' || d == 'c' || d == 'C' || d == 'd' || d == 'D' || d == 'e' || d == 'E' || d == 'f' || d == 'F' || d == 'g' || d == 'G' || d == 'h' || d == 'H' || d == 'i' || d == 'I' || d == 'j' || d == 'J' || d == 'k' || d == 'K' || d == 'l' || d == 'L' || d == 'm' || d == 'M' || d == 'n' || d == 'N' || d == 'o' || d == 'O' || d == 'p' || d == 'P' || d == 'q' || d == 'Q' || d == 'r' || d == 'R' || d == 's' || d == 'S' || d == 't' || d == 'T' || d == 'u' || d == 'U' || d == 'v' || d == 'V' || d == 'w' || d == 'W' || d == 'x' || d == 'X' || d == 'y' || d == 'Y' || d == 'z' || d == 'Z') return true;
      return false;
    } 
    
    boolean checkNumeric(char d) {
      if(d == '0' || d == '1' || d == '2' || d == '3' || d == '4' || d == '5' || d == '6' || d == '7' || d == '8' || d == '9') return true;
      return false;
    }
    
    boolean checkSpecial(char d) {
      if(d == ' ' || d == '/' || d == '\\' || d == '(' || d == ')' || d == '[' || d == ']' || d == '-' || d == '_' || d == '{' || d == '}' || d == '<' || d == '>' || d == '.' || d == ',' || d == '?' || d == '!' || d == '$' || d == '&' || d == '@' || d == '#' || d == '^' || d == '%' || d == '*' || d == ';' || d == ':' || d == '|' || d == '`' || d == '~') return true;
      return false;
    } 
  }
  
  class ArrowToggle {
    int x;
    int y;
    String[] options;
    
    int curSelect;
    int countDown;
    
    ArrowToggle(int x, int y, String[] options) {
      this.x = x;
      this.y = y;
      this.options = options;
      
      curSelect = 0;
      countDown = 0;
    }
    
    void update() {
      pushMatrix();
        translate(x, y);
        fill(255);
        triangle(0, -2, 10, -10, 20, -2);
        triangle(0, 2, 10, 10, 20, 2);
        
        fill(255);
        textFont(FONTframeRate, 12);
        text(options[curSelect], 20, 0);
      popMatrix();
      
      if(countDown > 0) countDown--;
      if(mousePressed && mouseButton == LEFT && mouseX > x && mouseX < x+20 && mouseY > y-10 && mouseY < y+10 && countDown == 0) {
        if(mouseY < y) {
          if(curSelect < 1) curSelect = options.length-1;
          else curSelect--;
        } else {
          if(curSelect > options.length-2) curSelect = 0;
          else curSelect++;
        }
        countDown += 10;
      }
    }
  }
}
