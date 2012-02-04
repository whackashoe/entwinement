"""
These are basically just wrappers for processing functions,
they are the basics to get drawing done, I'll add a few links
for reference

pushMatrix, popMatrix, translate, and scale: 
	http://processing.org/learning/transform2d/
beginShape, vertex, endshape:
	http://processing.org/reference/vertex_.html
"""


class ScreenDraw:
    dcom = ''   # holds all internal code to pass to game- generally do not touch.
    
    # def __init__(self, 
    
        
    # sets the body color for which bodies after this will be drawn
    def fill(self, r, g, b, a):
	    self.dcom += 'f '+str(r)+' '+str(g)+' '+str(b)+' '+str(a)+';'

    # sets the edge color for which bodies after this will be drawn
    def stroke(self, r, g, b, a):
	    self.dcom += 's '+str(r)+' '+str(g)+' '+str(b)+' '+str(a)+';'

    # sets the width of edges for which bodies after this will be drawn
    def strokeWeight(self, weight):
	    self.dcom += 'sw '+str(weight)+';'

    # pushes transformation matrix; you *MUST* pop it when done
    def pushMatrix(self):
	    self.dcom += 'pum;'

    # takes matrix off stack, all transformations are reset to before you pushed
    # do not call unless you have called pushMatrix first
    def popMatrix(self):
	    self.dcom += 'pom;'

    # moves subsequent drawing in current and child matrices by the offset specified
    def translate(self, x, y, z=0):
	    self.dcom += 'tr '+str(x)+' '+str(y)+' '+str(z)+';'

    # multiplies current and sub matrices width, height, and depth
    def scale(self, w, h, d=1):
	    self.dcom += 'sc '+str(w)+' '+str(h)+' '+str(d)+';'
	
    # rotates subsequent drawings in current and child matrices
    def rotate(self, r):
	    self.dcom += 'ro '+str(r)+';'

    # self.dcommand to call before calling vertex; note that you may not use other drawing methods within
    # beginshape() however you may call fill() to blend
    def beginShape(self):
	    self.dcom += 'bs;'

    # ends polygonal shape, you *MUST* call this when done with making shape
    def endShape(self):
	    self.dcom += 'es;'

    # used between beginShape and endShape to create a vertex of polygon
    def vertex(self, x, y, z=0):
	    self.dcom += 'v '+str(x)+' '+str(y)+' '+str(z)+';'

    # sets the size the text drawn after using it will be drawn
    def textSize(self, size):
	    self.dcom += 'ts '+str(size)+';'

    # draws text, note that y specifies where to draw the bottom of letters
    # so generally set y (textSize) more than with other functions to self.dcompensate
    def text(self, x, y, content):
	    self.dcom += 't '+str(x)+' '+str(y)+' '+content+';'

    def rect2d(self, x, y, w, h):
	    self.dcom += 'r '+str(x)+' '+str(y)+' '+str(w)+' '+str(h)+';'

    def rect3d(self, x, y, z, w, h):
	    self.dcom += 'r '+str(x)+' '+str(y)+' '+str(z)+' '+str(w)+' '+str(h)+';'

    def circ2d(self, x, y, w, h):
	    self.dcom += 'c '+str(x)+' '+str(y)+' '+str(w)+' '+str(h)+';'

    def circ3d(self, x, y, z, w, h):
	    self.dcom += 'c '+str(x)+' '+str(y)+' '+str(z)+' '+str(w)+' '+str(h)+';'

    def line2d(self, x1, y1, x2, y2):
	    self.dcom += 'l '+str(x1)+' '+str(y1)+' '+str(x2)+' '+str(y2)+';'

    def line3d(self, x1, y1, z1, x2, y2, z2):
	    self.dcom += 'l '+str(x1)+' '+str(y1)+' '+str(z1)+' '+str(x2)+' '+str(y2)+' '+str(z2)+';'

    def triangle2d(self, x1, y1, x2, y2, x3, y3):
	    self.dcom += 'p '+str(x1)+' '+str(y1)+' '+str(x2)+' '+str(y2)+' '+str(x3)+' '+str(y3)+';'

    def triangle3d(self, x1, y1, z1, x2, y2, z2, x3, y3, z3):
	    self.dcom += 'p '+str(x1)+' '+str(y1)+' '+str(z1)+' '+str(x2)+' '+str(y2)+' '+str(z2)+' '+str(x3)+' '+str(y3)+' '+str(z3)+';'
	   
	   
toWorld = ScreenDraw()      # creates context for drawing on game world
toScreen = ScreenDraw()     # creates context for drawing onto game screen
