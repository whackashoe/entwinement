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