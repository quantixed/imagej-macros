/*
 The aim is to make montages the way we like them.
 Horizontal - grayscale single channels with merge(s) on the right
 Vertical - grayscale single channels with merge(s) on the bottom

 If you have a 3 channel RGB TIFF (1 slice), you can make a 3 or 4 panel
 simple montage with "Montage Horizontal RGB". Specify the order of grayscale channels, merge is on right.
 Also specify grouting for the montage. There's no outside border, but there is an option to add a scale bar.
 There is a vertical version called "Montage Vertical RGB"

 For more flexible montages you can use "Montage Horizontal Flexible" (or the vertical version)
 It should work for all images (>1 chnnel or slice) including a single frame RGB.
 You can arange grayscale channel panels and up to two merges that you specify.
 As for the simple montage, you can specify the grout and scale bar.

 Batch processing of a directory TIFFs is possible for "Montage Horizontal RGB".
 In this case specify your first montage and the rest of the directory will be processed in the same way.
*/


macro "Montage Horizontal RGB on Directory"	{
	s=call("ij.macro.Interpreter.getAdditionalFunctions");
	while(startsWith(s,"//qFunctions")!=1) {
		qFpath = getDirectory("plugins")+"quantixed/Figure Maker/qFunctions.txt";
		functions = File.openAsString(qFpath);
		call("ij.macro.Interpreter.setAdditionalFunctions", functions);
		}
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
