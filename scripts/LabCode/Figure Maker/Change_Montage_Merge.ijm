/*
 * The montage macros make a merge from the standard colours.
 * If a nonstandard colourset is required, this macro will change the merge panel.
 * It takes the RGB channels and changes them to Orange, Fresh, Purple (OFP), respectively.
 * Must have the NeuroCytoLUTs installed - macro checks for this.
 * Will work on all open images.
 * Limitation: will only change the right (or bottom) panel, i.e. if two merges are present, only far one is changed.
 * Idea is to 1) make a montage, 2) add ROI zooms, 3) change the merge panel, 4) compile montages
 * http://github.com/quantixed/imagej-macros/
 */

macro "Change Montage Merge Panels"	{
	if (nImages == 0)	exit("No image open");
	if (lutCheck() == 0)	exit("NeuroCytoLUTs are missing");
	setBatchMode(true);
	do{
		autoChangeMontage();
	} while (nImages > 0);
	setBatchMode(false);
}

function autoChangeMontage() {
// use default options to change merge panel in a montage
// assumes merge is on the right/bottom and therefore not inverted
	lutdir = getDirectory("luts");
	title = getTitle();
	dir1 = getDirectory("image");
	newName = "change_" + title;
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
		panelDecisions[i] = false;
	}
	panelDecisions[nPanel - 1] = true;

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
				// run routine here ----
				run("Copy");
				newImage("tmpMrg", "RGB", ww, hh, 1);
				run("Paste");
				run("Make Composite");
				run("16-bit");
				lut = lutdir + "CRL_OPF orange.lut";
				open(lut);
				run("Next Slice [>]");
				lut = lutdir + "CRL_OPF fresh.lut";
				open(lut);
				run("Next Slice [>]");
				lut = lutdir + "CRL_OPF purple.lut";
				open(lut);
				run("RGB Color");
				selectWindow("tmpMrg (RGB)");
				run("Select All");
				run("Copy");
				selectWindow(title);
				run("Paste");
				// end routine ----
				run("Select None");
				// close temp windows
				selectWindow("tmpMrg");
				close();
				selectWindow("tmpMrg (RGB)");
				close();
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
}

function lutCheck() {
	check = true;
	lutdir = getDirectory("luts");
	path = lutdir + "CRL_OPF orange.lut";
	if(!File.exists(path)) check = false;
	path = lutdir + "CRL_OPF fresh.lut";
	if(!File.exists(path)) check = false;
	path = lutdir + "CRL_OPF purple.lut";
	if(!File.exists(path)) check = false;
	return check;
}
