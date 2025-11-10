/*
 * This macro picks an ROI and makes an expanded version external to the montage.
 * Use ROI_Zoom.ijm to make an inset zoom - this version is to make a zoomed *panel*.
 * User can select the size of the ROI and the expansion factor.
 * It is meant to be used for montages but it will work on single square images.
 * Open 1 image. Run Macro. Pick settings.
 * Click in the centre of where you want your ROI to be (any panel will work).
 * http://github.com/quantixed/imagej-macros/
 */

macro "Make ROI Zoom External"	{
	if (nImages == 0)	exit("No image(s) open");

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
	if (nShots > 1) exit("Stacks are not currently supported");
	
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
	// ask what size ROI and expansion
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
	Dialog.addMessage("What size box for expansion?");
	Dialog.addNumber("Box size (px)", 50);
    Dialog.addMessage("Expansion factor.\nEnter 0 for zooms to be the same size as a panel.");
	Dialog.addNumber("Expansion e.g. 2 for 2X", 0);
	Dialog.addNumber("Border for boxes (px)", bStroke);
	Dialog.addCheckbox("White border?", true);
	Dialog.addMessage("Make boxes and zooms for which panels...");
	Dialog.addCheckboxGroup(1,nPanel,labels,defaults);
	// need to add something here so that the user can define where boxes go
	Dialog.show();

	bSize = Dialog.getNumber();
	expand = Dialog.getNumber();
    bStroke = Dialog.getNumber();
	colorChoice = Dialog.getCheckbox();
	for (i=0; i<nPanel; i++)	{
		panelDecisions[i] = Dialog.getCheckbox();
	}
	// decisions collected now define dSize (w and h of inset)
	dSize = bSize * expand;
    if(dSize == 0) {
        dSize = h;
		if (vChoice == "vert") {
			dSize = w;
		}
    }
	// sanity check in case box is bigger than panel
	if ((bSize > h) && lengthOf(vChoice) == 0)	exit("Box will be too big, use different expansion");
	if ((bSize > w) && vChoice == "vert")	exit("Box will be too big, use different expansion");
	
	// User defines the centre of the box for expansion
	// this is still useful because a user can pinpoint where they want the zoom
	selectWindow(title);
	setTool(7); // not sure how to force single point vs multi-point
	waitForUser("Define box", "Click on the image to centre the box for expansion.\n\nTo change position, drag the point.");
	if (selectionType == 10)	{
		Roi.getCoordinates(xa,ya);
	} else	exit("Works with point selection only");
	xp = xa[0];
	yp = ya[0];
	// we use the first point if multiple points are selected
	selectWindow(title);
	makeRectangle(xp-(bSize/2),yp-(bSize/2),bSize,bSize);
	setTool(0);
	waitForUser("Box position OK?", "Click-and-hold inside the box to drag it until you are happy,\nClick OK when you're finished.");
	xp = x + (width / 2);
	yp = y + (height / 2);
	// sanity check that box is correct size
	getSelectionBounds(x,y,width,height);
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

	filestr = "";
	// do the copy/pasting
	for (i=0; i<nPanel; i++)	{
		selectWindow(title);
		if (panelDecisions[i] == 1)	{
            run("Select None");
            if (vChoice == "vert") {
                xq = xp1 + 0; // --for future dev
				yq = yp1 + (i * (w + grout));
            } else {
				xq = xp1 + (i * (h + grout));
                yq = yp1 + 0; // --for future dev
            }
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
			run("Select None");
            // save the image
            path = dir1 + "zPanel" + (i + 1) + "_" + newName;
	        if(!endsWith(path, ".tif")) {
		        path = path + ".tif";
	        }
            saveAs("TIFF", path);
            close();
			filestr = filestr + path + "\n";
		}
	}

    // save the image
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
		print(f, "ROI Zoom External");
		print(f, newName);
		print(f, "Clicked box centre: " + xp + "," + yp);
		print(f, "Box size: " + bSize + ". Expansion: " + expand + ". Stroke: " + bStroke + ".");
		print(f, filestr);
	File.close(f);
	setBatchMode(false);
}
