/*
 * Compile montage images to make a figure.
 * User can choose to:
 * 1) array row montages vertically, or
 * 2) array column montages horizontally
 */

macro "Compile Row Montages"	{
	if (nImages < 2) exit ("2 or more images are required");
	compmtg("");
}

macro "Compile Column Montages"	{
	if (nImages < 2) exit ("2 or more images are required");
	compmtg("vert");
}

function compmtg(vChoice)	{
	// vChoice is vert if we will do horizontal array
	imgArray = newArray(nImages);
	rowArray = newArray(nImages);
	nameArray = newArray(nImages);
	print("\\Clear");
	for (i=0; i<nImages; i++)	{
		selectImage(i+1);
		imgArray[i] = getImageID();
		title = getTitle();
		rowArray[i] = title;
	}
	len = imgArray.length;
	
	// Standard sizes
	grout = 16;
	res = 300;
	sblen = 10;
	mag = 0.069;
	// Make dialog box
	Dialog.create("Compile Montages"); 
	// variations based on number of files
	if (vChoice == "vert")	{
		Dialog.addMessage("Select order for your compilation, left to right");
	}
	else {
		Dialog.addMessage("Select order for your compilation, top to bottom");
	}
	for (i = 0; i < len; i ++)	{
		labStr = d2s(i+1,0);
		Dialog.addChoice(labStr, rowArray);
	}
	Dialog.addNumber("Row gap (px, default = 2 x grout):", 16);
	Dialog.addNumber("d.p.i.", 300);
	Dialog.addCheckbox("Scale bar?", false);
	Dialog.addNumber("Scale bar size (µm):", 10);
	Dialog.addNumber("1 px is how many µm?", 0.069);
	Dialog.show();
	// variations based on number of files
	for (i = 0; i < len; i ++)	{
		nameArray[i] = Dialog.getChoice();
	}
	grout = Dialog.getNumber();
	res = Dialog.getNumber();
	sbchoice = Dialog.getCheckbox();
	sblen = Dialog.getNumber();
	mag = Dialog.getNumber();
	// decisions collected
	setBatchMode(true);
	
	// setup for save
	win = getTitle();
	dir1 = getDirectory("image");
	newName = "cmp" + len + win;
	
	// get dimensions
	wArray = newArray(len);
	hArray = newArray(len);
	hPosArray = newArray(len+1);
	hPosArray[0] = 0;
	height = 0;
	for (i=0; i<len; i++)   {
		selectImage(nameArray[i]);
		if (vChoice == "vert")
			run("Rotate 90 Degrees Right");
		getDimensions(w, h, c, nFrames, dummy);
		wArray[i] = w;
		hArray[i] = h;
		hPosArray[i+1] = hPosArray[i] + h;
		width = width + w;
		height = height + h;
	}
	// check widths are the same
	if (width / len != w)	{
		print("Check widths");
	}
	newImage(newName, "RGB", w,(height)+(grout*(len-1)), 1);
	for (i=0; i<len; i++)   {
		selectImage(nameArray[i]);
		run("Select All");
		run("Copy");
		close();
		selectImage(newName);
		makeRectangle(0, (hPosArray[i])+(grout*i), wArray[i], hArray[i]);
		run("Paste");
	}
	// now put back?
	if (vChoice == "vert")
		run("Rotate 90 Degrees Left");
	//add scale bar (height is same as grout)
	if (sbchoice==true)	{
		getDimensions(w, h, c, nFrames, dummy);
		setColor(255,255,255);
		fillRect(w-((grout/2)+(sblen/mag)), h-(2*(grout/2)), sblen/mag, grout/2);
	}
	//specify dpi default is 300 dpi
	run("Set Scale...", "distance=res known=1 unit=inch");
	run("Select None");
	//save montage
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
}