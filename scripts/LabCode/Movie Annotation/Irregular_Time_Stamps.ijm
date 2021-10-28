/*
 * Simple macro to overlay timestamps on a movie
 * The idea is to use a text file of times.
 * This is useful:
 * 		- if you have irregular timestamps
 * 		- if you don't like the built-in option(s) for timestamps.
 * Text file must be:
 * 		- time in seconds (or minutes) they get styled as 00:00
 * 		- each time on a new line
 * 		- same number of lines as frames
 * Ideas for future: 
 * 		- deal with milliseconds
 * 		- allow user to specify format
 */

macro Timestamps_From_File {
// Label series using time stamps from a text file
	requires("1.49");
	if (nImages == 0) exit("Stack or hyperstack required.");
	title1 = getTitle();
	// work out what sort of image we are labelling
	getDimensions(width, height, channels, slices, frames);
	if (slices == 1 && frames == 1) exit("Stack or hyperstack required.");
	if (Stack.isHyperstack == false && slices > 1) {
		imgType = "stack"; 
	} else {
		imgType = "hyperstack";
	}

	// find the text file containing time stamps and load it.
	pathfile = File.openDialog("Choose the file to Open:"); 
	list = File.openAsString(pathfile); // opens file 
 	entries = split(list, "\n"); // splits lines of text into array

 	// warn user if the number of timestamps is less than the number of slices or 
 	if(imgType == "stack" && (entries.length != slices)) print("Warning: number of timestamps does not match number of slices"); 
 	if(imgType == "hyperstack" && (entries.length != frames)) print("Warning: number of timestamps does not match number of frames"); 

	stampSize = howBigShouldTextBe(width,height);
	// make dialog for user input
	Dialog.create("Timestamp options");
		cornerArray = newArray("LT", "RT", "LB", "RB");
		Dialog.addChoice("Corner for timestamps", cornerArray);
		Dialog.addNumber("Size", stampSize);
		Dialog.addCheckbox("Flatten?", false);
	Dialog.show();

	// Collect data from dialog window
	stampPos = Dialog.getChoice();
	stampSize = Dialog.getNumber();
	flattenOpt = Dialog.getCheckbox();
 	
 	setBatchMode(true);
 	run("Colors...", "foreground=white background=black selection=white"); 
	selectWindow(title1);
	polarity = false;
	for (i = 0; i < entries.length; i++) {
		j = parseInt(entries[i]);
		if (j < 0) {
			polarity = true;
			break;
		}
	}
	
 	for (i = 0; i < entries.length; i++) {
		t = parseInt(entries[i]); // this line results in seconds or minutes being whole numbers
		if (polarity == true) {
			if (t>=0) s = "+"+pad(floor((t/60)%60))+":"+pad(t%60); // time sec/60 stuff
			else s = "-"+pad(floor((-t/60)%60))+":"+pad(-t%60); // deal with negative number
		} else {
			s = ""+pad(floor((t/60)%60))+":"+pad(t%60); // time sec/60 stuff
		}
		// this shouldn't work for hyperstacks but it does - suspect this may break in the future
		setSlice(i + 1); // select slice number, 1-based
		setMetadata("Label", s);
	}
//	setTool("text");
	stampArray = whereDoesStampGo(stampPos, width, height, stampSize, polarity);
	run("Label...", "format=Label x="+stampArray[0]+" y="+stampArray[1]+" font="+stampSize+" use");
	if (flattenOpt == true) {
		run("Flatten");
	}
	setBatchMode(false);
}

function pad(n) {
	// pad single digit numbers with a preceding zero
	str = toString(n); // decimal rep of number j 
	if (lengthOf(str)==1) str="0"+str; 
	
	return str;
}

function howBigShouldTextBe(ww, hh)	{
	// check if image is an unsual aspect ratio, if so use small size
	if((ww / hh < 0.25) || (hh / ww < 0.25)) {
		return 8;
	} else {
		bigDim = maxOf(ww,hh);
		fSize = floor(bigDim / 200) * 12;
	}
	
	return fSize;
}

function whereDoesStampGo(corner, ww, hh, textSize, longLabel)	{
	coords = newArray(2);
	if (longLabel == true) {
		xSize = 4 + (3.5 * textSize);
		ySize = -4.5 + (0.9 * textSize);
	} else {
		xSize = 4 + (2.75 * textSize);
		ySize = -4.5 + (0.9 * textSize);
	}
	
	if (corner == "LT")	{
		coords[0] = 2;
		coords[1] = 2 + ySize;
	}
	if (corner == "LB")	{
		coords[0] = 2;
		coords[1] = hh - 2;
	}
	if (corner == "RT")	{
		coords[0] = ww - 2 - xSize;
		coords[1] = 2 + ySize;
	}
	if (corner == "RB")	{
		coords[0] = ww - 2 - xSize;
		coords[1] = hh - 2;
	}
	
	return coords;
}

// this macro was contributed by Meghane Sittewelle
// allows user to save text file of time stamps for use in the main macro

macro Save_Time_Stamps_To_Text_File	{
	run("Bio-Formats Macro Extensions");
	id = File.openDialog("Choose a file");
	Ext.setId(id);
	Ext.getImageCount(imageCount);
	deltaT = newArray(imageCount);
	// make a text file
	dirsave = File.getDirectory(id);
	filename = File.getNameWithoutExtension(id);
	f = File.open(dirsave+File.separator+filename+"_deltaT.txt");
	
	for (no = 0; no < imageCount; no ++) {
		Ext.getPlaneTimingDeltaT(deltaT[no], no);
		print(f, deltaT[no] + "\n");
	}
	
	File.close(f);
}