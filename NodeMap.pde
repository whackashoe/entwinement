class NodeMap {
  boolean[][] nodes;
  float scaleX;
  float scaleY;
  
  NodeMap(int w, int h, float scaleX, float scaleY) {
    nodes = new boolean[h][w];
    this.scaleX = scaleX;
    this.scaleY = scaleY;
  }
  
  PGraphics loadFromCurrent() {
    PGraphics pg = createGraphics(nodes[0].length, nodes.length, P2D);
    pg.beginDraw();
    pg.stroke(255);
    pg.strokeWeight(1);
    for(int i=0; i<game.polyData.size(); i++) {
      Polygon ph = (Polygon) game.polyData.get(i);
      if(ph.type != 3) {
        pg.fill(255, 100);
        pg.triangle(ph.x[0]*scaleX, ph.y[0]*scaleY, ph.x[1]*scaleX, ph.y[1]*scaleY, ph.x[2]*scaleX, ph.y[2]*scaleY);
      }
    }
    pg.endDraw();
    
    /*
    boolean[] cropsY = new boolean[nodes.length];
    boolean[] cropsX = new boolean[nodes[0].length];
    
    for(int y=0; y<nodes.length; y++) {
      int xAmount = 0;
      for(int x=0; x<nodes[y].length; x++) {
        if(nodes[y][x] == 0) xAmount++;
      }
      if(xAmount == nodes[y].length) cropsX[y] = true;
    }
    
    for(int x=0; x<nodes[0].length; x++) {
      int yAmount = 0;
      for(int y=0; y<nodes.length; y++) {
        if(nodes[y][x] == 0) yAmount++;
      }
      if(yAmount == nodes.length) cropsY[x] = true;
    }
    */
    
    return pg;
  }
}
