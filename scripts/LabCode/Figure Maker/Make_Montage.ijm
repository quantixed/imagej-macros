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

 Batch processing of a directory TIFFs will be added shortly.
*/


macro "Make Montage" {
	if (nImages > 0) exit ("Please close all open images");
	filepath = File.openDialog("Select a File");
	open(filepath);
  dir1 = getDirectory("image");
	// determine what we are dealing width
	getDimensions(ww, hh, cc, ss, ff);
	// warn if image is not square
	if (ww != hh) print("Input image is not square");
	//
	if (bitDepth() == 8 || bitDepth() == 16) {
		if (cc * ss * ff == 1) exit ("Need more than one channel, slice, or frame");
		if ((cc > 1 && ss > 1) || (cc > 1 && ff > 1) || (ss > 1 && ff > 1)) exit ("Reduce dimensions before making montage");
		montageMaker(dir1);
	}
	else if (bitDepth() == 24 && ss * ff == 1)	{
		run("Split Channels");
		run("Images to Stack");
		montageMaker(dir1);
	}
  else exit ("Input image does not meet requirements for montage");
}
