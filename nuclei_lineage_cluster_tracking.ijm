// This macro will assist in tracking the entire lineage of a nucleus. We'll follow nuclei as they divide,
// keeping a track from the end of interphase 10 till the end of interphase 13. The movies need to be
// prepared in advance. These can have multiple color channels, of which preferably some slices are blank,
// and will carry the tracks, which can be then saved for the purpose of presentation.

// The tracks will be saved with file names based on the xy-coordinate of the nuclei in the first frame. So,
// the tracks will be automatically sorted according to their anterior-posterior position. In other words,
// there is no need to track the nuclei sequentially from anterior or from the posterior region

// This macro will require 'Pick point tool advanced' to assist with tracking. So, we start with a reminder
//waitForUser("reminder to install 'Pick point tool advanced'");
run("Install...", "install=/Applications/Fiji.app/macros/Pick_point_tool_advanced.ijm");

run("Set Measurements...", "centroid center stack redirect=None decimal=6");

dialogX=1600;		dialogY=-250; // the location where the dialog boxes will appear

// We'll now open the pre-prepared stack for tracking
File.openDialog("Choose the prepared file for tracking");
name=File.nameWithoutExtension();		folder=File.directory();

open(folder+name+".tif");		Stack.getDimensions(width, height, channels, slices, frames);

shortName=substring(name, 0, indexOf(name, "_t"));

File.makeDirectory(folder+shortName+"_tracked_lineages/");
// the folder where all cluster tracks from one embryo will be saved

inf=0;
do{ // infinite Do-While loop
	
	xTrack=newArray(frames*8);		yTrack=newArray(frames*8);
	// frames*8, as the number of total tracks would be 8 in any followed cluster
	
	lineage=0;		lineages=newArray("1-000", "2-001", "3-010", "4-011", "5-100", "6-101", "7-110", "8-111", "9-done");
	// The binary string version will be used to identify the lineage tree of the nucleus beind tracked
	// the additional array item '9-done' will keep the array from running over too soon
	
	run("Clear Results");
	
	do{ // DO-WHILE loop over lineages
		Dialog.createNonBlocking("Tracking assist");		Dialog.setLocation(dialogX,dialogY);
		Dialog.addMessage("Select the identity of the lineage");
		Dialog.addChoice("Lineage = ", lineages, lineages[lineage]);
		Dialog.addMessage("Finish tracking this lineage\nand click Ok");
		Dialog.show();
		
		lineage=Dialog.getChoice();		lineage=substring(lineage, 0, indexOf(lineage, "-"));	lineage=parseInt(lineage)-1;
		
		if (lineage<9){
		
			if (nResults>frames && lineage>0){
				old=getResult("Frame", frames);		IJ.deleteRows(old-1, frames-1);
			}
			
			// Now we will manually check if there are correct number of lines in the results table or not.
			// Each line will correspond to one timepoint. If not, the macro will pause and ask us to check
			// the results table again, to make sure that there is one-on-one correspondance between result
			// table rows and the time points
			
			while(nResults!=frames){ // WHILE loop to check the one-on-one correspondance
				Dialog.createNonBlocking("check results table");		Dialog.setLocation(dialogX,dialogY);
				Dialog.addMessage("when results table is fine\nclick Ok");
				Dialog.show();
			} // WHILE loop to check the one-on-one correspondance
			
			// Now, we'll set aside the xy-coordinates of "picked points"
			for (i=0; i<frames; i++){
				xTrack[frames*lineage+i]=getResult("XM", i);		yTrack[frames*lineage+i]=getResult("YM", i);
			}
			// Note that depending on the value of 'lineage' we can, in theory, overwrite the existing track.
			// This could come in handy while doing corrections, on the fly.
		}
		
		lineage=lineage+1;
	
	} while (lineage<lineages.length) // DO-WHILE loop over lineages
	
	run("Clear Results");
	
	// now writing the individual xy-coordinate pairs
	for (i=0; i<frames; i++){
		setResult("x1", i, xTrack[frames*0+i]);		setResult("y1", i, yTrack[frames*0+i]);
		setResult("x2", i, xTrack[frames*1+i]);		setResult("y2", i, yTrack[frames*1+i]);
		setResult("x3", i, xTrack[frames*2+i]);		setResult("y3", i, yTrack[frames*2+i]);
		setResult("x4", i, xTrack[frames*3+i]);		setResult("y4", i, yTrack[frames*3+i]);
		setResult("x5", i, xTrack[frames*4+i]);		setResult("y5", i, yTrack[frames*4+i]);
		setResult("x6", i, xTrack[frames*5+i]);		setResult("y6", i, yTrack[frames*5+i]);
		setResult("x7", i, xTrack[frames*6+i]);		setResult("y7", i, yTrack[frames*6+i]);
		setResult("x8", i, xTrack[frames*7+i]);		setResult("y8", i, yTrack[frames*7+i]);
	} // the xy-coordinates of "picked points" are now written as raw data in Results table
	
	nameX=round(getResult("x1", 0));		nameY=round(getResult("y1", 0));
	// The xy-coordinates of the nuclei in the first frame will be used to generate a unique file name string
	// for each cluster, and would be used while saving both the raw tracks and stats.
	
	// Saving the raw data separately, so that it could be used for further calculations as needed. Alternatively, it could also be used
	// for adding the tracks on blank image movies, which can then be combined with the original movie for representation purposes.
	saveAs("Results", folder+shortName+"_tracked_lineages/"+IJ.pad(nameX, 3)+"_"+IJ.pad(nameY, 3)+"_raw-tracks.csv");	run("Clear Results");
	// raw tracks saved, results table wiped clean.
	
	for (i=0; i<frames; i++){
		// now we'll do some statistics with the coordinates
		x=newArray(xTrack[i], xTrack[frames*1+i], xTrack[frames*2+i], xTrack[frames*3+i], xTrack[frames*4+i], xTrack[frames*5+i], xTrack[frames*6+i], xTrack[frames*7+i]);
		y=newArray(yTrack[i], yTrack[frames*1+i], yTrack[frames*2+i], yTrack[frames*3+i], yTrack[frames*4+i], yTrack[frames*5+i], yTrack[frames*6+i], yTrack[frames*7+i]);
		
		Array.getStatistics(x, minX, maxX, meanX, stdDevX);		Array.getStatistics(y, minY, maxY, meanY, stdDevY);
		// Normally stdDev should always be a number. But, if that's not the case
		if (isNaN(stdDevX)){ stdDevX=0; }
		if (isNaN(stdDevY)){ stdDevY=0; }

		// then writing the averaged xy-coordinates
		setResult("x_avg", i, meanX);		setResult("y_avg", i, meanY);
		setResult("x_std", i, stdDevX);		setResult("y_std", i, stdDevY);
		
		if (round(maxX-minX+maxY-minY)==0){ // IF there is only one nucleus
		
			nNuclei=1;
		
		}else{ // ELSE we count how many nuclei (unique xy-coordinate pairs) there are
			
			nNuclei=1; // and then we increment
			
			for(count=0; count<7; count++){
			
				// the xy-coordinates of two points will be considered separate if they are at least a micron apart
				if (round(abs(x[count]-x[count+1])+abs(y[count]-y[count+1]))!=0){	nNuclei=nNuclei+1;	}
			
			} // FOR loop to count nuclei
		}
		setResult("#Nuclei", i, nNuclei);
		
	} // The coordinates for the 'center of mass', and a the number of nuclei in the cluster, is written in Results table
	
	saveAs("Results", folder+shortName+"_tracked_lineages/"+IJ.pad(nameX, 3)+"_"+IJ.pad(nameY, 3)+"_stats.csv");	run("Clear Results");
	// stats for various tracks saved, results table wiped clean
	
	inf=getBoolean("Want to continue tracking?");

}while (inf==1) // infinite Do-While loop

exit(); // optionally, we can also save the tracking, and then exit
