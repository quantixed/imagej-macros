/*
 * Montage compiler will compile montages to make a figure.
 * Previously the user needed to determine the orientation
 * Now the function determines the orientation in order to:
 * 1) array row montages vertically, or
 * 2) array column montages horizontally
 */

macro "Montage Compiler"	{
	if (nImages < 2) exit ("2 or more images are required");
	mtgcomp();
}
