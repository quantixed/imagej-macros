/*
 * The montage macros make a merge from the standard colours.
 * If a nonstandard colourset is required, this macro will change the merge panel.
 * It takes the RGB channels and changes them to e.g. Magenta, Green, Blue
 * Can also be used with non-standard LUTs e.g. Orange, Fresh, Purple (OFP).
 * Must have the custom LUTs installed - macro checks for this.
 * Will work on all open images and will leave them open for inspection.
 * Limitation: will only change the right (or bottom) panel, i.e. if two merges are present, only far one is changed.
 * Limitation: assumes that the merge is not inverted.
 * Limitation: only works on montage and not compiled montages.
 * Limitation: if same-named images are open, may not work as expected.
 * Idea is to 1) make a montage, 2) add ROI zooms, 3) change the merge panel, 4) compile montages
 * The other use is to switch colours when 1 and 2 have been done on many images.
 * http://github.com/quantixed/imagej-macros/
 */

macro "RGB to OFP" {
	if (nImages == 0)	exit("No image open");
	if (lutCheck() == 0)	exit("Required LUTs are missing");
	colourString = "OFP";

	setBatchMode(true);
	
	titleList = getList("image.titles"); 
	count = lengthOf(titleList);
	for (i = 0; i < count; i++) {
		imageTitle = titleList[i];
		selectImage(imageTitle);
		autoChangeMontage(colourString);
	}
	
	setBatchMode(false);
}