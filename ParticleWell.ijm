/* Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
Inspired by Guzmán, Camilo, Manish Bagga, Amanpreet Kaur, Jukka Westermarck, and Daniel Abankwa. 
« ColonyArea: An ImageJ Plugin to Automatically Quantify Colony Formation in Clonogenic Assays ». 
PLOS ONE 9, no 3: e92444. https://doi.org/10.1371/journal.pone.0092444. */

//Allows the user to choose the folder containing the images and the folder for the results 
inputFolder=getDirectory("Choose input folder");
outputFolder=getDirectory("Choose output folder for the results");

//Dialog box to set the scale
Dialog.create("Options");
Dialog.addNumber("Measured distance (pixel)", 1925);
Dialog.addNumber("Known distance (mm)", 16.0); 
Dialog.addNumber("Minimum area (mm"+fromCharCode(0x00B2)+")", 0.0);
Dialog.addNumber("Threshold correction", 10.0);
Dialog.addChoice("Threshold method", 
	newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", 
		"Mean", "MinError", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", 
		"Shanbhag", "Triangle", "Yen"),
	"Default");
Dialog.addCheckbox("Manual Threshold", false);
Dialog.addCheckbox("Reposition selection circle", true);
Dialog.addNumber("Circle diameter (mm)", 13.0);
Dialog.addCheckbox("Save filtered image", false);
Dialog.show();
disPix = Dialog.getNumber();
disKnown = Dialog.getNumber();
minArea = Dialog.getNumber();
thldCor = Dialog.getNumber();
thldMethod = Dialog.getChoice();
manual = Dialog.getCheckbox();
circleselect = Dialog.getCheckbox();
circleDiam = Dialog.getNumber();
saveFiltered = Dialog.getCheckbox();

//print the infos in the Log window
manualStr = boleanstring(manual);
circleselectStr = boleanstring(circleselect);
print(
	"Measured distance (pixel) : "+ disPix + "\n"+ 
	"Known distance (mm) : "+ disKnown + "\n"+ 
	"Minimum area (mm"+fromCharCode(0x00B2)+") : "+ minArea+ "\n"+ 
	"Threshold correction : "+ thldCor+ "\n"+ 
	"Manual Threshold : "+ manualStr+ "\n"+
	"Reposition selection circle : "+ circleselectStr+ "\n"+ 
	"Circle diameter (mm) : "+ circleDiam
	); 

run("Text Window...", "name=Processed width=40 height=30 monospaced");

//In batch mode the windows are not shown so it is faster.
if (manual!=true) {
	if (circleselect!=true) setBatchMode(true);
	} 
run("Set Measurements...", "area mean perimeter shape limit redirect=None decimal=4");
run("Clear Results");

//Puts the name of the files in a list and process each image
list=getFileList(inputFolder);
for(i=0; i<list.length; i++) {
	//Open the images
	loc=inputFolder+list[i];
	//if(endsWith(loc, ".jpg")) 
	open(loc);
	run("Set Scale...", "distance="+disPix+" known="+disKnown+" unit=mm");

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
		
		//Uneven illumination correction
		run("Duplicate...", " ");
		rename(list[i]+"-med");
		//blur the image
		//run("Median...", "radius=73"); //opti 73
		run("Gaussian Blur...", "sigma=60"); //opti 60
		//run("Mean", "block_radius_x=70 block_radius_y=70"); //opti 70

		imageCalculator("Subtract create 32-bit", list[i]+"-bw", list[i]+"-med");
		
		//Threshold corrected image
		selectWindow("Result of "+list[i]+"-bw");
		if (saveFiltered == true) saveAs("Jpeg", outputPath+"-subtr"+ ".jpg");
		run("Gaussian Blur...", "sigma=2"); //Blur the particles to be sure to select the objects and not the sub-objects
		if (manual != false) {
			run("Threshold...");
			waitForUser("Adjust Threshold", "If necessary, use the \"Threshold\" tool to\nadjust the threshold, then click \"OK\".");
			selectImage("Result of "+list[i]+"-bw");  //make sure we still have the same image
			getThreshold(lower, upper);
			if (lower==-1) exit("Threshold was not set");
		} else {
			setAutoThreshold(thldMethod);
			getThreshold(lower,upper);
			setThreshold(lower,upper + thldCor);
		}
		setOption("BlackBackground", false);
		run("Convert to Mask");
		
		//Delete ROI outside of the circle 
		widthPix = getWidth;
		heightPix = getHeight;
		circleDiamPix = circleDiam*(disPix/disKnown);
		posx = (widthPix - circleDiamPix)/2;
		posy = (heightPix - circleDiamPix)/2;
		makeOval(posx, posy, circleDiamPix, circleDiamPix);
		if (circleselect != false) {
			setTool("oval");
			waitForUser("Place Circle", "Place the circle on the desired position");
		}
		setBackgroundColor(255, 255, 255);
		run("Clear Outside");
		//run("Fill Holes"); //Fill holes is not very usefull and can make issues with the wells edges

		//Analyse Particles and fill the result table in tidy format
		run("Analyze Particles...","size="+minArea+"-Infinity add display");
		if (roiManager("Count") > 0) {
			for (row = currentNResults; row < nResults; row++) //This add the file name in a row 
			{
				setResult("Label", row, list[i]);
			}
			updateResults;
			//transfer the label from the bw image to the color image
			selectWindow(list[i]);
			roiManager("Show All without labels"); 
			roiManager("Set Color", "red"); 
			roiManager("Set Line Width", 2);
			run("Flatten");
			roiManager("Delete");
		} else { 
			//If there is no particle, create one row with null values
			setResult("Label", currentNResults, list[i]);
			selectWindow(list[i]);
		}
		saveAs("Jpeg", outputPath+ ".jpg");
		close("*");
	}
	showProgress(i, list.length); //Shows a progress bar  
	print("[Processed]", list[i]+"\n"); //print the finished image in a new "Processed" window
}
closeWin("ROI Manager");
closeWin("Threshold");
saveAs("results", outputFolder+ "results"+ ".csv"); 
selectWindow("Log");
saveAs("Text", outputFolder+ "Log"+ ".txt");
waitForUser("Work done", "WORK DONE: Close all windows?");
closeWin("Log");
closeWin("Results"); 
closeWin("Processed");
setBatchMode(false);

function closeWin(winName)
{
	if (isOpen(winName)) 
	{
		selectWindow(winName);
		run("Close");
	}
}

function boleanstring(variable)
{
	if (variable == true) {
		varStr = "Yes";
	} else {
		varStr = "No";
	}
	return varStr;
}