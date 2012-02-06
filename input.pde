boolean keyHeld = false;

void mousePressed() {
  if(!playingOnline || world != null && game != null && game.meCast != null) {
    if(mouseButton == LEFT) {
      game.lmbPush = true; //if(game.meCast.alive) game.lmbPush = true;
      if(game.meCast.chooseGun) {
        if(mouseX<width/3) {
          for(int i=1; i<game.gunData.length; i++) {  //i is 1 because of fists
            if(mouseY < i*20+315 && mouseY >= i*20+295) {
              if(game.gunData[i].choice) {
                game.meCast.switchGun(i);
                game.meCast.chooseGun = false;
              }
            }
          }
        }
      }
    } 
    
    if(mouseButton == RIGHT) game.rmbPush = true; //if(mouseButton == RIGHT && game.meCast.alive) game.rmbPush = true;
    if(mouseButton == CENTER) game.cmbPush = true;
    
    mouseHeld = true;
  }
}

void mouseReleased() {
  if(!playingOnline || world != null && game != null && game.meCast != null) {
    if(mouseButton == LEFT) { game.lmbPush = false; }
    if(mouseButton == CENTER) {
      game.keyGunChange = false;
      game.cmbPush = false;
    }
    if(mouseButton == RIGHT) { game.rmbPush = false; }
  }
}

void keyPressed() {
  char lkey = Character.toLowerCase(key);
  if(!playingOnline || world != null && game != null && game.meCast != null) {
    keyHeld = true;
    if(game.mapLoaded) {
      if(lkey == settings.keyLeft) keyResult |= keyA;
      if(lkey == settings.keyRight) keyResult |= keyD;
      if(lkey == settings.keyUp) keyResult |= keyW;
      if(lkey == settings.keyDown) keyResult |= keyS;
      
      if(lkey == settings.keyKill) game.meCast.health--;
      if(lkey == settings.keyPickup) keyResult |= keyX;
      if(lkey == settings.keyDrop) keyResult |= keyF;
      if(lkey == settings.keyReload) keyResult |= keyR;
      
      if(lkey == settings.keyPause && !game.showInputBox) game.pause();
    }
    if(key == CODED) {
      if(keyCode == ESC) exitProgram();
      if(game.mapLoaded) {
        if(keyCode == KeyEvent.VK_F1) {
          if(settings.drawDebugData) settings.drawDebugData = false;
          else settings.drawDebugData = true;
        }
        if(keyCode == KeyEvent.VK_F2) {
          saveFrame("screenshots/"+month()+"-"+day()+"-"+year()+"_"+hour()+"."+minute()+"."+second()+".png"); 
          game.kConsole.addKillBoxText("Screenshot saved", game.kConsole.white);
        }
      }
      
      if(keyCode == UP) game.meCast.changeGunUp();
      if(keyCode == DOWN) game.meCast.changeGunDown();
    }
  }
}

void keyReleased() {
  char lkey = Character.toLowerCase(key);
  if(!playingOnline || world != null && game != null && game.meCast != null) {
    if(game.mapLoaded) {
      if(lkey == settings.keyLeft) {
        keyResult ^= keyA;
        game.aPush=false;
      }
      
      if(lkey == settings.keyRight) {
        keyResult ^= keyD;
        game.dPush=false;
      }
      
      if(lkey == settings.keyUp) {
        keyResult ^= keyW;
        game.wPush=false;
      }
      
      if(lkey == settings.keyDown) {
        keyResult ^= keyS;
        game.sPush=false;
        game.meCast.crouch = false;
      }
      
      if(lkey == settings.keyKill) game.meCast.health--;
      
      if(lkey == settings.keyPickup) {
        keyResult ^= keyX;
        game.xPush=false;
      }
      
      if(lkey == settings.keyDrop) {
        keyResult ^= keyF;
        game.fPush=false;
      }
      
      if(lkey == settings.keyReload) {
        keyResult ^= keyR;
        game.rPush=false;
      }
      
      if(lkey == settings.keyNade) game.meCast.throwNade();
      
      if(lkey == settings.keyMenu && game.paused) {
        game.setMenuMode(true);
        mainMenu = true;
        game.paused = false;
      }
      
      if(lkey == settings.keyPause) game.pausePush = false;
      
      if(lkey == TAB) {
        if(game.showInputBox) game.showInputBox = false;
        else game.showInputBox = true;
      }
        
      if(lkey == ENTER || lkey == RETURN) {
        if(game.showInputBox &&  !game.inputBox.data.equals("")) {
          game.parseInputBoxData(game.inputBox.data);
          game.inputBox.data = "";
        }
      }
      
      if(!game.showInputBox) {
        if(lkey == '1' || lkey == '2' || lkey == '3' || lkey == '4' || lkey == '5' || lkey == '6' || lkey == '7' || lkey == '8' || lkey == '9' || lkey == '0') {
          int keyNumber = Integer.parseInt(Character.toString(lkey));
          if(keyNumber == 0) keyNumber = 9;
          else keyNumber--;
          if(keyNumber < game.meCast.gunHolds.size()-1) game.meCast.curGun = (HoldGun) game.meCast.gunHolds.get(keyNumber);
        }
      }
    }
    keyHeld = false;
  }
}
