d_polygons = []

class Polygon:
	def __init__(self, x1, y1, x2, y2, x3, y3):
		self.x1 = x1
		self.y1 = y1
		self.x2 = x2
		self.y2 = y2
		self.x3 = x3
		self.y3 = y3
		
	def setType(self, type):
		self.type = type
	
	def setPosition(self, x1, y1, x2, y2, x3, y3):
		self.x1 = x1
		self.y1 = y1
		self.x2 = x2
		self.y2 = y2
		self.x3 = x3
		self.y3 = y3
	
	def setZAxis(self, z1, z2, z3):
		self.z1 = x1
		self.z1 = y1
		self.z1 = z1
		
	def setRHW(self, r1, r2, r3):
		self.rhw1 = rhw1
		self.rhw2 = rhw2
		self.rhw3 = rhw3
		
	def setUV(self, u1, v1, u2, v2, u3, v3):
		self.u1 = u1
		self.v1 = v1
		self.u2 = u2
		self.v2 = v2
		self.u3 = u3
		self.v3 = v3
		
	def setVColours(self, r1, g1, b1, a1, r2, g2, b2, a2, r3, g3, b3, a3):
		self.r1 = r1
		self.g1 = g1
		self.b1 = b1
		self.a1 = a1
		self.r2 = r2
		self.g2 = g2
		self.b2 = b2
		self.a2 = a2
		self.r3 = r3
		self.g3 = g3
		self.b3 = b3
		self.a3 = a3

def addPolygon(type, x1, y1, x2, y2, x3, y3, density, restitution, friction, red, green, blue, alpha):
	global com
	com += 'a poly '+str(type)+' '+str(x1)+' '+str(y1)+' '+str(x2)+' '+str(y2)+' '+str(x3)+' '+str(y3)+' '+str(density)+' '+str(restitution)+' '+str(friction)+' '+str(red)+' '+str(green)+' '+str(blue)+' '+str(alpha)+';'

def addPolygonExplicit(type, x1, y1, x2, y2, x3, y3, density, restitution, friction, r1, g1, b1, a1, r2, g2, b2, a2, r3, g3, b3, a3, textureId, u0, v0, u1, v1, u2, v2, rhw0, rhw1, rhw2):
	global com
	com += 'a poly '+str(type)+' '+str(x1)+' '+str(y1)+' '+str(x2)+' '+str(y2)+' '+str(x3)+' '+str(y3)+' '+str(density)+' '+str(restitution)+' '+str(friction)+' '+str(r1)+' '+str(g1)+' '+str(b1)+' '+str(a1)+' '+str(r2)+' '+str(g2)+' '+str(b2)+' '+str(a2)+' '+str(r3)+' '+str(g3)+' '+str(b3)+' '+str(a3)+' '+str(textureId)+' '+str(u0)+' '+str(v0)+' '+str(u1)+' '+str(v1)+' '+str(u2)+' '+str(v2)+' '+str(rhw0)+' '+str(rhw1)+' '+str(rhw2)+';'

def getPolygon(n):
	global d_polygons
	return d_polygons[n]
	
	
def getPolygonCount():
	global d_polygons
	return len(d_polygons)


