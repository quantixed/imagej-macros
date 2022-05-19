/*
 * Apply color blindness simulation to current image
 * Apply all simulation modes on duplicate images
 * Collect in stack, create montage
 * 
 * 2020-07-20
 * @Author: Henrik Persson
 * Edits: quantixed 2022-03-26
 */

if (nImages < 1) exit ("One image is required.");

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

//get original image name
originalName = getTitle();

//create new stack to store treated images
newImage("Colorblindness simulation", "RGB black", getWidth(), getHeight(), colorModes.length);

/*
 * loop over all colorModes
 * create duplicate image and apply colormode. 
 * Copy to stack and add label
 */
for(i=0; i<colorModes.length; i++){
	selectWindow(originalName);
	run("Duplicate...", " ");
	rename(colorModes[i]);//duplicated image
	run("Simulate Color Blindness", "mode=[" + colorModes[i] + "]");
	run("Copy");
	close();//the duplicated image
	selectWindow("Colorblindness simulation");
	setSlice(i+1);
	setMetadata("Label",colorModes[i]);//add label to current slice
	run("Paste");//add duplicated, simulated image
}

run("Select None");
// close original image
selectWindow(originalName);
close();

//Create a montage
selectWindow("Colorblindness simulation");
setForegroundColor(255, 0, 255); // magenta is easier to see
run("Make Montage...", "columns=3 rows=3 scale=0.25 border=5 font=18 label use");
if(lastIndexOf(originalName, ".") == -1) {
	shortName = originalName;
	extension = "";
} else {
	extension = substring(originalName, lastIndexOf(originalName, "."));
	shortName = substring(originalName, 0, lastIndexOf(originalName, "."));
}
newName = shortName + "_cb" + extension;
rename(newName);
setForegroundColor(255, 255, 255); // back to white

setBatchMode(false);