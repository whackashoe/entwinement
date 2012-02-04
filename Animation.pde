class Animation {
  String name;
  PImage[] running;
  PImage[] standing;
  int runDelay;
  int standDelay;
  
  Animation(String name_, int[] delayAmounts_) {
    name = name_;
    runDelay = delayAmounts_[0];
    standDelay = delayAmounts_[1];
    File dir;
    String[] dirChildren;
    
    //DO RUNNING SHIT
    dir = new File(sketchPath+"/mods/"+settings.mod+"/gfx/sprites/"+name+"/running");
    dirChildren = dir.list();
    dirChildren = sort(dirChildren);
    running = new PImage[dirChildren.length];
    for(int i=0; i<dirChildren.length; i++) running[i] = loadImage(sketchPath+"/mods/"+settings.mod+"/gfx/sprites/"+name+"/running/"+dirChildren[i]);
    
    //DO STANDING SHIT
    dir = new File(sketchPath+"/mods/"+settings.mod+"/gfx/sprites/"+name+"/standing");
    dirChildren = dir.list();
    standing = new PImage[dirChildren.length];
    for(int i=0; i<dirChildren.length; i++) standing[i] = loadImage(sketchPath+"/mods/"+settings.mod+"/gfx/sprites/"+name+"/standing/"+dirChildren[i]);
    //println(name+" sprites loaded");
  }
  
  int getId(int type_, int i_, int tics_) {
    //type is: 0-running, etc
    //i is current frame sent
    //tics is amount of second/30 tosee if its time to switch
    if(type_ == 0) {
      if(tics_ < runDelay) return i_;
      if(i_ == running.length-1) return 0;
      return i_+1;
    }
    return 0;
  }
}
