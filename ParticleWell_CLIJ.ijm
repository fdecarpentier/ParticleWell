//Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
//Inspired Guzmán, Camilo, Manish Bagga, Amanpreet Kaur, Jukka Westermarck, and Daniel Abankwa. « ColonyArea: An ImageJ Plugin to Automatically Quantify Colony Formation in Clonogenic Assays ». PLOS ONE 9, no 3: e92444. https://doi.org/10.1371/journal.pone.0092444.

//CLIJ2 allows GPU-accelerated image processing 
run("CLIJ2 Macro Extensions", "cl_device="); 
Ext.CLIJ2_clear(); 

//Allows the user to choose the folder containing the images and the folder for the results 
inputFolder=getDirectory("Choose input folder");
outputFolder=getDirectory("Choose output folder for the results");

Dialog.create("Options");
Dialog.addNumber("Distance in pixels", 1890);
Dialog.addNumber("Known distance", 1.5);
Dialog.show();
disPix = Dialog.getNumber();
disKnown = Dialog.getNumber();  

//Puts the name of the files in a list
list=getFileList(inputFolder);

//In batch mode the windows are not shown so it is faster.
setBatchMode(true);
run("Set Measurements...", "area mean perimeter shape limit redirect=None decimal=3");
run("Clear Results");

for(i=0; i<list.length; i++) {
	//Open the images
	loc=inputFolder+list[i];
	//if(endsWith(loc, ".jpg")) 
	open(loc);
	print(loc); //I don't know why but it doesn't work without printing the value of loc
	run("Set Scale...", "distance="+disPix+" known="+disKnown+" unit=cm");

	//Processes of the image to measure the area of each particle and add an overlay
	if(nImages>=1) {
		outputPath=outputFolder+list[i];
		//The following two lines removes the file extension
		fileExtension=lastIndexOf(outputPath,"."); 
		if(fileExtension!=-1) outputPath=substring(outputPath,0,fileExtension);
		currentNResults = nResults;
		run("Duplicate...", " ");
		rename(list[i]+"-bw");
		run("32-bit"); //Convert to black and white
		bw = getTitle(); 
		Ext.CLIJ2_push(bw);
		Ext.CLIJ2_medianSliceBySliceBox(bw, med, 50, 50);
		Ext.CLIJ2_pull(med);
		imageCalculator("Subtract create 32-bit", list[i]+"-bw", med);
		selectWindow("Result of "+list[i]+"-bw");
		setAutoThreshold("Default");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Fill Holes"); 		
		width = getWidth;
  		height = getHeight;
  		shrink = 25;
  		makeOval(shrink, shrink, width-shrink, height-shrink);
		setBackgroundColor(255, 255, 255);
		run("Clear Outside");
		run("Analyze Particles...","size=0-Infinity add display");
		for (row = currentNResults; row < nResults; row++) //This add the file name in a row 
		{
			setResult("Label", row, list[i]);
		}
		selectWindow(list[i]);
		roiManager("Show All without labels"); //transfer the label from the bw image to color image
		roiManager("Set Color", "red"); 
		roiManager("Set Line Width", 2);
		run("Flatten");
		roiManager("Delete");
		saveAs("Jpeg", outputPath+ ".jpg");
		close("*");
	}
	showProgress(i, list.length);  //Shows a progress bar  
}
setOption("ShowRowNumbers", false); 
saveAs("results", outputFolder+ "results"+ ".csv"); 
selectWindow("Results");
run("Close"); 
setBatchMode(false);