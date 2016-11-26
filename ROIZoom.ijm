/* Under development
 *  
 */


/*
 * Read in image:
 * 	Should be able to calculate the dimensions of the montage
 * Need to ask what is
 * 	bSize
 * 	expansion size
 * 	corner
 * 
 */

macro "ROI Zoom"	{
	if (nImages > 1)	{
		print("ROIZoom only works on a single montage or image");
		return;
	}
	if (nImages == 0)	{
		print("No image open");
		return;
	}
		
	imageID = getImageID();
	title = getTitle();
	run("Select None");
	getDimensions(w, h, c, nFrames, dummy);

	// assume 1 row
	if (w == h) {
		nCol = 1;
		grout = 0;
	}
	else	{
		nCol = floor(w/h);
		grout = (w - (nCol * h)) / (nCol - 1);
	}

	// ask what size ROI and expansion and corner
	cornerArray = newArray("LT", "RT", "LB", "RB");
	// Make dialog box
	Dialog.create("Specify ROI Zoom"); 
	Dialog.addMessage("Select corner for zoom");
	Dialog.addChoice("Corner", cornerArray);
	Dialog.addMessage("What size box for expansion?");
	Dialog.addNumber("Box size (px)", 50);
	Dialog.addNumber("Expansion e.g. 2X", 2);
	Dialog.addNumber("Border for boxes (px)", 2);
	// need to add something here so that the user can define where boxes go
	Dialog.show();
	
	corner = Dialog.getChoice();
	bSize = Dialog.getNumber();
	expand = Dialog.getNumber();
	bStroke = Dialog.getNumber();
	// decisions collected

	// User defines the centre of the box for expansion
	setTool(7); // not sure how to force single point vs multi-point
	waitForUser("Define box", "Click on image to centre of box for expansion");
	if (selectionType == 10)	{
		getBoundingRect(xp, yp, width, height);
		// print("x="+xp+" y="+yp+" "+width+" "+height);
		makeRectangle(xp-(bSize/2),yp-(bSize/2),bSize,bSize);
		// need to do something where user clicks too close to the edge
		selectImage(imageID);
	}
	else	{
		print("Works with point selection only");
	}
	// figure out which column the selction is in
	// each panel is h x h pixels separated by grout
	sp = floor(xp / h);	// sp is the panel where selection is
	// this is risky but box should not be less than grout away from panel edge
	
}	



// do the next part      
	
	
	setBatchMode(true);
}

