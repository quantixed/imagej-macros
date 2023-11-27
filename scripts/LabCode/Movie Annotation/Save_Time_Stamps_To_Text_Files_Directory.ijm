/*
 * A wrapper to process all files in a directory (subdirectories are not included) and
 * extract the timing information from each file. The output is a text file with the
 * timing information for each image in each series. The output file is saved in the
 * output directory with the same name as the input file but with a "_deltaT.txt"
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(!File.isDirectory(input + File.separator + list[i]) & endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	run("Bio-Formats Macro Extensions");
	id = input + File.separator + file;
	Ext.setId(id);
	// get number of series and total images in each series
	Ext.getSeriesCount(seriesCount);
	Ext.getImageCount(imageCount);
	// find total number of timings
	totalCount = seriesCount * imageCount;
	
	// make a text file
	filename = File.getNameWithoutExtension(file);
	f = File.open(output+File.separator+filename+"_deltaT.txt");
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