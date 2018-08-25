/*
 * Reconvert color LUT to intensity
 * Olivier BURRI - BioImaging and Optics Platform BIOP, EPFL
 * https://gist.github.com/lacan/db89358ca5ba5d4308a52fc37cd05550
 * extended for use with a stack
 * This macro is very slow...
 */

// Before running this macro, make sure that you have an image called LUT with the color scalebar separately

// Keep original image reference
ori = getTitle();

// Build LUT
selectImage("LUT");
getDimensions(lw,lh,lc,lz,lt);
makeLine(lw/2,0,lw/2,lh);

getSelectionCoordinates(x,y);
lut = newArray(y[1]-y[0]+1);
k=0;
for(j=round(y[0]);j<round(y[1]);j++) {
	lut[k] = getPixel(round(x[0]),j);
	k++;
}

// Start converting the values
setBatchMode(true);

// Some information to create the new image
selectImage(ori);
getDimensions(w,h,c,z,t);
// change z to 1 if you want to only convert one slice of your stack
newImage(ori+" - Reconverted", "16-bit black", w, h, z);
new = getTitle();

for(k=0; k<z; k++)	{
	selectImage(ori);
	setSlice(k+1);
	selectImage(new);
	setSlice(k+1);
	// Loop  through all the pixels
	for(i=0; i<w;i++) {
		for(j=0; j<h;j++) {
			selectImage(ori);
			val = getPixel(i,j);
			
			newVal = findValIdx(val, lut); // Where the magic happens
			selectImage(new);
			setPixel(i,j,newVal);
		}
	}
print("Done slice", k+1);
}
// Comment as needed, here the scalebar was inverted
run("Invert");
setBatchMode(false);


/*
 * Magic function, returns the array index of the most similar LUT value
 */
function findValIdx(value, lut) {
	valred = (val>>16)&0xff;  // extract red byte (bits 23-17) 
	valgreen = (val>>8)&0xff; // extract green byte (bits 15-8) 
	valblue = val&0xff;       // extract blue byte (bits 7-0)
	minD = 99999999999;
	for(i=0; i<lut.length; i++) {
		lutred = (lut[i]>>16)&0xff;  // extract red byte (bits 23-17) 
		lutgreen = (lut[i]>>8)&0xff; // extract green byte (bits 15-8) 
		lutblue = lut[i]&0xff;       // extract blue byte (bits 7-0)

		// Get euclidean distance
		deltargb = sqrt((valred - lutred)*(valred - lutred) + (valgreen - lutgreen)*(valgreen - lutgreen) + (valblue - lutblue)*(valblue - lutblue));
		
		// Keep minimum value
		if(deltargb < minD) {
			minD = deltargb;
			minI = i;

			// If 0 then we have the exact match already
			if(deltargb == 0) return minI;
		}
	}
	return minI;
}
