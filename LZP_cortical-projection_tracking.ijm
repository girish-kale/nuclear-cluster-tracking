// In this macro, we split the Local Z projection output stacks into cortical and yolk regions, and then 
// also separate the histone and jupiter channels and save them. So, in effect we create 4 timelapses.
// All are saved at 16-bit to save disk space, while retaining the dynamic range

print("\\Clear");
numFolders=getNumber("Number of conditions =", 8); // This should be double the number of genotypes

while (numFolders>0){
	path=getDirectory("Open the folder with LZPed hyperstacks");	print(path);
	
	numFolders=numFolders-1;
}

list=getInfo("log");
data_folders=split(list, "\n");

print("\\Clear");

folder=0;

while (folder<data_folders.length){ // While loop through genotypes and temperatures
	
	//folder=getDirectory("Choose a folder with movies");	files=getFileList(folder);

	files=getFileList(data_folders[folder]);
	
	file=0;
	setBatchMode(true); // this makes the code run much faster
	
	while(file<files.length){ // While loop over files
	
		existance=indexOf(files[file],"LZP");
		
		if (existance>0){ // IF statement to pick Local Z Projected files
	
			open(data_folders[folder]+files[file]);		name=File.nameWithoutExtension;
			
			newName=substring(name, 0, indexOf(name,"_LZP"));		print(data_folders[folder]+newName);
	
			selectWindow(name+".tif");		run("Duplicate...", "title=["+newName+"_cortical_DNA] duplicate channels=1 slices=1-8");
			selectWindow(newName+"_cortical_DNA");				run("Z Project...", "projection=[Sum Slices] all");
			selectWindow("SUM_"+newName+"_cortical_DNA");		run("Blue");		setMinAndMax(0, 65535);		run("16-bit");
			resetMinAndMax();
			//save(data_folders[folder]+newName+"_cortical_DNA.tif");

			selectWindow(name+".tif");		run("Duplicate...", "title=["+newName+"_apical_MT] duplicate channels=2 slices=1-6");
			selectWindow(newName+"_apical_MT");				run("Z Project...", "projection=[Sum Slices] all");
			selectWindow("SUM_"+newName+"_apical_MT");		run("Magenta");		setMinAndMax(0, 65535);		run("16-bit");
			resetMinAndMax();
			//save(data_folders[folder]+newName+"_apical_MT.tif");

			selectWindow(name+".tif");		run("Duplicate...", "title=["+newName+"_sub-apical_MT] duplicate channels=2 slices=7-12");
			selectWindow(newName+"_sub-apical_MT");				run("Z Project...", "projection=[Sum Slices] all");
			selectWindow("SUM_"+newName+"_sub-apical_MT");		run("Grays");		setMinAndMax(0, 65535);		run("16-bit");
			run("Multiply...", "value=0 stack"); // Could have just created an empty stack. But, what's the fun in that :P
			//save(data_folders[folder]+newName+"_sub-apical_MT.tif");
			
			run("Merge Channels...", "c1=[SUM_"+newName+"_sub-apical_MT] c2=[SUM_"+newName+"_sub-apical_MT] c3=[SUM_"+newName+"_sub-apical_MT] c4=[SUM_"+newName+"_cortical_DNA] c5=[SUM_"+newName+"_apical_MT] create");
			rename(newName+"_track.tif");			save(data_folders[folder]+newName+"_track.tif");

			close("*");
			
		} // IF statement to pick Local Z Projected files
		
		file=file+1;
	} // While loop over files
	
	run("Collect Garbage");		setBatchMode("exit and display");
	folder=folder+1;

} // While loop through genotypes and temperatures
exit();

