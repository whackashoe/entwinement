void contactStarted(FContact contact) {
  //CHECK EXPLOSIONS FOR COLLISIONS 
  checkExplosions(contact);
  if(!playingOnline) {
    //CHECK TO SEE BULLET COLLISIONS
    for(int i=0; i<game.bulletData.size(); i++) {
      Bullet ph = (Bullet) game.bulletData.get(i);
      if(contact.getBody1()==(ph.b) || contact.getBody2()==(ph.b)) { 
        if(game.gunData[ph.type].boom && !contact.getBody1().isSensor() && !contact.getBody2().isSensor()) ph.blowUp();
        
        for(int p=0; p<game.polyData.size(); p++) {
          Polygon polyCast = (Polygon) game.polyData.get(p);
          if(contact.getBody1()==(polyCast.p) || contact.getBody2()==(polyCast.p)) {
            if(!contact.getBody1().isSensor() && !contact.getBody2().isSensor()) {
              if(!game.gunData[ph.type].delayExplode) ph.alive=false;
              return;
            }
          }
        }
        
        for(int s=0; s<game.soldierData.size(); s++) {
          Soldier soldierCast = (Soldier) game.soldierData.get(s);
          if(contact.getBody1()==(soldierCast.self) || contact.getBody2()==(soldierCast.self)) {
            cSoldierBullet(soldierCast, ph);
            return;
          }
        }
        
        for(int s=0; s<game.grappleData.size(); s++) {
          Grapple grappleCast = (Grapple) game.grappleData.get(s);
          if(contact.getBody1()==(grappleCast.body) || contact.getBody2()==(grappleCast.body)) {
            cGrappleBullet(grappleCast, ph);
            return;
          }
        }
        
        for(int h=0; h<game.vehicleData.size(); h++) {
          Vehicle carCast = (Vehicle) game.vehicleData.get(h);
          for(int j=0; j<carCast.parts.size(); j++) {
            Vehicle.Part partCast = (Vehicle.Part) carCast.parts.get(j);
            if(!partCast.collider ) {
              if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
                cVehicleBullet(partCast, ph);
                return;
              }
            }
          }
        }
      
       for(int p=0; p<game.pickupData.size(); p++) {
         Pickups pph = (Pickups) game.pickupData.get(p);
         if(contact.getBody1()==(pph.collide) || contact.getBody2()==(pph.collide)) {
           if(!game.gunData[ph.type].delayExplode) ph.alive = false;
           return;
         }
        }  
      }
    }
    
    for(int i=0; i<game.soldierData.size(); i++) {
      Soldier soldierCast = (Soldier) game.soldierData.get(i);
      if(contact.getBody1()==(soldierCast.self)  || contact.getBody2()==(soldierCast.self)) {
        if(checkSoldierJump(contact, soldierCast)) return;

        for(int p=0; p<game.polyData.size(); p++) {
          Polygon polyCast = (Polygon) game.polyData.get(p);
          if(contact.getBody1()==(polyCast.p)  || contact.getBody2()==(polyCast.p)) {
            cSoldierPoly(soldierCast, contact.getVelocityY(), contact);
            return;
          }
        }
        
        for(int g=0; g<game.grappleData.size(); g++) {
          Grapple grappleCast = (Grapple) game.grappleData.get(g);
          if(contact.getBody1()==(grappleCast.body)  || contact.getBody2()==(grappleCast.body)) {
            cGrappleBody(grappleCast, soldierCast.self, contact);
            return;
          }
        }
      }
    }
    
    for(int v=0; v<game.vehicleData.size(); v++) {
      Vehicle vehicleCast = (Vehicle) game.vehicleData.get(v);
      for(int i = 0; i<vehicleCast.parts.size(); i++) {
        Vehicle.Part partCast = (Vehicle.Part) vehicleCast.parts.get(i);
        
        if(partCast.collider) {
          if(!vehicleCast.isInhabited) {
            if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
              for(int s=0; s<game.soldierData.size(); s++) {
                Soldier sh = (Soldier) game.soldierData.get(s);
                if(contact.getBody1()==(sh.self) || contact.getBody2()==(sh.self)) {
                  cSoldierVehicle(sh, vehicleCast);
                  return;
                }
              }
            }
          }
        } else {
          for(int p=0; p<game.polyData.size(); p++) {
            Polygon pCast = (Polygon) game.polyData.get(p);
            FPoly polyCast = pCast.p;
            if(contact.getBody1()==(polyCast) || contact.getBody2()==(polyCast)) {
              if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
                partCast.setTouchingPoly(true);
                return;
              }
            }
          }
          
          for(int g=0; g<game.grappleData.size(); g++) {
            Grapple grappleCast = (Grapple) game.grappleData.get(g);
            if(contact.getBody1()==(grappleCast.body)  || contact.getBody2()==(grappleCast.body)) {
              cGrappleBody(grappleCast, partCast.getBody(), contact);
              return;
            }
          }
        }
      }
    }  
  //IF PLAYING ONLINE  
  } else {
    for(int i=0; i<game.bulletData.size(); i++) {
      Bullet ph = (Bullet) game.bulletData.get(i);
      if(contact.getBody1()==(ph.b) || contact.getBody2()==(ph.b)) {
        if(!contact.getBody1().isSensor() && !contact.getBody2().isSensor()) {
          if(!game.gunData[ph.type].delayExplode) ph.alive = false;
          return;
        }
      }
    }
  }
  
  
  
  
  for(int g=0; g<game.grappleData.size(); g++) {
    Grapple grappleCast = (Grapple) game.grappleData.get(g);
    if(contact.getBody1()==(grappleCast.body)  || contact.getBody2()==(grappleCast.body)) {
      
      for(int i=0; i<game.pickupData.size(); i++) {
        Pickups pickupsCast = (Pickups) game.pickupData.get(i);
        if(contact.getBody1() == pickupsCast.p || contact.getBody2() == pickupsCast.p) {
          cGrappleBody(grappleCast, pickupsCast.p, contact);
          return;
        }
      }
      
      for(int i=0; i<game.polyData.size(); i++) {
        Polygon polyCast = (Polygon) game.polyData.get(i);
        if(contact.getBody1() == polyCast.p || contact.getBody2() == polyCast.p) {
          cGrappleBody(grappleCast, polyCast.p, contact);
          return;
        }
      }
    }
  }
}

void contactPersisted(FContact contact) {
  checkExplosions(contact);
  
  if(!playingOnline) {
    for(int v=0; v<game.vehicleData.size(); v++) {
      Vehicle vehicleCast = (Vehicle) game.vehicleData.get(v);
      for(int i = 0; i<vehicleCast.parts.size(); i++) {
        Vehicle.Part partCast = (Vehicle.Part) vehicleCast.parts.get(i);
        //CHECK SELF COLLIDE
        if(partCast.collider && !vehicleCast.isInhabited) {
          if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
            for(int s=0; s<game.soldierData.size(); s++) {
              Soldier sh = (Soldier) game.soldierData.get(s);
              if(contact.getBody1()==(sh.self) || contact.getBody2()==(sh.self)) {
                cSoldierVehicle(sh, vehicleCast);
                return;
              }
            }
          }
        }
        
        //CHECK POLY and earth COLLIDE
        for(int p=0; p<game.polyData.size(); p++) {
          Polygon pCast = (Polygon) game.polyData.get(p);
          FPoly polyCast = (FPoly) pCast.p;
          if(contact.getBody1()==(polyCast) || contact.getBody2()==(polyCast)) {
            if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
              partCast.setTouchingPoly(true);
              return;
            }
          }
        }
        
        //IF NOT TOUCHING POLY WE SHOULD CHECK IF IT IS TOUCHING VEHICLE
        if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
          for(int vd=0; vd<game.vehicleData.size(); vd++) {
            Vehicle vehicleCast2 = (Vehicle) game.vehicleData.get(vd);
            for(int p=0; p<vehicleCast2.parts.size(); p++) {
              Vehicle.Part partCast2 = (Vehicle.Part) vehicleCast2.parts.get(p);
              if(v == vd) continue;
              
              if(partCast2.alive) {
                if(contact.getBody1()==(partCast2.getBody())) {
                  partCast.setTouchingPoly(true);  //set to true just so we can drive
                  return;
                }
              }
            }
          }
        }
      }
    }
  }
  
  for(int s=0; s<game.soldierData.size(); s++) {
    Soldier soldierCast = (Soldier) game.soldierData.get(s);
    if(contact.getBody1()==(soldierCast.self) || contact.getBody2()==(soldierCast.self)) {
      for(int c=0; c<game.flagData.size(); c++) {
        Flag ch = (Flag) game.flagData.get(c);
        if(contact.getBody1()==(ch.flag) || contact.getBody2()==(ch.flag)) {
          ch.pickup(soldierCast);
          return;
        }
      }   
     
      for(int i=0; i<game.pickupData.size(); i++) {
        Pickups ph = (Pickups) game.pickupData.get(i);
        if(contact.getBody1()==(ph.collide) || contact.getBody2()==(ph.collide)) {
          cSoldierPickup(soldierCast, ph);
          return;
        }
      }
      
      if(checkSoldierJump(contact, soldierCast)) return;
    }
  }
}

void contactEnded(FContact contact) {
  if(!playingOnline) {
    for(int s=0; s<game.soldierData.size(); s++) {
      Soldier soldierCast = (Soldier) game.soldierData.get(s);

      if(contact.getBody1() == soldierCast.self || contact.getBody2() == soldierCast.self) {
        for(int i=0; i<game.vehicleData.size(); i++) {
          Vehicle vehicleCast = (Vehicle) game.vehicleData.get(i);
          for(int j=0; j<vehicleCast.parts.size(); j++) {
            Vehicle.Part partCast = (Vehicle.Part) vehicleCast.parts.get(j);
            if(partCast.collider) {
              if(contact.getBody1()==partCast.getBody() || contact.getBody2()==partCast.getBody()) {
                soldierCast.touchingVehicle=false;
                return;
              }
            }
          }
        }
        
        for(int i=0; i<game.pickupData.size(); i++) {
          Pickups ph = (Pickups) game.pickupData.get(i);
          if(contact.getBody1()==(ph.p) || contact.getBody2()==(ph.p)) {
            soldierCast.touchingPickup=false;
            return;
          }
        }
      }
      //CHECK FOR VEHICLE
      /*for(int v=0; v<game.vehicleData.size(); v++) {
        Vehicle vehicleCast = (Vehicle) game.vehicleData.get(v);
        for(int i = 0; i<vehicleCast.parts.size(); i++) {
          Vehicle.Part partCast = (Vehicle.Part) vehicleCast.parts.get(i);
          if(contact.getBody1()==(partCast.getBody()) || contact.getBody2()==(partCast.getBody())) {
            for(int p=0; p<game.polyData.size(); p++) {
              Polygon pCast = (Polygon) game.polyData.get(p);
              if(contact.getBody1()==(pCast.p) || contact.getBody2()==(pCast.p)) {
                partCast.setTouchingPoly(false);
                return;
              }
            }
          }
        }
      }*/
    }
  }
}

void checkExplosions(FContact contact) {
  for(int e=0; e<game.explosionData.size(); e++) {
    Explosion explosionCast = (Explosion) game.explosionData.get(e);
    if(explosionCast.physAlive) {  //ONLY NEED TO CHECK IF THE SENSOR IS STILL ON
      FCircle sensorCast = (FCircle) explosionCast.c;
      if(contact.getBody1()==(sensorCast) || contact.getBody2()==(sensorCast)) {
        //CHECK FOR VEHICLES
        for(int i = 0; i < game.vehicleData.size(); i++) {
          Vehicle vehicleCast = (Vehicle) game.vehicleData.get(i);
          for(int k=0; k<vehicleCast.parts.size(); k++) {
            Vehicle.Part partCast = (Vehicle.Part) vehicleCast.parts.get(k);
            
             if(contact.getBody1()==(partCast.getBody())  || contact.getBody2()==(partCast.getBody())) {
              float distance = dist(partCast.getBody().getX(), partCast.getBody().getY(), explosionCast.x, explosionCast.y);
              partCast.health += constrain(map(distance, 0, explosionCast.radius, -explosionCast.damage, 0), -1000, 0);
              cExplosionBody(explosionCast, partCast.getBody(), distance, vehicleCast.explosionMult);
              return;
            }
          }
        }
        //CHECK FOR SOLDIERS
        for(int i = 0; i < game.soldierData.size(); i++) {
          Soldier sCast = (Soldier) game.soldierData.get(i);
          if(contact.getBody1()==(sCast.self)  || contact.getBody2()==(sCast.self)) {
            float distance = dist(sCast.self.getX(), sCast.self.getY(), sensorCast.getX(), sensorCast.getY());
            if(isVisible(sensorCast.getX(), sensorCast.getY(), sCast.self.getX(), sCast.self.getY()) || distance < explosionCast.radius*0.6) {
              if(!sCast.isInvincible) sCast.health += constrain(map(distance, 0, explosionCast.radius, -explosionCast.damage, 0), -1000, 0);
              cExplosionBody(explosionCast, sCast.self, distance, 0.5);
              sCast.killLogging(-3);
              return;
            }
          } 
        }
        //CHECK FOR SOLDIERS
        for(int i = 0; i < game.ragdollData.size(); i++) {
          Ragdoll rCast = (Ragdoll) game.ragdollData.get(i);
          if(rCast.ragEffect) {
            for(int j=0; j<rCast.pieces.length; j++) {
              if(contact.getBody1()==(rCast.pieces[j])  || contact.getBody2()==(rCast.pieces[j])) {
                float distance = dist(rCast.pieces[j].getX(), rCast.pieces[j].getY(), sensorCast.getX(), sensorCast.getY());
                if(isVisible(sensorCast.getX(), sensorCast.getY(), rCast.pieces[j].getX(), rCast.pieces[j].getY()) || distance < explosionCast.radius*0.6) {
                  cExplosionBody(explosionCast, rCast.pieces[j], distance, 0.5);
                  return;
                }
              } 
            }
          }
        }
        //CHECK FOR PICKUPS
        for(int i = 0; i < game.pickupData.size(); i++) {
          Pickups pCast = (Pickups) game.pickupData.get(i);
          if(contact.getBody1()==(pCast.p)  || contact.getBody2()==(pCast.p)) {
            float distance = dist(pCast.p.getX(), pCast.p.getY(), sensorCast.getX(), sensorCast.getY());
            if(isVisible(sensorCast.getX(), sensorCast.getY(), pCast.p.getX(), pCast.p.getY()) || distance < explosionCast.radius*0.6) {
              cExplosionBody(explosionCast, pCast.p, distance, 0.5);
              return;
            }
          } 
        }
        /*
        //CHECK FOR BULLETS
        for(int i = 0; i < game.bulletData.size(); i++) {
          Bullet pCast = (Bullet) game.bulletData.get(i);
          FCircle b = (FCircle) pCast.b;
          if(contact.getBody1()==(b)  || contact.getBody2()==(b)) {
            float distance = dist(b.getX(), b.getY(), sensorCast.getX(), sensorCast.getY());
            if(isVisible(sensorCast.getX(), sensorCast.getY(), b.getX(), b.getY()) || distance < explosionCast.radius*0.6) {
              cExplosionBody(explosionCast, b, distance, 0.5);
              return;
            }
          } 
        }
        */
        //CHECK FOR GRAPPLES
        for(int i=0; i<game.grappleData.size(); i++) {
          Grapple sCast = (Grapple) game.grappleData.get(i);
          if(contact.getBody1()==(sCast.body)  || contact.getBody2()==(sCast.body)) {
            float distance = dist(sCast.body.getX(), sCast.body.getY(), sensorCast.getX(), sensorCast.getY());
            if(isVisible(sensorCast.getX(), sensorCast.getY(), sCast.body.getX(), sCast.body.getY()) || distance < explosionCast.radius*0.6) {
              sCast.health += constrain(map(distance, 0, explosionCast.radius, -explosionCast.damage, 0), -1000, 0);
              cExplosionBody(explosionCast, sCast.body, distance, 0.5);
              return;
            }
          } 
        }
      } 
      
    }
  }
}

boolean checkSoldierJump(FContact contact, Soldier sh) {
  if((contact.getBody1() == sh.self && !contact.getBody2().isSensor()) || (contact.getBody2() == sh.self && !contact.getBody1().isSensor())) {
    boolean canJump = false;
    if(contact.getY() > sh.self.getY()+sh.self.getSize()/4) canJump = true;
    
    if(settings.debugMode && sh.me) {
      println("contact:"+int(contact.getX())+"/"+int(contact.getY()));
      println("me:"+int(sh.self.getX())+"/"+int(sh.self.getY()));
    }
    
    if(canJump) {
      game.meCast.canJump = true;
      return true;
    }
  }
  return false;
}

void cExplosionBody(Explosion explosionCast, FBody bodyCast, float distance, float multiplier) {
  float explodeAngle = atan2(bodyCast.getY() - explosionCast.c.getY(), bodyCast.getX() - explosionCast.c.getX());
  float mappedDistance = map(distance, 0, explosionCast.radius, -explosionCast.damage, 0);
  bodyCast.addForce(-sin(explodeAngle)*explosionCast.damage*(mappedDistance*multiplier), cos(explodeAngle)*explosionCast.damage*(mappedDistance*multiplier));          
}

void cSoldierPropellor(Soldier sh_) {
  /*
  if(!sh_.isInvincible) {
    sh_.self.addForce(int(random(-1000, 1000)), int(random(-500, 0)));
    sh_.health = sh_.health-100;
    for(int i=0; i<int(random(bloodMax, bloodMax)); i++) { game.particleData.add(new Particle(sh_.self.getX(), sh_.self.getY(), 5, 5, 0)); }
  }
  */
}

void cVehicleBullet(Vehicle.Part partCast, Bullet bulletCast) {
  if(!partCast.getBody().isSensor()) {
    partCast.hurt(game.gunData[bulletCast.type].damage);
    for(int i=0; i<int(random(0, 3)); i++) game.particleData.add(new Particle(2, bulletCast.b.getX(), bulletCast.b.getY(), random(4, 10)));
    if(!game.gunData[bulletCast.type].delayExplode) bulletCast.alive = false;
  }
}


void cSoldierBullet(Soldier s_, Bullet bh_) {
  if(!game.friendlyFire && game.getGameType() != 0 && game.getGameType() != 1) {  //IF FRIENDLYFIRE AND WERE PLAYING TEAMMATCH
    Soldier sh = (Soldier) game.getSoldierById(bh_.id);
    if(s_.team == sh.team && !sh.zombie) return;
  }
  
  for(int i=0; i<int(random(bloodMin, bloodMax)); i++) game.particleData.add(new Particle(1, bh_.b.getX(), bh_.b.getY(), random(2.5, 6)));
  
  if(!s_.isInvincible) {
    if(bh_.b.getY() < s_.self.getY()-s_.self.getSize()/2) s_.health -= game.gunData[bh_.type].damage*1.5;  //headshot
    else s_.health -= game.gunData[bh_.type].damage;  //regular body shot
    
    s_.curGun.bink += game.gunData[bh_.type].bink;
    
    if(game.gunData[bh_.type].flame) s_.startFire();
  }
  
  s_.killLogging(bh_);
  if(s_.health < 0) for(int i=0; i<bloodMax; i++) game.particleData.add(new Particle(1, bh_.b.getX(), bh_.b.getY(), random(3, 8)));
  if(!game.gunData[bh_.type].delayExplode) bh_.alive = false;
  
  if(game.gunData[bh_.type].explodeOnSoldierImpact) {
    bh_.blowUp();
    bh_.alive = false;
  }
}

void cGrappleBullet(Grapple s_, Bullet bh_) {
  s_.health -= game.gunData[bh_.type].damage;
  if(!game.gunData[bh_.type].delayExplode) bh_.alive = false;
}

void cGrappleBody(Grapple grappleCast, FBody bodyCast, FContact contact) {
  if(!contact.getBody2().isSensor() & !contact.getBody1().isSensor()) {
    if(grappleCast.alive && !grappleCast.attached) grappleCast.foundConnect(bodyCast, contact.getX() - contact.getBody1().getX(), contact.getY() - contact.getBody1().getY());
  }
}

void cSoldierPoly(Soldier sh_, float yVelo_, FContact contact_) {
  //sh_.canJump = true;
  sh_.backFlipping = false;
  
  if(yVelo_ > 1000) {  //FOR FALLS
    sh_.health = sh_.health-(int(yVelo_)-1000);
    //for(int i=0; i<abs((int(yVelo_)-1000) / 100); i++) { game.particleData.add(new Particle(sh_.self.getX()+int(random(-sh_.self.getSize(), sh_.self.getSize())), sh_.self.getY()+(int(random(0, sh_.self.getSize()/2))), 10, 5, 0)); }
    for(int i=0; i<abs((int(yVelo_)-1000) / 100); i++) game.particleData.add(new Particle(1, sh_.self.getX()+int(random(-sh_.self.getSize(), sh_.self.getSize())), sh_.self.getY()+(int(random(0, sh_.self.getSize()/2))), random(3, 6)));
    sh_.killLogging(-1);
    sh_.canJump = false;
  }
  
  if(sh_.curAttachment == 0 && sh_.curAttachmentAmmo < game.jetpackMax) sh_.curAttachmentAmmo++;
}

void cSoldierVehicle(Soldier sh, Vehicle vh) {
  sh.touchingVehicle = true;
  sh.tVehicle = (Vehicle) vh;
}

void cSoldierPickup(Soldier sh_, Pickups pickupCast_) {
  if(pickupCast_.type[0] == 1) {
    sh_.health += pickupCast_.type[1];
    pickupCast_.alive = false;
  } else {
    sh_.touchingPickup = true;
    sh_.tPickup = pickupCast_;
  }
}
