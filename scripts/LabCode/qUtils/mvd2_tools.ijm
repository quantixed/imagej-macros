/*
 * Macros to work with mvd2 libraries from Perkin Elmer Ultraview Spinning Disk microscope
 * 1. open all image series in an mvd2 library and save as OME-TIFF in the same or different directory
 * 2. list all images in the library
 */

macro "mvd2 Save All As Tiff" {
	run("Bio-Formats Macro Extensions");
	id = File.openDialog("Choose a file");
	Ext.setId(id);
	Ext.getSeriesCount(seriesCount);
	destdir = getDirectory("Choose Destination Directory ");
	setBatchMode(true);
	
	for (s=0; s<seriesCount; s++) {  
		run("Bio-Formats Importer",
			"open=[" + id + "] " +
			"autoscale " +
			"color_mode=Grayscale " +
			"rois_import=[ROI manager] " +
			"view=Hyperstack " +
			"stack_order=XYCZT " +
			"series_" + (s+1));
		str = getTitle();
//		save(File.getParent(id) + "/" + str + "_series_" + s + ".tiff");
		save(destdir + str + "_series_" + s + ".tiff");
		close();
	}
	setBatchMode(false);
	Ext.close();
}

macro "mvd2 List All Images" {
	run("Bio-Formats Macro Extensions");
	id = File.openDialog("Choose a file");
	Ext.setId(id);
	Ext.getSeriesCount(seriesCount);
	setBatchMode(true);
	
	for (s=0; s<seriesCount; s++) { 
		Ext.setSeries(s);
		Ext.getSeriesName(seriesName);
		print(seriesName);
	}
	setBatchMode(false);
	Ext.close();
}
