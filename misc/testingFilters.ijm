function calculate_kernel(sigma, kernel_size){
	//kernel_size = 15;
	centre = floor(kernel_size/2);
	kernel = "[";
	//min_val = 1;
	kernel_num=newArray(kernel_size * kernel_size);
	for (i=0;i<kernel_size;i++){
		for (j=0;j<kernel_size;j++){
			//val = lapofgauss(i-centre,j-centre,sigma);
			//val = lapofgauss(i-centre,j-centre,sigma) * -1 * (kernel_size * kernel_size);
			val = lapofgauss(i-centre,j-centre,sigma) * -1;
			kernel_num[i*kernel_size+j] = val;
		}
	}
	for (i=0;i<kernel_size;i++){
		for (j=0;j<kernel_size;j++){
			kernel = kernel + " " + d2s(kernel_num[i*kernel_size+j],7);
		}
		kernel = kernel + "\n";
	}
	kernel = kernel + "]";
	print(kernel);
	return kernel;
}

function lapofgauss(x, y, sigma){
	prefactor = -1.0/(2*PI*pow(sigma,4));
	midfactor = 2 - (pow(x,2) + pow(y,2))/pow(sigma,2);
	endfactor = exp(-1.0*(pow(x,2)+pow(y,2))/(2*pow(sigma,2)));
	
	return prefactor*midfactor*endfactor
}

//a = calculate_kernel(1,9);
//run("Convolve...", "text1="+a+"");

filter = "Gaussian Blur...";

parameters1 = newArray(0.5,1,2,5,0.5,1,2,5,0.5,1,2,5);
parameters2 = newArray(5,5,5,5,9,9,9,9,15,15,15,15);
param1=parameters1[0];
param2=parameters2[0];
title=getTitle();

run("Duplicate...", " ");
a = calculate_kernel(param1,param2);
run("Convolve...", "text1="+a+"");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT", "stack");
rename("stack");
setFont("SansSerif", 12, " antialiased");
setColor("white");
text = "parameter: "+param1+","+param2;
drawString(text, 10, 20, "black");

for (i = 1; i < parameters1.length; i++) {
	selectWindow(title);
	param1 = parameters1[i];
	param2 = parameters2[i];
	run("Duplicate...", " ");
	a = calculate_kernel(param1,param2);
	run("Convolve...", "text1="+a+"");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT", "stack");
	setColor("white");
	text = "parameter: "+param1+","+param2;
	drawString(text, 10, 20, "black");
	thiswindow = getTitle();
	run("Concatenate...", "  title=stack open image1=stack image2=" + thiswindow + " image3=[-- None --]");
}

rows = floor(sqrt(parameters1.length));
if (parameters1.length % rows > 0){
	nonexact = 1;
}else{
	nonexact = 0;
}
cols = floor(parameters1.length / rows) + nonexact;
run("Make Montage...", "columns=" + cols + " rows=" + rows + " scale=1");
selectWindow("stack");
close();
