/* Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
Inspired by Guzmán, Camilo, Manish Bagga, Amanpreet Kaur, Jukka Westermarck, and Daniel Abankwa. 
« ColonyArea: An ImageJ Plugin to Automatically Quantify Colony Formation in Clonogenic Assays ». 
PLOS ONE 9, no 3: e92444. https://doi.org/10.1371/journal.pone.0092444. */

//Allows the user to choose the folder containing the images and the folder for the results 
inputFolder=getDirectory("Choose input folder");
med = "med";

setBatchMode(true);

list=getFileList(inputFolder);

for(i=0; i<list.length; i++) {
	loc=inputFolder+list[i];
	open(loc);
	run("32-bit"); //Convert to black and white
	t1 = getTime();
	run("Gaussian Blur...", "sigma=80");	
	t2 = getTime();
	close();
	print("Gauss;"+ list[i] + ";" + (t2-t1));

	open(loc);
	run("32-bit"); //Convert to black and white
	t3 = getTime();
	run("Median...", "radius=50");
	t4 = getTime();
	close();
	print("Median;"+ list[i] + ";" + (t4-t3));

	open(loc);
	run("32-bit"); //Convert to black and white
	t5 = getTime();
	run("Mean...", "radius=100");
	t6 = getTime();
	close();
	print("Mean;"+ list[i] + ";" + (t6-t5));
}
setBatchMode(false);