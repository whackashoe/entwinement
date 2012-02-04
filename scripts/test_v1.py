#!/usr/bin/python

#does not work
#int_onvehicleremove
#addearth?

class test:
	requestMouseKeyboard = 'true'
	i = 0
	
	def __init__(this):
		this.i = 0
		loadVehicle('newcar.xml')
    	
	def update(this):
		if this.i < 10:
			addPolygon(0, this.i*100, 0, this.i*100+100, 0, this.i*100+50, 100, 0, 0, 0, 0, 0, 0, 255)
			addScenery('amb_moon2-sk.png', this.i*100, 0, this.i*20, 100, 100, 0)
			addCat(-this.i*100, -150)
			this.i = this.i+1
			if this.i == 10:
				addVehicle(0, this.i*80, 200)
				
		return 0

	def onSoldierRespawn(this, id):
		print id
		
	
		
'''# GENERAL SOLDIER SHIZ

		#elif this.i == 7:
		#	addDeath(0)

def enterVehicle(id, vid):
	global com
	com += 's_en '+str(id)+' '+str(vid)+';'

def exitVehicle(id):
	global com
	com += 's_ex '+str(id)+';'


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

def addSpawn(x, y, type, subType, amount):
	global com
	com += 'a sp '+str(x)+' '+str(y)+' '+str(type)+' '+str(subType)+' '+str(amount)+';'

def addEarth(x, y, radius, size, detail):
	global com
	com += 'a ea '+str(x)+' '+str(y)+' '+str(radius)+' '+str(size)+' '+str(detail)+';'

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

def rm_Script(id):
	global com
	com += 'rm sc '+str(id)+';'


def changeSoldier(id1, id2):
	global com
	com += 'c_s '+str(id1)+' '+str(id2)+';'


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
'''

