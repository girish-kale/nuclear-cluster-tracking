// This macro assists with processing hyperstacks using the 'Local Z Projector' plugin.
// Pre-determine the hyperstack to be processed.  
close("*");		//print("\\Clear");		//run("Clear Results");

File.openDialog("Open the hyperstack for Local Z projection");

name=File.nameWithoutExtension;
folder=File.directory;
date=File.getName(folder);			//'date' is the name of the 'target' folder

//
open(folder+name+".tif");
//run("TIFF Virtual Stack...", "open=["+folder+name+".tif]");
getDimensions(width, height, channels, slices, frames);

//open(folder+"MAX_"+name+"_pre-cellularization.csv");	IJ.renameResults("Results");
selectWindow(name+".tif");
	
Dialog.createNonBlocking("select frame for...");
Dialog.addMessage("the beginning...");
Dialog.setLocation(1500,-200);
Dialog.show();

Stack.getPosition(channel, slice, begin);

Dialog.createNonBlocking("select frame for...");
Dialog.addMessage("the ending...");
Dialog.setLocation(1500,-200);
Dialog.show();

Stack.getPosition(channel, slice, end);

selectWindow(name+".tif");
run("Duplicate...", "title=["+name+"] duplicate channels=1-2 slices=1-"+slices+" frames="+begin+"-"+end);

close(name+".tif");			rename(name+".tif");		run("Collect Garbage");

Dialog.createNonBlocking("the direction for correction");
Dialog.addMessage("Jup-GFP is shifted to...");
Dialog.addCheckbox("Left", false);
Dialog.addCheckbox("Right", false);
Dialog.setLocation(1500,-200);
Dialog.show();

left=Dialog.getCheckbox();
right=Dialog.getCheckbox();

if (left || right) {
	run("Split Channels");
	selectWindow("C1-"+name+".tif"); // His-RFP
	selectWindow("C2-"+name+".tif"); // Jup-GFP
	
	if (left==1){	// if Jup-GFP is shifted to left
		selectWindow("C2-"+name+".tif"); // Jup-GFP
		run("Canvas Size...", "width=1032 height=512 position=Center-Right zero");
		selectWindow("C1-"+name+".tif"); // His-RFP
		run("Canvas Size...", "width=1032 height=512 position=Center-Left zero");
	}else if (right==1){	// if Jup-GFP is shifted to right
		selectWindow("C2-"+name+".tif"); // Jup-GFP
		run("Canvas Size...", "width=1032 height=512 position=Center-Left zero");
		selectWindow("C1-"+name+".tif"); // His-RFP
		run("Canvas Size...", "width=1032 height=512 position=Center-Right zero");
	}
	
	//imageCalculator("Add create stack", "C1-"+name+".tif","C2-"+name+".tif");
	//selectWindow("Result of C1-"+name+".tif");			rename("C3-"+name+".tif");
	//run("Merge Channels...", "c1=[C1-"+name+".tif] c2=[C2-"+name+".tif] c3=[C3-"+name+".tif] create");
	
	run("Merge Channels...", "c1=[C1-"+name+".tif] c2=[C2-"+name+".tif] create");
	//setTool("zoom");
	rename(name+".tif");		Stack.setDisplayMode("grayscale");
}
run("Local Z Projector");
//run("LZP execute");

Dialog.createNonBlocking("pause...");
Dialog.addMessage("... for Local Z projection");
Dialog.setLocation(1500,-100);
Dialog.show();

close(name+".tif");		rename(name+"_LZP.tif");		Stack.setDisplayMode("grayscale");

save(folder+date+"_"+name+"_t"+begin+"-"+end+"_LZP.tif");

close("*");			run("Collect Garbage");

exit();

