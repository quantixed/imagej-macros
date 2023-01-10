function replaceRGBvalue(oldR,oldG,oldB,newR,newG,newB) {
	if (bitDepth != 24) {
		exit("Requires RGB image");
	}

	getDimensions(width, height, channels, slices, frames);

	if (slices > 1 || frames > 1) {
		exit("This function only works on single images");
	}
	
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			u = getPixel(i, j);
			red = (u>>16)&0xff;  // extract red byte (bits 23-17)
			green = (u>>8)&0xff; // extract green byte (bits 15-8)
			blue = u&0xff;       // extract blue byte (bits 7-0)
	        if(red == oldR && green == oldG && blue == oldB) {
	        	v = newR << 16 + newG << 8 + newB;
	        	setPixel(i, j, v);
	        }
		}
	}
}
