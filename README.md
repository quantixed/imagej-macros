# imagej-macros
Some simple macros for ImageJ/FIJI that we are using in the lab. These tools are now available via the *quantixed* ImageJ [update site](http://sites.imagej.net/Quantixed/). Instructions for how to follow a 3rd party update site are [here](http://imagej.net/How_to_follow_a_3rd_party_update_site). This is the best way to install these macros and maintain the latest versions.

## Quick links

1. [Figure Maker](#figure-maker)
	1. Prepare your [images](#prepare-your-images)
	2. Make a [montage](#montage)
	3. Optional: add [ROI Zoom](#roi-zoom)
	4. [Compile](#put-the-rows-together) your montages
	4. [Columns](#i-want-columns-not-rows) not rows?
	5. [Figures the quantixed way](#figures-the-quantixed-way)
2. [Blind Analysis](#blind-analysis)
3. [Other Utilities](#other-utilities)


###Figure Maker

There are macros to help you to make figures with montages - made the way we like them! There are other plugins for making figures in ImageJ but none did what we [wanted](#figures-the-quantixed-way), so we made our own.


####Prepare your images

Load in your multichannel image, adjust how you want and then crop.
To do this select *Click Square ROI* from the >> on the toolbar.
![fm001](https://cloud.githubusercontent.com/assets/13585138/21343084/102d6bac-c68d-11e6-9b60-44a104d398be.jpg)
This tool gives 400 x 400 pixel square ROI, right click to get a different size.
Select the area you want.
![fm003](https://cloud.githubusercontent.com/assets/13585138/21343083/102d4b40-c68d-11e6-8206-18931f024783.jpg)
Crop your images and save them as TIFFs.
![fm004](https://cloud.githubusercontent.com/assets/13585138/21343086/102eaf44-c68d-11e6-9d9a-1f64e56ba5f3.jpg)


####Make a montage row

To make a nicely spaced montage (row of images). Select *Plugins>quantixed>Figure Maker>Montage Horizontal Flexible*

Note that there are other options here: to make a simple RGB montage (this is good for three channel images were you just want one merge panel, this also works on whole directories), there are [vertical montage](#i-want-columns-not-rows) options for flexible and RGB montages.

![fm005](https://cloud.githubusercontent.com/assets/13585138/21343087/103c11e8-c68d-11e6-8856-db03fb962e48.jpg)

You are asked to pick your cropped TIFF.

You can specify the number of grayscale (channel) panels and choose the number of merge.

![fm007](https://cloud.githubusercontent.com/assets/13585138/21343089/104b0bb2-c68d-11e6-8842-275e9fd6b3d7.jpg)

In the next dialog you can pick which panels go where in your montage.

Grout and scale bars can be added flexibly, no border is added. This is different to ImageJ's Make Montage and makes figure rows the [way we like them](figures-the-quantixed-way)! Note that if you are going to compile montages, it's best to add a single scale bar at this stage.

![fm008](https://cloud.githubusercontent.com/assets/13585138/21343090/104b8556-c68d-11e6-9c33-a2c08f7021d7.jpg)

Your montage is saved in the same directory as the original image. The macro leaves it there, so that you can admire your awesome data!

![fm009](https://cloud.githubusercontent.com/assets/13585138/21343091/104e877e-c68d-11e6-9117-0876f4418d7e.jpg)


####Optional: add ROIs and zooms

Sometimes, we like to add a ROI and a zoomed version of this ROI to various panels in the montage. To do this open your montage and select *Plugins>quantixed>Figure Maker>ROI Zoom*

![fm013](https://cloud.githubusercontent.com/assets/13585138/21343095/10675182-c68d-11e6-9098-49bbc239a2b1.jpg)

You can pick which corner you want the zoom and which panels you'd like to add an ROI and zoom.

After clicking OK, you are asked to select the centre of the ROI.

![fm014](https://cloud.githubusercontent.com/assets/13585138/21343096/1069deac-c68d-11e6-9b24-61ea7f380bb7.jpg)


####Now put the rows together

Finally, if we have more than one montage, we need to compile them together. Load in all the montages you'd like to compile. Now select *Plugins>quantixed>Figure Maker>Compile Row Montages*

![fm010](https://cloud.githubusercontent.com/assets/13585138/21343092/105b0648-c68d-11e6-8c66-d6f371a17452.jpg)

The dialog asks you to select which montage you'd like where.

![fm011](https://cloud.githubusercontent.com/assets/13585138/21343093/105eb9b4-c68d-11e6-8879-16d91192a8e8.jpg)

Your compilation will save back in the same directory as the montages. Note, that you can always make one compilation and then add more montages or other compilations.

![fm012](https://cloud.githubusercontent.com/assets/13585138/21343094/1066f890-c68d-11e6-94d6-8141bc44bf7d.jpg)


####I want columns not rows

This is fine. Just select *Plugins>quantixed>Figure Maker>Montage Vertical Flexible* This will do the same thing but put the channels vertically with any merges at the bottom. Note that there is a version to make simple RGB montages. There is a vertical version of this too.

Remember that when you compile vertical montages, you need to select *Plugins>quantixed>Figure Maker>Compile Column Montages*


####Figures the quantixed way

For multichannel microscopy images, e.g. from an immunofluorescence experiment, *quantixed* follows these rules for best practice.

1. Individual channels as grayscale - reason: the eye does not detect black-to-red in the same way as black-to-green
2. In a row montage the merge is on the right. In a column montage it is at the bottom
3. Square images, square ROIs and square zooms
4. No border
5. Scale bar in the bottom right corner
4. Fixed grout of 8 pixels (suggested)
6. Scale bar of 10 µm, height of 2 x grout (suggested)
7. Grouting between conditions is 2 x grout between channels (suggested)
8. Labelling is done in Illustrator or some other software to assemble the final figure, *not* in ImageJ


###Blind Analysis

`BlindAnalysis.ijm` Takes a directory of TIFFs, strips the label from them and saves them with a blinded name. A tsv called `log.txt` is created to log the association between the original file and the blinded copy. Works on TIFF only.

`RemoveLabels.ijm` Takes a directory of TIFFs and removes the label from the file for blinding. Use another method for changing filenames.


###Other utilities

Open all the nd2 files in a directory and save them as TIFF to another directory with `nd2SaveAsTiff.ijm`.

Maybe you like to open a whole directory of images, look through them, closing the bad ones and leaving the good ones open. Perhaps you want to grab the list of good images so that you can come back to it later? Well, `PrintTitlesOfNiceImages.ijm` does this for you.

