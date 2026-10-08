/*
 * Set_Current_Channel_To_Grays.ijm
 *
 * Sets the Grays LUT on the active image's current channel and the
 * corresponding channel in every other open image. Display mode is set to "color".
 */

if (nImages==0)
    exit("No images are open.");

sourceTitle = getTitle();
getDimensions(sourceWidth, sourceHeight, sourceChannels, sourceSlices, sourceFrames);
Stack.getPosition(sourceChannel, sourceSlice, sourceFrame);

imageTitles = getList("image.titles");
for (i=0; i<imageTitles.length; i++) {
    targetTitle = imageTitles[i];
    selectWindow(targetTitle);
    getDimensions(targetWidth, targetHeight, targetChannels, targetSlices, targetFrames);

    if (targetChannels != sourceChannels)
        print("Set current channel to Grays: channel-count mismatch: " +
            sourceTitle + " (" + sourceChannels + ") -> " +
            targetTitle + " (" + targetChannels + "). Attempting channel " +
            sourceChannel + ".");

    // Attempt the corresponding channel, even when channel counts differ.
    Stack.setChannel(sourceChannel);
    // Set the LUT to Grays for the current channel.
    Stack.setDisplayMode("color");
    run("Grays");
}

selectWindow(sourceTitle);
Stack.setPosition(sourceChannel, sourceSlice, sourceFrame);
// print("Set channel " + sourceChannel + " to the Grays LUT in all open images.");
