d_baseVehicles = []
d_vehicles = []

class BaseVehicle:
	def __init__(self, src):
		self.src = src
		
def getBaseVehicle(n):
	global d_baseVehicles
	return d_baseVehicles[n]
		
def getBaseVehicleCount():
	global d_baseVehicles
	return len(d_baseVehicles)
	


class Vehicle:
	def __init__(self, id, type, x, y):
		self.id = id
		self.type = type
		self.x = x
		self.y = y
		self.xVelo = 0
		self.yVeli = 0
		
	def setPosition(self, x, y, xv, yv):
		self.x = x
		self.y = y
		self.xVelo = xv
		self.yVelo = yv
		

def getVehicle(n):
	global d_vehicles
	return d_vehicles[n]

def getVehicleById(id):
	global d_vehicles
	for n in xrange(len(d_vehicles)):
		v = d_vehicles[n]
		if v.id == id:
			return s

def getVehicleCount():
	global d_vehicles
	return len(d_vehicles)		
