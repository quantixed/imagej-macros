/* 
 *  Shuffler macro by Christophe Leterrier
 *  v1.0 26/06/08
 *  Forking this to make BlindAnalysis.ijm
*/

macro "STK Extractor" {
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
	
	// Print arrays for verifications
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
		
	
	LABEL=newArray("C=0", "C=1", "C=2", "C=3");
	LABEL_CHK=newArray(4);
	SAVE_ARRAY = newArray("In the source folder", "In a subfolder of the source folder", "In a folder next to the source folder", "In a custom folder");
	
	// Creation of the dialog box
	// You have to specify the strings corresponding to each channels
	Dialog.create("stk extractor");
	Dialog.addCheckbox("Channel 01", true);
	Dialog.addString("Channel 01 Label :", LABEL[0]);
	Dialog.addCheckbox("Channel 02", true);
	Dialog.addString("Channel 02 Label :", LABEL[1]);
	Dialog.addCheckbox("Channel 03", false);
	Dialog.addString("Channel 03 Label :", LABEL[2]);
	Dialog.addCheckbox("Channel 04", false);
	Dialog.addString("Channel 04 Label :", LABEL[3]);
	Dialog.addMessage("\n");
	Dialog.addChoice("Save shuffled images :", SAVE_ARRAY, "In a subfolder of the source folder");
	
	Dialog.show();
	
	// Feeding variables from dialog choices
	for (k=0; k<LABEL.length; k++) {
		LABEL_CHK[k]=Dialog.getCheckbox();
		if (LABEL_CHK[k]==true) {
			LABEL[k]=Dialog.getString();
		}
		else LABEL[k]="none";
	}
	SAVE_TYPE=Dialog.getChoice();
	
	// Print arrays for verifications
	CH_STRING="[";
	for (k=0; k<LABEL.length; k++) {	
		CH_STRING=CH_STRING+"  "+LABEL[k];
	}
	CH_STRING=CH_STRING+" ]";
	print("CH_LABELs="+CH_STRING);

	
	// Localize or create the output folder
	OUTPUT_DIR="Void";
	if (SAVE_TYPE=="In the source folder") {
		OUTPUT_DIR=DIR_PATH;
	}
	if (SAVE_TYPE=="In a subfolder of the source folder") {
		OUTPUT_DIR=DIR_PATH+"SHUF"+File.separator;
		File.makeDirectory(OUTPUT_DIR);
	}
	if (SAVE_TYPE=="In a folder next to the source folder") {
		OUTPUT_DIR=File.getParent(DIR_PATH);
		OUTPUT_DIR=OUTPUT_DIR+"SHUF"+File.separator;
		File.makeDirectory(OUTPUT_DIR);
	}
	if (SAVE_TYPE=="In a custom folder") {
		OUTPUT_DIR=getDirectory("Choose the save folder");
	}
	

	// Determine how many files are .tif images with the proper channels: IM_NUMBER<=ALL_NAMES.length
	IM_NUMBER=0;
	for (i=0; i<ALL_EXT.length; i++) {
		if (ALL_EXT[i]==".tif") {
			for (k=0; k<4; k++) {
				if (LABEL_CHK[k]==true && indexOf(ALL_NAMES[i],LABEL[k])!=-1) {
					IM_NUMBER=IM_NUMBER+1;
				}
			}
		}
	}
	// Define an array for storing .tif names, extensions (usefull if extended to more than .tif), channels and shortname (name without channel info)
	IM_NAMES=newArray(IM_NUMBER);
	IM_EXT=newArray(IM_NUMBER);
	IM_CH=newArray(IM_NUMBER);
	IM_SHORT=newArray(IM_NUMBER);
	
	// Test all files for extension and channel and eventually store their names, extension and channel in the reference arrays : NAMES, EXT for extensions, SHORT for short name
	j=0;
	for (i=0; i<ALL_EXT.length; i++) {
		if (ALL_EXT[i]==".tif") {		
			for (k=0; k<4; k++) {
				if (LABEL_CHK[k]==true && indexOf(ALL_NAMES[i],LABEL[k])!=-1) {
					IM_NAMES[j]=ALL_NAMES[i];
					IM_CH[j]=LABEL[k];
					IM_EXT[j]=ALL_EXT[i];
					start=indexOf(IM_NAMES[j],IM_CH[j]);
					stop=start+lengthOf(IM_CH[j]);
					IM_SHORT[j]=substring(IM_NAMES[j],0,start)+substring(IM_NAMES[j],stop,lengthOf(IM_NAMES[j]));		
					j=j+1;
				}
			}
		}
	}
	
	// Print arrays for verifications
	IM_NAMES_STRING="[";
	IM_EXT_STRING="[";
	IM_CH_STRING="[";
	IM_SHORT_STRING="[";
	for (j=0; j<IM_NUMBER; j++) {	
		IM_NAMES_STRING=IM_NAMES_STRING+"  "+IM_NAMES[j];
		IM_EXT_STRING=IM_EXT_STRING+"  "+IM_EXT[j];
		IM_CH_STRING=IM_CH_STRING+"  "+IM_CH[j];
		IM_SHORT_STRING=IM_SHORT_STRING+"  "+IM_SHORT[j];
	}
	IM_NAMES_STRING=IM_NAMES_STRING+" ]";
	IM_EXT_STRING=IM_EXT_STRING+" ]";
	IM_CH_STRING=IM_CH_STRING+" ]";
	IM_SHORT_STRING=IM_SHORT_STRING+" ]";
	print("IM_NAMES="+IM_NAMES_STRING);
	print("IM_EXT="+IM_EXT_STRING);
	print("IM_CH="+IM_CH_STRING);
	print("IM_SHORT="+IM_SHORT_STRING);
	
	
	
	// Generate a permutation array of length IM_NUMBER
	// for the permutation generation method see http://www2.toki.or.id/book/AlgDesignManual/BOOK/BOOK4/NODE151.HTM
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

	// Associate sequentially permuted positions to images names
	IM_PERM_NAMES=newArray(IM_NUMBER);
	for(j=0; j<IM_NUMBER; j++){
		IM_PERM_NAMES[j]="shuf_"+IM_PERM[j]+"_"+IM_CH[j]+IM_EXT[j];
		// this additional loop propagates the permuted position to all images that are a different channel of the same acquisition: as a consequence, all permuted positions will not be present in the shuffled images names
		for (j2=0; j2<IM_NUMBER; j2++) {
			if (IM_SHORT[j2]==IM_SHORT[j]) {
				// Generate the shuffled image name, using the pad() function (see at the bottom)
				IM_PERM_NAMES[j2]="shuf_"+pad(IM_PERM[j],3,0)+"_"+IM_CH[j2]+IM_EXT[j2];
			}
		}
	}
	
	// Print arrays for verifications
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
	
	// Open each images (loop on IM_NAMES) and save them in the destination folder as the original file (IM_NAME) and as the shuffled file (IM_PERM_NAME). Additionnally logs both names in the log.txt file created in the destination folder
	setBatchMode(true);
	f=File.open(OUTPUT_DIR+"log.txt");
	print(f, "Shuffler log");
	for(j=0; j<IM_NUMBER; j++){
		INPUT_PATH=DIR_PATH+IM_NAMES[j];
		OUTPUT_PATH=OUTPUT_DIR+IM_NAMES[j];
		OUTPUT_PATH_PERM=OUTPUT_DIR+IM_PERM_NAMES[j];
		open(INPUT_PATH);
		save(OUTPUT_PATH);
		save(OUTPUT_PATH_PERM);
		print(f,IM_NAMES[j]+"\t"+IM_PERM_NAMES[j]);
		close();
	}
	setBatchMode("exit and display");
	showStatus("finished");
	
}

// This function generates a padded number, ie 34 cbecomes 00034 by pad(34,5,0): number is the number to pad (here 34), width is the final length of the padded number (here 5), character is the character added to the left (here 0)
function pad(number, width, character) {
       number = toString(number); // force string
       character = toString(character);
       for (len = lengthOf(number); len < width; len++)
               number = character + number;
       return number;
}