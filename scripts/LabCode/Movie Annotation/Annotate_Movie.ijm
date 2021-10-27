/*
 * Macro to annotate a movie with a single arrowhead to illustrate a moving feature.
 * The aim is to have the arrowhead a fixed distance from the object and keep a constant shape
 * The code will annotate non-consecutive frames.
 * 
 * quantixed, Oct 2021
 */

// load the movie file
// use multipoint tool to record the feature of interest in a single ROI in the manager
// the single ROI can be saved and loaded as required for complex annotations

macro Annotate_Movie	{
	if (nImages != 1) exit("One image and multipoint ROI required");
	original = getTitle();
	// error checking
	getDimensions(width, height, channels, slices, frames);
	if ((slices == 1) && (frames == 1)) exit("This macro requires a z-stack or time series.");
	if (roiManager("count") != 1) exit("One multipoint ROI required.");

	// Create dialog window
	Dialog.create("Annotate options");
		directionArray = newArray("Top Left", "Top Centre", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Centre", "Bottom Right");
		Dialog.addChoice("Arrowhead points from", directionArray);
		Dialog.addNumber("Offset (px)", 4);
	//	Dialog.addNumber("Arrowhead width", 2);
		Dialog.addNumber("Arrowhead size", 6)
	Dialog.show();

	// Collect data from dialog window
	arrowPos = Dialog.getChoice();
	arrowOffset = Dialog.getNumber();
	//arrowWidth = Dialog.getNumber();
	arrowSize = Dialog.getNumber();
	// convert arrow position choice to radians (using x,y coords not x,y image coords
	if (arrowPos == "Top Left") arrowSel = PI * 1.25;
	if (arrowPos == "Top Centre") arrowSel = PI * 1.5;
	if (arrowPos == "Top Right") arrowSel = PI * 1.75;
	if (arrowPos == "Middle Left") arrowSel = PI * 1;
	if (arrowPos == "Middle Right") arrowSel = PI * 0;
	if (arrowPos == "Bottom Left") arrowSel = PI * 0.75;
	if (arrowPos == "Bottom Centre") arrowSel = PI * 0.5;
	if (arrowPos == "Bottom Right") arrowSel = PI * 0.25;
	
	roiManager("select", 0);
	// get array of x and y coords
	getSelectionCoordinates(xCoords, yCoords);
	// to get the frame numbers we need this little hack
	run("Clear Results");
	run("Measure");
	frameNumbers = newArray(nResults());
	for (i = 0; i < nResults(); i++) {
	    frameNumbers[i] = getResult('Frame', i);
	}
	roiManager("reset");
	arrowWidth = 2; // comment out this line if it is specified above
	run("Arrow Tool...", "width="+arrowWidth+" size="+arrowSize+" color=White style=Filled");
	selectWindow(original);
		for (i = 0; i < nResults(); i++) {
			arrowArray = makeArrowPositions(xCoords[i],yCoords[i],arrowSel,arrowOffset,arrowSize);
		    makeArrow(arrowArray[0], arrowArray[1], arrowArray[2], arrowArray[3], "filled");
			Roi.setPosition(0, 0, frameNumbers[i]);
		    Overlay.addSelection();
		    run("Select None");
	}
}

function makeArrowPositions(xc, yc, radiansOfArrow, offPx, widthOfArrow)	{
	//xStart, yStart, xStop, yStop
	theArrowArray = newArray(4);
	if(widthOfArrow < 10) {
		dist = 4;
	} else {
		dist = 10;
	}
	farPoint = offPx + dist;
	nearPoint = offPx;
	theArrowArray[0] = xc + (farPoint * cos(radiansOfArrow));
	theArrowArray[1] = yc + (farPoint * sin(radiansOfArrow));
	theArrowArray[2] = xc + (nearPoint * cos(radiansOfArrow));
	theArrowArray[3] = yc + (nearPoint * sin(radiansOfArrow));

	return theArrowArray;
}
