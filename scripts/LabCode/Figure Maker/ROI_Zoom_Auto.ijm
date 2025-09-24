/*
 * This macro works like ROI zoom but eliminates the need for multiple clicks
 * The ROI and the expansion have a white border
 * User can select the size of the ROI, the expansion, the corner and the border size
 * They also need to give the centre of the ROI
 * It will run with multiple images open, but only works on the active image.
 * http://github.com/quantixed/imagej-macros/
 */

macro "Auto Add ROI Zoom"	{
	if (nImages == 0)	exit("No image open");

	imageID = getImageID();
	title = getTitle();
	dir1 = getDirectory("image");
	newName = "zooms_" + title;
	run("Select None");
	getDimensions(w, h, c, numSlices, nFrames);
	// code doesn't work as intended with muli-channel images
	if (c > 1) exit("Image must be RGB or single channel");
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
	} else if (w > h)	{
		nCol = floor(w/h);
		nRow = 1;
		grout = (w - (nCol * h)) / (nCol - 1);
		if (nCol == 1)	{
			grout = 0;
		}
		nPanel = nCol;
		vChoice = "";
	} else {
		nCol = 1;
		nRow = floor(h/w);
		grout = (h - (nRow * w)) / (nRow - 1);
		if (nRow == 1)	{
			grout = 0;
		}
		nPanel = nRow;
		vChoice = "vert";
	}
	// ask what size ROI and expansion and corner
	cornerArray = newArray("LB", "LT", "RB", "RT");
	labels = newArray(nPanel);
		defaults = newArray(nPanel);
		panelDecisions = newArray(nPanel);
		for (i=0; i<nPanel; i++)	{
			labels[i] = "Panel "+i+1;
			defaults[i] = true;
		}
	// setting default border stroke to 4 px because 1 pt is 1/72 inch
	// at 300 ppi, this would be 300/72 = 4.167 px
	bStroke = 4;
	// but if grout is smaller, set to half grout instead but ensure it is an even integer
	if (grout > 0) bStroke = grout / 2;
	if (bStroke % 2 != 0) bStroke = bStroke - 1;
	if (bStroke < 2) bStroke = 2;
	// Make dialog box
	Dialog.create("Specify ROI Zoom");
	Dialog.addMessage("Select corner for zoom");
	Dialog.addChoice("Corner", cornerArray);
	Dialog.addMessage("What size box for expansion?");
	Dialog.addNumber("Box size (px)", 50);
	Dialog.addNumber("Expansion e.g. 2X", 2);
	Dialog.addNumber("Border for boxes (px)", bStroke);
	Dialog.addCheckbox("White border?", true);
	Dialog.addMessage("Make boxes and zooms in panels...");
	Dialog.addCheckboxGroup(1,nPanel,labels,defaults);
    Dialog.addNumber("ROI Centre X (px)", 0);
    Dialog.addNumber("ROI Centre Y (px)", 0);
	// need to add something here so that the user can define where boxes go
	Dialog.show();

	corner = Dialog.getChoice();
	bSize = Dialog.getNumber();
	expand = Dialog.getNumber();
	bStroke = Dialog.getNumber();
	colorChoice = Dialog.getCheckbox();
	for (i=0; i<nPanel; i++)	{
		panelDecisions[i] = Dialog.getCheckbox();
	}
    xp = Dialog.getNumber();
    yp = Dialog.getNumber();
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

	// make box
	makeRectangle(xp-(bSize/2),yp-(bSize/2),bSize,bSize);
	getSelectionBounds(x,y,width,height);
	// sanity check that box is correct size
	if (width != height || width != bSize) exit("A single square ROI of " + bSize + " x " + bSize + " pixels is required");

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
	} else {
		sp = floor(xp / h);
		// x and y coords of ROI centre relative to the panel LT
		xp1 = xp - (sp * (h + grout));
		yp1 = yp - 0; // --for future dev
		// sanity check in case user has clicked too close to the edge
		if (xp1-(bSize/2) < 0 || yp1-(bSize/2) < 0)	exit("Try again, too close to the edge");
		if (xp1+(bSize/2) > h || yp1+(bSize/2) > h)	exit("Try again, too close to the edge");
	}

	setBatchMode(true);
	// border will be white if colorChoice is True
	if (colorChoice) {
		if (bitDepth() == 8) setColor(255);
		if (bitDepth() == 24) setColor(255,255,255);
		if (bitDepth() == 16) setColor(65535);
	} else {
		setColor(getValue("color.foreground"));
	}

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
  	path = dir1 + newName;
	if(!endsWith(path, ".tif")) {
		path = path + ".tif";
	}
	saveAs("TIFF", path);
	// save a log file
	path = substring(path,0,lengthOf(path) - 4) + ".txt";
	f = File.open(path);
		print(f, "ROI Zoom");
		print(f, newName);
		print(f, "Clicked box centre: " + xp + "," + yp);
		print(f, "Box size: " + bSize + ". Expansion: " + expand + ". Stroke: " + bStroke + ". Corner: " + corner);
	File.close(f);
	setBatchMode(false);
}
