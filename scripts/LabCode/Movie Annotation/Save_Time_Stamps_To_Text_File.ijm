/* 
 * This macro was originally contributed by Meghane Sittewelle
 * Allows user to save text file of time stamps for use in the main macro
 * 230714 - macro now works with files with multiple series
 * This change means that there is now a header in the text file to sepcify
 * Series, Z, C, T (all 0-index) and time (in units not specified).
 * To use the timestamps in the main macro a single column of times is required
 */

macro Save_Time_Stamps_To_Text_File	{
	run("Bio-Formats Macro Extensions");
	id = File.openDialog("Choose a file");
	Ext.setId(id);
	// get number of series and total images in each series
	Ext.getSeriesCount(seriesCount);
	Ext.getImageCount(imageCount);
	// find total number of timings
	totalCount = seriesCount * imageCount;
	
	// make a text file
	dirsave = File.getDirectory(id);
	filename = File.getNameWithoutExtension(id);
	f = File.open(dirsave+File.separator+filename+"_deltaT.txt");
	print(f, "series" + "," + "z" + "," + "c" + "," + "t" + "," + "deltaT" + "\n");
	
	for (so = 0; so < seriesCount; so ++) {
		if(seriesCount > 1) {
			Ext.setSeries(so);
		}
		for (no = 0; no < imageCount; no ++) {
			Ext.getZCTCoords(no, z, c, t);
			Ext.getPlaneTimingDeltaT(deltaT, no);
			print(f, so + "," + z + "," + c + "," + t + "," + deltaT + "\n");
		}
	}

	File.close(f);
}
