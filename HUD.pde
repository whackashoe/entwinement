class HUD {
  
  PGraphics minimap;
  
  HUD() {

  }
  
  void update(GL gl) {
    if(settings.drawMinimap) {
      if(minimap != null) image(minimap, width-200, 200);
    }
    
    pushMatrix();
    translate(width-50, 15);
    textFont(FONTframeRate);
    fill(255);
    text(int(frameRate)+" fps", 0, 0);
    if (playingOnline && game != null && game.meCast != null && game.meCast.ping > 0) text("Ping: "+game.meCast.ping, -50, 20);
    /*text("Time Alive: "+int(game.meCast.timeAlive/30), 0, 0);
     
     fill(255);
     text("Vehicles Downed: "+vehiclesDowned, 0, 20);
     
     
     fill(255);
     text("Soldiers Downed: "+enemySoldiersDowned, 0, 40);
     
     fill(255);
     text("Soldiers Alive: "+game.soldierData.size(), 0, 60);*/
    popMatrix();


    if (game.meCast.chooseGun) {
      pushMatrix();
      translate(50, 350);
      //DRAW BOX
      fill(0, 100);
      pushMatrix();
      beginShape();
      translate(-20, -40);
      vertex(0, -0);
      vertex(width/5, 0);
      vertex(width/5, height*.4);
      vertex(0, height*.4);
      endShape();
      popMatrix();
      textFont(FONTframeRate);
      //DRAW SELECTION
      for (int i=1; i<game.gunData.length; i++) {
        if (game.gunData[i].choice) {
          fill(255);
          text(game.gunData[i].name, 20, i*20-40);
          if (game.gunData[i].weaponImg) {
            tint(255, 255);
            image(game.gunData[i].weapon, 0, -20);
          }
        } 
        else {
          fill(255, 100);
          text("--unavailable--", 20, i*20-40);
        }
      }
      popMatrix();
    }  

    pushMatrix();
      translate(0, height-15);
      //black BAR
      fill(0, 100);
      beginShape();
      vertex(0, 0);
      vertex(width, 0);
      vertex(width, 30);
      vertex(0, 30);
      endShape();
      if (game.meCast.alive) {
        /*fill(255);
         if(!game.meCast.driving) {
         text("Health: "+int(game.meCast.health), 15, 15);
         } else {
         text("Health: "+int(game.meCast.health)+" Vehicle: "+int(game.meCast.curCar.health), 15, 15);
         text(" X:"+abs(int(game.meCast.curCar.getCockpit().getVelocityX()))+" Y: "+int(game.meCast.curCar.getCockpit().getVelocityY()), 100, 30);
         }
         */
  
        if (game.meCast.health >= 25) fill(28+map(constrain(game.meCast.health, 25, 100), 25, 100, 201, 0), 230, 49, 100);
        else fill(229, 28, 68, 100);
        beginShape(QUADS);
        vertex(0, 0);
        vertex(0, 30);
        vertex(map(constrain(game.meCast.health, 0, 100), 0, 100, 0, width/3), 30);
        vertex(map(constrain(game.meCast.health, 0, 100), 0, 100, 0, width/3), 0);
        if (game.meCast.driving) {
          fill(229, 105, 28, 200);
          vertex(0, 20);
          vertex(0, 30);
          vertex(map(constrain(game.meCast.curCar.health, 0, game.meCast.curCar.startingHealth), 0, game.meCast.curCar.startingHealth, 0, width/3), 30);
          vertex(map(constrain(game.meCast.curCar.health, 0, game.meCast.curCar.startingHealth), 0, game.meCast.curCar.startingHealth, 0, width/3), 20);
        }
        endShape();
        fill(255);
        text(int(game.meCast.health), width/3/2-10, 10);
        text("K"+game.meCast.kills+"/D"+game.meCast.deaths, 10, 10);
        if (game.meCast.driving) text(int(game.meCast.curCar.health), width/3/2+40, 10);
        
        pushMatrix();
        translate(width/3, 0);
        if (game.meCast.curGun.reloadCount == 0) { 
          pushMatrix();
          float offsetX = 0;
          for (int i=0; i<game.gunData[game.meCast.curGun.gun].ammo; i++) offsetX += width/3/game.gunData[game.meCast.curGun.gun].ammo;
          offsetX = (width/3 - offsetX)/2;
  
          translate(offsetX, 0);
  
          for (int i=0; i<game.meCast.curGun.ammo; i++) {
            pushMatrix();
            scale(width/3/game.gunData[game.meCast.curGun.gun].ammo, 30);
            translate(i, 0);
            if (i % 2 == 0) fill(77, 180, 255, 100);
            else fill(77, 180, 255, 35);
            beginShape();
            vertex(0, 0);
            vertex(1, 0);
            vertex(1, 1);
            vertex(0, 1);
            endShape();
            popMatrix();
          }
          popMatrix();
  
          if (game.meCast.curGun.delayCount > 0) {
            fill(255, 0);
            beginShape();
            vertex(0, 20);
            fill(255, 50);
            vertex(0, 30);
            vertex(map(game.meCast.curGun.delayCount, 0, game.gunData[game.meCast.curGun.gun].delayTime, 0, width/3), 30);
            fill(255, 0);
            vertex(map(game.meCast.curGun.delayCount, 0, game.gunData[game.meCast.curGun.gun].delayTime, 0, width/3), 20);
            endShape();
          }
        } 
        else {
          fill(77, 180, 255, 70);
          beginShape(QUADS);
          vertex(0, 0);
          fill(77, 180, 255, 20);
          vertex(0, 30);
          vertex(map(game.meCast.curGun.reloadCount, 0, game.gunData[game.meCast.curGun.gun].reloadTime, 0, width/3), 30);
          fill(77, 180, 255, 70);
          vertex(map(game.meCast.curGun.reloadCount, 0, game.gunData[game.meCast.curGun.gun].reloadTime, 0, width/3), 0);
          endShape();
        }
        fill(255);
        text(game.gunData[game.meCast.curGun.gun].name+" "+game.meCast.curGun.ammo+"/"+game.gunData[game.meCast.curGun.gun].ammo, 10, 15);
        popMatrix();
  
        pushMatrix();
        translate(width*0.67, 0);
        if (game.meCast.curAttachmentAmmo > 0) {
          if (game.meCast.curAttachment == 0) { 
            if (!mousePressed || mouseButton != RIGHT) fill(229, 28, 220, 100);
            else fill(251, 31, 242, 120);
            beginShape(QUADS);
            vertex(0, 0);
            vertex(0, 30);
            vertex(map(game.meCast.curAttachmentAmmo, 0, game.jetpackMax, 0, width/3), 30);
            vertex(map(game.meCast.curAttachmentAmmo, 0, game.jetpackMax, 0, width/3), 0);
            endShape();
            fill(255);
            text(game.meCast.curAttachmentAmmo, width/3/2-10, 10);
          } 
          else {
            if (game.meCast.curAttachment == 1) { 
              fill(255);
              text("Grapple: "+game.meCast.curAttachmentAmmo, 400, 15);
            }
            if (game.meCast.curAttachment == 2) { 
              fill(255);
              text("Airstrike: "+game.meCast.curAttachmentAmmo, 400, 15);
            }
          }
        }
        popMatrix();
      } 
      else {
        fill(255, 100);
        beginShape(QUADS);
        vertex(0, 0);
        vertex(0, 30);
        vertex(map(game.meCast.respawnTime, 0, game.meCast.initialRespawnTime, 0, width), 30);
        vertex(map(game.meCast.respawnTime, 0, game.meCast.initialRespawnTime, 0, width), 0);
        fill(200, 100);
        vertex(0, 20);
        vertex(0, 30);
        vertex(map(game.meCast.respawnTime, 0, game.meCast.initialRespawnTime, 0, width), 30);
        vertex(map(game.meCast.respawnTime, 0, game.meCast.initialRespawnTime, 0, width), 20);
        endShape();
      }
    popMatrix();
    
    if(settings.drawDebugData) {
      pushMatrix();
      translate(10, 150);
      fill(255);
      textFont(FONTframeRate, 12);
      text("Particles:"+game.particleData.size(), 0, 0);
      text("Bullets:"+game.bulletData.size(), 0, 15);
      text("Explosions:"+game.explosionData.size(), 0, 30);
      text("Soldiers:"+game.soldierData.size(), 0, 45);
      text("Vehicles:"+game.vehicleData.size(), 0, 60);
      text("Polygons:"+game.polyData.size(), 0, 75);
      text("Sceneries:"+game.sceneryData.size(), 0, 90);
      text("Bodies:"+world.getBodies().size(), 0, 105);
      text("Pickups:"+game.pickupData.size(), 0, 120);
      popMatrix();
    }
  }
}
