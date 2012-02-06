class KillConsole {
  private int x;
  private int y;
  private int w;
  private int h;
  private int cap;  //AMOUNT OF KILLS TO DISPLAY
  
  ArrayList data;  //all data that is sent here
  ArrayList cdata;  //color data
  
  ColorText white = new ColorText(255, 255, 255, 255);
  ColorText red = new ColorText(255, 100, 100, 255);
  ColorText green = new ColorText(100, 255, 100, 255);
  ColorText blue = new ColorText(100, 100, 255, 255);
    
  KillConsole() {
    data = new ArrayList();
    cdata = new ArrayList();
    x = settings.killConsoleX;
    y = settings.killConsoleY;
    w = settings.killConsoleW;
    h = settings.killConsoleH;
    cap = settings.killConsoleLines;
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
        if(!game.showInputBox) scale(settings.killConsoleW, settings.killConsoleH);
        else scale(width/3, height);
        fill(0, 25);
        
        beginShape();  //DRAWS BOX
          vertex(0, 0);
          vertex(0, 1);
          vertex(1, 1);
          vertex(1, 0);
        endShape();
      popMatrix();
      translate(15, 20);
      fill(255);
      
      //startpoint is used for cropping text size based on if typing or not
      int startPoint = constrain(data.size()-settings.killConsoleLines, 0, Integer.MAX_VALUE);
      if(game.showInputBox) startPoint = constrain(data.size()-int(height/15)+5, 0, Integer.MAX_VALUE);
      
      for(int i=startPoint, j=0; i<data.size(); i++, j++) {
        String s = (String) data.get(i);
        while(data.size() > cdata.size()) cdata.add(white);  //quick fix for odd bug?
        ColorText c = (ColorText) cdata.get(i);
        fill(c.r, c.g, c.b, c.a);
        text(s, 15, j*15, 3);
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
 
 void addKillBoxText(String text_, ColorText c) {
   if(text_ == null) text_ = "";
   data.add(new String(text_));
   cdata.add(new ColorText(c));
 } 
 
 class ColorText {
   int r;
   int g;
   int b;
   int a;
   
   ColorText(int r, int g, int b, int a) {
     this.r = r;
     this.g = g;
     this.b = b;
     this.a =a;
   }
   
   ColorText(ColorText c) {
     this.r = c.r;
     this.g = c.g;
     this.b = c.b;
     this.a =c.a;
   }
 }
}
