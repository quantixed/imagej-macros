/* Nikon's NIS software allows channels to be saved with wavelength rather than pure RGB
 *  This causes a problem because there is contamination of other channels under some circumstances.
 *  This macro will convert the channels to pure RGB and save as RGB
 *  Open all files first with BioFormats (AutoScale) Composite Hyperstack
 *  Evaluates which channel is bluish, redish and greenish.
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
    for (j=1; j< 4; j++)  {
    	Stack.setChannel(j);
    	getLut(reds,greens,blues);
    	if (reds[255] > greens[255] && reds[255] > blues[255]) {
    	run("Red");
    	}
    	if (greens[255] > reds[255] && greens[255] > blues[255]) {
    	run("Green");
    	}
    	if (blues[255] > reds[255] && blues[255] > greens[255]) {
    	run("Blue");
    	}
    }
    // make RGB version
    run("RGB Color");
    saveAs("TIFF", dir1+win);
    close();
    selectImage(id);
    close();
    }