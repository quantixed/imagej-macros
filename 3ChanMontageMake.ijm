/*
 This script will take a 3 channel RGB TIFF (1 slice) and make a 4 panel
 montage. Red, Green, Blue and Merge (L-R) with an 8 pixel border, trimmed to
 edges.
 */

//Before running, open the image and have no other images open
dir1 = getDirectory("image");
win = getTitle();
merge = dir1+win
newName = "montage" + win
getDimensions(w, h, c, nFrames, dummy);
run("Split Channels");
open(merge);
run("Images to Stack", "name=4ch title=[] use");
//Make montage didn't work properly (cropped panels)
//run("Make Montage...", "columns=4 rows=1 scale=1 first=1 last=4 increment=1 border=8 font=12");
//trim border
//makeRectangle(8, 8, ((w*4)+8*3), h);
//run("Crop");
newImage(newName, "RGB", ((w*4)+8*3), h, 1);
//1st panel - red
selectImage("4ch");
setSlice(1);
run("Copy");
selectImage(newName);
makeRectangle(0, 0, 600, 600);
run("Paste");
//2nd panel - green
selectImage("4ch");
setSlice(2);
run("Copy");
selectImage(newName);
makeRectangle(608, 0, 600, 600);
run("Paste");
//3rd panel - blue
selectImage("4ch");
setSlice(3);
run("Copy");
selectImage(newName);
makeRectangle(1216, 0, 600, 600);
run("Paste");
//4th panel - Merge
selectImage("4ch");
setSlice(4);
run("Copy");
selectImage(newName);
makeRectangle(1824, 0, 600, 600);
run("Paste");
//save montage
saveAs("TIFF", dir1+newName);
close();
//close tempstack "4ch"
selectWindow("4ch");
close();
