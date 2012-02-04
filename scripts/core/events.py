# GAME EVENTS
# redefine these in your game script

def onGameTypeChange(type): pass
def onGamePause(): pass
def onGameUnpause(): pass

def onSoldierDie(id): pass
def onSoldierKill(id, deadPlayerId): pass
def onSoldierRespawn(id): pass
def onSoldierCommand(id, content):	pass
def onSoldierSpeak(id, content): pass
def onSoldierAdd(id, name, team): pass
def onSoldierRemove(id): pass
def onSoldierChangeGun(id, type): pass
#def onSoldierChangeTeam(id, team): pass
def onSoldierMove(id, x, y, xv, yv): pass	#very heavy, use requestsoldierpv instead
def onSoldierEnterVehicle(id, vid): pass
def onSoldierExitVehicle(id): pass

def onVehicleAdd(id, type, x, y): pass
def onVehicleRemove(id): pass
def onVehicleMove(id, x, y, xv, yv): pass	#very heavy, use requestvehiclepv instead


"""
the following are internal only functions, 
do not overload these ones or else obvious
things will break. 

"""

#GAME
def int_onGameTypeChange(type):
	global gameType
	gameType = type
	
def int_onGamePause():
	global gamePaused
	gamePaused = 'true'

def int_onGameUnpause():
	global gamePaused
	gamePaused = 'false'

#SPAWN
def int_onSpawnAdd(x, y, type, subType, amount):
	global d_spawns
	d_spawns.append(Spawn(x, y, type, subType, amount))

#VEHICLES
def int_onBaseVehicleAdd(src):
	global d_baseVehicles
	d_baseVehicles.append(BaseVehicle(src))
	
def int_onBaseVehicleRemove(id):
	global d_baseVehicles
	d_baseVehicles.remove(n)
	
def int_onVehicleAdd(id, type, x, y):
	global d_vehicles
	d_vehicles.append(Vehicle(id, type, x, y))
	print 'vehicle added'+str(id)
	

	
def int_onVehicleRemove(id):
	global d_vehicles
	return
	'''for n in xrange(len(d_vehicles)):
		print str(n)+'-'+str(len(d_vehicles))
		if d_vehicles[n].id == id:
			d_vehicles.remove(n)
	'''

#SOLDIER
def int_onSoldierAdd(id, name, team):
	global d_soldiers
	d_soldiers.append(Soldier(id, name, team))

def int_onSoldierRemove(id):
	global d_soldiers
	for n in xrange(len(d_soldiers)):
		if d_soldiers[n].id == id:
			d_soldiers.remove(n)

def int_onSoldierMove(id, x, y, xv, yv):
	s = getSoldierById(id)
	s.setPosition(x, y, xv, yv)

def int_onSoldierChangeGun(id, type):
	s = getSoldierById(id)
	s.setGun(type)

def int_onSoldierDie(id):
	s = getSoldierById(id)
	s.die()
	
def int_onSoldierKill(idOfDead, idOfKiller):
	if idOfDead == idOfKiller:	#check suicide and if so punish with extra death
		s = getSoldierById(idOfKiller)
		s.deaths += 1
		return
	s = getSoldierById(idOfKiller)
	s.kills += 1

def int_onSoldierRespawn(id):
	s = getSoldierById(id)
	s.respawn()
	
def int_onSoldierEnterVehicle(id, vid):
	s = getSoldierById(id)
	s.driving = "true"
	
def int_onSoldierExitVehicle(id):
	s = getSoldierById(id)
	s.driving = "false"

def int_changeSoldierName(id, name):
	s = getSoldierById(id)
	s.setName(name)

