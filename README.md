# imagej-macros
Macros for ImageJ/FIJI that we are using in the lab. They are simple utilities.

###Making Figures
There are four macros to make figures with montages - made the way we like them!

1. Load in your image and use `ClickSquareROI.ijm` macro tool to define an ROI to crop your image. Optional: use `MakeNISPureRGB.ijm` if using images that have mixed LUTs.

2. Use `MultiMontageMacro.ijm` to make a nicely spaced row of images. You can do two things:

	1. From an RGB tiff you can make 2 or 3 grayscale images with the merge on the right.
	2. From a multichannel TIFF you can do up to 4 grayscale images with 0-2 merges on the right.

	You can specify the order of the grayscale images and determine the merge (for multichannel). Grout and scale bars can be added flexibly, no border is added. This is different to ImageJ's Make Montage and makes figure rows the way we like them! Now, `MontageMacro.ijm` is rolled into `MultiMontageMacro.ijm`.

3. Use `ROIZoom.ijm` to add ROI boxes and zoomed version into the corner of your images. This macro lets the user pick an ROI (using the point tool) and will make the expansion and put a neat border around it. You can define the size of the ROI, the expansion, the border, the corner where the expansion is placed. It's meant for montages and you can pick which panels you'd like to do this for (default is all). It should also work on single square images.

4. Then use `CompileMontages.ijm` to put these figure rows together. Grout and scale bar can be added flexibly.

###Blind Analysis
`BlindAnalysis.ijm` Takes a directory of TIFFs, strips the label from them and saves them with a blinded name. A tsv called `log.txt` is created to log the association between the original file and the blinded copy. Works on TIFF only.

`RemoveLabels.ijm` Takes a directory of TIFFs and removes the label from the file for blinding. Use another method for changing filenames.