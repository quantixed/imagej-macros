/*
 This macro will take a 3 channel RGB TIFF (1 slice) and make a 3 or 4 panel
 montage. Specify order of grayscale channels, merge is on right.
 Also specify grouting for the montage. There's no outside border or scale bar.
*/
filepath=File.openDialog("Select a File"); 
open(filepath);
if (bitDepth() != 24) exit ("RGB image required.");
//
Dialog.create("Montage Choice"); 
Dialog.addMessage("How many panels?");
Dialog.addMessage("Four Panels (three channels + merge)");
Dialog.addMessage("Three Panels (two channels + merge)");
Dialog.addChoice("I'd like...", newArray("3", "4"));
Dialog.show();
panels = Dialog.getChoice();
//Next dialog
fourpanel = newArray("RGBM", "RBGM", "GRBM", "GBRM", "BGRM", "BRGM");
threepanel = newArray("RGM", "RBM", "GRM", "GBM", "BRM", "BGM");
grout=8;
Dialog.create("Panel Details");
Dialog.addMessage("What layout would you like?");
if (panels=="4")
	Dialog.addChoice("Four Panels (three channels + merge):", fourpanel);
else 
	Dialog.addChoice("Three Panels (two channels + merge):", threepanel);
Dialog.addNumber("Grout size (pixels):", 8);
Dialog.addNumber("d.p.i.", 300);
Dialog.show();
choice = Dialog.getChoice();
grout = Dialog.getNumber();
res = Dialog.getNumber();
//
dir1 = getDirectory("image");
win = getTitle();
merge = dir1+win;
newName = "mtg" + choice + win;
getDimensions(w, h, c, nFrames, dummy);
run("Split Channels");
open(merge);
run("Images to Stack", "name=stk title=[] use");
len=lengthOf(choice);
newImage(newName, "RGB", ((w*len)+(grout*(len-1))), h, 1);
//convert choice to numeric (frame number)
str1=replace(choice,"R","1");
str2=replace(str1,"G","2");
str3=replace(str2,"B","3");
str4=replace(str3,"M","4");
//
for (i=0; i<len; i++)   {
	ch=substring(str4, i, i+1);
	selectImage("stk");
	setSlice(ch);
	run("Copy");
	selectImage(newName);
	makeRectangle((w*i)+(grout*i), 0, w, h);
	run("Paste");
}
//specify dpi default is 300 dpi
run("Set Scale...", "distance=res known=1 unit=inch");
//save montage
saveAs("TIFF", dir1+newName);
close();
//close tempstack "stk"
selectWindow("stk");
close();
