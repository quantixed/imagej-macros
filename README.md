# imagej-macros
Macros for ImageJ/FIJI that we are using in the lab. They are simple utilities.

###Making Figures
There are two macros to make figures. Use `MontageMacro.ijm` to make a 3 or 4 panel row from an RGB tiff. The macro will place the RGB merge on the right and single grayscale channels in the order you specify. Grout and scale bars can be added flexibly, no border is added. This is different to ImageJ's Make Montage and makes figure rows the way we like them! Then use `CompileMontages.ijm` to put these figue rows together. Grout and scale bar can be added flexibly.

###Blind Analysis
`BlindAnalysis.ijm` Takes a directory of TIFFs, strips the label from them and saves them with a blinded name. A tsv called `log.txt` is created to log the association between the original file and the blinded copy. Works on TIFF only.

###Remove Labels
`RemoveLabels.ijm` Takes a directory of TIFFs and removes the label from the file for blinding. Use another method for changing filenames.