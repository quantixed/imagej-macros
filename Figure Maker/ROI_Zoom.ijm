/*
 * This macro picks an ROI and makes an expanded version in the corner
 * The ROI and the expansion have a white border
 * User can select the size of the ROI, the expansion, the corner and the border size
 * It is meant to be used for montages but it will work on single square images.
 * Open 1 image. Run Macro. Pick settings.
 * Click in the centre of where you want your ROI to be (any panel will work).
 * http://github.com/quantixed/imagej-macros/
 */

macro "Add ROI Zoom"	{
	s=call("ij.macro.Interpreter.getAdditionalFunctions");
	if(startsWith(s,"//qFunctions")!=1) {
		qFpath = getDirectory("plugins")+"/quantixed/Figure Maker/qFunctions.txt";
		functions = File.openAsString(qFpath);
		call("ij.macro.Interpreter.setAdditionalFunctions", functions);
		}
	if (nImages > 1) exit ("Use a single image or single montage");
	if (nImages == 0)	exit("No image open");

	imageID = getImageID();
	title = getTitle();
	dir1 = getDirectory("image");
	newName = "zooms_" + title;
	run("Select None");
	getDimensions(w, h, c, numSlices, nFrames);
	// deal with multiple frames or slices
	nShots = maxOf(numSlices,nFrames);
	if (numSlices > 1 && nFrames > 1) exit("Number of slices and frames is greater than one");
	if (numSlices == 1) sliceOrFrame = 0;
	if (numSlices > 1) sliceOrFrame = 1;
	if (nFrames > 1) sliceOrFrame = 2;

	// work out grout size
	if (w == h) {
		nCol = 1;
		nRow = 1;
		grout = 0;
		nPanel = 1;
		vChoice = "";
	}
	else if (w > h)	{
		nCol = floor(w/h);
		nRow = 1;
		grout = (w - (nCol * h)) / (nCol - 1);
		nPanel = nCol;
		vChoice = "";
	}
	else {
		nCol = 1;
		nRow = floor(h/w);
		grout = (h - (nRow * w)) / (nRow - 1);
		nPanel = nRow;
		vChoice = "vert";
	}
	// ask what size ROI and expansion and corner
	cornerArray = newArray("LT", "RT", "LB", "RB");
	labels = newArray(nPanel);
		defaults = newArray(nPanel);
		panelDecisions = newArray(nPanel);
		for (i=0; i<nPanel; i++)	{
			labels[i] = "Panel "+i+1;
			defaults[i] = true;
		}
	// Make dialog box
	Dialog.create("Specify ROI Zoom");
	Dialog.addMessage("Select corner for zoom");
	Dialog.addChoice("Corner", cornerArray);
	Dialog.addMessage("What size box for expansion?");
	Dialog.addNumber("Box size (px)", 50);
	Dialog.addNumber("Expansion e.g. 2X", 2);
	// setting border to 4 px because 1 pt is 1/72 inch
	// at 300 ppi, this would be 300/72 = 4.167 px
	Dialog.addNumber("Border for boxes (px)", 4);
	Dialog.addMessage("Make boxes and zooms in panels...");
	Dialog.addCheckboxGroup(1,nPanel,labels,defaults);
	// need to add something here so that the user can define where boxes go
	Dialog.show();

	corner = Dialog.getChoice();
	bSize = Dialog.getNumber();
	expand = Dialog.getNumber();
	bStroke = Dialog.getNumber();
	for (i=0; i<nPanel; i++)	{
		panelDecisions[i] = Dialog.getCheckbox();
	}
	// decisions collected now define dSize (w and h of inset)
	dSize = bSize * expand;
	// sanity check in case zoom is bigger than panel
	if ((dSize > h) && lengthOf(vChoice) == 0)	exit("Zoom will be too big, use different expansion");
	if ((dSize > w) && vChoice == "vert")	exit("Zoom will be too big, use different expansion");
	// maybe they want to make the zoom the width of panel, let them but limit stroke so it doesn't go into next panel
	if ((dSize == h && bStroke > grout) && lengthOf(vChoice) == 0)	exit("Use different stroke size to do this");
	if ((dSize == w && bStroke > grout) && vChoice == "vert")	exit("Use different stroke size to do this");
	// entered a silly number
	if (bStroke > 20 * grout && grout > 0)	exit("Use a smaller stroke size");

	// User defines the centre of the box for expansion
	setTool(7); // not sure how to force single point vs multi-point
	waitForUser("Define box", "Click on image to centre of box for expansion");
	if (selectionType == 10)	{
		getBoundingRect(xp, yp, width, height);
		// print("x="+xp+" y="+yp+" "+width+" "+height);
		makeRectangle(xp-(bSize/2),yp-(bSize/2),bSize,bSize);
		selectImage(imageID);
	}
	else	exit("Works with point selection only");

	// figure out which panel the selection is in
	// each panel is h x h pixels separated by grout for horizontal
	// and w x w pixels separated by grout for vertical
	// this is risky but box should not be less than grout away from panel edge
	// will fail in cases of large grout or many panels.
	// sp is the panel where selection is, 0-based
	if (vChoice == "vert") {
		sp = floor(yp / w);
		// x and y coords of ROI centre relative to the panel LT
		xp1 = xp - 0; // --for future dev
		yp1 = yp - (sp * (w + grout));
		// sanity check in case user has clicked too close to the edge
		if (xp1-(bSize/2) < 0 || yp1-(bSize/2) < 0)	exit("Try again, too close to the edge");
		if (xp1+(bSize/2) > w || yp1+(bSize/2) > w)	exit("Try again, too close to the edge");
	}
	else {
		sp = floor(xp / h);
		// x and y coords of ROI centre relative to the panel LT
		xp1 = xp - (sp * (h + grout));
		yp1 = yp - 0; // --for future dev
		// sanity check in case user has clicked too close to the edge
		if (xp1-(bSize/2) < 0 || yp1-(bSize/2) < 0)	exit("Try again, too close to the edge");
		if (xp1+(bSize/2) > h || yp1+(bSize/2) > h)	exit("Try again, too close to the edge");
	}

	setBatchMode(true);
	// border will be white
	if (bitDepth() == 8) setColor(255);
	if (bitDepth() == 24) setColor(255,255,255);
	if (bitDepth() == 16) setColor(65535);

	if (vChoice == "vert") {
		if (corner == "RT" || corner == "RB")	{
			dStartx = w - dSize;
		}
		else if (corner == "LT" || corner == "LB")	{
			dStartx = 0;
		}
		// do the copy/pasting
		for (i=0; i<nPanel; i++)	{
			if (panelDecisions[i] == 1)	{
				run("Select None");
				xq = xp1 + 0; // --for future dev
				yq = yp1 + (i * (w + grout));
				for (j=0; j<nShots; j++)	{
					if (sliceOrFrame == 1)
						Stack.setSlice(j+1);
					else if (sliceOrFrame == 2)
						Stack.setFrame(j+1);
					makeRectangle(xq-(bSize/2),yq-(bSize/2),bSize,bSize);
					run("Copy");
					// make border
					fillRect(xq-((bSize + bStroke)/2),yq-((bSize + bStroke)/2),bSize+bStroke,bSize+bStroke);
					makeRectangle(xq-(bSize/2),yq-(bSize/2),bSize,bSize);
					run("Paste");
					run("Internal Clipboard");
					selectWindow("Clipboard");
					cmd = "width="+dSize+" height="+dSize+" constrain average interpolation=Bilinear";
					run("Size...", cmd);
					run("Select All");
					run("Copy");
					close("Clipboard");
					selectWindow(title);
					// T dStarty is top side of panel; B dStarty is bottom side of panel - dSize
					if (corner == "LT" || corner == "RT")	{
						dStarty = (i * (w + grout));
					}
					else if (corner == "LB" || corner == "RB")	{
						dStarty = w + (i * (w + grout)) - dSize;
					}
					// dStartx calculated outside the loop
	
					// make border for zoom
					if (corner == "LB")	{
						fillRect(dStartx,dStarty-bStroke,dSize+bStroke,dSize+bStroke);
					}
					else if (corner == "LT")	{
						fillRect(dStartx,dStarty,dSize+bStroke,dSize+bStroke);
					}
					else if (corner == "RB")	{
						fillRect(dStartx-bStroke,dStarty-bStroke,dSize+bStroke,dSize+bStroke);
					}
					else if (corner == "RT")	{
						fillRect(dStartx-bStroke,dStarty,dSize+bStroke,dSize+bStroke);
					}
					// now paste zoom
					makeRectangle(dStartx,dStarty,dSize,dSize);
					run("Paste");
				}
			}
		}
	}
	else {
		if (corner == "LB" || corner == "RB")	{
			dStarty = h - dSize;
		}
		else if (corner == "LT" || corner == "RT")	{
			dStarty = 0;
		}
		// do the copy/pasting
		for (i=0; i<nPanel; i++)	{
			if (panelDecisions[i] == 1)	{
				run("Select None");
				xq = xp1 + (i * (h + grout));
				yq = yp1 + 0; // --for future dev
				for (j=0; j<nShots; j++)	{
					if (sliceOrFrame == 1)
						Stack.setSlice(j+1);
					else if (sliceOrFrame == 2)
						Stack.setFrame(j+1);
					makeRectangle(xq-(bSize/2),yq-(bSize/2),bSize,bSize);
					run("Copy");
					// make border
					fillRect(xq-((bSize + bStroke)/2),yq-((bSize + bStroke)/2),bSize+bStroke,bSize+bStroke);
					makeRectangle(xq-(bSize/2),yq-(bSize/2),bSize,bSize);
					run("Paste");
					run("Internal Clipboard");
					selectWindow("Clipboard");
					cmd = "width="+dSize+" height="+dSize+" constrain average interpolation=Bilinear";
					run("Size...", cmd);
					run("Select All");
					run("Copy");
					close("Clipboard");
					selectWindow(title);
					// L dStartx is left side of panel; R dStartX is right side of panel - dSize
					if (corner == "LB" || corner == "LT")	{
						dStartx = (i * (h + grout)); // L
					}
					else if (corner == "RB" || corner == "RT")	{
						dStartx = h + (i * (h + grout)) - dSize; // R
					}
					// dStarty calculated outside the loop
	
					// make border for zoom
					if (corner == "LB")	{
						fillRect(dStartx,dStarty-bStroke,dSize+bStroke,dSize+bStroke);
					}
					else if (corner == "LT")	{
						fillRect(dStartx,dStarty,dSize+bStroke,dSize+bStroke);
					}
					else if (corner == "RB")	{
						fillRect(dStartx-bStroke,dStarty-bStroke,dSize+bStroke,dSize+bStroke);
					}
					else if (corner == "RT")	{
						fillRect(dStartx-bStroke,dStarty,dSize+bStroke,dSize+bStroke);
					}
					// now paste zoom
					makeRectangle(dStartx,dStarty,dSize,dSize);
					run("Paste");
				}
			}
		}
	}

	selectWindow(title);
	run("Select None");
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
}
