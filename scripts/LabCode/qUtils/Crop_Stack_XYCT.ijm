/*
 * Script to make a rectangular crop and crop in space (slices) and time (frames)
 * Options:
 * 	recurse the directory or to stay in the top directory
 * 	overwrite the data or not
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (visibility=MESSAGE, value="Specify crop:\nUse -1 for no box", required=false) msg1
#@ Integer (label = "Box width (px)", value = 50) xsize
#@ Integer (label = "Box height (px)", value = 50) ysize
#@ String (visibility=MESSAGE, value="Use -1 to centre box in image", required=false) msg2
#@ Integer (label = "Box upper-left x (px)", value = -1) xul
#@ Integer (label = "Box upper-left y (px)", value = -1) yul
#@ String (visibility=MESSAGE, value="Use -1 for all slices", required=false) msg3
#@ Integer (label = "Starting slice", value = 3) zstart
#@ Integer (label = "Ending slice", value = 3) zstop
#@ String (visibility=MESSAGE, value="Use -1 for all frames", required=false) msg4
#@ Integer (label = "Starting frame", value = 1) tstart
#@ Integer (label = "Ending frame", value = 30) tstop
#@ Boolean (label = "Recursive?", value = true, persist = false) recur
#@ Boolean (label = "Overwrite data?", value = false, persist = false) overwrite

// script starts here
setBatchMode(true);

processFolder(input);

setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") || !endsWith(input,"\\")) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]) && recur == true)
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processTopFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") || !endsWith(input,"\\")) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	open(input + file);
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	
	// if all frames are to be kept
	if (tstart < 0 || tstop < 0) {
		tstart = 1;
		tstop = slices;
	} else if (tstart > tstop) {
		// in case user has put these in the wrong way around
		temp = tstart;
		tstart = tstop;
		tstop = temp;
	}
	
	// if all slices are to be kept
	if (zstart < 0 || zstop < 0) {
		zstart = 1;
		zstop = slices;
	} else if (zstart > zstop) {
		// in case user has put these in the wrong way around
		temp = zstart;
		zstart = zstop;
		zstop = zemp;
	}
	
	// select box
	if (xul == -1) {
		x1 = floor((width / 2) - (xsize / 2));
	} else {
		x1 = xul;
	}
	if (yul == -1) {
		y1 = floor((height / 2) - (ysize / 2));
	} else {
		y1 = yul;
	}
	
	// in case no box is to be used
	if (xsize == -1 || ysize == -1) {
		run("Select None");
	} else {
		makeRectangle(x1, y1, xsize, ysize);
	}
	
	run("Duplicate...", "title=test duplicate slices=" + zstart + "-" + zstop + " frames=" + tstart + "-" + tstop);
	
	if (overwrite == true) {
		save(input + file);
	} else {
		copyname = replace(file, suffix, "_crop" + suffix);
		save(input + copyname);
	}
	
	close();
	close();
}