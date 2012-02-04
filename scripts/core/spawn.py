d_spawns = []

class Spawn:
	def __init__(self, x, y, type, subType, amount):
		self.x = 0
		self.y = 0
		self.type = 0
		self.subType = 0
		self.amount = 0
		

def addSpawn(x, y, type, subType, amount):
	global com
	com += 'a sp '+str(x)+' '+str(y)+' '+str(type)+' '+str(subType)+' '+str(amount)+';'
	
def getSpawn(n):
	global d_spawns
	return d_spawns[n]
	
	
def getSpawnCount():
	global d_spawns
	return len(d_spawns)
