/*
 * Set_All_To_Grayscale.ijm
 *
 * Sets all images to grayscale.
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

    // if (targetChannels != sourceChannels)
    //     print("Set all channels to Grays: channel-count mismatch: " +
    //         sourceTitle + " (" + sourceChannels + ") -> " +
    //         targetTitle + " (" + targetChannels + "). Processing available channels.");

    // for (c=1; c<=targetChannels; c++) {
    //     Stack.setChannel(c);
    //     run("Grays");
    // }
    Stack.setDisplayMode("grayscale");
}

selectWindow(sourceTitle);
Stack.setPosition(sourceChannel, sourceSlice, sourceFrame);
// print("Set all available channels to the Grays LUT in all open images.");
