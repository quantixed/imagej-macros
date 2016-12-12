var boxSize = 400;

macro "Box Tool - C000R4488D88" {
	getCursorLoc(x, y, z, flags);
	left = 16
	while ((flags&left)!=0) {
    	getCursorLoc(x, y, z, flags);
    	makeRectangle(x-(boxSize/2),y-(boxSize/2),boxSize,boxSize);
    	wait(10);
  		}
	}

macro "Box Tool Options" {
	boxSize = getNumber("Box size: ", boxSize);
	}
