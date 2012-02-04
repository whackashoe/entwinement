# TODO
#def teleportObject(id, x, y): pass
#def applyForceToObject(id, xf, yf): pass
#def setVelocityOfObject(id, x, y): pass
#def setRotationOfObject(id, r): pass
#def applyRotationToObject(id, r): pass

	
def loadVehicle(src):
	global com
	com += 'l bv '+str(src)+';'

def loadGun(src):
	global com
	com += 'l g '+str(src)+';'

def loadGunList(src):
	global com
	com += 'l gl '+str(src)+';'

def loadScript(src):
	global com
	com += 'l sc '+str(src)+';'
	
def loadParticle(src):
	global com
	com += 'l p '+str(src)+';'

def loadMap(src, x, y, w, h):
	global com
	com += 'l m '+str(src)+' '+str(x)+' '+str(y)+' '+str(w)+' '+str(h)+';'

def addVehicle(type, x, y):
	global com
	com += 'a v '+str(type)+' '+str(x)+' '+str(y)+';'


def loadTexture(src):
	global com
	com += 'a tex '+src+';'

def addScenery(name, x, y, z, w, h, r):
	global com
	com += 'a scen '+str(name)+' '+str(x)+' '+str(y)+' '+str(z)+' '+str(w)+' '+str(h)+' '+str(r)+';'

def addSceneryFullData(name, x, y, z, w, h, r, r1, g1, b1, a1, r2, g2, b2, a2, r3, g3, b3, a3, z0, z1, z2, z3):
	global com
	com += 'a scen '+str(name)+' '+str(x)+' '+str(y)+' '+str(z)+' '+str(w)+' '+str(h)+' '+str(r)+' '+str(r1)+' '+str(g1)+' '+str(b1)+' '+str(a1)+' '+str(r2)+' '+str(g2)+' '+str(b2)+' '+str(a2)+' '+str(r3)+' '+str(g3)+' '+str(b3)+' '+str(a3)+' '+str(z0)+' '+str(z1)+' '+str(z2)+' '+str(z3)+';'
	
def addBullet(x, y, xf, yf, type, id):
	global com
	com += 'a b '+str(id)+' '+str(x)+' '+str(y)+' '+str(xf)+' '+str(yf)+' '+str(type)+' '+str(id)+';'
	
def addExplosion(x, y, r, t):
	global com
	com += 'a ex '+str(x)+' '+str(y)+' '+str(r)+' '+str(y)+';'

def addEarth(x, y, radius, size, detail):
	global com
	com += 'a ea '+str(x)+' '+str(y)+' '+str(radius)+' '+str(size)+' '+str(detail)+';'

def addGravitron(x, y, gravity, distance):
	global com
	com += 'a gr '+str(x)+' '+str(y)+' '+str(gravity)+' '+str(distance)+';'

def addHealthBox(x, y, amount):
	global com
	com += 'a hb '+str(x)+' '+str(y)+' '+str(amount)+';'

def addAttachmentBox(x, y, type, amount):
	global com
	com += 'a ab '+str(x)+' '+str(y)+' '+str(type)+' '+str(amount)+';'

def addGunBox(x, y, type, ammo, reloadTimer, reloading):
	global com
	com += 'a gb '+str(x)+' '+str(y)+' '+str(ammo)+' '+str(reloadTimer)+' '+str(reloading)+';'
	
def addParticle(type, x, y, r):
	global com
	com += 'a pa '+str(type)+' '+str(x)+' '+str(y)+' '+str(r)+';'
	
def addCat(x, y):
	global com
	com += 'a c '+str(x)+' '+str(y)+';'

#TODO
#def addPhysObjBox(id, x, y, w, h, d, r, f): pass
#def addCirc(id, x, y, r, d, r, f): pass
#def addTri(id, x1, y1, x2, y2, x3, y3): pass
#def addDJoint(id, b1_id, b2_id, x1, y1, x2, y2, dist, freq): pass

# DEATH/REMOVAL
def rm_Soldier(id):
	global com
	com += 'rm s '+str(id)+';'

def rm_Vehicle(id):
	global com
	com += 'rm v '+str(id)+';'

def rm_BaseVehicle(id):
	global com
	com += 'rm bv '+str(id)+';'

def rm_Spawn(id):
	global com
	com += 'rm sp '+str(id)+';'

def rm_Earth(id):
	global com
	com += 'rm e '+str(id)+';'

def rm_Gravitron(id):
	global com
	com += 'rm gr '+str(id)+';'

def rm_Pickup(id):
	global com
	com += 'rm p '+str(id)+';'

def rm_Gun(id):
	global com
	com += 'rm g '+str(id)+';'

def rm_Script(id):
	global com
	com += 'rm sc '+str(id)+';'

# TODO
# def rm_Object(id): pass
# def rm_Joint(id): pass


# world shit
def changeGravity(x, y):
	global com
	com += 'c_g '+str(x)+' '+str(y)+';'
	
def changeCamera(time, eyeX, eyeY, eyeZ, targetX, targetY, targetZ):
	global com
	com += 'c_c '+str(time)+' '+str(eyeX)+' '+str(eyeY)+' '+str(eyeZ)+' '+str(targetX)+' '+str(targetY)+' '+str(targetZ)+';'

def changeCameraView(time, eyeX, eyeY, eyeZ, targetX, targetY, targetZ, upX, upY, upZ):
	global com
	com += 'c_c '+str(time)+' '+str(eyeX)+' '+str(eyeY)+' '+str(eyeZ)+' '+str(targetX)+' '+str(targetY)+' '+str(targetZ)+' '+str(upX)+' '+str(upY)+' '+str(upZ)+';'


"""
all of the functions prepended with request
request the data after update finishes,
if you need this data this *game loop*,
(not this (script)update loop because that is impossible)-
then just return 1 in update and this data will be 
requested and (most likely) updated for you, 
update will run again without the game loop progressing-

this(above) is only supposed to be a fallback mechanism for 
special circumstances. try to program with the requests in
mind as to not slow down game
"""

def requestSoldierGunInfo(id):
	global com
	com += 'req s '+str(id)+' g;'

def requestSoldierPV(id):
	global com
	com += 'req s '+str(id)+' pv;'

def requestVehiclePV(id):
	global com
	com += 'req v '+str(id)+' pv;'
	
def requestPolygonCount():
	global com
	com += 'req p c;'
	
def requestPolygonType(id):
	global com
	com += 'req p t'+str(id)+';'
	
def requestPolygonPosition(id):
	global com
	com += 'req p p'+str(id)+';'
	
def requestPolygonZAxis(id):
	global com
	com += 'req p z'+str(id)+';'
	
def requestPolygonRHW(id):
	global com
	com += 'req p r'+str(id)+';'
	
def requestPolygonUV(id):
	global com
	com += 'req p uv'+str(id)+';'

def requestPolygonVertexColors(id):
	global com
	com += 'req p v'+str(id)+';'

