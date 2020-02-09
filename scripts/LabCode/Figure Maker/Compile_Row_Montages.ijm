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
