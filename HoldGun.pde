class HoldGun {
  int gun;
  int ammo;
  float bink = 0;
  int delayCount;
  int reloadCount;
  
  HoldGun() {
    this.gun = 0;
    this.ammo = 0;
    this.delayCount = 0;
    this.reloadCount = 0;
  }
  
  HoldGun(int gun) {
    this.gun = gun;
    this.ammo = game.gunData[gun].ammo;
    this.delayCount = int(game.gunData[gun].delayTime/4);
    this.reloadCount = 0;
  }
  
  HoldGun(int gun, int ammo, int delayCount, int reloadCount) {
    this.gun = gun;
    this.ammo = ammo;
    this.delayCount = delayCount;
    this.reloadCount = reloadCount;
  }
  
  void update() {
    if(bink > QUARTER_PI) bink = QUARTER_PI;
    else if(bink > 0) bink -= game.BINK_MINUS;
    else bink = 0;
    
    if(reloadCount > 0) {
      reloadCount--;
      if(reloadCount == 0) {
        ammo = game.gunData[gun].ammo;
        delayCount = 0;
      }
    }
    if(delayCount > 0) delayCount--;
  }
  
  void shoot() {
    bink += game.gunData[gun].recoil;
    delayCount = game.gunData[gun].delayTime;
    ammo--;
    
    if(ammo < 1) reload();
  }
  
  boolean canShoot() {
    if(ammo > 0) {
      if(reloadCount == 0 && delayCount == 0) return true;
    } else if(reloadCount == 0) {
      reload();
    }
    return false;
  }
  
  void reload() {
    reloadCount = game.gunData[gun].reloadTime;
  }
}
