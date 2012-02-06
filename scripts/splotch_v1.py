#!/usr/bin/python

"""
Demo for simple procedurally generated maps
"""

class splotch:
	requestMouseKeyboard = 'false'
	start = 0
	
	def __init__(this):
		#global enginePoint
		#java.lang.System.out.println(enginePoint)
		#enginePoint = EngineState()
		#print enginePoint
		#print enginePoint.mapLoaded
		loadTexture("blank.bmp")
		amnt = 20
		for i in range(-amnt/2, amnt/2):
			this.createSplotch(i*400, 0, 20, 400)
		

	def createSplotch(this, x, y, detail, radius):
		if detail < 3:
			return 0
		
		angle = 360.0/detail
		tData = [ [0 for i in range(6) ] for i in range(detail) ]	#holds poly data for each triangle
		
		
		for i in range(detail):
			tData[i][0] = x  												#setllllllllllllllllllll center y
			tData[i][2] = x+radius*math.cos(math.radians(angle)*i)			#set point x
			tData[i][3] = y+radius*math.sin(math.radians(angle)*i)			#set point y
			if i != detail-1:
				tData[i][4] = x+radius*math.cos(math.radians(angle)*(i+1)) 	#set next point x
				tData[i][5] = y+radius*math.sin(math.radians(angle)*(i+1))  #set next point y
			else: 
				tData[i][4] = tData[0][2]									#set to first point x
				tData[i][5] = tData[0][3]									#set to first point y
		  
		
		for i in range(detail):
			addPolygonExplicit(0, 
					tData[i][0], tData[i][1], 
					tData[i][2], tData[i][3], 
					tData[i][4], tData[i][5], 
					0, 0.2, 0.01, 
					255, 0, 0, 255, 
					255, 0, 0, 255, 
					255, 0, 0, 255, 
					0,
					0.1, 0.2,
					1, 0.2,
					1, 1,
					-2, 1, 0.1,
					);
		
		addSpawn(x, y-radius, 6, 0, 1)
		addGravitron(x, y, 700, radius*2)
		
	def update(this):
		if this.start == 0:
			s = getSoldiers()
			for i in range(len(s)):
				s[i].teleport(0, -500)
			
			this.start += 1
		
	def onSoldierRespawn(this, id):
		getSoldierById(id).changeAttachment(0, 1000)