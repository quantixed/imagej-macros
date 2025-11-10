/*
 * Inverted grayscale panels can enhance dim features.
 * This macro enables the user to invert the grayscale channels of a montage
 * Idea is to 1) make a montage, 2) add ROI zooms, 3) do inversion, 4) compile montages
 * http://github.com/quantixed/imagej-macros/
 */

macro "Auto-Invert Montage Panels"	{
	if (nImages == 0)	exit("No image open");
	setBatchMode(true);
	do{
		autoInvertMontage();
	} while (nImages > 0);
	setBatchMode(false);
}

function autoInvertMontage() {
// use default options to invert panels in a montage
// inverts all grayscale panels, assumes merge is on the right/bottom and therefore not inverted
// black border of 4 pixels around inverted panels

	imageID = getImageID();
	title = getTitle();
	dir1 = getDirectory("image");
	newName = "invert_" + title;
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
		ww = w;
		hh = h;
	}
	else if (w > h)	{
		nCol = floor(w/h);
		nRow = 1;
		grout = (w - (nCol * h)) / (nCol - 1);
		nPanel = nCol;
		vChoice = "";
		ww = h;
		hh = h;
	}
	else {
		nCol = 1;
		nRow = floor(h/w);
		grout = (h - (nRow * w)) / (nRow - 1);
		nPanel = nRow;
		vChoice = "vert";
		ww = w;
		hh = w;
	}

	// collect decisions
	panelDecisions = newArray(nPanel);
	for (i=0; i<nPanel; i++)	{
		panelDecisions[i] = true;
	}
	panelDecisions[nPanel - 1] = false;
	colorChoice = true;
	bStroke = 4;

	// border will be black if colorChoice is True
	if (colorChoice) {
		if (bitDepth() == 8) setColor(0);
		if (bitDepth() == 24) setColor(0,0,0);
		if (bitDepth() == 16) setColor(0);
	}

	for (i=0; i<nPanel; i++)	{
		if (panelDecisions[i] == 1)	{
			run("Select None");
			// top left of panel is
			if (vChoice == "vert") {
				xq = 0 + 0; // --for future dev
				yq = 0 + (i * (hh + grout));
			} else {
				xq = 0 + (i * (ww + grout));
				yq = 0 + 0; // --for future dev
			}
			for (j=0; j<nShots; j++)	{
				if (sliceOrFrame == 1)
					Stack.setSlice(j+1);
				else if (sliceOrFrame == 2)
					Stack.setFrame(j+1);
				makeRectangle(xq,yq,ww,hh);
				run("Invert");
				run("Select None");
				// make border
				if (colorChoice == true) {
					makeRectangle(xq,yq,ww,hh);
					setKeyDown("alt");
					makeRectangle(xq + bStroke, yq + bStroke, ww - (2 * bStroke), hh - (2 * bStroke));
					setKeyDown("none");
//					setForegroundColor(0, 0, 0);
					run("Fill", "slice");
				}
				run("Select None");
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
}
