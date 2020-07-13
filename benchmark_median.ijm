/* Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
Inspired by Guzmán, Camilo, Manish Bagga, Amanpreet Kaur, Jukka Westermarck, and Daniel Abankwa. 
« ColonyArea: An ImageJ Plugin to Automatically Quantify Colony Formation in Clonogenic Assays ». 
PLOS ONE 9, no 3: e92444. https://doi.org/10.1371/journal.pone.0092444. */

//Allows the user to choose the folder containing the images and the folder for the results 
inputFolder=getDirectory("Choose input folder");
med = "med";
run("CLIJ2 Macro Extensions", "cl_device="); 
Ext.CLIJ2_clear(); 

setBatchMode(true);

list=getFileList(inputFolder);

for(i=0; i<list.length; i++) {
	loc=inputFolder+list[i];
	open(loc);
	run("32-bit"); //Convert to black and white
	t1 = getTime();
	run("Mean 3D...", "x=3 y=3 z=3");
	t2 = getTime();
	close();
	print("ImageJ;"+ list[i] + ";" + (t2-t1));

	open(loc);
	run("32-bit"); //Convert to black and white
	bw = getTitle(); 
	t3 = getTime();
	Ext.CLIJ2_push(bw);
	Ext.CLIJ_mean3DBox(bw, med, 3, 3, 3);
	Ext.CLIJ2_pull(med);
	t4 = getTime();
	close();
	print("CLIJ2;"+ list[i] + ";" + (t4-t3));
}
setBatchMode(false);