class GameCom {
  /*holds commands from server regarding setting body positions and such*/
  int type;  //0 is soldier
  int[] idata;
  float[] fdata; //generally holds xpos, ypos, xvelo, yvelo etc.
  boolean[] bdata;
  String[] sdata;
  
  
  //for pos/velo etc.
  GameCom(int type, int[] idata, float[] fdata) {
    this.type = type;
    this.idata = idata;
    this.fdata = fdata;
  }
  
  //for map loadings
  GameCom(int type, int[] idata, String[] sdata) {
    this.type = type;
    this.idata = idata;
    this.sdata = sdata;
  }
  
  //for vehicles
  GameCom(int type, int[] idata, float[] fdata, boolean[] bdata) {
    this.type = type;
    this.idata = idata;
    this.fdata = fdata;
    this.bdata = bdata;
  }
  
  
  void update() {
    switch(type) {
      case -3://start map from drop
        if(mainMenu || game != null) {
          world.clear();
          clearAllEngineData();
        }
        
        game = new Engine(sdata[0]);
        loadMap(sdata[0], 0.0, 0.0, 1.0, 1.0);
        mainMenu = false;
        game.setMenuMode(false);
        
        
        game.setGuns(loadGuns("list1.xml"));
        loadRagdoll("test");
        game.mapLoaded = true;
        game.mapBounds = game.calcMapBounds();
        
        Spawn meTempSpawn = game.getSoldierSpawn();
        game.soldierData.add(new Soldier(meTempSpawn.x, meTempSpawn.y));
        game.meCast = (Soldier) game.soldierData.get(game.soldierData.size()-1);
        game.meCast.setMe(true);
        game.meCast.respawn(meTempSpawn.x, meTempSpawn.y);
        
        playing = true;
        
        break;
      case -2:  //start map from server
        if(mainMenu || game != null) {
          world.clear();
          clearAllEngineData();
        }
        mainMenu = false;
        game.setMenuMode(false);
        game = new Engine(sdata[0]);
        loadMapRepo(sdata[0]);
        playing = true;
        break;
      case -1:  //start map from menu
        if(mainMenu && game != null) {
          world.clear();
          clearAllEngineData();
        }
        mainMenu = false;
        game = new Engine(sdata[0]);
        loadMapRepo(sdata[0]);
        playing = true;
        
        if(idata.length > 0) {
          mainMenu = true;
          game.setMenuMode(true);
        }
        break;
      case 0:
        Soldier sh = getSoldierById(idata[0]);
        if(sh != null) {
          try {
            sh.self.setPosition(fdata[0], fdata[1]);
            sh.self.setVelocity(fdata[2], fdata[3]);
          } catch(Exception e) {
            e.printStackTrace();
          } catch(Error e) {
            e.printStackTrace();
          }
        }
        break;
      case 1:
        Pickups ph = getPickupById(idata[0]);
        if(ph != null) {
          try {
            ph.p.setPosition(fdata[0], fdata[1]);
            ph.p.setVelocity(fdata[2], fdata[3]);
          } catch(Exception e) {
            e.printStackTrace();
          } catch(Error e) {
            e.printStackTrace();
          }
        }
        break;
      case 2:
        Grapple gh = getGrappleById(idata[0]);
        if(gh != null) {
          try {
            gh.body.setPosition(fdata[0], fdata[1]);
            gh.body.setVelocity(fdata[2], fdata[3]);
          } catch(Exception e) {
            e.printStackTrace();
          } catch(Error e) {
            e.printStackTrace();
          }
        }
        break;
      case 3:
        Vehicle vh = getVehicleById(idata[0]);
        if(vh != null) {
          for(int i=0; i<vh.parts.size(); i++) {
            Vehicle.Part vph = (Vehicle.Part) vh.parts.get(i);
            try {
              vph.getBody().setPosition(fdata[i*5+0], fdata[i*5+1]);
              vph.getBody().setVelocity(fdata[i*5+2], fdata[i*5+3]);
              vph.getBody().setRotation(fdata[i*5+4]);
              vph.alive = bdata[i];
            } catch(Exception e) {
              e.printStackTrace();
            } catch(Error e) {
              e.printStackTrace();
            }
          }
        }
        break;
    }
  }
}
