/* Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
Inspired by Guzmán, Camilo, Manish Bagga, Amanpreet Kaur, Jukka Westermarck, and Daniel Abankwa. 
« ColonyArea: An ImageJ Plugin to Automatically Quantify Colony Formation in Clonogenic Assays ». 
PLOS ONE 9, no 3: e92444. https://doi.org/10.1371/journal.pone.0092444. */

//Allows the user to choose the folder containing the images and the folder for the results 
outputFolder=getDirectory("Choose output folder for the results");

setBatchMode(true); //In batch mode the windows are not shown so it is faster.
title = getTitle();
fileExtension=lastIndexOf(title,"."); 
if(fileExtension!=-1) title=substring(title,0,fileExtension);

width = getWidth/6;
height = getHeight/4;
x = newArray(0, 1, 2, 3, 4, 5); 
y = newArray(0, 1, 2, 3); 

for (i=0; i<x.length; i++) {
	x[i]*=width;
}
for (i=0; i<y.length; i++) {
	y[i]*=height;
}

for(i=0; i<x.length; i++) {
	for(j=0; j<y.length; j++){
		makeRectangle(x[i], y[j], 2400, 2400);
		run("Duplicate...", " ");
		rename(i+"-"+j);
		saveAs("Jpeg", outputFolder+title+"-"+j+"-"+i+".jpg");
		close();	
	}
	showProgress(i, x.length); //Shows a progress bar
}
setBatchMode(false);