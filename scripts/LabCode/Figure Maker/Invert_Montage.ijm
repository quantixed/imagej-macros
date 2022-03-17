/*
 * Inverted grayscale panels can enhance dim features.
 * This macro enables the user to invert the grayscale channels of a montage
 * Idea is to 1) make a montage, 2) add ROI zooms, 3) do inversion, 4) compile montages
 * http://github.com/quantixed/imagej-macros/
 */

macro "Invert Montage Panels"	{
	if (nImages > 1) exit ("Use a single image or single montage");
	if (nImages == 0)	exit("No image open");

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
	// dialog for choices
	labels = newArray(nPanel);
	defaults = newArray(nPanel);
	panelDecisions = newArray(nPanel);
	for (i=0; i<nPanel; i++)	{
		labels[i] = "Panel "+i+1;
		defaults[i] = true;
	}
	// set last checkbox to false because we probably have a color merge in that panel
	defaults[nPanel-1] = false;
	// Make dialog box
	Dialog.create("Specify Panels To Invert");
	Dialog.addMessage("Invert panels...");
	Dialog.addCheckboxGroup(1,nPanel,labels,defaults);
	Dialog.addMessage("Black border around inverted panels");
	Dialog.addCheckbox("Black border?", true);
	Dialog.addNumber("Internal border (px)", 4);
	Dialog.show();

	// collect decisions
	for (i=0; i<nPanel; i++)	{
		panelDecisions[i] = Dialog.getCheckbox();
	}
	colorChoice = Dialog.getCheckbox();
	bStroke = Dialog.getNumber();

	// entered a silly number
	if (bStroke > 20 * grout && grout > 0)	exit("Use a smaller stroke size");

	setBatchMode(true);
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
	close();
	setBatchMode(false);
}
