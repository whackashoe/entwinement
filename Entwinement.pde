/* Copyright (c) 2011 Jett LaRue, whackashoe@gmail.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import sojamo.drop.*;
import fisica.*;
import ai.pathfinder.*;
import hypermedia.net.*;
import controlP5.*;

import java.math.BigInteger;
import java.awt.geom.*;
import java.nio.*;
import java.lang.*;

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.GLU;

import com.sun.opengl.util.BufferUtil;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.PixelGrabber;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import org.python.util.PythonInterpreter; 
import org.python.core.*;





Engine game;
PGraphicsOpenGL pgl;
Menu gameMenu;
ControlP5 controlP5;
SDrop drop;
Minim minim;
FWorld world;
UDP client;
ServerList serverList;

boolean mainMenu;
ArrayList gameComData;
ArrayList baseVehicleData;
ArrayList baseRagdollData;
PFont FONThud;
PFont FONTframeRate;
PFont FONTtitle;
PFont FONTmaps;
float transX, transY;
float mapH, mapW;
float xgravity;
float ygravity;


int keyResult = 0;
final static int keyW = 1;
final static int keyD = 2;
final static int keyS = 4;
final static int keyA = 8;
final static int keyX = 16;
final static int keyF = 32;
final static int keyR = 64;

int bloodMin = 0;
int bloodMax = 10;

boolean altUpdate;
boolean mouseHeld;

boolean playingOnline;
int serverPort;
String serverIp;
String serverMapName;
String[] mapFilesNeeded;
String[] mapFilesHashes;
byte[] largePartialFile;
boolean dlMap;
boolean playing;
boolean pickedServer;
int onlineId;
int lastSoldierPVTime;
int lastConnectAttemptCountDown;


Settings settings;
String[] sceneryList;

/*
// this table is used to store all command line parameters
 // in the form: name=value
 static Hashtable params=new Hashtable();
 
 // here we overwrite PApplet's main entry point (for application mode)
 // we're parsing all commandline arguments and copy only the relevant ones
 
 static public void main(String args[]) {
 
 String[] newArgs = new String[3+args.length];
 newArgs[0] = "--sketch-path=/home/whackashoe/Coding/sketchbook/entwinement/entwinement";
 newArgs[1] = "--dislay=1";
 newArgs[2] = "entwinement";
 
 for(int i=0; i<args.length; i++) {
 newArgs[i+1]=args[i];
 if (args[i].indexOf("=")!=-1) {
 String[] pair=split(args[i], '=');
 params.put(pair[0],pair[1]);
 }
 }
 // pass on to PApplet entry point
 PApplet pa = new entwinement();
 pa.main(newArgs);
 }
 */

OutputStream consoleOutput;
PrintStream consolePrintOut;

AudioSample backgroundMusic;

void setup() {
  settings = new Settings("default.ini");
  size(settings.normalScreenWidth == -1 ? screenWidth : settings.normalScreenWidth, settings.normalScreenHeight == -1 ? screenHeight : settings.normalScreenHeight, OPENGL);
  frameRate(60);

  println("Entwinement V001");

  if (!settings.writeOutText) {
    println("\n");
    println("--Writing to console disabled");
    println("--Saving to "+sketchPath+"/outputs/console-"+month()+"-"+day()+"-"+year()+"_"+hour()+"."+minute()+"."+second()+".txt");
    try {
      consoleOutput = new FileOutputStream(sketchPath+"/outputs/console-"+month()+"-"+day()+"-"+year()+"_"+hour()+"."+minute()+"."+second()+".txt");
      consolePrintOut = new PrintStream(consoleOutput);
      try {
        System.setOut(consolePrintOut);
        System.setErr(consolePrintOut);
      } 
      catch(Exception e) {
        e.printStackTrace();
      }
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  sphereDetail(settings.sphereD);
  if (settings.antialiasing) smooth();
  else noSmooth();
  
  imageMode(CORNER);
  rectMode(CENTER);
  noCursor();
  noiseDetail(5, 0.93);
  background(0);

  Fisica.init(this);
  Fisica.setScale(25);
  minim = new Minim(this);
  //settings.checkAudio();
  AudioOutput out = minim.getLineOut();
  out.printControls();
  drop = new SDrop(this);
  pgl = (PGraphicsOpenGL) g;

  FONTframeRate = loadFont("ArialMT-12.vlw");
  FONTtitle = loadFont("Ubuntu-Bold-48.vlw");
  FONTmaps = loadFont("Ubuntu-Bold-48.vlw");
  
  if(settings.playMusic) {
    backgroundMusic = minim.loadSample("mods/"+settings.mod+"/sfx/soundtrack/dadwhy.mp3");
    if(settings.useVolume) backgroundMusic.setVolume(map(constrain(settings.musicVolume, 0, 100), 0, 100, 0, 1.0));
    else if(settings.useGain) backgroundMusic.setGain(-80+(map(constrain(settings.musicVolume, 0, 100), 0, 100, 0, 86)));
    backgroundMusic.trigger();
  }
  
  sceneryList = loadSceneryList();

  serverList = new ServerList();
  mouseHeld = false;
  playingOnline = false;
  baseVehicleData = new ArrayList();
  baseRagdollData = new ArrayList();
  gameComData = new ArrayList();

  client = new UDP(this, settings.clientPort, settings.clientIp);
  client.listen(true);
  client.broadcast(true);
  client.loopback(false);  

  mainMenu = true;
  gameMenu = new Menu();
  //game = new Engine("TESTING SCRIPTS");
  //loadMapRepo("_proctest.xml");
}

void draw() {
  pgl = (PGraphicsOpenGL) g;
  GL gl = null;

  while (gameComData.size () > 0) {
    GameCom com = (GameCom) gameComData.get(0);
    if (com == null) { //rare/odd bug due to thread sync issues i'm guessing???
      gameComData.clear();
      break;
    }
    com.update();
    gameComData.remove(0);
  }

  if (settings.drawIntro) {
    background(0, 10);
    settings.introTimer--;
    stroke(255, 100);
    strokeWeight(5);
    for (int i=0; i<width+settings.introTimer*10; i++) line(i, random(0, height), i, height);

    if (settings.introTimer == 0) { 
      settings.drawIntro = false; 
      noStroke();
    }
  } 
  else if (mainMenu) {
    gameMenu.update(gl);
  } 
  else if (game != null) {
    game.update(gl);
  }


  fill(255, 50);
  if (game != null && game.meCast != null) ellipse(mouseX, mouseY, map(constrain(game.meCast.curGun.bink, 0, QUARTER_PI), 0, QUARTER_PI, 10, 70), map(constrain(game.meCast.curGun.bink, 0, QUARTER_PI), 0, QUARTER_PI, 10, 70));
}

void connectToServer(String ip_, int port_) {
  if (lastConnectAttemptCountDown == 0) {
    lastSoldierPVTime = 0;
    playingOnline = true;
    dlMap = false;
    playing = false;
    serverIp = ip_;
    serverPort = port_;
    println("Attempting to join "+ip_+":"+port_);
    byte[] b = new byte[1];
    b[0] = 0;
    client.send(b, serverIp, serverPort);
    lastConnectAttemptCountDown = 15;
  }
}

void requestServerList() {  //REQUEST SERVERS FROM LOBBY SERVER
  byte[] b = new byte[1];
  b[0] = 1;
  client.send(b, settings.lobbyIp, settings.lobbyPort);
  serverList.updateList();
}

void clearAllEngineData() {
  game = new Engine("clear");
  println("world bodies"+world.getBodies().size());
  for(int i=0; i<world.getBodies().size(); i++) {
    FBody ph = (FBody) world.getBodies().get(i);
    world.remove(ph);
  }
  world = new FWorld();
  println("world bodies"+world.getBodies().size());
}

void initPhysics(float w_, float h_, float xGrav_, float yGrav_) {
  mapW = w_;
  mapH = h_;
  xgravity = xGrav_;
  ygravity = yGrav_;
  world = new FWorld(-mapW/2, -mapH/2, mapW/2, mapH/2);
  world.setEdges(-mapW/2, -mapH/2, mapW/2, mapH/2);
  world.setEdgesRestitution(1.0);
  //world.setEdgesDrawable(true);
  world.setGravity(xGrav_, yGrav_);
  world.setGrabbable(false);
}

void addGameCom(int type, int[] idata, float[] fdata) {
  gameComData.add(new GameCom(type, idata, fdata));
}

void addGameCom(int type, int[] idata, String[] sdata) {
  gameComData.add(new GameCom(type, idata, sdata));
}

void addGameCom(int type, int[] idata, float[] fdata, boolean[] bdata) {
  gameComData.add(new GameCom(type, idata, fdata, bdata));
}

PImage maskGreen(PImage m_) {
  color c = color(0, 0, 0, 0);
  m_.loadPixels();
  for (int i=0; i<m_.pixels.length; i++)
    if (
    ( m_.pixels[i] >> 16 & 0xFF) == 0 &&
      (m_.pixels[i] >> 8 & 0xFF) == 255 &&
      (m_.pixels[i] & 0xFF) == 0
      ) m_.pixels[i] = 0;

  m_.updatePixels();
  return m_;
}

String getCorrectSceneryName(String src) {
  if(sceneryList == null) return src;
  
  for(int i=0; i<sceneryList.length; i++) {
    if(sceneryList[i].toLowerCase().startsWith(src.toLowerCase())) {
      if(sceneryList[i].equals(src)) {
        return src;
      } else {
        return sceneryList[i];
      }
    }
  }
  
  return src;
}

public final boolean isVisible(float x1, float y1, float x2, float y2) {  
  for (int i=0; i<game.polyData.size(); i++) {
    Polygon ph = (Polygon) game.polyData.get(i);
    int vCount = 1;

    if (ph.type != 3) {
      for (int x=0; x<3; x++) {
        if (linesIntersect(x1, y1, x2, y2, ph.x[x], ph.y[x], ph.x[vCount], ph.y[vCount])) return false;
        vCount++;
        if (vCount == 3) vCount=0;
      }
    }
  }
  return true;
}

public static boolean linesIntersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  // Return false if either of the lines have zero length
  if (x1 == x2 && y1 == y2 || x3 == x4 && y3 == y4) return false;

  // Fastest method, based on Franklin Antonio's "Faster Line Segment Intersection" topic "in Graphics Gems III" book (http://www.graphicsgems.org/)
  float ax = x2-x1;
  float ay = y2-y1;
  float bx = x3-x4;
  float by = y3-y4;
  float cx = x1-x3;
  float cy = y1-y3;

  float alphaNumerator = by*cx - bx*cy;
  float commonDenominator = ay*bx - ax*by;
  if (commonDenominator > 0) {
    if (alphaNumerator < 0 || alphaNumerator > commonDenominator) return false;
  } 
  else if (commonDenominator < 0) {
    if (alphaNumerator > 0 || alphaNumerator < commonDenominator) return false;
  }

  float betaNumerator = ax*cy - ay*cx;
  if (commonDenominator > 0) {
    if (betaNumerator < 0 || betaNumerator > commonDenominator) return false;
  } 
  else if (commonDenominator < 0) {
    if (betaNumerator > 0 || betaNumerator < commonDenominator) return false;
  }

  if (commonDenominator == 0) {
    // This code wasn't in Franklin Antonio's method. It was added by Keith Woodward.
    // The lines are parallel.
    // Check if they're collinear.
    float y3LessY1 = y3-y1;
    float collinearityTestForP3 = x1*(y2-y3) + x2*(y3LessY1) + x3*(y1-y2); // see http://mathworld.wolfram.com/Collinear.html
    // If p3 is collinear with p1 and p2 then p4 will also be collinear, since p1-p2 is parallel with p3-p4
    if (collinearityTestForP3 == 0) {
      // The lines are collinear. Now check if they overlap.
      if (x1 >= x3 && x1 <= x4 || x1 <= x3 && x1 >= x4 ||
        x2 >= x3 && x2 <= x4 || x2 <= x3 && x2 >= x4 ||
        x3 >= x1 && x3 <= x2 || x3 <= x1 && x3 >= x2) {
        if (y1 >= y3 && y1 <= y4 || y1 <= y3 && y1 >= y4 ||
          y2 >= y3 && y2 <= y4 || y2 <= y3 && y2 >= y4 ||
          y3 >= y1 && y3 <= y2 || y3 <= y1 && y3 >= y2) {
          return true;
        }
      }
    }
    return false;
  }
  return true;
}

Vehicle getVehicleById(int id_) {
  for (int i=0; i<game.vehicleData.size(); i++) {
    Vehicle ph = (Vehicle) game.vehicleData.get(i);
    if (ph.id == id_) return ph;
  }
  return null;
}

Soldier getSoldierById(int id_) {
  for (int i=0; i<game.soldierData.size(); i++) {
    Soldier ph = (Soldier) game.soldierData.get(i);
    if (ph.id == id_) return ph;
  }
  return null;
}

Grapple getGrappleById(int id_) {
  for (int i=0; i<game.grappleData.size(); i++) {
    Grapple ph = (Grapple) game.grappleData.get(i);
    if (ph.id == id_) return ph;
  }
  return null;
}

Pickups getPickupById(int id_) {
  for (int i=0; i<game.pickupData.size(); i++) {
    Pickups ph = (Pickups) game.pickupData.get(i);
    if (ph.id == id_) return ph;
  }
  return null;
}

boolean isBiggestInArray(int[] a, int pos) {  //CHECKS IF SPECIFIC POSITION IN ARRAY IS THE BIGGEST IN ARRAY
  for (int i=0; i<a.length; i++) if (i != pos && a[i] > a[pos]) return false;
  return true;
}

boolean arrayDataLargerThanZero(int[] a) {
  for (int i=0; i<a.length; i++) if (a[i] > 0) return true;
  return false;
} 

int getBiggestInArray(int[] a) {  //RETURNS POSITION OF BIGGEST NUMBER IN ARRAY
  if (a.length == 0) return -1;
  int r = 0;
  int amount = 0;

  for (int i=0; i<a.length; i++) {
    if (a[i] > amount) {
      r = i;
      amount = a[i];
    }
  }

  return r;
}

int[] setArrayToZero(int n) {  //RETURNS NEW ARRAY OF N LENGTH TO 0
  int[] r = new int[n];
  for (int i=0; i<n; i++) r[i] = 0;
  return r;
}


String stringArrayToSentence(String[] n, int offset) {
  String s = "";
  for (int i=offset; i<n.length; i++) s += n[i]+" ";
  return s;
}

boolean stringArrayContains(String[] s_, String data_) {
  for (int i=0; i<s_.length; i++) if (s_[i].equals(data_)) return true;
  return false;
}

byte[] removeFirstBytes(byte[] b_, int amount_) {
  byte[] tb = new byte[b_.length-amount_];  //TEMP DATA FROM IT
  for (int i=0; i<tb.length; i++) { 
    tb[i] = b_[i+amount_];
  }
  return tb;
}

float byteArrayToFloat(byte[] b_) {
  char[] c = new char[b_.length];
  for (int i=0; i<b_.length; i++) { 
    c[i] = char(b_[i]);
  }
  String[] s = new String[b_.length];
  for (int i=0; i<b_.length; i++) { 
    s[i] = str(c[i]);
  }

  String joinedString = join(s, "");
  return float(joinedString);
}

float byteArrayToInt(byte[] b_) {
  char[] c = new char[b_.length];
  for (int i=0; i<b_.length; i++) { 
    c[i] = char(b_[i]);
  }
  String[] s = new String[b_.length];
  for (int i=0; i<b_.length; i++) { 
    s[i] = str(c[i]);
  }

  String joinedString = join(s, "");
  int f = int(joinedString);
  return f;
}

byte[] float2byte(float f_) {
  /*
  THIS FUNCTION MAY MAKE NON DECIMAL NUMBERS HUGE...GUESS WELL SEE...
   */

  String s = str(f_);
  byte[] b = new byte[12];
  for (int i=0; i<12; i++) { 
    b[i] = 0;
  }
  for (int i=0; i<s.length(); i++) {
    b[i] = byte(s.charAt(i));
  }
  return b;
}

public static byte[] toByte(int data) {  
  return new byte[] {  
    (byte)((data >> 24) & 0xff), 
    (byte)((data >> 16) & 0xff), 
    (byte)((data >> 8) & 0xff), 
    (byte)((data >> 0) & 0xff),
  };
}

public static byte toByte(boolean data) {
  if (data == false) return 0;
  else return 1;
}

public static boolean toBoolean(byte data) {
  if (data == 0) return false;
  else return true;
}

public static int toInt(byte[] data) {
  if (data == null || data.length != 4) return 0x0;
  // ----------
  return (int)( // type cast not necessary for int
  (0xff & data[0]) << 24  |
    (0xff & data[1]) << 16  |
    (0xff & data[2]) << 8   |
    (0xff & data[3]) << 0
    );
}

public static byte[] toByte(float data) {  
  return toByte(Float.floatToRawIntBits(data));
}

public static float toFloat(byte[] data) {
  if (data == null || data.length != 4) return 0x0;
  // ---------- simple:
  return Float.intBitsToFloat(toInt(data));
}

boolean checkHash(String path_, String hash_) {
  //File f = new File(path_);
  //if(f.exists()) return false;
  return createHash(path_).equals(hash_);
}

byte[] messageDigest(String message, String algorithm) {
  try {
    java.security.MessageDigest md = java.security.MessageDigest.getInstance(algorithm);
    md.update(message.getBytes());
    return md.digest();
  } 
  catch(java.security.NoSuchAlgorithmException e) {
    println(e.getMessage());
    return null;
  }
} 

String createHash(String path_) {
  byte[] md5hash = messageDigest(new String(loadBytes(path_)), "MD5");
  BigInteger bigInt = new BigInteger(1, md5hash);
  return bigInt.toString(16);
}

String createHash(byte[] path_) {
  byte[] md5hash = messageDigest(new String(path_), "MD5");
  BigInteger bigInt = new BigInteger(1, md5hash);
  return bigInt.toString(16);
}

public void exitProgram() {
  println("Exit at "+month()+"-"+day()+"-"+year()+"_"+hour()+"."+minute()+"."+second());
  try {
    consoleOutput.flush();
    consoleOutput.close();
  } 
  catch(Exception e) {
    e.printStackTrace();
  }

  for (int i=0; i<game.gunData.length; i++) {
    if (game.gunData[i].sound) {
      game.gunData[i].asShoot.close();
    }
  }
  minim.stop();
  exit();
}

