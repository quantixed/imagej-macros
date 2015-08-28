/*
 * The idea is to compile montage images to make a figure
 */
if (nImages < 2)	{
	print("2 or more images are required");
	return;
}
else if (nImages >4)	{
	print("I can only compile 4 images in this version");
	return;
}
imgArray = newArray(nImages);
for (i=0; i<nImages; i++)	{
	selectImage(i+1);
	imgArray[i] = getImageID();
	title = getTitle();
    print((i+1) + " : " + title);
}

tworow = newArray("12","21");
threerow = newArray("123","132","213","231","312","321");
fourrow = newArray("1234","1243","1324","1342","1423","1432","2143","2134","2341","2314","2431","2413","3124","3142","3214","3241","3412","3421","4132","4123","4231","4213","4321","4312");
grout = 16;
res = 300;
sblen = 10;
mag = 0.069;
Dialog.create("Compile Montages"); 
Dialog.addMessage("Select order for your compilation");
if (imgArray.length==2)	{
	Dialog.addChoice("Top and bottom", tworow);
}
else if (imgArray.length==3)	{
	Dialog.addChoice("Top, middle, bottom", threerow);
}
else if (imgArray.length==4)	{
	Dialog.addChoice("Top, row 2, row 3, bottom", fourrow);
}
Dialog.addNumber("Row gap (px, default = 2 x grout):", 16);
Dialog.addNumber("d.p.i.", 300);
Dialog.addCheckbox("Scale bar?", false);
Dialog.addNumber("Scale bar size (µm):", 10);
Dialog.addNumber("1 px is how many µm?", 0.069);
Dialog.show();
choice = Dialog.getChoice();
grout = Dialog.getNumber();
res = Dialog.getNumber();
sbchoice = Dialog.getCheckbox();
sblen = Dialog.getNumber();
mag = Dialog.getNumber();
//

win = getTitle();
newName = "cmp" + choice + win;
run("Images to Stack", "name=stk title=[] use");
getDimensions(w, h, c, nFrames, dummy);
len=lengthOf(choice);
newImage(newName, "RGB", w,(h*len)+(grout*(len-1)), 1);
//
for (i=0; i<len; i++)   {
	ch=substring(choice, i, i+1);
	selectImage("stk");
	setSlice(ch);
	run("Copy");
	selectImage(newName);
	makeRectangle(0, (h*i)+(grout*i), w, h);
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

//close tempstack "stk"
selectWindow("stk");
close();