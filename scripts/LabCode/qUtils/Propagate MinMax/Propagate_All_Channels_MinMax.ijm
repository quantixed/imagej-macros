/*
 * Propagate_All_Channels_MinMax.ijm
 *
 * Copies the Brightness & Contrast min/max values for every channel
 * in the active image to the corresponding channels in every other
 * open image.
 */

if (nImages==0)
    exit("No images are open.");

sourceTitle = getTitle();
getDimensions(sourceWidth, sourceHeight, sourceChannels, sourceSlices, sourceFrames);
Stack.getPosition(sourceChannel, sourceSlice, sourceFrame);

// Store the source image's display range for each channel.
sourceMin = newArray(sourceChannels);
sourceMax = newArray(sourceChannels);
for (c=1; c<=sourceChannels; c++) {
    Stack.setChannel(c);
    getMinAndMax(sourceMin[c-1], sourceMax[c-1]);
}

imageTitles = getList("image.titles");
for (i=0; i<imageTitles.length; i++) {
    targetTitle = imageTitles[i];
    if (targetTitle==sourceTitle)
        continue;

    selectWindow(targetTitle);
    getDimensions(targetWidth, targetHeight, targetChannels, targetSlices, targetFrames);

    if (targetChannels != sourceChannels)
        print("Propagate all channels: channel-count mismatch: " +
            sourceTitle + " (" + sourceChannels + ") -> " +
            targetTitle + " (" + targetChannels + "). Attempting available channels.");

    // Only channels present in both images can be addressed.
    // Images with fewer channels are therefore handled without aborting.
    channelsToCopy = minOf(sourceChannels, targetChannels);
    for (c=1; c<=channelsToCopy; c++) {
        Stack.setChannel(c);
        setMinAndMax(sourceMin[c-1], sourceMax[c-1]);
    }
}

selectWindow(sourceTitle);
Stack.setPosition(sourceChannel, sourceSlice, sourceFrame);
print("Propagated min/max display ranges for " + channelsToCopyDescription(sourceChannels) + " from " + sourceTitle + ".");

function minOf(a, b) {
    if (a < b) return a;
    return b;
}

function channelsToCopyDescription(n) {
    if (n==1) return "1 channel";
    return "" + n + " channels";
}
