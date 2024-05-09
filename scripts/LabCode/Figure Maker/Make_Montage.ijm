/*
 The aim is to make montages the way we like them.
 Horizontal - grayscale single channels with merge(s) on the right
 Vertical - grayscale single channels with merge(s) on the bottom

 The code got a spring clean in Feb 2020 which allows more channels for the grayscale
 and other colours in the merge(s).

 Notes:
 1. row or column montages are generated (user decides)
 2. Input can be 8-bit, 16-bit stacks/composites or single slice RGB Images
 3. Specify the grouting of the montage (white space between panels)
 4. There's no outside border, and there is an option to add a scale bar (scaling taken from image)
 5. The idea is to compile them afterwards using Montage Compiler
*/


macro "Make Montage" {
	if (nImages > 0) exit ("Please close all open images");
	filepath = File.openDialog("Select a File");
	open(filepath);
  dir1 = getDirectory("image");
	// determine what we are dealing width
	getDimensions(ww, hh, cc, ss, ff);
	win = getTitle();
	okVar = checkImageForMontage(win);
	if (okVar == true) {
		montageMaker(dir1);
	} else if (okVar == false) {
		rename("mmTemp");
		dir = getDir("temp");
		if (dir == "")
      		exit("No temp directory available");
		// check temporary directory for temporary montage files, delete if found
		qCheckForTempFiles(dir);
		// split out stack into separate files in temporary directory
		qSaveImageSequence(dir);
		montageMakerMulti(dir, dir1, false, win);
	}
}

function qCheckForTempFiles(dir) {
	list = getFileList(dir);
	tiffnum = 0;
	for (i = 0; i < list.length; i ++) {
		if (startsWith(list[i], "mmTemp") && endsWith(toLowerCase(list[i]), ".tif")) {
			tiffnum = tiffnum + 1;
			ok = File.delete(dir + list[i]);
		}
	}
}

function qSaveImageSequence(dir) {
	win = getTitle();
	setBatchMode(true);

	getDimensions(ww, hh, cc, ss, ff);
	if(cc == 1) {
		run("Image Sequence... ", "dir=" + dir + " format=TIFF start=0 digits=4");
	} else {
		if(ss > 1) {
			for(i = 0; i < ss; i++) {
				selectWindow(win);
				run("Duplicate...", "duplicate slices=" + (i + 1));
				saveAs("Tiff", dir + "mmTemp" + IJ.pad(i, 4) + ".tif");
				close();
			}
		} else {
			for(i = 0; i < ff; i++) {
				selectWindow(win);
				run("Duplicate...", "duplicate frames=" + (i + 1));
				saveAs("Tiff", dir + "mmTemp" + IJ.pad(i, 4) + ".tif");
				close();
			}
		}
	}
	selectWindow(win);
	close();
	setBatchMode(false);
}