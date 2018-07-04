/*
 * Compile montage images to make a figure.
 * User can choose to:
 * 1) array row montages vertically, or
 * 2) array column montages horizontally
 */

macro "Compile Row Montages"	{
  s=call("ij.macro.Interpreter.getAdditionalFunctions");
  if(startsWith(s,"//qFunctions")!=1) {
    qFpath = getDirectory("plugins")+"quantixed/Figure Maker/qFunctions.txt";
    functions = File.openAsString(qFpath);
    // this opens too quickly on first attempt, so we receive a string from call
		success = call("ij.macro.Interpreter.setAdditionalFunctions", functions);
		// and test for it
		while(success==-1) {
			print("Waiting");
		}
		if(success==0)  {
			wait(1000);
		}
	}
	if (nImages < 2) exit ("2 or more images are required");
	compmtg("");
}
