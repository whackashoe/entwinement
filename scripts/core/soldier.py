d_soldiers = []

class Soldier:
	def __init__(self, id, name, team):
		self.id = id
		self.name = name
		self.team = team
		self.x = 0
		self.y = 0
		self.xVelo = 0
		self.yVelo = 0
		self.kills = 0
		self.deaths = 0
		self.alive = 'true'
		self.driving = 'false'
		
		self.gun = 0
		self.ammo = 0
		self.reloading = 'false'

	def setPosition(self, x, y, xv, yv):
		self.x = x
		self.y = y
		self.xVelo = xv
		self.yVelo = yv

	def setName(self, name):
		self.name = name

	def setTeam(self, team):
		self.team = team
	
	def setGun(self, gun):
		self.gun = gun
		
	def setGunInfo(self, gun, ammo, reloading):
		self.gun = gun
		self.ammo = ammo
		self.reloading = reloading

	def die(self):
		self.alive = 'false'
		self.driving = 'false'
		self.deaths += 1

	def respawn(self):
		self.alive = 'true'
		
	def teleport(self, x, y):
		global com
		self.x = x
		self.y = y
		com += 'f_t s '+str(self.id)+' '+str(self.x)+' '+str(self.y)+';'
	
	def applyForce(self, xf, yf):
		global com
		com += 'f_af s '+str(self.id)+' '+str(xf)+' '+str(yf)+';'
		
	def setVelocity(self, xf, yf):
		global com
		self.xVelo = xf
		self.yVelo = yf
		com += 'f_v s '+str(self.id)+' '+str(self.xVelo)+' '+str(self.yVelo)+';'
	
	def changeTeam(self, team):
		global com
		self.team = team
		com += 's_ct '+str(self.id)+' '+str(self.team)+';'

	def changeGun(self, gun):
		global com
		self.gun = gun
		com += 's_cg '+str(self.id)+' '+str(self.gun)+';'

	def changeAttachment(self, type, amount):
		global com
		com += 's_ca '+str(self.id)+' '+str(type)+' '+str(amount)+';'

	def killSoldier(self):
		global com
		self.alive = false
		com += 's_ks '+str(id)+';'

	def respawnSoldier(self, spawn):
		global com
		com += 's_rs '+str(self.id)+' '+str(spawn)+';'

	def enterVehicle(self, vehicleId):
		global com
		com += 's_en '+str(self.id)+' '+str(vehicleId)+';'

	def exitVehicle(self):
		global com
		com += 's_ex '+str(self.id)+';'

	def addKill(self):
		global com
		self.kills += 1
		com += 's_ak '+str(self.id)+';'

	def addDeath(self):
		global com
		self.deaths += 1
		com += 's_ad '+str(self.id)+';'

	def dropGun(self):
		global com
		com += 's_dg '+str(self.id)+';'


def addSoldier(team):
	global com
	com += 'a s '+str(team)+';'
	
def getSoldier(n):
	global d_soldiers
	return d_soldiers[n]

def getSoldierById(id):
	global d_soldiers
	for n in xrange(len(d_soldiers)):
		s = d_soldiers[n]
		if s.id == id:
			return s
	

def getSoldierCount():
	global d_soldiers
	return len(d_soldiers)
	


def getTeamKills(team):
	amount = 0
	for n in xrange(len(d_soldiers)):
		s = d_soldiers[n]
		if s.team == team:
			amount += s.kills
	return amount
			
def getTeamDeaths(team):
	amount = 0
	for n in xrange(len(d_soldiers)):
		s = d_soldiers[n]
		if s.team == team:
			amount += s.deaths
	return amount
	
def getTeamSize(team):
	amount = 0
	for n in xrange(len(d_soldiers)):
		s = d_soldiers[n]
		if s.team == team:
			amount += 1
	return amount
