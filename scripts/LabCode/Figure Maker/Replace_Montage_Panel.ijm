/*
 * This macro is to replace a panel in a quantixed montage movie
 * There's not much point on running it on a static image
 * http://github.com/quantixed/imagej-macros/
 */

#@ File (label = "Montage file", style = "file") mtg
#@ File (label = "Replacement panel", style = "file") pnl
#@ Integer (label = "Panel to be replaced", value = 1) panel


open(mtg);
mtgID = getImageID();
mtgTitle = getTitle();
dir1 = getDirectory("image");
newName = "rp" + panel + "_" + mtgTitle;
run("Select None");
getDimensions(w, h, c, numSlices, nFrames);
// code doesn't work as intended with muli-channel images
if (bitDepth() != 24 | (c > 1)) exit("Image must be RGB");
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

if(nPanel == 1) exit("The montage only has one panel");
if(nPanel < panel) exit("There are only " + nPanel + " panels");

// now open replacement panel
open(pnl);
pnlID = getImageID();
pnlTitle = getTitle();
getDimensions(pw, ph, pc, ps, pf);
// warn if it is not square
if(pw != ph) print("Caution: replacement panel is not square");
if (c > 1) exit("Check channels matches montage");
// check other dimensions
if(numSlices != ps) exit("Replacement panel does not have the same number of slices as montage");
if(nFrames != pf) exit("Replacement panel does not have the same number of frames as montage");

if(vChoice == "vert") {
	// check that widths are the same
	if(w != pw) exit("Replacement panel is not the same width as montage");
} else {
	if(h != ph) exit("Replacement panel is not the same height as montage");
}

if (vChoice == "vert") {
	// find top left corner of panel to be replaced
	xp1 = 0;
	yp1 = (panel - 1) * (w + grout);
} else {
	xp1 = (panel - 1) * (h + grout);
	yp1 = 0;
}
// do the copy/pasting
for (j=0; j<nShots; j++)	{
	selectImage(pnlID);
	if (sliceOrFrame == 1)
		Stack.setSlice(j+1);
	else if (sliceOrFrame == 2)
		Stack.setFrame(j+1);
	run("Select All");
	run("Copy");
	selectImage(mtgID);
	if (sliceOrFrame == 1)
		Stack.setSlice(j+1);
	else if (sliceOrFrame == 2)
		Stack.setFrame(j+1);
	makeRectangle(xp1,yp1,pw,ph);
	run("Paste");
}
close(pnlTitle);
selectWindow(mtgTitle);
run("Select None");
path = dir1 + newName;
if(!endsWith(path, ".tif")) {
	path = path + ".tif";
}
saveAs("TIFF", path);
close();