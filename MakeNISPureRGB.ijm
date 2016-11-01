/* Nikon's NIS software allows channels to be saved with wavelength rather than pure RGB
 *  This causes a problem because there is contamination of other channels under some circumstances.
 *  This macro will convert the channels to pure RGB and save as RGB
 *  Open all files first with BioFormats (AutoScale) Composite Hyperstack
 *  This is a rough version that will work on BGR composites only.
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
    Stack.setChannel(1)
    run("Blue");
    Stack.setChannel(2)
    run("Green");
    Stack.setChannel(3)
    run("Red");
    // make RGB version
    run("RGB Color");
    saveAs("TIFF", dir1+win);
    close();
    selectImage(id);
    close();
    }