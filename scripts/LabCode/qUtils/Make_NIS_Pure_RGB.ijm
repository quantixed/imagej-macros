/* Nikon's NIS software allows channels to be saved with a LUT based on wavelength
 * This causes a problem because there is contamination of other channels under some circumstances.
 * This macro will convert the first three channels to pure RGB LUTs and save a version
 * Open all files first with BioFormats (AutoScale) Composite Hyperstack
 * Evaluates which channel is bluish, redish and greenish.
 * Note: an earlier version of this macro saved the file in 24-bit RGB BioFormats
 * this version retains the image type.
 */

setBatchMode(true);
imgArray = newArray(nImages);
dir1 = getDirectory("Choose Destination Directory ");
for (i=0; i<nImages; i++) {
		selectImage(i+1);
		imgArray[i] = getImageID();
		}
for (i=0; i< imgArray.length; i++) {
		selectImage(imgArray[i]);
		id = getImageID();
		win = getTitle();
		getDimensions(ww, hh, ch, sl, fr);
		for (j=0; j<ch; j++)  {
			Stack.setChannel(j+1);
			getLut(reds,greens,blues);
			if (reds[255] > greens[255] && reds[255] > blues[255])
				run("Red");
			else if (greens[255] > reds[255] && greens[255] > blues[255])
				run("Green");
			else if (blues[255] > reds[255] && blues[255] > greens[255])
				run("Blue");
			else
				run("Grays");
			}
			path = dir1 + win;
			if(!endsWith(path, ".tif")) {
				path = path + ".tif";
			}
			saveAs("TIFF", path);
		close();
	}
