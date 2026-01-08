/*
 * Script to make a rectangular crop and/or crop (get a range)
 *  of channels and/or
 *  of z (slices) and/or
 *  of time (frames)
 * Options:
 * 	recurse the directory or to stay in the top directory
 */

#@ File (label = "Input directory", style = "directory") in
#@ File (label = "Output directory", style = "directory") out
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (visibility=MESSAGE, value="----------Specify crop:-----------", required=false) msg0
#@ String (visibility=MESSAGE, value="For no box, use 0", required=false) msg1
#@ Integer (label = "Box width (px)", value = 50) xsize
#@ Integer (label = "Box height (px)", value = 50) ysize
#@ String (visibility=MESSAGE, value="Use -1 to centre box in image", required=false) msg2
#@ Integer (label = "Box upper-left x (px)", value = 0) xul
#@ Integer (label = "Box upper-left y (px)", value = 0) yul
#@ String (visibility=MESSAGE, value="For all channels, use 0", required=false) msg3
#@ Integer (label = "Starting channel", value = 1) cstart
#@ Integer (label = "Ending channel", value = 3) cstop
#@ String (visibility=MESSAGE, value="For all slices, use 0", required=false) msg4
#@ Integer (label = "Starting slice", value = 3) zstart
#@ Integer (label = "Ending slice", value = 3) zstop
#@ String (visibility=MESSAGE, value="For all frames, use 0", required=false) msg5
#@ Integer (label = "Starting frame", value = 1) tstart
#@ Integer (label = "Ending frame", value = 30) tstop
#@ Boolean (label = "Recursive?", value = true, persist = false) recur

// script starts here

inputlocal = correctDirEnding(in);
outputlocal = correctDirEnding(out);
if (inputlocal == outputlocal) {
	waitForUser("Input and Output directories are the same.\nImages will be OVERWRITTEN\nContinue?");
}
print("\\Clear");
setBatchMode(true);
processFolder(inputlocal);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	input = correctDirEnding(input);
	output = correctDirEnding(out);
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]) && recur == true)
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	open(input + file);
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	imgtype = determineImageType(width, height, channels, slices, frames);
	cropc = true;
	cropz = true;
	cropt = true;
	
	// if all FRAMES are to be kept
	if (tstart < 1 || tstop < 1) {
		tbegin = 1;
		tend = frames;
		cropt = false;
	} else if (tstart > tstop) {
		// in case user has put these in the wrong way around
		tbegin = tstop;
		tend = tstart;
	} else {
		tbegin = tstart;
		tend = tstop;
	}
	if (tbegin > frames || tend > frames) {
		print(file + " - Requested frames are out of range - using all");
		cropt = false;
	}
	
	// if all SLICES are to be kept
	if (zstart < 1 || zstop < 1) {
		zbegin = 1;
		zend = slices;
		crop = false;
	} else if (zstart > zstop) {
		// in case user has put these in the wrong way around
		zbegin = zstop;
		zend = zstart;
	} else {
		zbegin = zstart;
		zend = zstop;
	}
	if (zbegin > slices || zend > slices) {
		print(file + " - Requested slices are out of range - using all");
		cropz = false;
	}
	
	// if all CHANNELS are to be kept
	if (cstart < 1 || cstop < 1) {
		cbegin = 1;
		cend = channels;
		cropc = false;
	} else if (cstart > cstop) {
		// in case user has put these in the wrong way around
		cbegin = cstop;
		cend = cstart;
	} else {
		cbegin = cstart;
		cend = cstop;
	}
	if (cbegin > channels || cend > channels) {
		print(file + " - Requested channels are out of range - using all");
		cropc = false;
	}
	
	// -- XY crop --
	
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
	if (xsize < 1 || ysize < 1) {
		run("Select None");
	} else {
		makeRectangle(x1, y1, xsize, ysize);
	}
	
	// Duplicate ---
	
	cropstr = "";
	if (cropc) cropstr = cropstr + " channels=" + cbegin + "-" + cend;
	if (cropz) cropstr = cropstr + " slices=" + zbegin + "-" + zend;
	if (cropt) cropstr = cropstr + " frames=" + tbegin + "-" + tend;
	
	if (lengthOf(imgtype) > 3) {
		run("Duplicate...", "title=test duplicate" + cropstr);	
	} else if (imgtype == "XYC") {
		run("Duplicate...", "title=test duplicate channels=" + cbegin + "-" + cend);
	} else if (imgtype == "XYZ") {
		run("Duplicate...", "title=test duplicate range=" + zbegin + "-" + zend);
	} else if (imgtype == "XYT") {
		run("Duplicate...", "title=test duplicate range=" + tbegin + "-" + tend);
	}
	
	// input maybe the parent directory or a subdirectory
	// destination may not have the necessary subdirectory
	outpath = replace(input, correctDirEnding(in), output);

	if(!File.exists(outpath)) makeDirectoryTree(outpath);

	save(outpath + file);
	
	close("*");
}

function determineImageType(width, height, channels, slices, frames) {
	s = "XY";
	if (channels > 1) s = s + "C";
	if (slices > 1) s = s + "Z";
	if (frames > 1) s = s + "T";
	return s;
}