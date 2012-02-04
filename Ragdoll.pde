class Ragdoll {
  String name;
  ArrayList parts;
  ArrayList animations;
  boolean alive;

  int type;
  int curAnim;
  int curFrame;
  int delayTime;
  int curDelay;

  FCircle[] pieces;
  FRevoluteJoint[] pieceJoints;

  boolean ragEffect = false;

  Ragdoll(String name) {  //used for loading base ragdolls
    this.name = name;
    parts = new ArrayList();
    animations = new ArrayList();
  }

  Ragdoll(int type) {  //load and setup
    this.type = type;
    alive = true;
    curFrame = 0;
    curAnim = 0;
    delayTime = 1;
    curDelay = 0;

    Ragdoll ragCast = (Ragdoll) baseRagdollData.get(type);
    name = ragCast.name;
    parts = new ArrayList();
    for (int i=0; i<ragCast.parts.size(); i++) {  //copy over base parts
      Ragdoll.Part ragPartCast = (Ragdoll.Part) ragCast.parts.get(i);
      parts.add(new Part(ragPartCast.connect));
      Ragdoll.Part curPartCast = (Ragdoll.Part) parts.get(parts.size()-1);
      curPartCast.type = ragPartCast.type;
      curPartCast.size = ragPartCast.size;
      curPartCast.colour = ragPartCast.colour;
    }
    pieces = new FCircle[parts.size()];
    for (int i=0; i<pieces.length; i++) pieces[i] = new FCircle(0);
    animations = new ArrayList();
    for (int i=0; i<ragCast.animations.size(); i++) {  //copy over animations
      Ragdoll.Animation ragAnimCast = (Ragdoll.Animation) ragCast.animations.get(i);
      animations.add(new Animation(ragAnimCast.name));
      Ragdoll.Animation thisRagAnimCast = (Ragdoll.Animation) animations.get(animations.size()-1);
      for (int j=0; j<ragAnimCast.frames.size(); j++) {  //copy over frames
        Ragdoll.Animation.Frame ragAnimFrameCast = (Ragdoll.Animation.Frame) ragAnimCast.frames.get(i);
        thisRagAnimCast.addFrame(ragAnimFrameCast.x, ragAnimFrameCast.y);
      }
    }
  }

  void update() {
    curDelay++;
    if (curDelay >= delayTime) {
      Animation animCast = (Animation) animations.get(curAnim);
      if (curFrame < animCast.frames.size()-1) curFrame++;
      else curFrame = 0;

      curDelay = 0;
    }
  }

  void render(FBody self, float rad, float rotation) {
    Ragdoll ragCast = (Ragdoll) baseRagdollData.get(type);
    Animation animCast = (Animation) ragCast.animations.get(curAnim);
    Animation.Frame frameCast = (Animation.Frame) animCast.frames.get(curFrame);

    float[][] skeletonPos = new float[parts.size()][2];

    for (int i=0; i<parts.size(); i++) {
      if (!ragEffect) {
        if ((rotation < -HALF_PI && rotation > -PI) || (rotation > HALF_PI && rotation < PI)) skeletonPos[i][0] = self.getX()+(frameCast.x[i]*-rad);
        else skeletonPos[i][0] = self.getX()+(frameCast.x[i]*rad);

        skeletonPos[i][1] = self.getY()+(frameCast.y[i]*rad)-rad/2;
      } 
      else {
        skeletonPos[i][0] = pieces[i].getX();
        skeletonPos[i][1] = pieces[i].getY();
      }
    }

    fill(255);
    for (int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if (ph.type == 0) {
        pushMatrix();
        translate(skeletonPos[i][0], skeletonPos[i][1]);
        scale(rad, rad);
        fill(ph.colour[0], ph.colour[1], ph.colour[2], ph.colour[3]);
        ellipse(0, 0, ph.size, ph.size);
        popMatrix();
      } 
      else if (ph.connect != -1 && ph.type == 1) {
        Part phCon = (Part) parts.get(ph.connect);
        strokeWeight(phCon.size);
        beginShape(LINES);
          stroke(phCon.colour[0], phCon.colour[1], phCon.colour[2], phCon.colour[3]);
          vertex(skeletonPos[ph.connect][0], skeletonPos[ph.connect][1]);
          stroke(ph.colour[0], ph.colour[1], ph.colour[2], ph.colour[3]);
          vertex(skeletonPos[i][0], skeletonPos[i][1]);
        endShape();
      }
    }
    noStroke();
  }

  void changeAnimation(int curAnim) {
    this.curAnim = curAnim;
    this.curFrame = 0;
    this.curDelay = 0;
  }

  void createEffect(FBody self, float rad, float rotation) {
    Ragdoll ragCast = (Ragdoll) baseRagdollData.get(type);
    Animation animCast = (Animation) ragCast.animations.get(curAnim);
    Animation.Frame frameCast = (Animation.Frame) animCast.frames.get(curFrame);

    for (int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      pieces[i] = new FCircle(3);
      if ((rotation < -HALF_PI && rotation > -PI) || (rotation > HALF_PI && rotation < PI)) pieces[i].setPosition(self.getX()-(frameCast.x[i]*rad), self.getY()+(frameCast.y[i]*rad));
      else pieces[i].setPosition(self.getX()+(frameCast.x[i]*rad), self.getY()+(frameCast.y[i]*rad));
      pieces[i].setGroupIndex(-1);
      pieces[i].setRestitution(0.001);
      pieces[i].setDensity(0.001);
      pieces[i].setFriction(0.1);
      pieces[i].setVelocity(self.getVelocityX()+(random(-1.0, 1.0)*map(self.getVelocityX(), 0, 1000, 0, 100)), self.getVelocityY()+(random(-1.0, 1.0)*map(self.getVelocityX(), 0, 1000, 0, 100)));
    }

    int tempPieceJointCount = 0;
    for (int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if (ph.connect != -1) tempPieceJointCount++;
    }
    pieceJoints = new FRevoluteJoint[tempPieceJointCount];
    tempPieceJointCount = 0;
    for (int i=0; i<parts.size(); i++) {
      Part ph = (Part) parts.get(i);
      if (ph.connect >= 0) {
        pieceJoints[tempPieceJointCount] = new FRevoluteJoint(pieces[i], pieces[ph.connect], (pieces[i].getX()+pieces[ph.connect].getX())/2, (pieces[i].getY()+pieces[ph.connect].getY())/2);
        pieceJoints[tempPieceJointCount].setEnableLimit(true);
        tempPieceJointCount++;
      }
    }

    for (int i=0; i<pieces.length; i++) world.add(pieces[i]);
    for (int i=0; i<pieceJoints.length; i++) world.add(pieceJoints[i]);
    ragEffect = true;
  }

  void endRagEffect() {
    for (int i=0; i<pieceJoints.length; i++) world.remove(pieceJoints[i]);
    for (int i=0; i<pieces.length; i++) world.remove(pieces[i]);
    ragEffect = false;
  }

  void addPart(int connect) { 
    parts.add(new Part(connect));
  }

  void addAnimation(String name) { 
    animations.add(new Animation(name));
  }

  class Part {
    int connect;  //part it connects to
    int type;  //type of render(0 circle, 1 line)
    float size;   //size to render
    int[] colour;  //rgba


    Part(int connect) { 
      this.connect = connect;
      this.type = 1;
      this.size = 5;
      colour = new int[4];
    }

    void setType(int type) { 
      this.type = type;
    }

    void setSize(float size) { 
      this.size = size;
    }

    void setColour(int r, int g, int b, int a) {
      colour = new int[4];
      this.colour[0] = r;
      this.colour[1] = g;
      this.colour[2] = b;
      this.colour[3] = a;
    }
  }

  class Animation {
    String name;   //name of animation
    ArrayList frames;

    Animation(String name) {
      this.name = name;
      frames = new ArrayList();
    }

    void addFrame(float[] x, float[] y) { 
      frames.add(new Frame(x, y));
    }

    class Frame {
      float[] x;
      float[] y;

      Frame(float[] x, float[] y) {
        this.x = x;
        this.y = y;
      }
    }
  }
}

