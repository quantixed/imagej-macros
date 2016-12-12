setBatchMode(true);
imgArray = newArray(nImages);
dir1 = getDirectory("Choose Destination Directory ");
for (i=0; i<nImages; i++) {
    selectImage(i+1);
    imgArray[i] = getImageID();
    }
for (i=0; i< imgArray.length; i++) {
    selectImage(imgArray[i]);
    id = getImageID();
    win = getTitle();
    run("Rotate 90 Degrees Left");
    saveAs("TIFF", dir1+win);
    close();
    }
