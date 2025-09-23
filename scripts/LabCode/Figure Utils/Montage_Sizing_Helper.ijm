/*
 * The purpose of this script is to check whether the grout size will be visible in the final figure
 * It uses values provided by the user. Typically, the grout in a montage will be x pixels, then a
 * compiled montage uses spacing of 2x pixels. The scale bar is drawn at a height of x pixels in a
 * single montage or at 2x pixels in a compiled montage. ROI zooms are usually at x pixels.
 * Figure width refers to the size of the figure on the page.
 * Montage refers to an array of image panels which will occupy a part of the Figure.
 * Panel refers to a sub-part of the montage not a part of the Figure.
 */

#@ Integer (label="Figure width (mm):", value=170, persist=false) figwidth
#@ String (visibility=MESSAGE, value="Montage is what fraction of the figure width?", required=false) msg1
#@ Float (Label="1 = Full width, 0.5 = half width ...", min=0, max=1, value=0.5, stepsize = 0.01, style="format:0.00") mtgfrac
#@ String (visibility=MESSAGE, value="Will there be labels at the side of the montage?", required=false) msg2
#@ Boolean (label = "Side labels?", value=true, persist=false) labcorr
#@ Integer (label="Number of panels", style="slider", min=2, max=6, stepSize=1) npanel
#@ Integer (label="Panel width (px)", style="slider", min=20, max=1000, stepSize=10) panelwidth
#@ Integer (label="Grout size (px)", value=8, persist=false) grout


// physical width of the montage
figWidthmm = (figwidth * mtgfrac);
if(labcorr) figWidthmm = figWidthmm - 5;
// dpi in mm
dpimm = (300/25.4);

// width of the montage in pixels based on the information given
mtgWidthpx = (npanel * panelwidth) + (grout * (npanel - 1));
// width of this montage in mm
mtgWidthmm = mtgWidthpx / dpimm;
// scaling so that it will fit into the figure
mtgScale = figWidthmm / mtgWidthmm;
// size of grout in the figure
groutWidthmm = (grout / dpimm) * mtgScale;

s = "Montage is " + npanel + " panels wide. Each panel is " + panelwidth + " pixels.\n";
s = s + "Selected grout size is " + grout + " pixels.\n****\n";
s = s + "Montage width should be " + figWidthmm + " mm.\n";
s = s + "Montage width is " + mtgWidthpx + " px.\n";
s = s + "At 300 dpi, this is " + mtgWidthmm + " mm.\n****\n";
s = s + "You will scale it by " + mtgScale * 100 + " % to make it fit.\n";
s = s + "Which makes the grout " + groutWidthmm + " mm, or " + (groutWidthmm / 0.35) + " pt.\n****\n";
if(groutWidthmm / 0.35 < 1)
	s = s + "Since this is less than 1 pt, you should\n  INCREASE the grout size or DECREASE the panel width.\n";
else if (groutWidthmm / 0.35 > 4)
	s = s + "Since this is more than 4 pt, you should\n  DECREASE the grout or INCREASE the panel width.\n";
else
	s = s + "Since this is more than 1 pt, it should look OK.\n";
print("\\Clear");
print(s);