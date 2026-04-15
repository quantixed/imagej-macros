/*
*  This simple macro enhances contrast of the all open images in each channel
*  It uses the mid-frame and mid-slice to determine contrast limits
*  The partner macro Stack Auto Contrast works on one image and uses the current
*  frame/slice to auto contrast each channel
*/

// get list of all open images
list = getList("image.titles");
for (i = 0; i < list.length; i++)	{
    selectWindow(list[i]);
    getDimensions(width, height, channels, slices, frames);
    Stack.getPosition(channel, slice, frame);
    // set to mid-slice and mid-frame for auto contrast
    Stack.setPosition(channel, round(slices/2), round(frames/2));
    for (c = 1; c <= channels; c++)	{
        Stack.setPosition(c, round(slices/2), round(frames/2));
        //run("Brightness/Contrast...");
        run("Enhance Contrast", "saturated=0.35");
    }
    // return to original channel, slice and frame
    Stack.setPosition(channel, slice, frame);
}
