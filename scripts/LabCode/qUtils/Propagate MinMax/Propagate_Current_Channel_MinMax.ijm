/*
 * Propagate_Current_Channel_MinMax.ijm
 *
 * Copies the current channel's Brightness & Contrast min/max values
 * from the active image to the same channel in every other open image.
 */

if (nImages==0)
    exit("No images are open.");

sourceTitle = getTitle();
getDimensions(sourceWidth, sourceHeight, sourceChannels, sourceSlices, sourceFrames);
Stack.getPosition(sourceChannel, sourceSlice, sourceFrame);

// Read the display range from the active image and current channel.
getMinAndMax(sourceMin, sourceMax);

imageTitles = getList("image.titles");
for (i=0; i<imageTitles.length; i++) {
    targetTitle = imageTitles[i];
    if (targetTitle==sourceTitle)
        continue;

    selectWindow(targetTitle);
    getDimensions(targetWidth, targetHeight, targetChannels, targetSlices, targetFrames);

    if (targetChannels != sourceChannels)
        print("Propagate current channel: channel-count mismatch: " +
            sourceTitle + " (" + sourceChannels + ") -> " +
            targetTitle + " (" + targetChannels + "). Attempting channel " + sourceChannel + ".");

    // setChannel() may fail for an image with too few channels; keep going.
    Stack.setChannel(sourceChannel);
    setMinAndMax(sourceMin, sourceMax);
}

selectWindow(sourceTitle);
Stack.setPosition(sourceChannel, sourceSlice, sourceFrame);
print("Propagated channel " + sourceChannel + " range [" + sourceMin + ", " + sourceMax + "] from " + sourceTitle + ".");
