# imagej-macros
Macros for ImageJ/FIJI that we are using in the lab. They are simple utilities.

###Making Figures
There are two macros to make figures. Use `MultiMontageMacro.ijm` to make a nicely spaced row of images. You can do two things:

1. From an RGB tiff you can make 2 or 3 grayscale images with the merge on the right.
2. From a multichannel TIFF you can do up to 4 grayscale images with 0-2 merges on the right.

You can specify the order of the grayscale images and determine the merge (for multichannel). Grout and scale bars can be added flexibly, no border is added. This is different to ImageJ's Make Montage and makes figure rows the way we like them! Then use `CompileMontages.ijm` to put these figue rows together. Grout and scale bar can be added flexibly.
Now, `MontageMacro.ijm` is rolled into `MultiMontageMacro.ijm`.

###Blind Analysis
`BlindAnalysis.ijm` Takes a directory of TIFFs, strips the label from them and saves them with a blinded name. A tsv called `log.txt` is created to log the association between the original file and the blinded copy. Works on TIFF only.

###Remove Labels
`RemoveLabels.ijm` Takes a directory of TIFFs and removes the label from the file for blinding. Use another method for changing filenames.