/*
 This macro will take a 3 channel RGB TIFF (1 slice) and make a 3 or 4 panel
 montage. Specify order of grayscale channels, merge is on right.
 Also specify grouting for the montage. There's no outside border, but there is an option to add a scale bar
*/
macro "Multi-purpose Montage Maker"	{
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() == 24)
		rgb2Montage();
	else if (bitDepth() == 8 || bitDepth() == 16)
		montageFrom16Bit();
}

macro "Montage from RGB" {
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() != 24) exit ("RGB image required.");
		rgb2Montage();
}

macro "Montage from >4Ch" {
	// check for open files
	filepath=File.openDialog("Select a File"); 
	open(filepath);
	if (bitDepth() == 8 || bitDepth() == 16)
		montageFrom16Bit();
	else
		exit ("Use Montage from RGB instead.");
}

function rgb2Montage()	{
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
	//add scale bar (height is same as grout)
	if (sbchoice==true)	{
		getDimensions(w, h, c, nFrames, dummy);
		setColor(255,255,255);
		fillRect(w-(grout+(sblen/mag)), h-(2*grout), sblen/mag, grout);
	}
	//specify dpi default is 300 dpi
	run("Set Scale...", "distance=res known=1 unit=inch");
	//save montage
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
}

function montageFrom16Bit()	{
	
	// check how many slices/channels
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels == 1) exit ("Need more than one channel.");
	// perform more checks here

	
	imgArray = newArray(nImages);
	rowArray = newArray(nImages);
	for (i=0; i<nImages; i++)	{
		selectImage(i+1);
		imgArray[i] = getImageID();
		title = getTitle();
		rowArray[i] = title;
	}
	// give the option of making up to 2 merges
	Dialog.create("Montage Choice"); 
	Dialog.addMessage("How many grayscale panels?");
	Dialog.addChoice("I'd like...", newArray("1","2","3","4"));
	Dialog.addMessage("How many merge panels?");
	Dialog.addChoice("I'd like...", newArray("1","2"));
	Dialog.show();
	gPanels = Dialog.getChoice();
	mPanels = Dialog.getChoice();
	
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
	//add scale bar (height is same as grout)
	if (sbchoice==true)	{
		getDimensions(w, h, c, nFrames, dummy);
		setColor(255,255,255);
		fillRect(w-(grout+(sblen/mag)), h-(2*grout), sblen/mag, grout);
	}
	//specify dpi default is 300 dpi
	run("Set Scale...", "distance=res known=1 unit=inch");
	//save montage
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
}
