/*
 The aim is to make montages the way we like them.
 Grayscale single channels with a merge on the right.
 
 If you have a 3 channel RGB TIFF (1 slice), you can make a 3 or 4 panel
 montage with "Simple Montage (RGB)". Specify order of grayscale channels, merge is on right.
 Also specify grouting for the montage. There's no outside border, but there is an option to add a scale bar.
 
 Use "Flexible Montage Maker" for images with >3 channels or >3 frames (it works for RGB too).
 You can add up to four grayscale channel panels and up to two merges that you specify.
 As for simple montage, you can specify the grout and scale bar.

 There are now vertical options for these two montage makers.

 Batch processing of a directory TIFFs is possible for Simple Montage (RGB).
*/


macro "Multi-purpose Montage Maker"	{
	// this will take a guess at what you want to do
	if (nImages > 0) exit ("Please close all open images");
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() == 24)
		rgb2Montage("");
	else if (bitDepth() == 8 || bitDepth() == 16)
		montageFrom16Bit("");
}

macro "Simple Montage (RGB)" {
	if (nImages > 0) exit ("Please close all open images");
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() != 24) exit ("RGB image required.");
		rgb2Montage("");
}

macro "Flexible Montage Maker" {
	if (nImages > 0) exit ("Please close all open images");
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() == 8 || bitDepth() == 16)
		montageFrom16Bit("");
	else if (bitDepth() == 24)	{
		// this won't work if someone feeds a stack of RGB images
		run("Split Channels");
		run("Images to Stack");
		montageFrom16Bit("");
	}
}

macro "Simple Montage on Directory"	{
	if (nImages > 0) exit ("Please close all open images");
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");
	list = getFileList(dir1);

	tiffnum = 0;
	// How many TIFFs do we have? Directory could contain other directories.
	for (i=0; i<list.length; i++) {		
 		if (indexOf(toLowerCase(list[i]), ".tif")>0) {	
 			tiffnum=tiffnum+1;		
 		}
 	}
 	tifflist = newArray(tiffnum);
	mtglist = newArray(tiffnum);
	j = 0;
	for (i=0; i<list.length; i++) {
		if (indexOf(toLowerCase(list[i]), ".tif")>0) {
			tifflist[j] = list[i];
			mtgname = "mtg_" + list[i];
			mtglist[j] = mtgname;
			j=j+1;
		}
	}
	// there is no check that all images are RGB, square etc.
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
	Dialog.addCheckbox("Scale bar?", false);
	Dialog.addNumber("Scale bar size (µm):", 10);
	Dialog.addNumber("1 px is how many µm?", 0.069);
	Dialog.show();
	choice = Dialog.getChoice();
	grout = Dialog.getNumber();
	res = Dialog.getNumber();
	sbchoice = Dialog.getCheckbox();
	sblen = Dialog.getNumber();
	mag = Dialog.getNumber();

	//convert choice to numeric (frame number)
	str1=replace(choice,"R","1");
	str2=replace(str1,"G","2");
	str3=replace(str2,"B","3");
	str4=replace(str3,"M","4");

	setBatchMode(true);

	for (i=0; i<tifflist.length; i++)	{
		input = dir1 + tifflist[i];
		output = dir2 + mtglist[i];
		open(input);
		// as before
		getDimensions(w, h, c, nFrames, dummy);
		run("Split Channels");
		open(input);
		run("Images to Stack", "name=stk title=[] use");
		len=lengthOf(choice);
		newImage(mtglist[i], "RGB", ((w*len)+(grout*(len-1))), h, 1);
		for (j=0; j<len; j++)   {
			ch=substring(str4, j, j+1);
			selectImage("stk");
			setSlice(ch);
			run("Copy");
			selectImage(mtglist[i]);
			makeRectangle((w*j)+(grout*j), 0, w, h);
			run("Paste");
		}
		selectImage("stk");
		close();
		selectImage(mtglist[i]);
		//add scale bar (height is same as grout)
		if (sbchoice==true)	{
			getDimensions(w, h, c, nFrames, dummy);
			setColor(255,255,255);
			fillRect(w-(grout+(sblen/mag)), h-(2*grout), sblen/mag, grout);
		}
		//specify dpi default is 300 dpi
		run("Set Scale...", "distance="+res+" known=1 unit=inch");
		//save montage
		save(output);
		close();
	}
	setBatchMode(false);
}

macro "Simple Vertical Montage (RGB)" {
	if (nImages > 0) exit ("Please close all open images");
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() != 24) exit ("RGB image required.");
		rgb2Montage("vert");
}

macro "Flexible Vertical Montage Maker" {
	if (nImages > 0) exit ("Please close all open images");
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() == 8 || bitDepth() == 16)
		montageFrom16Bit("vert");
	else if (bitDepth() == 24)	{
		// this won't work if someone feeds a stack of RGB images
		run("Split Channels");
		run("Images to Stack");
		montageFrom16Bit("vert");
	}
}

