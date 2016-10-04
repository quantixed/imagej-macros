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
	ALL_EXT=newArray(ALL_NAMES.length);
	// Create extensions array
	for (i=0; i<ALL_NAMES.length; i++) {
		if (File.isDirectory(DIR_PATH+ALL_NAMES[i])!=1){
			LENGTH=lengthOf(ALL_NAMES[i]);
			ALL_EXT[i]=substring(ALL_NAMES[i],LENGTH-4,LENGTH);
		}
		else ALL_EXT[i]="folder";
	}
	
	// Print arrays for verification
	ALL_NAMES_STRING="[";
	ALL_EXT_STRING="[";
	for (i=0; i<ALL_NAMES.length; i++) {	
		ALL_NAMES_STRING=ALL_NAMES_STRING+"  "+ALL_NAMES[i];
		ALL_EXT_STRING=ALL_EXT_STRING+"  "+ALL_EXT[i];
	}
	ALL_NAMES_STRING=ALL_NAMES_STRING+" ]";
	ALL_EXT_STRING=ALL_EXT_STRING+" ]";
	print("ALL_NAMES="+ALL_NAMES_STRING);
	print("ALL_EXT="+ALL_EXT_STRING);
	
	SAVE_ARRAY = newArray("In the source folder", "In a subfolder of the source folder", "In a folder next to the source folder", "In a custom folder");
	
	// Creation of the dialog box
	Dialog.create("blind analysis");
	Dialog.addChoice("Save blind analysis images :", SAVE_ARRAY, "In a subfolder of the source folder");
	Dialog.show();
	SAVE_TYPE=Dialog.getChoice();
	
	// Localize or create the output folder
	OUTPUT_DIR="Void";
	if (SAVE_TYPE=="In the source folder") {
		OUTPUT_DIR=DIR_PATH;
	}
	if (SAVE_TYPE=="In a subfolder of the source folder") {
		OUTPUT_DIR=DIR_PATH+"BLIND"+File.separator;
		File.makeDirectory(OUTPUT_DIR);
	}
	if (SAVE_TYPE=="In a folder next to the source folder") {
		OUTPUT_DIR=File.getParent(DIR_PATH);
		OUTPUT_DIR=OUTPUT_DIR+"BLIND"+File.separator;
		File.makeDirectory(OUTPUT_DIR);
	}
	if (SAVE_TYPE=="In a custom folder") {
		OUTPUT_DIR=getDirectory("Choose the save folder");
	}

	// How many TIFFs do we have? Directory could contain other directories.
	for (i=0; i<ALL_EXT.length; i++) {		
 		if (ALL_EXT[i]==".tif") {	
 			IM_NUMBER=IM_NUMBER+1;		
 		}
 	}
	//IM_NUMBER=ALL_EXT.length;
	IM_NAMES=newArray(IM_NUMBER);
	IM_EXT=newArray(IM_NUMBER);
	
	// Test all files for extension
	j=0;
	for (i=0; i<ALL_EXT.length; i++) {
		if (ALL_EXT[i]==".tif") {	
			IM_NAMES[j]=ALL_NAMES[i];
			IM_EXT[j]=ALL_EXT[i];
			j=j+1;
		}
	}
	
	// Print arrays for verification
	IM_NAMES_STRING="[";
	IM_EXT_STRING="[";
	IM_CH_STRING="[";
	IM_SHORT_STRING="[";
	for (j=0; j<IM_NUMBER; j++) {	
		IM_NAMES_STRING=IM_NAMES_STRING+"  "+IM_NAMES[j];
		IM_EXT_STRING=IM_EXT_STRING+"  "+IM_EXT[j];
	}
	IM_NAMES_STRING=IM_NAMES_STRING+" ]";
	IM_EXT_STRING=IM_EXT_STRING+" ]";
	print("IM_NAMES="+IM_NAMES_STRING);
	print("IM_EXT="+IM_EXT_STRING);
	
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
		IM_PERM_NAMES[j]="blind_"+pad(IM_PERM[j],4,0); // for more than 9999 images change width
	}
	
	// Print arrays for verification
	IM_PERM_STRING="[";
	IM_PERM_NAMES_STRING="[";
	for (j=0; j<IM_NUMBER; j++) {	
		IM_PERM_STRING=IM_PERM_STRING+"  "+IM_PERM[j];
		IM_PERM_NAMES_STRING=IM_PERM_NAMES_STRING+"  "+IM_PERM_NAMES[j];
	}
	IM_PERM_STRING=IM_PERM_STRING+" ]";
	IM_PERM_NAMES_STRING=IM_PERM_NAMES_STRING+" ]";
	print("IM_PERM="+IM_PERM_STRING);
	print("IM_PERM_NAMES="+IM_PERM_NAMES_STRING);
	
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
		setMetadata("Label", "");
		save(OUTPUT_PATH_PERM);
		print(f,IM_NAMES[j]+"\t"+IM_PERM_NAMES[j]);
		close();
	}
	setBatchMode("exit and display");
	showStatus("finished");
	
}

// This function generates a padded number, i.e. 34 becomes 00034 by pad(34,5,0)
// number is the number to pad (here 34)
// width is the final length of the padded number (here 5)
// character is the character added to the left (here 0)
function pad(number, width, character) {
       number = toString(number); // force string
       character = toString(character);
       for (len = lengthOf(number); len < width; len++)
               number = character + number;
       return number;
}