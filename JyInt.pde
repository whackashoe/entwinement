class JyInt {
  private PythonInterpreter interp;
  public boolean alive;
  String comToScript = "";  //HOLDS COMMANDS TO SEND TO SCRIPT
  
  String[] toWorldDraw;
  String[] toScreenDraw;
 
  ArrayList classData;  //holds all script and "register" fields
  
  JyInt(String src[], String ver[]) {
    alive = true;
    classData = new ArrayList();
    
    try {
      interp = new PythonInterpreter(null, new PySystemState());
      
      PySystemState sys = Py.getSystemState();           
      interp.execfile(sketchPath+"/scripts/core/core.py");
      interp.set("enginePoint", Py.java2py(game));
      interp.execfile(sketchPath+"/scripts/core/io.py");
      interp.execfile(sketchPath+"/scripts/core/events.py");
      interp.execfile(sketchPath+"/scripts/core/draw.py");
      //load class files
      interp.execfile(sketchPath+"/scripts/core/soldier.py");
      interp.execfile(sketchPath+"/scripts/core/spawn.py");
      interp.execfile(sketchPath+"/scripts/core/vehicle.py");
      interp.execfile(sketchPath+"/scripts/core/polygon.py");
    } catch(Exception e) {
      alive = false;
      System.err.println("An error arose in core");
      e.printStackTrace();
    }

    for(int i=0; i<src.length; i++) loadScript(src[i], ver[i]);
  }
  
  void loadScript(String name, String version) {
    try {
      interp.execfile(sketchPath+"/scripts/"+name+"_v"+version+".py");
      interp.exec(name+" = "+name+"()");
    } catch(Exception e) {
      System.err.println("An error arose in: scripts/"+name+"_v"+version+".py");
      e.printStackTrace();
      exitProgram();
    }
    
    classData.add(new Register(name, version));
    
    println(name+" version:"+version+" loaded");
  }
  
  void update() {
    comToScript = "";  //RESETS COMMANDS READY TO SEND TO SCRIPT
    toWorldDraw = new String[0];
    toScreenDraw = new String[0];
   
    if(game != null) {
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.requestMouseKeyboard) {
          sendMouseKeyboardData();  //if sent we finish loop as it only needs to be sent once
          break;
        }
      }
    }
    
    for(int i=0; i<classData.size(); i++) {
      Register ph = (Register) classData.get(i);
      if(ph.scriptUpdate) interp.exec(ph.name+".update()");  //GETS RETURN OF UPDATE, 0 IS STOP CALLING UPDATE
    }
    
    
    toGame((String) interp.get("com", String.class));  //SEND DATA TO PARSER

    toScreenDraw = splitTokens(interp.eval("getScreenDraw()").asString(), ";");
    toWorldDraw = splitTokens(interp.eval("getWorldDraw()").asString(), ";");

    interp.eval("reset()").__tojava__(Integer.class);  //finish
  }
  
  void toGame(String n) {    
    String[] commands = splitTokens(n, ";");
    for(int i=0; i<commands.length; i++) parse(commands[i]);  //CARRY OUT ACTIONS AND MAY APPEND DATA TO COMTOSCRIPT
    
    if(!comToScript.equals("")) toScript(comToScript);  //SEND DATA TO SCRIPT IF ANY HAS BEEN BUILT
  }
  
  void toScript(String n) {
    String[] commands = splitTokens(n, ";");
    for(int i=0; i<commands.length; i++) interp.eval(commands[i]);  //SEND COMMANDS TO SCRIPT
  }
  
  void parse(String data) {
    StringBuffer buf = null;
   
    if(data.length() > 1) {
      //NOW WE SPLIT IT INTO PIECES
      String[] piece = split(data, ' ');
      
      if(piece.length > 1) {
        for(int i=0; i<piece.length; i++) {
          if(piece[i].equals("")) {
           game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
            return;
          }
        }
      }
      
      //AND CHECK FOR COMMANDS
      if(piece[0].equals("commands")) {
        game.kConsole.addKillBoxText("*****COMMAND LIST*****", game.kConsole.blue);
        game.kConsole.addKillBoxText("____________________", game.kConsole.white);
        if(piece.length == 1) {
          game.kConsole.addKillBoxText("Welcome to Entwinement", game.kConsole.white);
          game.kConsole.addKillBoxText("", game.kConsole.white);
          game.kConsole.addKillBoxText("Type \"/commands load\" for commands related to loading", game.kConsole.white);
          game.kConsole.addKillBoxText("Type \"/commands add\" for commands related to adding things to world", game.kConsole.white);
          game.kConsole.addKillBoxText("Type \"/commands remove\" for commands related to removing things from world", game.kConsole.white);
          game.kConsole.addKillBoxText("Type \"/commands alter\" for commands related to altering world", game.kConsole.white);
        }
        
        if(piece.length == 2) {
          if(piece[1].equals("load")) {
            game.kConsole.addKillBoxText("/l bv (filename)", game.kConsole.white);
            game.kConsole.addKillBoxText("Loads vehicle, must load before adding", game.kConsole.blue);
            game.kConsole.addKillBoxText("/l g (filename)", game.kConsole.white);
            game.kConsole.addKillBoxText("Loads gun", game.kConsole.blue);
            game.kConsole.addKillBoxText("/l gl (filename)", game.kConsole.white);
            game.kConsole.addKillBoxText("Loads gunlist", game.kConsole.blue);
            game.kConsole.addKillBoxText("/l sc (filename)", game.kConsole.white);
            game.kConsole.addKillBoxText("Loads script", game.kConsole.blue);
            game.kConsole.addKillBoxText("/l m (filename) (x) (y) (scaleX) (scaleY)", game.kConsole.white);
            game.kConsole.addKillBoxText("Loads map layer", game.kConsole.blue);
            game.kConsole.addKillBoxText("/l tex (filename)", game.kConsole.white);
            game.kConsole.addKillBoxText("Loadsmaptexture", game.kConsole.blue);
          } else if(piece[1].equals("add")) {
            game.kConsole.addKillBoxText("/a s (team)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds soldier", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a sp (x) (y) (type) (subtype) (amount)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds spawn", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a p (type) (x1) (y1) (x2) (y2) (x3) (y3) (denity) (restitution) (friction) (red) (green) (blue) (alpha)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds polygon", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a v (type) (x) (y)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds vehicle, type is integer (0 for first baseVehicle loaded)", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a scen (filename) (x) (y) (z) (width) (height) (rotation)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds scenery", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a b (x) (y) (xforce) (yforce) (type) (soldierid)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds bullet", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a ea (x) (y) (radius) (size) (detail)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds earth", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a gr (x) (y) (strength) (distance)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds gravitron", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a hb (x) (y) (amount)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds healthbox", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a ab (x) (y) (type) (amount)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds attachment box", game.kConsole.blue);
            game.kConsole.addKillBoxText("/a gb (x) (y) (type) (ammo) (reloadtimer) (reloading)", game.kConsole.white);
            game.kConsole.addKillBoxText("Adds gun box", game.kConsole.blue);
          } else if(piece[1].equals("alter")) {
            game.kConsole.addKillBoxText("/c_g (x) (y)", game.kConsole.white);
            game.kConsole.addKillBoxText("Change gravity", game.kConsole.blue);
            game.kConsole.addKillBoxText("/c_c (time) (ex) (ey) (ez) (tx) (ty) (tz)", game.kConsole.white);
            game.kConsole.addKillBoxText("Change Camera for set time", game.kConsole.blue);
          }
        }
      }
      
      else if(piece[0].equals("req") || piece[0].equals("request")) {
         if(piece[1].equals("s")) {
            Soldier ph = (Soldier) game.getSoldierById(Integer.parseInt(piece[2]));
            if(piece[3].equals("pv")) {
              comToScript += "getSoldierById("+Integer.toString(ph.id)+").setPosition("+ph.self.getX()+", "+ph.self.getY()+", "+ph.self.getVelocityX()+", "+ph.self.getVelocityY()+");";
            } else if(piece[3].equals("g")) {
              comToScript += "getSoldierById("+Integer.toString(ph.id)+").setGunInfo("+ph.curGun.gun+", "+ph.curGun.ammo+", \""+Integer.toString(ph.curGun.reloadCount)+"\");";
            }
            
         } else if(piece[1].equals("v")) {
            Vehicle ph = (Vehicle) game.getVehicleById(Integer.parseInt(piece[2]));
            if(piece[3].equals("pv")) {
              comToScript += "getVehicleById("+Integer.toString(ph.id)+").setPosition("+ph.getCockpit().getX()+", "+ph.getCockpit().getY()+", "+ph.getCockpit().getVelocityX()+", "+ph.getCockpit().getVelocityY()+");";
            }
            
         } else if(piece[1].equals("p")) {
           if(piece[2].equals("c")) {
             comToScript += "d_polygon_count = "+Integer.toString(game.polyData.size())+";";
           } else if(piece.length > 2) {
             Polygon ph = (Polygon) game.polyData.get(Integer.parseInt(piece[piece.length-1]));
             if(piece[2].equals("t")) {
               comToScript += "getPolygon("+piece[3]+").setType("+ph.type+");";
             } else if(piece[2].equals("p")) {
               comToScript += "getPolygon("+piece[3]+").setPosition("+Float.toString(ph.x[0])+", "+Float.toString(ph.y[0])+", "+Float.toString(ph.x[1])+", "+Float.toString(ph.y[1])+", "+Float.toString(ph.x[2])+", "+Float.toString(ph.y[2])+");";
             } else if(piece[2].equals("z")) {
               comToScript += "getPolygon("+piece[3]+").setZAxis("+Float.toString(ph.z[0])+", "+Float.toString(ph.z[1])+", "+Float.toString(ph.z[2])+");";
             } else if(piece[2].equals("r")) {
               comToScript += "getPolygon("+piece[3]+").setRHW("+Float.toString(ph.rhw[0])+", "+Float.toString(ph.rhw[1])+", "+Float.toString(ph.rhw[2])+");";
             } else if(piece[2].equals("u")) {
               comToScript += "getPolygon("+piece[3]+").setUV("+Float.toString(ph.u[0])+", "+Float.toString(ph.v[0])+", "+Float.toString(ph.u[1])+", "+Float.toString(ph.v[1])+", "+Float.toString(ph.u[2])+", "+Float.toString(ph.v[2])+");";
             } else if(piece[2].equals("v")) {
               comToScript += "getPolygon("+piece[3]+").setVColours("+Float.toString(ph.vR[0])+", "+Float.toString(ph.vG[0])+", "+Float.toString(ph.vB[0])+", "+Float.toString(ph.vA[0])+Float.toString(ph.vR[1])+", "+Float.toString(ph.vG[1])+", "+Float.toString(ph.vB[1])+", "+Float.toString(ph.vA[1])+Float.toString(ph.vR[2])+", "+Float.toString(ph.vG[2])+", "+Float.toString(ph.vB[2])+", "+Float.toString(ph.vA[2])+")";
             }
           }
         }
        
      } else if(piece[0].equals("ls") || piece[0].equals("list")) {  //LIST
        if(piece.length == 1) {  //EXPLAIN LISTING REQUIRES ARGUMENT
          System.err.println("ls requires an argument\n      s for soldiers\n      bv for basevehicles\n      v for vehicles");
        } else if(piece.length == 2) {  //USE LISTING NORMALLY
          if(game.soldierData.size() > 0 && (piece[1].equals("sn") || piece[1].equals("soldiernames"))) {  //LIST SOLDIERSNAMES
            comToScript += "getSoldierNames(";
            for(int i=0; i<game.soldierData.size(); i++) {
              Soldier ph = (Soldier) game.soldierData.get(i);
              comToScript += "\""+ph.name+"\"";
              if(i != game.soldierData.size()-1) comToScript += ",";
            }
            comToScript += ");";
          } else if(baseVehicleData.size() > 0 && (piece[1].equals("bv") || piece[1].equals("basevehicle"))) {
            comToScript += "getVehicleNames(";
            for(int i=0; i<baseVehicleData.size(); i++) {
              Vehicle ph = (Vehicle) baseVehicleData.get(i);
              comToScript += "\""+ph.name+"\"";
              if(i != baseVehicleData.size()-1) comToScript += ",";
            }
            comToScript += ");";
          } else if(piece[1].equals("v") || piece[1].equals("vehicle")) {
            /*println("*****LISTING VEHICLES*****");
            for(int i=0; i<game.vehicleData.size(); i++) {
              Vehicle ph = (Vehicle) game.vehicleData.get(i);
              println("**"+i+"**"+ph.name+"**"+ph.id+"**");
            }
            */
          } else {
            game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
          }
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
      } else if(piece[0].equals("l") || piece[0].equals("load")) {  //LOAD SOMETHING FOR MAP
        if(piece[1].equals("bv") || piece[1].equals("basevehicle")) {
          String[] xmlSplit = split(piece[2], '.');
          if(xmlSplit.length > 1 && xmlSplit[1].equals("xml")) {
            loadVehicle(piece[2]);
            game.kConsole.addKillBoxText("**Vehicle "+piece[2]+" loaded**", game.kConsole.green);
          } else {
            game.kConsole.addKillBoxText("*****CHECK FILE FORMAT*****", game.kConsole.red);
          }
        } else if(piece[1].equals("gl") || piece[1].equals("gunlist")) {
          String[] xmlSplit = split(piece[2], '.');
          if(xmlSplit.length > 1 && xmlSplit[1].equals("xml")) {
            loadGuns(piece[2]);
            game.kConsole.addKillBoxText("**Gunlist "+piece[2]+" loaded**", game.kConsole.green);
          } else {
            game.kConsole.addKillBoxText("*****CHECK FILE FORMAT*****", game.kConsole.red);
          }
            
        } else if(piece[1].equals("g") || piece[1].equals("gun")) {
          String[] xmlSplit = split(piece[2], '.');
          if(xmlSplit.length > 1 && xmlSplit[1].equals("xml")) {
            game.gunData = (Gun[]) append(game.gunData, loadIndividualGun(piece[2], boolean(piece[3])));
            game.kConsole.addKillBoxText("**Gun "+piece[2]+" loaded**", game.kConsole.green);
          } else {
            game.kConsole.addKillBoxText("*****CHECK FILE FORMAT*****", game.kConsole.red);
          }
          
          /* else if(piece[1].equals("p") || piece[1].equals("particle")) {
            String[] xmlSplit = split(piece[2], '.');
            if(xmlSplit.length > 1 && xmlSplit[1].equals("xml")) {
              loadParticle(piece[2]);
              println("**PARTICLE "+piece[2]+" LOADED**");
            } else {
              System.err.println("*****CHECK FILE FORMAT******");
            }
          }
          
          */
        } else if(piece[1].equals("sc") || piece[1].equals("script")) {
          /*String[] pySplit = split(piece[2], '.');
          if(pySplit.length > 1 && pySplit[1].equals("py")) {
            loadScript(piece[2]);
          } else {
            System.err.println("*****CHECK FILE FORMAT******");
          }*/
          
        } else if(piece[1].equals("m") || piece[1].equals("map")) {
          String[] mapSplit = split(piece[2], '.');
          if(mapSplit.length > 1) loadMap(piece[2], Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]));
          else game.kConsole.addKillBoxText("*****CHECK FILE FORMAT*****", game.kConsole.red);
          
        } 
        
      } else if(piece[0].equals("a") || piece[0].equals("add")) {  //ADD SOMETHING TO MAP
        if(piece[1].equals("fo")) {
          if(piece.length == 9) {
            game.physObjData.add(new PhysObj(Integer.parseInt(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8])));
          } else if(piece.length == 10) {
            game.physObjData.add(new PhysObj(Integer.parseInt(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8]), Float.parseFloat(piece[9])));
          } else if(piece.length == 12) {
            game.physObjData.add(new PhysObj(Integer.parseInt(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8]), Float.parseFloat(piece[9]), Float.parseFloat(piece[10]), Float.parseFloat(piece[11])));
          }
        }
        
        else if(piece[1].equals("s") || piece[1].equals("soldier")) {
          if(piece.length == 2) {
            game.soldierData.add(new Soldier(transX+mouseX-width/2, transY+mouseY-height/2));
            Soldier ph = (Soldier) game.soldierData.get(game.soldierData.size()-1);
            game.kConsole.addKillBoxText("**Added Soldier "+ph.self.getX()+"/"+ph.self.getY()+"**", game.kConsole.green);
          } else if(piece.length == 3) {
            game.soldierData.add(new Soldier(transX+mouseX-width/2, transY+mouseY-height/2));
            Soldier ph = (Soldier) game.soldierData.get(game.soldierData.size()-1);
            ph.setupAnim();
            ph.setTeam(constrain(Integer.parseInt(piece[2]), 0, 3));
            game.kConsole.addKillBoxText("**Added Soldier "+ph.self.getX()+"/"+ph.self.getY()+"**", game.kConsole.green);
          } else {
            game.kConsole.addKillBoxText("*****ADD SOLDIER ERROR: "+piece.length+" args given, 0 or 1 needed *****", game.kConsole.red);
          }
          
        } else if(piece[1].equals("v") || piece[1].equals("vehicle")) {
          if(baseVehicleData.size() > 0) {
            game.vehicleData.add(new Vehicle(new Vec2D(Integer.parseInt(piece[3]), Integer.parseInt(piece[4])), constrain(Integer.parseInt(piece[2]), 0, baseVehicleData.size()-1)));
            Vehicle ph = (Vehicle) game.vehicleData.get(game.vehicleData.size()-1);
            //println("**VEHICLE "+ph.name+" ADDED**");
            game.kConsole.addKillBoxText("**Vehicle "+ph.name+" added**", game.kConsole.green);
          } else {
            System.err.println("ADD VEHICLE ERROR: YOU NEED ATLEAST ONE BASEVEHICLE BEFORE YOU CAN CLONE(load basevehicle first)");
            
          }
          
        } else if(piece[1].equals("b") || piece[1].equals("bullet")) {
          if(piece.length == 8) game.bulletData.add(new Bullet(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Integer.parseInt(piece[6]), Integer.parseInt(piece[7])));
          else System.err.println("ADD BULLET ERROR: "+piece.length+" args given, 6 needed ");
          
        } else if(piece[1].equals("ex") || piece[1].equals("explosion")) {
          if(piece.length == 6) game.explosionData.add(new Explosion(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Integer.parseInt(piece[5])));
          else System.err.println("ADD EXPLOSION ERROR: "+piece.length+" args given, 4 needed ");
          
        } else if(piece[1].equals("sp") || piece[1].equals("spawn")) {
          if(piece.length == 7) game.spawnData.add(new Spawn(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Integer.parseInt(piece[4]), Integer.parseInt(piece[5]), Integer.parseInt(piece[6])));
          else System.err.println("ADD SPAWN ERROR: "+piece.length+" args given, 5 needed ");
          
        } else if(piece[1].equals("ea") || piece[1].equals("earth")) {
          if(piece.length == 7) game.earthData.add(new Earth(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Integer.parseInt(piece[6])));
          else System.err.println("ADD EARTH ERROR: "+piece.length+" args given, 5 needed ");
          
        } else if(piece[1].equals("gr") || piece[1].equals("gravitron")) {
          if(piece.length == 6) game.gravitronData.add(new Gravitron(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5])));
          else System.err.println("ADD GRAVITRON ERROR: "+piece.length+" args given, 4 needed ");
          
        } else if(piece[1].equals("hb") || piece[1].equals("healthbox")) {
          if(piece.length == 5) game.pickupData.add(new Pickups(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Integer.parseInt(piece[4])));
          else System.err.println("ADD HEALTHBOX ERROR: "+piece.length+" args given, 3 needed ");
          
        } else if(piece[1].equals("ab") || piece[1].equals("attachmentbox")) {
          if(piece.length == 6) game.pickupData.add(new Pickups(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Integer.parseInt(piece[4]), Integer.parseInt(piece[5])));
          else System.err.println("ADD ATTACHMENTBOX ERROR: "+piece.length+" args given, 4 needed ");
          
        } else if(piece[1].equals("gb") || piece[1].equals("gunbox")) {
          if(piece.length == 6) {
            HoldGun temp = new HoldGun(Integer.parseInt(piece[4]), Integer.parseInt(piece[5]), game.gunData[Integer.parseInt(piece[4])].delayTime, Integer.parseInt(piece[6]));
            game.pickupData.add(new Pickups(Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), temp));
          } else {
            System.err.println("ADD GUNBOX ERROR: "+piece.length+" args given, 4 needed ");
          }
        } else if(piece[1].equals("pa") || piece[1].equals("particle")) {
          if(piece.length == 6) game.particleData.add(new Particle(Integer.parseInt(piece[2]), Float.parseFloat(piece[3]), Integer.parseInt(piece[4]), Integer.parseInt(piece[5])));
          else System.err.println("ADD PARTICLE ERROR: "+piece.length+" args given, 4 needed ");
        } else if(piece[1].equals("c") || piece[1].equals("cat")) {
          if(piece.length == 4) game.catData.add(new Cat(Float.parseFloat(piece[2]), Float.parseFloat(piece[3])));
          else System.err.println("ADD CAT ERROR: "+piece.length+" args given, 2 needed ");
        } else if(piece[1].equals("poly")) {
          if(piece.length == 16) {
            game.addPoly(Integer.parseInt(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8]), Float.parseFloat(piece[9]), Float.parseFloat(piece[10]), Float.parseFloat(piece[11]), Integer.parseInt(piece[12]), Integer.parseInt(piece[13]), Integer.parseInt(piece[14]), Integer.parseInt(piece[15]));
          } else if(piece.length == 34) {
            game.addPoly(Integer.parseInt(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8]), Float.parseFloat(piece[9]), Float.parseFloat(piece[10]), Float.parseFloat(piece[11]), 255, 255, 255, 255);
            Polygon ph = (Polygon) game.polyData.get(game.polyData.size()-1);
            ph.setVColours(0, Integer.parseInt(piece[12]), Integer.parseInt(piece[13]), Integer.parseInt(piece[14]), Integer.parseInt(piece[15]));
            ph.setVColours(1, Integer.parseInt(piece[16]), Integer.parseInt(piece[17]), Integer.parseInt(piece[18]), Integer.parseInt(piece[19]));
            ph.setVColours(2, Integer.parseInt(piece[20]), Integer.parseInt(piece[21]), Integer.parseInt(piece[22]), Integer.parseInt(piece[23]));
            ph.setTextureId(Integer.parseInt(piece[24]));
            ph.setUV(Float.parseFloat(piece[25]), Float.parseFloat(piece[26]), Float.parseFloat(piece[27]), Float.parseFloat(piece[28]), Float.parseFloat(piece[29]), Float.parseFloat(piece[30]));
            ph.setRHW(Float.parseFloat(piece[31]), Float.parseFloat(piece[32]), Float.parseFloat(piece[33]));
          }
     
          else System.err.println("ADD POLY ERROR: "+piece.length+" args given, 14 or 32 needed ");
        } else if(piece[1].equals("tex")) {
          if(piece.length == 3) {
            game.mapTextureGL = append(game.mapTextureGL, loadMapTexture(piece[2]));
          } else {
            System.err.println("ADD TEXTURE ERROR: "+piece.length+" args given, 3 needed ");
          }
        } else if(piece[1].equals("scen")) {
          if(piece.length == 9) {
            game.sceneryData.add(new Scenery(piece[2], Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8])));
          } else if(piece.length == 29) {
            game.sceneryData.add(new Scenery(piece[2], Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8])));
            Scenery sh = (Scenery) game.sceneryData.get(game.sceneryData.size()-1);
            sh.setVColours(0, Integer.parseInt(piece[9]), Integer.parseInt(piece[10]), Integer.parseInt(piece[11]), Integer.parseInt(piece[12]));
            sh.setVColours(0, Integer.parseInt(piece[13]), Integer.parseInt(piece[14]), Integer.parseInt(piece[15]), Integer.parseInt(piece[16]));
            sh.setVColours(0, Integer.parseInt(piece[17]), Integer.parseInt(piece[18]), Integer.parseInt(piece[19]), Integer.parseInt(piece[20]));
            sh.setVColours(0, Integer.parseInt(piece[21]), Integer.parseInt(piece[22]), Integer.parseInt(piece[23]), Integer.parseInt(piece[24]));
            sh.setDepth(0, Float.parseFloat(piece[25]));
            sh.setDepth(1, Float.parseFloat(piece[26]));
            sh.setDepth(2, Float.parseFloat(piece[27]));
            sh.setDepth(3, Float.parseFloat(piece[28]));
          } else {
             System.err.println("ADD SCENERY ERROR: "+piece.length+" args given, 3, 9, or 29 needed ");
          }
        }
        
      } else if(piece[0].equals("rm") || piece[0].equals("remove")) {  //REMOVE SOMETHING FROM MAP
        if(piece[1].equals("s") && game.soldierData.size() > 0) {
          if(piece.length == 2) {
            Soldier ph = (Soldier) game.soldierData.get(game.soldierData.size()-1);
            game.removeSoldierById(ph.id);
          } else if(piece.length == 3) {
            game.removeSoldierById(constrain(Integer.parseInt(piece[2]), 0, game.soldierData.size()-1));
          }
          
        } else if(piece[1].equals("v") && game.vehicleData.size() > 0) {
          if(piece.length == 2) {
            Vehicle ph = (Vehicle) game.vehicleData.get(game.vehicleData.size()-1);
            ph.alive = false;
            ph.update(null);
            game.vehicleData.remove(game.vehicleData.size()-1);
          } else if(piece.length == 3) {
            Vehicle ph = (Vehicle) game.vehicleData.get(constrain(Integer.parseInt(piece[2]), 0, game.vehicleData.size()-1));
            ph.alive = false;
            ph.update(null);
            game.vehicleData.remove(constrain(Integer.parseInt(piece[2]), 0, game.vehicleData.size()-1));
          }
          
        } else if(piece[1].equals("bv") && baseVehicleData.size() > 0) {
          if(piece.length == 2) baseVehicleData.remove(baseVehicleData.size()-1);
          else if(piece.length == 3) baseVehicleData.remove(constrain(Integer.parseInt(piece[2]), 0, baseVehicleData.size()-1));
          
        } else if(piece[1].equals("sp") && game.spawnData.size() > 0) {
          if(piece.length == 3) game.spawnData.remove(constrain(Integer.parseInt(piece[2]), 0, game.spawnData.size()-1));
        
        } else if(piece[1].equals("e") && game.earthData.size() > 0) {
          if(piece.length == 3) {
            Earth ph = (Earth) game.earthData.get(constrain(Integer.parseInt(piece[2]), 0, game.earthData.size()-1));
            ph.delete();
            game.earthData.remove(constrain(Integer.parseInt(piece[2]), 0, game.earthData.size()-1));
          }
          
        } else if(piece[1].equals("gr") && game.gravitronData.size() > 0) {
          if(piece.length == 2) game.gravitronData.remove(game.gravitronData.size()-1);
          else if(piece.length == 3) game.gravitronData.remove(constrain(Integer.parseInt(piece[2]), 0, game.gravitronData.size()-1));
          
        } else if(piece[1].equals("p") && game.pickupData.size() > 0) {
          if(piece.length == 3) {
            Pickups ph = (Pickups) game.pickupData.get(constrain(Integer.parseInt(piece[2]), 0, game.pickupData.size()-1));
            ph.alive = false;
          }
          
        } else if(piece[1].equals("g") && game.gunData.length > 0) {
          if(piece.length == 3) {  //delete element by copying array
            Gun[] t1GunData = game.gunData;
            Gun[] t2GunData = new Gun[0];
            t1GunData[constrain(Integer.parseInt(piece[2]), 0, t1GunData.length)] = null;
            for(int i=0; i<t1GunData.length; i++) if(t1GunData[i] != null) t2GunData = (Gun[]) append(t2GunData, t1GunData[i]);
            game.gunData = t2GunData;
          }
          
        }
        
      } else if(piece[0].equals("s_ct") || piece[0].equals("changeteam")) {  //CHANGE TEAM
        if(piece.length == 1) {
          game.meCast.setTeam(int(random(0, 4)));
        } else if(piece.length == 2) {
          game.meCast.setTeam(constrain(Integer.parseInt(piece[1]), 0, 3));
        } else if(piece.length == 3) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.setTeam(constrain(Integer.parseInt(piece[2]), 0, 3));
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
        
      } else if(piece[0].equals("s_cg") || piece[0].equals("changegun")) { 
        if(piece.length == 2) {
          game.meCast.curGun.gun = constrain(Integer.parseInt(piece[1]), 0, game.gunData.length-1);
        } else if(piece.length == 3) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.curGun.gun = constrain(Integer.parseInt(piece[2]), 0, game.gunData.length-1);
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
        
      } else if(piece[0].equals("s_ca") || piece[0].equals("changeattachment")) {
        if(piece.length == 3) {
          game.meCast.setAttachment(Integer.parseInt(piece[1]), Integer.parseInt(piece[2]));
        } else if(piece.length == 4) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.setAttachment(Integer.parseInt(piece[2]), Integer.parseInt(piece[3]));
        }
        
      } else if(piece[0].equals("s_ks") || piece[0].equals("killsoldier")) { 
        if(piece.length == 2) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.health = 0;
        }
        
      } else if(piece[0].equals("s_rs") || piece[0].equals("respawnsoldier")) { 
        if(piece.length == 3) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.curSpawnCast = (Spawn) game.spawnData.get(Integer.parseInt(piece[2]));
          ph.curSpawnCast.spawnSoldier(ph);
        }
        
      } else if(piece[0].equals("s_en") || piece[0].equals("entervehicle")) { 
        if(piece.length == 3) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.enterVehicle((Vehicle) game.vehicleData.get(constrain(Integer.parseInt(piece[2]), 0, game.vehicleData.size()-1)));
        }
        
      } else if(piece[0].equals("s_ex") || piece[0].equals("exitvehicle")) { 
        if(piece.length == 2) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.exitVehicle(true);
        }
        
      } else if(piece[0].equals("s_ak") || piece[0].equals("addkill")) { 
        if(piece.length == 2) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.kills++;
        }
        
      } else if(piece[0].equals("s_ad") || piece[0].equals("adddeath")) { 
        if(piece.length == 2) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.deaths++;
        }
        
      } else if(piece[0].equals("s_dg") || piece[0].equals("dropgun")) { 
        if(piece.length == 2) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[1]), 0, game.soldierData.size()-1));
          ph.throwGun();
        }
      } else if(piece[0].equals("f_t") || piece[0].equals("teleport")) {
        if(piece[1].equals("s")) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[2]), 0, game.soldierData.size()-1));
          if(!ph.driving) ph.self.setPosition(constrain(Integer.parseInt(piece[3]), -mapW/2+50, mapW/2-50), constrain(Integer.parseInt(piece[4]), -mapH/2+50, mapH/2-50));
          else game.kConsole.addKillBoxText("*****Cannot teleport while driving*****", game.kConsole.red);
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
      } else if(piece[0].equals("f_af") || piece[0].equals("applyforce")) {
        if(piece[1].equals("s")) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[2]), 0, game.soldierData.size()-1));
          if(!ph.driving) ph.self.addForce(Integer.parseInt(piece[3]), Integer.parseInt(piece[4]));
          else game.kConsole.addKillBoxText("*****Cannot apply force while driving*****", game.kConsole.red);
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
      } else if(piece[0].equals("f_r") || piece[0].equals("rotate")) {
        if(piece[1].equals("s")) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[2]), 0, game.soldierData.size()-1));
          if(!ph.driving) ph.self.setRotation(Integer.parseInt(piece[3]));
          else game.kConsole.addKillBoxText("*****Cannot set rotation while driving*****", game.kConsole.red);
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
      } else if(piece[0].equals("f_ar") || piece[0].equals("applyrotate")) {
        if(piece[1].equals("s")) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[2]), 0, game.soldierData.size()-1));
          if(!ph.driving) ph.self.adjustRotation(Integer.parseInt(piece[3]));
          else game.kConsole.addKillBoxText("*****Cannot apply rotation while driving*****", game.kConsole.red);
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
      } else if(piece[0].equals("f_v") || piece[0].equals("velocity")) {
        if(piece[1].equals("s")) {
          Soldier ph = (Soldier) game.soldierData.get(constrain(Integer.parseInt(piece[2]), 0, game.soldierData.size()-1));
          if(!ph.driving) ph.self.setVelocity(Integer.parseInt(piece[3]), Integer.parseInt(piece[4]));
          else game.kConsole.addKillBoxText("*****Cannot set rotation while driving*****", game.kConsole.red);
        } else {
          game.kConsole.addKillBoxText("*****CHECK SYNTAX*****", game.kConsole.red);
        }
        
      } else if(piece[0].equals("c_g") || piece[0].equals("changegravity")) {
        if(piece.length == 3) {
          world.setGravity(Float.parseFloat(piece[1]), Float.parseFloat(piece[2]));
        }
        
      } else if(piece[0].equals("c_s") || piece[0].equals("changesoldier")) {
        if(piece.length == 3) {
          game.meCast = (Soldier) game.soldierData.get(Integer.parseInt(piece[3]));
          game.meCast.setMe(true);
          Soldier oldMe = (Soldier) game.soldierData.get(Integer.parseInt(piece[2]));
          oldMe.me = false;
          
          if(game.meCast.ai) {
            game.meCast.ai = false;
            oldMe.ai = true;
          }
        }
        
      } else if(piece[0].equals("c_c")) {
        if(piece.length == 8) {
          game.setCamera(Float.parseFloat(piece[1]), Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]));
        } else if(piece.length == 11) {
          game.setCamera(Float.parseFloat(piece[1]), Float.parseFloat(piece[2]), Float.parseFloat(piece[3]), Float.parseFloat(piece[4]), Float.parseFloat(piece[5]), Float.parseFloat(piece[6]), Float.parseFloat(piece[7]), Float.parseFloat(piece[8]), Float.parseFloat(piece[9]), Float.parseFloat(piece[10]));
        }
        
      } else if(piece[0].equals("fo")) {
        PhysObj ph = game.getPhysObjById(Integer.parseInt(piece[2]));
        
        if(ph != null) {
          if(piece[1].equals("t")) {
            ph.p.setPosition(Float.parseFloat(piece[3]), Float.parseFloat(piece[4]));
          } else if(piece[1].equals("af")) {
            ph.p.addForce(Float.parseFloat(piece[3]), Float.parseFloat(piece[4]));
          } else if(piece[1].equals("sv")) {
            ph.p.setVelocity(Float.parseFloat(piece[3]), Float.parseFloat(piece[4]));
          } else if(piece[1].equals("sr")) {
            ph.p.setRotation(Float.parseFloat(piece[3]));
          } else if(piece[1].equals("ar")) {
            ph.p.adjustRotation(Float.parseFloat(piece[3]));
          } else if(piece[1].equals("sc")) {
            ph.setColor(Integer.parseInt(piece[3]), Integer.parseInt(piece[4]), Integer.parseInt(piece[5]), Integer.parseInt(piece[6]));
          }
          
        }
        
        
      } else {
        game.kConsole.addKillBoxText("*****UNRECOGNIZED COMMAND*****", game.kConsole.red);
        game.kConsole.addKillBoxText("*****TYPE /commands  TO SEE LIST*****", game.kConsole.red);
      }
    }
  }
  
  String getSubsetDrawable(String[] n) {
    String s = "";
    if(n.length > 1) {
      for(int i=1; i<n.length; i++) {
        s += n[i];
        if(i != n.length-1) s+=" ";
      }
      s += ";";
      return s;
    } else {
      return null;
    }
  }
  
  void sendMouseKeyboardData() {
    String mPressed = "(\""+str(game.lmbPush)+"\", \""+str(game.rmbPush)+"\", \""+str(game.cmbPush)+"\")";
    interp.eval("setMouse("+Integer.toString(mouseX)+", "+Integer.toString(mouseY)+", "+mPressed+")");
    //interp.eval("setKey(\""+key+"\")");
  //  interp.set("keyPressed", key);
  }
  
  void changeSoldierName(int id, String name) {
    if(game.jython != null) game.jython.interp.eval("getSoldierById("+Integer.toString(id)+").setName(\""+name+"\")");
  }
  
  void changeSoldierGun(int id, int gun) {
    if(game.jython != null) game.jython.interp.eval("getSoldierById("+Integer.toString(id)+").setGun("+gun+")");
  }
  
  // EVENT FUNCTIONS ARE LISTED BELOW
  
  void onGameTypeChange(int type) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onGameTypeChange("+Integer.toString(type)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onGameTypeChange) interp.eval(ph.name+".onGameTypeChange("+Integer.toString(type)+")");
      }
    }
  }
  
  
  void onGamePause() {
    if(game.jython != null) {
      interp.eval("int_onGamePause()");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onGamePause) interp.eval(ph.name+".onGamePause()");
      }
    }
  }
  
  void onGameUnpause() {
    if(game.jython != null) {
      game.jython.interp.eval("int_onGameUnpause()");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onGameUnpause) interp.eval(ph.name+".onGameUnpause()");
      }
    }
  }
  
  void onSoldierAdd(int id, String name, int team) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierAdd("+Integer.toString(id)+", \""+name+"\", "+team+")");    
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierAdd) interp.eval(ph.name+".onSoldierAdd("+Integer.toString(id)+", \""+name+"\", "+team+")");
      }
    }
  }
  
  void onSoldierRemove(int id) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierRemove("+Integer.toString(id)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierRemove) interp.eval(ph.name+".onSoldierRemove("+Integer.toString(id)+")");
      }
    }
  }
  
  void onSoldierMove(int id, float x, float y, float xv, float yv) {  //STRICTLY EXTERNAL-- OTHERWISE GAME SLOWS TO A STOP
    if(game.jython != null) {      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierMove) interp.eval(ph.name+".onSoldierMove("+Integer.toString(id)+", "+Float.toString(x)+", "+Float.toString(y)+", "+Float.toString(xv)+", "+Float.toString(yv)+")");
      }
    }
  }
  
  void onSoldierDie(int id) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierDie("+Integer.toString(id)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierDie) interp.eval(ph.name+".onSoldierDie("+Integer.toString(id)+")");
      }
    }
  }
  
  void onSoldierKill(int idOfDead, int idOfKiller) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierKill("+Integer.toString(idOfDead)+", "+Integer.toString(idOfKiller)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierKill) interp.eval(ph.name+".onSoldierKill("+Integer.toString(idOfDead)+", "+Integer.toString(idOfKiller)+")");
      }
    }
  }
  
  void onSoldierRespawn(int id) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierRespawn("+Integer.toString(id)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierRespawn) interp.eval(ph.name+".onSoldierRespawn("+Integer.toString(id)+")");
      }
    }
  }
  
  void onSoldierCommand(int id, String content) {
    if(game.jython != null) {
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierCommand) interp.eval(ph.name+".onSoldierCommand("+Integer.toString(id)+",\""+content+"\")");
      }
    }
  }
  
  void onSoldierSpeak(int id, String content) {
    if(game.jython != null) {
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierSpeak) interp.eval(ph.name+".onSoldierSpeak("+Integer.toString(id)+",\""+content+"\")");
      }
    }
  }
  
  void onSoldierEnterVehicle(int id, int vId) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierEnterVehicle("+Integer.toString(id)+", "+Integer.toString(vId)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierEnterVehicle) interp.eval(ph.name+".onSoldierEnterVehicle("+Integer.toString(id)+", "+Integer.toString(vId)+")");
      }
    }
  }
  
  void onSoldierExitVehicle(int id) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onSoldierExitVehicle("+Integer.toString(id)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onSoldierExitVehicle) interp.eval(ph.name+".onSoldierExitVehicle("+Integer.toString(id)+")");
      }
    }
  }
  
  void onSpawnAdd(float x, float y, int type, int subType, int amount) {
    if(game.jython != null) game.jython.interp.eval("int_onSpawnAdd("+Float.toString(x)+", "+Float.toString(y)+", "+Integer.toString(type)+", "+Integer.toString(subType)+", "+Integer.toString(amount)+")");
  }
  
  
  void onBaseVehicleAdd(String src) {
    if(game.jython != null) game.jython.interp.eval("int_onBaseVehicleAdd(\""+src+"\")");
  }
  
  void onBaseVehicleRemove(int n) {
    if(game.jython != null) game.jython.interp.eval("int_onBaseVehicleRemove("+Integer.toString(n)+")");
  }
  
  void onVehicleAdd(int id, int type, float x, float y) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onVehicleAdd("+Integer.toString(id)+", "+Integer.toString(type)+", "+Float.toString(x)+", "+Float.toString(y)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onVehicleAdd) interp.eval(ph.name+".onVehicleAdd("+Integer.toString(id)+", "+Integer.toString(type)+", "+Float.toString(x)+", "+Float.toString(y)+")");
      }
    }
  }
  
  void onVehicleRemove(int id) {
    if(game.jython != null) {
      game.jython.interp.eval("int_onVehicleRemove("+Integer.toString(id)+")");
      
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onVehicleRemove) interp.eval(ph.name+".onVehicleRemove("+Integer.toString(id)+")");
      }
    }
  }
  
  void onVehicleMove(int id, float x, float y, float xv, float yv) {  //STRICTLY EXTERNAL-- OTHERWISE GAME SLOWS TO A STOP
    if(game.jython != null) {
      for(int i=0; i<classData.size(); i++) {
        Register ph = (Register) classData.get(i);
        if(ph.r_onVehicleMove) interp.eval(ph.name+".onVehicleMove("+Integer.toString(id)+", "+Float.toString(x)+", "+Float.toString(y)+", "+Float.toString(xv)+", "+Float.toString(yv)+")");
      }
    }
  }
  
  class Register {
    String name;
    String version;
    boolean scriptUpdate;
    
    //MODES
    boolean debugMode;
    boolean requestMouseKeyboard;
    
    //GAME REGISTERS
    boolean r_onGameTypeChange;
    boolean r_onGamePause;
    boolean r_onGameUnpause;
    
    boolean r_onSoldierAdd;
    boolean r_onSoldierRemove;
    boolean r_onSoldierDie;
    boolean r_onSoldierKill;
    boolean r_onSoldierRespawn;
    boolean r_onSoldierCommand;
    boolean r_onSoldierSpeak;
    boolean r_onSoldierMove;
    boolean r_onSoldierEnterVehicle;
    boolean r_onSoldierExitVehicle;
  
    boolean r_onVehicleAdd;
    boolean r_onVehicleRemove;
    boolean r_onVehicleMove;
    
    Register(String name, String version) {
      this.name = name;
      this.version = version;
      setupRegisters();
    }
    
    void setupRegisters() {
      
      String[] p = loadStrings("scripts/"+name+"_v"+version+".py");
      for(int i=0; i<p.length; i++) {
        if(p[i].contains("def update(this)")) scriptUpdate = true;
        else if(p[i].contains("requestMouseKeyboard = 'true'")) requestMouseKeyboard = true;
        else if(p[i].contains("debugMode = 'true'")) debugMode = true;
        else if(p[i].contains("def onGameTypeChange")) r_onGameTypeChange = true;
        else if(p[i].contains("def onGamePause")) r_onGamePause = true;
        else if(p[i].contains("def onGameUnpause")) r_onGameUnpause = true;
        else if(p[i].contains("def onSoldierDie")) r_onSoldierDie = true;
        else if(p[i].contains("def onSoldierKill")) r_onSoldierKill = true;
        else if(p[i].contains("def onSoldierRespawn")) r_onSoldierRespawn = true;
        else if(p[i].contains("def onSoldierCommand")) r_onSoldierCommand = true;
        else if(p[i].contains("def onSoldierSpeak")) r_onSoldierSpeak = true;
        else if(p[i].contains("def onSoldierAdd")) r_onSoldierAdd = true;
        else if(p[i].contains("def onSoldierRemove")) r_onSoldierRemove = true;
        else if(p[i].contains("def onSoldierMove")) r_onSoldierMove = true;
        else if(p[i].contains("def onSoldierEnterVehicle")) r_onSoldierEnterVehicle = true;
        else if(p[i].contains("def onSoldierExitVehicle")) r_onSoldierExitVehicle = true;
        else if(p[i].contains("def onVehicleAdd")) r_onVehicleAdd = true;
        else if(p[i].contains("def onVehicleRemove")) r_onVehicleRemove = true;
        else if(p[i].contains("def onVehicleMove")) r_onVehicleMove = true;
      }
    }
  }
}
