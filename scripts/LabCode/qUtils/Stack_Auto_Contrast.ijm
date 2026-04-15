/*
*  This simple macro enhances contrast of the current image in each channel
*  It uses the current frame and slice to determine contrast limits
*/

title = getTitle();
selectWindow(title);
getDimensions(width, height, channels, slices, frames);
Stack.getPosition(channel, slice, frame);
for (c = 1; c <= channels; c++)	{
    Stack.setPosition(c, slice, frame);
    //run("Brightness/Contrast...");
    run("Enhance Contrast", "saturated=0.35");
}
// return to original channel, slice and frame
Stack.setPosition(channel, slice, frame);