macro "nd2 Save As Tiff" {
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");
	list = getFileList(dir1);

	// Make an array of nd2 files only
	nd2list = newArray(0);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], ".nd2")) {
			nd2list = append(nd2list, list[i]);
		}
	}

	setBatchMode(true);
	for (i=0; i<nd2list.length; i++) {
	    showProgress(i+1, nd2list.length);
	    s = "open=["+dir1+nd2list[i]+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
	    run("Bio-Formats Importer", s);
	    saveAs("tiff", dir2+replace(nd2list[i],".nd2",".tif"));
		close();
	}
	setBatchMode(false);
}

function append(arr, value) {
	arr2 = newArray(arr.length+1);
	for (i=0; i<arr.length; i++)
		arr2[i] = arr[i];
		arr2[arr.length] = value;
	return arr2;
}
