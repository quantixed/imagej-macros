/*
 *  This macro will prepare a directory of TIFFs for blind analysis
 *  and log the association between original file and blind analysis file
 *  for unblinding at the end of the analysis
*/
macro "Blind Analysis" {
	dirPath = getDirectory("Select a directory");
	// Get all file names
	allNames = getFileList(dirPath);
	// Create the output folder
	outputDir = dirPath+"blind"+File.separator;
	File.makeDirectory(outputDir);
	// Make an array and extend it with names of *.tif only
	imNames = newArray(0);
	for (i = 0; i < allNames.length; i ++) {
		if (endsWith(allNames[i], ".tif")) {
			imNames = append(imNames, allNames[i]);
		}
	}
	imNum = imNames.length
	// Generate a permutation array of length imNum
	imPerm = newArray(imNum);
	for(i = 0; i < imNum; i ++) {
		imPerm[i] = i + 1;
	}
	// Shuffle the array
	for(i = 0; i < imNum; i ++) {
		j = floor(random * imNum);
		swap = imPerm[i];
		imPerm[i] = imPerm[j];
		imPerm[j] = swap;
	}
	// Associate sequentially permuted positions to image names
	imPermNames = newArray(imNum);
	for(i = 0; i < imNum; i ++){
		imPermNames[i] = "blind_" + IJ.pad(imPerm[i],4); // for more than 9999 images change width
	}
	// Open each image, strip metadata and save in the destination folder using the blinded name
	// Also log both names in the log.txt file created in the destination folder
	setBatchMode(true);
	f = File.open(outputDir+"log.txt");
	print(f, "Original_Name\tBlinded_Name"); // tab separated
	for(i = 0; i < imNum; i ++){
		inputPath = dirPath+imNames[i];
		outputPathPerm = outputDir+imPermNames[i];
		open(inputPath);
		totalSlices = nSlices;
		if(totalSlices > 1)  {
				stripFrameByFrame(totalSlices);
		} else  {
				setMetadata("Label", ""); // strips the label data from the image for blinding purposes
		}
		save(outputPathPerm);
		print(f,imNames[i]+"\t"+imPermNames[i]);
		close();
	}
	setBatchMode("exit and display");
	showStatus("finished");
}

// strips the label data from each slice of an image
function stripFrameByFrame(totalSlices)  {
  for(i = 0; i < totalSlices; i ++){
    setSlice(i+1);
	setMetadata("Label", "");
    }
}

// function that adds a variable to an array
function append(arr, value) {
	arr2 = newArray(arr.length + 1);
	for (i = 0; i < arr.length; i ++)
		arr2[i] = arr[i];
		arr2[arr.length] = value;
	return arr2;
}