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


// -- add batch Flexible Montage Maker? Difficult to do because of channel choice
// -- add a thing to make a series of images

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

function rgb2Montage(vChoice)	{
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
	//
	setBatchMode(true);
	//
	dir1 = getDirectory("image");
	win = getTitle();
	merge = dir1+win;
	newName = "mtg" + choice + win;
	getDimensions(w, h, c, nFrames, dummy);
	// rotate left?
	if (vChoice == "vert")
		run("Rotate 90 Degrees Left");
	run("Split Channels");
	open(merge);
	// rotate that left too?
	if (vChoice == "vert")
		run("Rotate 90 Degrees Left");
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
	// now put back?
	if (vChoice == "vert")
		run("Rotate 90 Degrees Right");
	//add scale bar (height is same as grout)
	if (sbchoice==true)	{
		getDimensions(w, h, c, nFrames, dummy);
		setColor(255,255,255);
		fillRect(w-(grout+(sblen/mag)), h-(2*grout), sblen/mag, grout);
	}
	//specify dpi default is 300 dpi
	run("Set Scale...", "distance="+res+" known=1 unit=inch");
	//save montage
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
}

function montageFrom16Bit(vChoice)	{
	// rotate left?
	if (vChoice == "vert")
		run("Rotate 90 Degrees Left");
	dir1 = getDirectory("image");
	// check how many slices/channels
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels * slices * frames == 1) exit ("Need more than one channel or slice or frame");
	run("Stack to Images");
	imgArray = newArray(nImages);
	colArray = newArray(nImages);
	mArray = newArray(nImages + 1);
	mArray[0] = "*None*";
	for (i=0; i<nImages; i++)	{
		selectImage(i+1);
		imgArray[i] = getImageID();
		title = getTitle();
		colArray[i] = title;
		mArray[i+1] = title;
	}
	// give the option of making up to 2 merges
	Dialog.create("Montage Choice"); 
	Dialog.addMessage("How many grayscale panels?");
	Dialog.addChoice("I'd like...", newArray("1","2","3","4"));
	Dialog.addMessage("How many merge panels?");
	Dialog.addChoice("I'd like...", newArray("0","1","2"));
	Dialog.show();
	gPanels = Dialog.getChoice();
	mPanels = Dialog.getChoice();
	gVar = parseInt(gPanels);
	mVar = parseInt(mPanels);
	// Make arrays to hold image choices
	gNameArray = newArray(gVar);
	if (mVar == 1) {
		m1NameArray = newArray(3);
	}
	else if (mVar == 2) {
		m1NameArray = newArray(3);
		m2NameArray = newArray(3);
	}
	
	// Next dialog
	grout=8;
	Dialog.create("Pick your panels"); 
	Dialog.addMessage("Select order for grayscale");
	// variations based on number of files
	if (gVar==1)	{
		Dialog.addChoice("Gray Panel 1", colArray);
	}
	else if (gVar==2)	{
		Dialog.addChoice("Gray Panel 1", colArray);
		Dialog.addChoice("Gray Panel 2", colArray);
	}
	else if (gVar==3)	{
		Dialog.addChoice("Gray Panel 1", colArray);
		Dialog.addChoice("Gray Panel 2", colArray);
		Dialog.addChoice("Gray Panel 3", colArray);
	}
	else if (gVar==4)	{
		Dialog.addChoice("Gray Panel 1", colArray);
		Dialog.addChoice("Gray Panel 2", colArray);
		Dialog.addChoice("Gray Panel 3", colArray);
		Dialog.addChoice("Gray Panel 4", colArray);
	}
	// variations based on merges
	if (mVar==0)	{
	}
	else if (mVar==1)	{
		Dialog.addMessage("Select channels for merge");
		Dialog.addChoice("Red", mArray);
		Dialog.addChoice("Green", mArray);
		Dialog.addChoice("Blue", mArray);
	}
	else if (mVar==2)	{
		Dialog.addMessage("Select channels for 1st merge");
		Dialog.addChoice("Red", mArray);
		Dialog.addChoice("Green", mArray);
		Dialog.addChoice("Blue", mArray);
		Dialog.addMessage("Select channels for 2nd merge");
		Dialog.addChoice("Red", mArray);
		Dialog.addChoice("Green", mArray);
		Dialog.addChoice("Blue", mArray);
	}
	Dialog.addNumber("Grout size (pixels):", 8);
	Dialog.addNumber("d.p.i.", 300);
	Dialog.addCheckbox("Scale bar?", false);
	Dialog.addNumber("Scale bar size (µm):", 10);
	Dialog.addNumber("1 px is how many µm?", 0.069);
	Dialog.show();
	// variations based on channels
	if (gVar==1)	{
		gNameArray[0] = Dialog.getChoice();
	}
	else if (gVar==2)	{
		gNameArray[0] = Dialog.getChoice();
		gNameArray[1] = Dialog.getChoice();
	}
	else if (gVar==3)	{
		gNameArray[0] = Dialog.getChoice();
		gNameArray[1] = Dialog.getChoice();
		gNameArray[2] = Dialog.getChoice();
	}
	else if (gVar==4)	{
		gNameArray[0] = Dialog.getChoice();
		gNameArray[1] = Dialog.getChoice();
		gNameArray[2] = Dialog.getChoice();
		gNameArray[3] = Dialog.getChoice();
	}
	// variations based on merges
	if (mVar==0)	{
	}
	else if (mVar==1)	{
		m1NameArray[0] = Dialog.getChoice();
		m1NameArray[1] = Dialog.getChoice();
		m1NameArray[2] = Dialog.getChoice();
	}
	else if (mVar==2)	{
		m1NameArray[0] = Dialog.getChoice();
		m1NameArray[1] = Dialog.getChoice();
		m1NameArray[2] = Dialog.getChoice();
		m2NameArray[0] = Dialog.getChoice();
		m2NameArray[1] = Dialog.getChoice();
		m2NameArray[2] = Dialog.getChoice();
	}
	grout = Dialog.getNumber();
	res = Dialog.getNumber();
	sbchoice = Dialog.getCheckbox();
	sblen = Dialog.getNumber();
	mag = Dialog.getNumber();
	// decisions collected
	setBatchMode(true);
	
	// collect details from images
	win = getTitle(); // could change this so that name is something more logical
	newName = "mtg" + win;
	len = gVar + mVar;
	newImage(newName, "RGB", ((width*len)+(grout*(len-1))), height, 1);

	// paste in grayscales
	for (i = 0; i < gVar; i++)   {
		wName = gNameArray[i];
		selectImage(wName);
		run("Copy");
		selectImage(newName);
		makeRectangle((width*i)+(grout*i), 0, width, height);
		run("Paste");
	}

	// make array to hold merge names
	mImgArray = newArray("merge1","merge2");

	// paste in merges
	for (i = 0; i < mVar; i++)   {
		if (i == 0) {
			mergeString = "c1=[" + m1NameArray[0] + "] c2=[" + m1NameArray[1] + "] c3=[" + m1NameArray[2] + "] keep";
			// print(mergestring);
			run("Merge Channels...", mergeString);
			rename("merge1");
		}
		else {
			mergeString = "c1=[" + m2NameArray[0] + "] c2=[" + m2NameArray[1] + "] c3=[" + m2NameArray[2] + "] keep";
			run("Merge Channels...", mergeString);  
			rename("merge2");
		}
		selectImage(mImgArray[i]);
		run("Copy");
		selectImage(newName);
		makeRectangle(((width*gVar)+(grout*gVar-1))+((width*i)+(grout*i)), 0, width, height);
		run("Paste");
	}
	
	selectImage(newName);
		// rotate right?
	if (vChoice == "vert")
		run("Rotate 90 Degrees Right");
	
	//add scale bar (height is same as grout)
	if (sbchoice==true)	{
		getDimensions(w, h, c, nFrames, dummy);
		setColor(255,255,255);
		fillRect(w-(grout+(sblen/mag)), h-(2*grout), sblen/mag, grout);
	}
	//specify dpi default is 300 dpi
	run("Set Scale...", "distance=res known=1 unit=inch");
	run("Select None");

	//save montage
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
	// close originals
	for (i=0; i<imgArray.length; i++)	{
		selectImage(imgArray[i]);
		close();
	}
}
