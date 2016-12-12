/* 
 *  BlindAnalysis.ijm
 *  This macro will take a directory of TIFFs
 *  	strip the label from them
 *  	save each with a randomised filename
 *  	log the association between original file and blind analysis file
 *  Adapted from:
 *  Shuffler macro by Christophe Leterrier v1.0 26/06/08
*/

macro "Blind Analysis" {
	DIR_PATH=getDirectory("Select a directory");
	
print("\\Clear");
print("DIR_PATH :"+DIR_PATH);
	
	// Get all file names
	ALL_NAMES=getFileList(DIR_PATH);

	// Create the output folder
	OUTPUT_DIR=DIR_PATH+"BLIND"+File.separator;
	File.makeDirectory(OUTPUT_DIR);

	// How many TIFFs do we have? Directory could contain other directories.
	for (i=0; i<ALL_NAMES.length; i++) {		
 		if (indexOf(toLowerCase(ALL_NAMES[i]), ".tif")>0) {	
 			IM_NUMBER=IM_NUMBER+1;		
 		}
 	}
	IM_NAMES=newArray(IM_NUMBER);
	IM_EXT=newArray(IM_NUMBER);
	
	// Test all files for extension
	j=0;
	for (i=0; i<ALL_NAMES.length; i++) {
		if (indexOf(toLowerCase(ALL_NAMES[i]), ".tif")>0) {	
			IM_NAMES[j]=ALL_NAMES[i];
			j=j+1;
		}
	}

	// Generate a permutation array of length IM_NUMBER	
	IM_PERM=newArray(IM_NUMBER);
	for(j=0; j<IM_NUMBER; j++) {
		IM_PERM[j]=j+1;
	}
	for(j1=0; j1<IM_NUMBER; j1++) {
		j2=floor(random*IM_NUMBER);
		swap=IM_PERM[j1];
		IM_PERM[j1]=IM_PERM[j2];
		IM_PERM[j2]=swap;
	}

	// Associate sequentially permuted positions to image names
	IM_PERM_NAMES=newArray(IM_NUMBER);
	for(j=0; j<IM_NUMBER; j++){
		IM_PERM_NAMES[j]="blind_"+IJ.pad(IM_PERM[j],4); // for more than 9999 images change width
	}

	// Open each image (loop on IM_NAMES) and save them in the destination folder
	// as the blinded file (IM_PERM_NAME).
	// Additionally logs both names in the log.txt file created in the destination folder
	setBatchMode(true);
	f=File.open(OUTPUT_DIR+"log.txt");
	print(f, "Original_Name\tBlinded_Name");
	for(j=0; j<IM_NUMBER; j++){
		INPUT_PATH=DIR_PATH+IM_NAMES[j];
		OUTPUT_PATH=OUTPUT_DIR+IM_NAMES[j];
		OUTPUT_PATH_PERM=OUTPUT_DIR+IM_PERM_NAMES[j];
		open(INPUT_PATH);
		setMetadata("Label", ""); // strips the label data from the image for blinding purposes
		save(OUTPUT_PATH_PERM);
		print(f,IM_NAMES[j]+"\t"+IM_PERM_NAMES[j]);
		close();
	}
	setBatchMode("exit and display");
	showStatus("finished");
	
}