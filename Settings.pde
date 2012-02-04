class Settings {
  //base settings
  char separator = '/';  //linux
  boolean normalScreen = true;  //set to false if "--present" is on
  
  //game options
  String playerName = "jett";
  int defaultGameType = 1;
  boolean[] defaultGameMode = new boolean[5]; //clean
  String startupMapName;
  String[] botNames;
  int menuType = 2;  //not imp- 0 for traditional menu, 1 for load startupMapName, 2 for random map?
  boolean debugMode = false;
  boolean writeOutText = false;
  
  //gfx
  int normalScreenWidth = 800;
  int normalScreenHeight = 600;
  int sphereD = 3;
  boolean textureMagNearest = true;
  boolean antialiasing = true;
  boolean anisotropic = true;
  String mod = "default";
  boolean frameCheck = false;
  boolean drawIntro = false;
  boolean drawMinimap = true;
  boolean drawTextures = true;
  boolean drawScenery = true;
  boolean drawSoldierNames = true;
  boolean drawPickupInfo = false;
  boolean drawKillConsole = true;
  boolean drawVehicles = true;
  boolean drawParticles = true;
  boolean drawBullets = true;
  boolean drawAnimations = true;
  boolean drawEarths = true;
  boolean drawBulletTrails = false;
  boolean drawDebugData = false;
  boolean drawBrokenPolygons = true;
  int brokenPolygonsMaxHealth = 100;
  int brokenPolygonsMaxDistortion = 100;
  boolean drawTrippyScenery = true;
  boolean drawTrippyPolygons = true;
  int trippySceneryMaxHealth = 25;
  int trippySceneryMaxDistortion = 5;
  int trippyPolygonsMaxHealth = 25;
  int trippyPolygonsMaxDistortion = 5;
  int killConsoleX = 0;
  int killConsoleY = 0;
  int killConsoleW = 250;
  int killConsoleH = 100;
  int killConsoleLines = 6;
  int introTimer = 90;
  int maxParticles = -1;
  
  //audio
  boolean playSounds = true;
  boolean playMusic = true;
  int soundVolume = 100;
  int musicVolume = 100;
  boolean useVolume = false;
  boolean useGain = true;
  boolean useBalance = false;
  
  //network
  String clientIp = "127.0.0.1";
  int clientPort = 12333;
  String lobbyIp = "127.0.0.1";
  int lobbyPort = 12345;
  
  //keys
  char keyLeft = 'a';
  char keyRight = 'd';
  char keyDown = 's';
  char keyUp = 'w';
  char keyKill = 'l';
  char keyPickup = 'x';
  char keyDrop = 'f';
  char keyReload = 'r';
  char keyNade = 'e';
  char keyMenu = 'm';
  char keyPause = 'p';
  
  Settings(String src) {
    //change folder separator if someone is using microshits
    try {
      String systemOS = System.getProperty("os.name");
      if(systemOS.startsWith("Windows")) separator = '\\';
    } catch (Exception e) {
      e.printStackTrace();
    }
    //if running in present mode set up to use semi full screen shits
    
    /*
    for(int i=0; i<args.length; i++) {
      if(args[i].startsWith("w")) {
        normalScreenWidth = false;
        break;
      }
    }
    */
    
    //check to see if settings is there
    String[] data = null;
    try {
     data = loadStrings(sketchPath+"/settings"+separator+src);
    } catch(Exception e) {
      System.out.println("settings"+separator+src+" not found");
    } catch(Error e) {
      System.out.println("something naughty happened: settings"+separator+src+" not found");
    }
    if(data == null) {
      System.out.println("something naughty happened: settings"+separator+src+" not found\n");
      return;
    }
    
    //start parsing ini

    Properties parse = new Properties();
    try {
      parse.load(new FileInputStream(sketchPath+"/settings"+separator+src));
      
      playerName = parse.getProperty("name");
      defaultGameType = Integer.parseInt(parse.getProperty("defaultGameType"));
      menuType = Integer.parseInt(parse.getProperty("menuType"));
      startupMapName = parse.getProperty("startupMapName");
      botNames = loadStrings(sketchPath+"/settings"+separator+parse.getProperty("botNameList"));      
      debugMode = (Integer.parseInt(parse.getProperty("debugMode")) == 0) ? false : true;
      writeOutText = (Integer.parseInt(parse.getProperty("writeOutText")) == 0) ? false : true;
      
      mod = parse.getProperty("mod");
      normalScreenWidth = Integer.parseInt(parse.getProperty("screenWidth"));
      normalScreenHeight = Integer.parseInt(parse.getProperty("screenHeight"));
      sphereD = Integer.parseInt(parse.getProperty("sphereDetail"));
      antialiasing = (Integer.parseInt(parse.getProperty("antialiasing")) == 0) ? false : true;
      textureMagNearest = (Integer.parseInt(parse.getProperty("textureMagNearest")) == 0) ? false : true;
      anisotropic = (Integer.parseInt(parse.getProperty("anisotropic")) == 0) ? false : true;
      frameCheck = (Integer.parseInt(parse.getProperty("frameCheck")) == 0) ? false : true;
      drawIntro = (Integer.parseInt(parse.getProperty("drawIntro")) == 0) ? false : true;
      drawTextures = (Integer.parseInt(parse.getProperty("drawTextures")) == 0) ? false : true;
      drawScenery = (Integer.parseInt(parse.getProperty("drawScenery")) == 0) ? false : true;
      drawSoldierNames = (Integer.parseInt(parse.getProperty("drawSoldierNames")) == 0) ? false : true;
      drawPickupInfo = (Integer.parseInt(parse.getProperty("drawPickupInfo")) == 0) ? false : true;
      drawKillConsole = (Integer.parseInt(parse.getProperty("drawKillConsole")) == 0) ? false : true;
      drawVehicles = (Integer.parseInt(parse.getProperty("drawVehicles")) == 0) ? false : true;
      drawParticles = (Integer.parseInt(parse.getProperty("drawParticles")) == 0) ? false : true;
      drawBullets = (Integer.parseInt(parse.getProperty("drawBullets")) == 0) ? false : true;
      drawAnimations = (Integer.parseInt(parse.getProperty("drawAnimations")) == 0) ? false : true;
      drawEarths = (Integer.parseInt(parse.getProperty("drawEarths")) == 0) ? false : true;
      drawBulletTrails = (Integer.parseInt(parse.getProperty("drawBulletTrails")) == 0) ? false : true;
      drawTrippyScenery = (Integer.parseInt(parse.getProperty("drawTrippyScenery")) == 0) ? false : true;
      drawTrippyPolygons = (Integer.parseInt(parse.getProperty("drawTrippyPolygons")) == 0) ? false : true;
      drawBrokenPolygons = (Integer.parseInt(parse.getProperty("drawBrokenPolygons")) == 0) ? false : true;
      brokenPolygonsMaxHealth = Integer.parseInt(parse.getProperty("brokenPolygonsMaxHealth"));
      brokenPolygonsMaxDistortion = Integer.parseInt(parse.getProperty("brokenPolygonsMaxDistortion"));
      trippyPolygonsMaxHealth = Integer.parseInt(parse.getProperty("trippyPolygonsMaxHealth"));
      trippyPolygonsMaxDistortion = Integer.parseInt(parse.getProperty("trippyPolygonsMaxDistortion"));
      trippySceneryMaxHealth = Integer.parseInt(parse.getProperty("trippySceneryMaxHealth"));
      trippySceneryMaxDistortion = Integer.parseInt(parse.getProperty("trippySceneryMaxDistortion"));

      killConsoleX = Integer.parseInt(parse.getProperty("killConsoleX"));
      killConsoleY = Integer.parseInt(parse.getProperty("killConsoleY"));
      killConsoleW = Integer.parseInt(parse.getProperty("killConsoleW"));
      killConsoleH = Integer.parseInt(parse.getProperty("killConsoleH"));
      killConsoleLines = Integer.parseInt(parse.getProperty("killConsoleLines"));
      introTimer = Integer.parseInt(parse.getProperty("introTimer"));
      maxParticles = Integer.parseInt(parse.getProperty("killConsoleLines"));
      
      playSounds = (Integer.parseInt(parse.getProperty("sound")) == 0) ? false : true;
      playMusic = (Integer.parseInt(parse.getProperty("music")) == 0) ? false : true;
      
      soundVolume = Integer.parseInt(parse.getProperty("soundVolume"));
      musicVolume = Integer.parseInt(parse.getProperty("musicVolume"));
      
      useVolume = (Integer.parseInt(parse.getProperty("useVolume")) == 0) ? false : true;
      useGain = (Integer.parseInt(parse.getProperty("useGain")) == 0) ? false : true;
      useBalance = (Integer.parseInt(parse.getProperty("useBalance")) == 0) ? false : true;
      
      clientIp = parse.getProperty("clientIp");
      clientPort = Integer.parseInt(parse.getProperty("clientPort"));
      lobbyIp = parse.getProperty("lobbyIp");
      lobbyPort = Integer.parseInt(parse.getProperty("lobbyPort"));
      
      keyLeft = parse.getProperty("keyLeft").charAt(0);
      keyRight = parse.getProperty("keyRight").charAt(0);
      keyDown = parse.getProperty("keyDown").charAt(0);
      keyUp = parse.getProperty("keyUp").charAt(0);
      keyKill = parse.getProperty("keyKill").charAt(0);
      keyPickup = parse.getProperty("keyPickup").charAt(0);
      keyDrop = parse.getProperty("keyDrop").charAt(0);
      keyReload = parse.getProperty("keyReload").charAt(0);
      keyNade = parse.getProperty("keyNade").charAt(0);
      keyMenu = parse.getProperty("keyMenu").charAt(0);
      keyPause = parse.getProperty("keyPause").charAt(0);
    } catch(Exception e) {
      e.printStackTrace();
    }
    
  }
  
  void checkAudio() {
    AudioOutput audioOut = minim.getLineOut();
    /*useVolume = audioOut.hasControl(Controller.VOLUME);
    useGain = audioOut.hasControl(Controller.GAIN);
    useBalance = audioOut.hasControl(Controller.BALANCE);
    */
  }
}
