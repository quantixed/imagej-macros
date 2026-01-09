macro "About_LabCode" {
	Dialog.create("About LabCode menu");
	str = "LabCode is a collection of ImageJ Macros from the quantixed update site\n"
	str += " \n--\n \n"
	str += "version 1.0.2"
	str += " \n\n--\n \n"
	str += "For instructions and further information see:\n \n"
	str += "https://github.com/quantixed/imagej-macros"
	Dialog.addMessage(str);
	Dialog.show();
	}