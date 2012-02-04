#!/usr/bin/python

"""
Entwinement Instructions:
This is loaded everytime "instructions" is clicked from main menu.
"""

class instructions:
	requestMouseKeyboard = 'true'
	curInstruction = 0
	countDown = 210
	
	def __init__(this):
		this.curInstruction = 0
		this.countDown = 210
    	
	def update(this):
		global mouseX
		global mouseY
		
		this.countDown -= 1
		
		toScreen.fill(255, 255, 255, 255)
		toScreen.textSize(50)
		
		if this.curInstruction == 0:
			toScreen.text(100, 70, "Welcome to Entwinement")
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 250
			return 0
		elif this.curInstruction == 1:
			toScreen.textSize(30)
			toScreen.text(100, 70, "Choose a Gun Before Moving:")
			toScreen.fill(0, 30, 200, 100)
			toScreen.beginShape()
			toScreen.vertex(200, 400)
			toScreen.vertex(525, 275)
			toScreen.vertex(525, 345)
			toScreen.endShape()
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 300
			return 0
		elif this.curInstruction == 2:
			toScreen.text(100, 70, "Movement")
			toScreen.fill(0, 30, 200, 100)
			toScreen.beginShape()
			toScreen.vertex(400, 200)
			toScreen.vertex(430, 350)
			toScreen.vertex(370, 350)
			toScreen.endShape()
			toScreen.beginShape()
			toScreen.vertex(50, 300)
			toScreen.vertex(200, 270)
			toScreen.vertex(200, 330)
			toScreen.endShape()
			toScreen.beginShape()
			toScreen.vertex(750, 300)
			toScreen.vertex(600, 270)
			toScreen.vertex(600, 330)
			toScreen.endShape()
			toScreen.fill(255, 255, 255, 255)
			toScreen.textSize(20)
			toScreen.text(105, 310, "Left(A)")
			toScreen.text(610, 310, "Right(D)")
			toScreen.text(360, 290, "Jump(W)")
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 240
			return 0
		elif this.curInstruction == 3:
			toScreen.textSize(30)
			toScreen.text(100, 70, "Shoot with Left Mouse Button")
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 350
			return 0
		elif this.curInstruction == 4:
			toScreen.text(100, 70, "Pickup Items with X")
			
			if this.countDown == 260:
				s = getSoldier(0)
				addAttachmentBox(s.x-400+mouseX, s.y-100, 0, 5000)
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 600
			return 0
		elif this.curInstruction == 5:
			toScreen.textSize(30)
			toScreen.text(100, 70, "Use Attachment with Right Mouse Button")
			
			if this.countDown == 100:
				s = getSoldier(0)
				addSoldier(1)
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 1000
			return 0
		elif this.curInstruction == 6:
			toScreen.fill(255, 0, 0, 255)
			toScreen.text(100, 70, "Take Him Out")
			
			s = getSoldier(0)
			if s.kills > 0:
				this.curInstruction += 1
				this.countDown = 500
			return 0
		elif this.curInstruction == 7:
			s = getSoldier(0)
			toScreen.fill(0, 255, 0, 255)
			if s.deaths == 0:
				toScreen.text(100, 70, "You owned him!")
			else:
				toScreen.text(100, 70, "Good job")
				
			toScreen.textSize(20)
			toScreen.text(200, 140, "Click the green triangle to go back to menu")
			
			if this.countDown < 1:
				this.curInstruction += 1
				this.countDown = 1000
		return 0

	def onSoldierMove(this, id, x, y, xv, yv):
		s = getSoldierById(id)
		s.setPosition(x, y, xv, yv)
			
	def onSoldierKill(this, idOfDead, idOfKiller):
		s = getSoldierById(idOfKiller)
		me = getSoldier(0)
		if s.id == me.id and me.deaths == 0 and me.kills > 1:
			addCat(me.x-400+mouseX, me.y-300+mouseY)
			addSoldier(me.kills)