/*
 * Apply color blindness simulation to current image
 * Apply all simulation modes on duplicate images
 * Collect in stack, create montage
 * 
 * Based on original code by: Henrik Persson
 * Edits: quantixed 2022-03-26
 * Updated: 2026-08-05
 * 
 */

#@ String (visibility=MESSAGE, value="Make montage of all Color Blindness simulations", required=false) msg1
#@ Boolean (label="Label color blindness types?", value=true) labeltypes
#@ Double (label="Scale factor", value=0.25, min=0.01, max=1, stepSize = 0.01, style="spinner") scalefactor
#@ Boolean (label="Use current foreground color? (uncheck for magenta)", value=false) forecol
#@ Integer (label="Grout size (px)", value=6) grout
#@ Integer (label="Font size for labels, if used (pt)", value=16) fontsize

// check we have at least one image and that the top image is RGB
if (nImages < 1) exit ("One image is required.");
if(bitDepth() != 24) exit ("Image must be RGB.");

//get original image name - we are working on the "top" image
originalName = getTitle();

setBatchMode(true);

//Load all possible color modes
colorModes = newArray(
		"Normal",
		"Protanopia (no red)", 
		"Deuteranopia (no green)", 
		"Tritanopia (no blue)",
		"Protanomaly (low red)",
		"Deuteranomaly (low green)",
		"Tritanomaly (low blue)",
		"Typical Monochromacy",
		"Atypical Monochromacy"
		);

//create new stack to store treated images
newImage("Colorblindness simulation", "RGB black", getWidth(), getHeight(), colorModes.length);

// loop over all colorModes, create duplicate image and apply colormode, copy to stack and add label
for(i=0; i<colorModes.length; i++){
	selectWindow(originalName);
	run("Duplicate...", " ");
	rename(colorModes[i]); // duplicated image
	run("Simulate Color Blindness", "mode=[" + colorModes[i] + "]");
	run("Copy");
	close(); // the duplicated image
	selectWindow("Colorblindness simulation");
	setSlice(i+1);
	setMetadata("Label",colorModes[i]); // add label to current slice
	run("Paste"); // add duplicated, simulated image
}

run("Select None");
// close original image
selectWindow(originalName);
close();

// create a montage
selectWindow("Colorblindness simulation");

// what is the current foreground color
fg = getValue("rgb.foreground");
r = (fg>>16)&0xff;
g = (fg>>8)&0xff;
b = fg&0xff;

if(forecol) {
	setForegroundColor(r, g, b);
} else {
	setForegroundColor(255, 0, 255); // magenta
}

cmd = "columns=3 rows=3 scale=" + scalefactor + " border=" + grout + " font=" + fontsize;
if(labeltypes) {
	cmd = cmd + " label use";
} else {
	cmd = cmd + " use";
}

run("Make Montage...", cmd);
if(lastIndexOf(originalName, ".") == -1) {
	shortName = originalName;
} else {
	shortName = substring(originalName, 0, lastIndexOf(originalName, "."));
}
newName = shortName + "_cb";
rename(newName);
setForegroundColor(r, g, b); // back to original foreground color

setBatchMode(false);