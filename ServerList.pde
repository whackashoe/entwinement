class ServerList {
  ArrayList servers;
  
  ServerList() {
    servers = new ArrayList();
  }
  
  void updateList() {
    byte[] b = new byte[0];
    this.updateList(b);
  }
  
  void updateList(byte[] b_) {
    servers = new ArrayList();
    servers.add(new Server("127.0.0.1", 12345, "Home Server", 0, 0, 0, false));
    String data = new String(b_);
    String[] lines = splitTokens(data, "\n");
    for(int i=0; i<lines.length; i++) {
      String[] pieces = splitTokens(lines[i], "*");
      println(pieces);
      if(pieces.length == 7) {
        boolean pword = false;
        if(pieces[6].equals("1")) pword = true;
        servers.add(new Server(pieces[0], Integer.parseInt(pieces[1]), pieces[2], Integer.parseInt(pieces[3]), Integer.parseInt(pieces[4]), Integer.parseInt(pieces[5]), boolean(Integer.parseInt(pieces[6]))));
      } else {
        println("only got "+pieces.length+" pieces");
      }
    }
  }
  
  class Server {
    String ip;
    int port;
    int curPlayers;
    int maxPlayers;
    int gameType;
    boolean passworded;
    String name;
    
    
    Server(String ip_, int port_, String name_, int curPlayers_, int maxPlayers_, int gameType_, boolean passworded_) {
      ip = ip_;
      port = port_;
      name = name_;
      curPlayers = curPlayers_;
      maxPlayers = maxPlayers_;
      gameType = gameType_;
      passworded = passworded_;
    }
  }
}
