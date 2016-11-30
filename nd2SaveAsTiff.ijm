macro "nd2 Save As Tiff" {
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");
	list = getFileList(dir1);

	nd2num = 0;
	// How many nd2s do we have? Directory could contain other directories.
	for (i=0; i<list.length; i++) {		
 		if (indexOf(toLowerCase(list[i]), ".nd2")>0) {	
 			nd2num=nd2num+1;		
 		}
 	}
	nd2list = newArray(nd2num);
	j = 0;
	for (i=0; i<list.length; i++) {
		if (indexOf(toLowerCase(list[i]), ".nd2")>0) {
			nd2name = replace(list[i],".nd2",".tif");
			nd2list[j]=nd2name;
			j=j+1;
		}
	}
	setBatchMode(true);
	for (i=0; i<nd2list.length; i++) {
	    showProgress(i+1, list.length);
	    s = "open=["+dir1+list[i]+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
	    run("Bio-Formats Importer", s);
	    saveAs("tiff", dir2+list[i]);
		close();
	}
	setBatchMode(false);
}
