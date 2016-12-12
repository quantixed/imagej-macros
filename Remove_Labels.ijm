dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory ");
list = getFileList(dir1);
setBatchMode(true);
for (i=0; i<list.length; i++) {
    showProgress(i+1, list.length);
    open(dir1+list[i]);
    setMetadata("Label", "");
    saveAs("tiff", dir2+list[i]);
	close();
	}