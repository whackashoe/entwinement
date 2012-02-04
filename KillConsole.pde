class KillConsole {
  private int x;
  private int y;
  private int w;
  private int h;
  private int cap;  //AMOUNT OF KILLS TO DISPLAY
  
  ArrayList data;
    
  KillConsole() {
    data = new ArrayList();
    x = settings.killConsoleX = 0;
    y = settings.killConsoleY = 0;
    w = settings.killConsoleW = 250;
    h = settings.killConsoleH = 100;
    cap = settings.killConsoleLines = 6;
  }
  
  void update(GL gl) {
    if(cap > 0 && settings.drawKillConsole) render(gl);
  }
  
  void render(GL gl) {
    textFont(FONTframeRate, 12);
    pushMatrix();
      translate(settings.killConsoleX, settings.killConsoleY);
      if(game.getGameType() != 0 && game.getGameType() != 1) {  //DRAWS SCORES PER TEAM IF TEAMMODE
        pushMatrix();
          scale(settings.killConsoleW, 20);
          fill(0, 100);
          beginShape();  //DRAWS BOX
            vertex(0, 0);
            vertex(0, 1);
            vertex(1, 1);
            vertex(1, 0);
          endShape();
        popMatrix();
        
        String[] t = game.getScoresText();
        for(int i=0; i<t.length; i++) {
          if(i == 0) fill(255, 255, 255, 255);
          else if(i == 1) fill(255, 200, 200, 255);
          else if(i == 2) fill(200, 255, 200, 255);
          else if(i == 3) fill(200, 200, 255, 255);
          text(t[i], settings.killConsoleW/8+(settings.killConsoleW/4*i), 25);
        }
      }
      
      pushMatrix();
        scale(settings.killConsoleW, settings.killConsoleH);
        fill(0, 25);
        beginShape();  //DRAWS BOX
          vertex(0, 0);
          vertex(0, 1);
          vertex(1, 1);
          vertex(1, 0);
        endShape();
      popMatrix();
      //deletes old shit
      while(data.size() > settings.killConsoleLines) data.remove(0);
      //draws text
      translate(15, 20);
      fill(255);
      for(int i=0; i<data.size(); i++) {
        String s = (String) data.get(i);
        text(s, 15, i*15+15, 3);
      }
    popMatrix();
  }
  
 
 void addKillData(int killerId, int victimId, int bulletId) {
   if(game.getSoldierById(killerId) == null || game.getSoldierById(victimId) == null) return;
   if(killerId == victimId) {
     if(bulletId >= 0) data.add(new String(game.getSoldierById(killerId).name+" selfkilled with a "+game.gunData[bulletId].name));
     else data.add(new String(game.getSoldierById(killerId).name+" selfkilled"));
     return;
   }
   
   if(bulletId >= 0) {
     data.add(new String(game.getSoldierById(killerId).name+" killed "+game.getSoldierById(victimId).name+" with a "+game.gunData[bulletId].name));
     return;
   } else {
     //todo
     return;
   }
 }
 
 void addKillBoxText(String text_) {
   if(text_ == null) text_ = "";
   data.add(new String(text_));
 } 
}
