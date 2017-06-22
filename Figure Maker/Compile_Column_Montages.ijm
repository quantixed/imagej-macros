/*
 * Compile montage images to make a figure.
 * User can choose to:
 * 1) array row montages vertically, or
 * 2) array column montages horizontally
 */

macro "Compile Column Montages"	{
  s=call("ij.macro.Interpreter.getAdditionalFunctions");
  if(startsWith(s,"//qFunctions")!=1) {
		qFpath = getDirectory("plugins")+"quantixed/Figure Maker/qFunctions.txt";
		functions = File.openAsString(qFpath);
		call("ij.macro.Interpreter.setAdditionalFunctions", functions);
    delay(3000);
	}
	if (nImages < 2) exit ("2 or more images are required");
	compmtg("vert");
}
