/*
 * Convert a folder and subfolders into TIFF.
 * Designed for nd2 files but will likely work with other formats.
 * Preserves metadata and has the option to convert to 8-bit.
 * Multipoint (nd2 series) will be converted into separated TIFFs
 */

#@ File (label = "Input directory", style = "directory") in
#@ File (label = "Output directory", style = "directory") out
#@ String (label = "File suffix", value = ".nd2") suffix
#@ Boolean (label = "8-bit conversion?", value = false) bit
#@ Boolean (label = "Series (Multipoint files)?", value = false) mp

// script starts here
setBatchMode(true);
inputlocal = in;
processFolder(inputlocal);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	input = correctDirEnding(input);
	output = correctDirEnding(out);
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// open file with bio-formats
	path = input + file;
	if (mp) {
		s = "open=[" + path + "] open_all_series";
	} else {
		s = "open=[" + path + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
	}
	run("Bio-Formats Importer", s);

	// input maybe the parent directory or a subdirectory
	// destination may not have the necessary subdirectories
	outpath = replace(input, correctDirEnding(in), output);
	if(!File.exists(outpath)) File.makeDirectory(outpath);

	if (mp) {
		while (nImages > 0) {
			if(bit) run("8-bit");
			name = getTitle();
			// it is possible to have a / in the window name which will cause problems
			name = replace(name, "/", "_");
			save(outpath + File.separator + name + ".tif");
			close();
		}
	} else {
		filename = File.getNameWithoutExtension(path);
		if(bit) run("8-bit");

		save(outpath + filename + ".tif");
		close();
	}
}