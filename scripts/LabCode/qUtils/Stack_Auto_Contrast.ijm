/*
*  This simple macro enhances contrast of the current image in each channel
*  It uses the first frame and slice to determine contrast limits
*/

title = getTitle();
selectWindow(title);
getDimensions(width, height, channels, slices, frames);
for (c = 1; c <= channels; c++)	{
    Stack.setPosition(c, 1, 1);
    //run("Brightness/Contrast...");
    run("Enhance Contrast", "saturated=0.35");
}