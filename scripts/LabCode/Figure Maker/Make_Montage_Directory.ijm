/*
 The aim is to make montages the way we like them.
 Horizontal - grayscale single channels with merge(s) on the right
 Vertical - grayscale single channels with merge(s) on the bottom

 The code got a spring clean in Feb 2020 which allows more channels for the grayscale
 and other colours in the merge(s).

 Notes:
 1. row or column montages are generated (user decides)
 2. Input can be 8-bit, 16-bit stacks/composites or single slice RGB Images
 3. Specify the grouting of the montage (white space between panels)
 4. There's no outside border, and there is an option to add a scale bar (scaling taken from image)
 5. The idea is to compile them afterwards using Montage Compiler

 This is to batch process a directory TIFFs.
*/


macro "Make Montages Directory" {
	if (nImages > 0) exit ("Please close all open images");
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");
	list = getFileList(dir1);

	tiffnum = 0;
	// How many TIFFs do we have? Directory could contain other directories.
	for (i = 0; i < list.length; i ++) {
		if (indexOf(toLowerCase(list[i]), ".tif")>0)
			tiffnum = tiffnum + 1;
	}
 	tifflist = newArray(tiffnum);
	mtglist = newArray(tiffnum);
	j = 0;
	for (i = 0; i < list.length; i ++) {
		if (indexOf(toLowerCase(list[i]), ".tif")>0) {
			tifflist[j] = list[i];
			mtglist[j] = "mtg_" + safeName(list[i]) + ".tif";
			j = j + 1;
		}
	}
	// make the choice of what we will do
	Dialog.create("Montage Choice");
	Dialog.addMessage("How many grayscale panels?");
	Dialog.addChoice("I'd like...", newArray("1","2","3","4","5","6","7"));
	Dialog.addMessage("How many merge panels?");
	Dialog.addChoice("I'd like...", newArray("0","1","2"));
	Dialog.addCheckbox("Vertical montage?", false);
	Dialog.show();
	gPanels = Dialog.getChoice();
	mPanels = Dialog.getChoice();
	vChoice = Dialog.getCheckbox();

	// Image choices
	gVar = parseInt(gPanels);
	mVar = parseInt(mPanels);
	// Make arrays to hold image choices
	gNameArray = newArray(gVar);
	if (mVar == 1) {
		m1NameArray = newArray(7);
	}
	else if (mVar == 2) {
		m1NameArray = newArray(7);
		m2NameArray = newArray(7);
	}

	// for colArray and mArray we don't know what we have but we have 7 channel max
	colArray = newArray("C1","C2","C3","C4","C5","C6","C7");
	mArray = newArray("*None*","C1","C2","C3","C4","C5","C6","C7");

	//Next dialog
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
	else if (gVar==5)	{
		Dialog.addChoice("Gray Panel 1", colArray);
		Dialog.addChoice("Gray Panel 2", colArray);
		Dialog.addChoice("Gray Panel 3", colArray);
		Dialog.addChoice("Gray Panel 4", colArray);
		Dialog.addChoice("Gray Panel 5", colArray);
	}
	else if (gVar==6)	{
		Dialog.addChoice("Gray Panel 1", colArray);
		Dialog.addChoice("Gray Panel 2", colArray);
		Dialog.addChoice("Gray Panel 3", colArray);
		Dialog.addChoice("Gray Panel 4", colArray);
		Dialog.addChoice("Gray Panel 5", colArray);
		Dialog.addChoice("Gray Panel 6", colArray);
	}
	else if (gVar==7)	{
		Dialog.addChoice("Gray Panel 1", colArray);
		Dialog.addChoice("Gray Panel 2", colArray);
		Dialog.addChoice("Gray Panel 3", colArray);
		Dialog.addChoice("Gray Panel 4", colArray);
		Dialog.addChoice("Gray Panel 5", colArray);
		Dialog.addChoice("Gray Panel 6", colArray);
		Dialog.addChoice("Gray Panel 7", colArray);
	}
	// variations based on merges
	if (mVar==0)	{
	}
	else if (mVar==1)	{
		Dialog.addMessage("Select channels for merge");
		Dialog.addChoice("Red", mArray);
		Dialog.addChoice("Green", mArray);
		Dialog.addChoice("Blue", mArray);
		Dialog.addChoice("Gray", mArray);
		Dialog.addChoice("Cyan", mArray);
		Dialog.addChoice("Magenta", mArray);
		Dialog.addChoice("Yellow", mArray);
	}
	else if (mVar==2)	{
		Dialog.addMessage("Select channels for 1st merge");
		Dialog.addChoice("Red", mArray);
		Dialog.addChoice("Green", mArray);
		Dialog.addChoice("Blue", mArray);
		Dialog.addChoice("Gray", mArray);
		Dialog.addChoice("Cyan", mArray);
		Dialog.addChoice("Magenta", mArray);
		Dialog.addChoice("Yellow", mArray);
		Dialog.addMessage("Select channels for 2nd merge");
		Dialog.addChoice("Red", mArray);
		Dialog.addChoice("Green", mArray);
		Dialog.addChoice("Blue", mArray);
		Dialog.addChoice("Gray", mArray);
		Dialog.addChoice("Cyan", mArray);
		Dialog.addChoice("Magenta", mArray);
		Dialog.addChoice("Yellow", mArray);
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
	else if (gVar==5)	{
		gNameArray[0] = Dialog.getChoice();
		gNameArray[1] = Dialog.getChoice();
		gNameArray[2] = Dialog.getChoice();
		gNameArray[3] = Dialog.getChoice();
		gNameArray[4] = Dialog.getChoice();
	}
	else if (gVar==6)	{
		gNameArray[0] = Dialog.getChoice();
		gNameArray[1] = Dialog.getChoice();
		gNameArray[2] = Dialog.getChoice();
		gNameArray[3] = Dialog.getChoice();
		gNameArray[4] = Dialog.getChoice();
		gNameArray[5] = Dialog.getChoice();
	}
	else if (gVar==7)	{
		gNameArray[0] = Dialog.getChoice();
		gNameArray[1] = Dialog.getChoice();
		gNameArray[2] = Dialog.getChoice();
		gNameArray[3] = Dialog.getChoice();
		gNameArray[4] = Dialog.getChoice();
		gNameArray[5] = Dialog.getChoice();
		gNameArray[6] = Dialog.getChoice();
	}
	// variations based on merges
	if (mVar==0)	{
	}
	else if (mVar==1)	{
		m1NameArray[0] = Dialog.getChoice();
		m1NameArray[1] = Dialog.getChoice();
		m1NameArray[2] = Dialog.getChoice();
		m1NameArray[3] = Dialog.getChoice();
		m1NameArray[4] = Dialog.getChoice();
		m1NameArray[5] = Dialog.getChoice();
		m1NameArray[6] = Dialog.getChoice();
	}
	else if (mVar==2)	{
		m1NameArray[0] = Dialog.getChoice();
		m1NameArray[1] = Dialog.getChoice();
		m1NameArray[2] = Dialog.getChoice();
		m1NameArray[3] = Dialog.getChoice();
		m1NameArray[4] = Dialog.getChoice();
		m1NameArray[5] = Dialog.getChoice();
		m1NameArray[6] = Dialog.getChoice();
		m2NameArray[0] = Dialog.getChoice();
		m2NameArray[1] = Dialog.getChoice();
		m2NameArray[2] = Dialog.getChoice();
		m2NameArray[3] = Dialog.getChoice();
		m2NameArray[4] = Dialog.getChoice();
		m2NameArray[5] = Dialog.getChoice();
		m2NameArray[6] = Dialog.getChoice();
	}
	grout = Dialog.getNumber();
	res = Dialog.getNumber();
	sbchoice = Dialog.getCheckbox();
	sblen = Dialog.getNumber();
	mag = Dialog.getNumber();
	// decisions collected

	setBatchMode(true);
	for (i = 0; i < tifflist.length; i ++)	{
		input = dir1 + tifflist[i];
		output = dir2 + mtglist[i];
		open(input);
		win = getTitle();
		getDimensions(ww, hh, cc, ss, ff);
		okVar = checkImageForMontage(win);
		if (okVar == true) {
			newName = mtglist[i];
      // if vertical montage, rotate all images left
    	if (vChoice == true) run("Rotate 90 Degrees Left");
			// first we will split the stack and make an array of the correct order
			run("Stack to Images");
			theWinList = getListOfImages();
			gWinArray = convertChoicesToWindows(gNameArray,theWinList);
			if (mVar==0)	{
				m1WinArray = newArray(0);
				m2WinArray = newArray(0);
			}    else if (mVar==1)	{
				m1WinArray = convertChoicesToWindows(m1NameArray,theWinList);
				m2WinArray = newArray(0);
			}    else if (mVar==2)	{
				m1WinArray = convertChoicesToWindows(m1NameArray,theWinList);
				m2WinArray = convertChoicesToWindows(m2NameArray,theWinList);
			}
			generateMontage(newName, vChoice, gVar, mVar, ww, hh, grout, res, sbchoice, sblen, mag, gWinArray, m1WinArray, m2WinArray);
			// save montage
			save(output);
			run("Close All");
		}
	}
	setBatchMode(false);
}
