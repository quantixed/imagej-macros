// this macro was contributed by Meghane Sittewelle
// allows user to save text file of time stamps for use in the main macro

macro Save_Time_Stamps_To_Text_File	{
	run("Bio-Formats Macro Extensions");
	id = File.openDialog("Choose a file");
	Ext.setId(id);
	Ext.getImageCount(imageCount);
	deltaT = newArray(imageCount);
	// make a text file
	dirsave = File.getDirectory(id);
	filename = File.getNameWithoutExtension(id);
	f = File.open(dirsave+File.separator+filename+"_deltaT.txt");

	for (no = 0; no < imageCount; no ++) {
		Ext.getPlaneTimingDeltaT(deltaT[no], no);
		print(f, deltaT[no] + "\n");
	}

	File.close(f);
}
