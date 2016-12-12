/*
 * The idea is to compile montage images to make a figure
 */

macro "Compile Montages"	{
	if (nImages < 2)	{
		print("2 or more images are required");
		return;
	}
	else if (nImages >4)	{
		print("I can only compile 4 images in this version");
		return;
	}
	imgArray = newArray(nImages);
	rowArray = newArray(nImages);
	nameArray = newArray(nImages);
	print("\\Clear");
	for (i=0; i<nImages; i++)	{
		selectImage(i+1);
		imgArray[i] = getImageID();
		title = getTitle();
		rowArray[i] = title;
	    print((i+1) + " : " + title);
	}
	
	if (isOpen("Log")) { 
	    selectWindow("Log"); 
	    setLocation(10, 50); 
	} 
	// Standard sizes
	grout = 16;
	res = 300;
	sblen = 10;
	mag = 0.069;
	// Make dialog box
	Dialog.create("Compile Montages"); 
	Dialog.addMessage("Select order for your compilation");
	// variations based on number of files
	if (imgArray.length==2)	{
		Dialog.addChoice("Top", rowArray);
		Dialog.addChoice("Bottom", rowArray);
	}
	else if (imgArray.length==3)	{
		Dialog.addChoice("Top", rowArray);
		Dialog.addChoice("Middle", rowArray);
		Dialog.addChoice("Bottom", rowArray);
	}
	else if (imgArray.length==4)	{
		Dialog.addChoice("Top", rowArray);
		Dialog.addChoice("Upper Mid", rowArray);
		Dialog.addChoice("Lower Mid", rowArray);
		Dialog.addChoice("Bottom", rowArray);
	}
	Dialog.addNumber("Row gap (px, default = 2 x grout):", 16);
	Dialog.addNumber("d.p.i.", 300);
	Dialog.addCheckbox("Scale bar?", false);
	Dialog.addNumber("Scale bar size (µm):", 10);
	Dialog.addNumber("1 px is how many µm?", 0.069);
	Dialog.show();
	// variations based on number of files
	if (imgArray.length==2)	{
		nameArray[0] = Dialog.getChoice();
		nameArray[1] = Dialog.getChoice();
	}
	else if (imgArray.length==3)	{
		nameArray[0] = Dialog.getChoice();
		nameArray[1] = Dialog.getChoice();
		nameArray[2] = Dialog.getChoice();
	}
	else if (imgArray.length==4)	{
		nameArray[0] = Dialog.getChoice();
		nameArray[1] = Dialog.getChoice();
		nameArray[2] = Dialog.getChoice();
		nameArray[3] = Dialog.getChoice();
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
	len = imgArray.length;
	newName = "cmp" + len + win;
	
	// get dimensions
	wArray = newArray(len);
	hArray = newArray(len);
	hPosArray = newArray(len+1);
	hPosArray[0] = 0;
	height = 0;
	for (i=0; i<len; i++)   {
		selectImage(nameArray[i]);
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
		selectImage(newName);
		makeRectangle(0, (hPosArray[i])+(grout*i), wArray[i], hArray[i]);
		run("Paste");
	}
	//add scale bar (height is same as grout)
	if (sbchoice==true)	{
		getDimensions(w, h, c, nFrames, dummy);
		setColor(255,255,255);
		fillRect(w-((grout/2)+(sblen/mag)), h-(2*(grout/2)), sblen/mag, grout/2);
	}
	//specify dpi default is 300 dpi
	run("Set Scale...", "distance=res known=1 unit=inch");
	//save montage
	saveAs("TIFF", dir1+newName);
	setBatchMode(false);
	/*
	// close tempstack "stk"
	selectWindow("stk");
	close();
	*/
}