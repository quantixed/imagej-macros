/*
 * Macro to save a "small" version of the top window to
 * the desktop for use in an electronic lab notebook.
 * This is the first version - expect bugs!
 */

macro "Make Version For ELN" {
	if (nImages < 1) exit ("I need an image to do this.");
	setBatchMode(true);
	title1 = getTitle();
	dir1 = getDirectory("image");
	id1 = getImageID();
	dir2 = getDirectory("home")+"Desktop"+File.separator+"ELNoutput"+File.separator;
	// make this directory on the desktop if it doesn't already exist
	File.makeDirectory(dir2);
	// width, height, channels, slices, frames
	getDimensions(ww, hh, cc, ss, ff);
	slice1 = getSliceNumber();
	TimeString = getTimeDate();
	// duplicate window
	if(ss > 1 || ff > 1) {
		//run("Duplicate...", "title=elnout duplicate range=1-" + ff); // possibility to add movie option here
		run("Duplicate...", "title=elnout");
	} else {
		run("Duplicate...", "title=elnout");
	}
	id2 = getImageID();
	// do something about size
	if(ww > 2000 || hh > 2000) {
		wFactor = -floor(-ww / 2000);
		hFactor = -floor(-hh / 2000);
		allFactor = maxOf(2,maxOf(wFactor,hFactor)); // at least do 50%
		run("Size...", "width=" + round(ww / allFactor) + " height=" + round(hh / allFactor) +  " depth=1 constrain average interpolation=Bilinear");
	}
	// downsample if necessary
	if (bitDepth==24)
		run("8-bit Color", "number=256");
	else
		run("8-bit");
	newName = TimeString + ".png";
	saveAs("png",dir2+newName);
	close();
	// record what happened
	print("\\Clear");
	print(title1 + " from " + dir1 + "\rexported as " + TimeString);
	selectWindow("Log");
	saveAs("text", dir2+newName+"_note.txt");
	setBatchMode(false);
}
function getTimeDate() {
	// Make unique filename.
	// ISO 8601 with no special characters is
	// YYYYMMDDTHHMMSSZ e.g. 20170630T193338Z
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	TimeString = "UTC"+year;
	if (month<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+month;
	if (dayOfMonth<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+dayOfMonth;
	if (hour<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+"T"+hour;
	if (minute<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+minute;
	if (second<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+second+"Z";
	TimeString = replace(TimeString,"UTC","");
    //showMessage(TimeString);
 	return TimeString;
}
