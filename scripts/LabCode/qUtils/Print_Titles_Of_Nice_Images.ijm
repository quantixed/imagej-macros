/*
 * Idea is to open a whole bunch of images and leave the ones open that you like
 * This macro will print to the log the title of the nice images.
 */

macro "What nice images do I have?"	{
	if (nImages < 1)	{
		print("No images open");
		return;
	}
	nameArray = newArray(nImages);
	print("\\Clear");
	for (i=0; i<nImages; i++)	{
		selectImage(i+1);
		title = getTitle();
		nameArray[i] = title;
	    print((i+1) + " : " + title);
	}