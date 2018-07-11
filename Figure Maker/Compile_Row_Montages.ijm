/*
 * Compile montage images to make a figure.
 * User can choose to:
 * 1) array row montages vertically, or
 * 2) array column montages horizontally
 */

macro "Compile Row Montages"	{
	s=call("ij.macro.Interpreter.getAdditionalFunctions");
	if(startsWith(s,"//qFunctions")!=1) {
		qFpath = getDirectory("plugins")+"LabCode/Figure Maker/QFunctions.txt";
		qFpath = replace(qFpath,"plugins","scripts");
		functions = File.openAsString(qFpath);
		call("ij.macro.Interpreter.setAdditionalFunctions", functions);
		}
	if (nImages < 2) exit ("2 or more images are required");
	compmtg("");
}
