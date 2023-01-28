//run("Set Measurements...", "area mean centroid center redirect=None decimal=6");
//run("Set Measurements...", "area centroid perimeter shape redirect=None decimal=6");
run("Set Measurements...", "area mean standard centroid center perimeter shape redirect=None decimal=6");			

inf=0;
do{
// an infinite DO...WHILE loop
	
folder=getDirectory("Choose a folder with tracks from one embryo"); // this should be the folder '.... tracked lineages'

target=File.getParent(folder);		//'target' would be the corresponding 'nuclei cluster tracking' folder

embryoName=File.getName(folder);	embryoName=substring(embryoName, 0, indexOf(embryoName, "_tracked"));	// embryo name would be useful later on

files=getFileList(folder);			run("Clear Results");

// Now we'll start collecting the average coordinates for individual clusters
// and the data on the number of cells.

xAvgAll=newArray(0);		yAvgAll=newArray(0);		numCellAll=newArray(0);		trackIDAll=newArray(0);		file=0;
do{ // DO-WHILE loop through files 

	if (endsWith(files[file],"_stats.csv")) { // IF statement to skip CSV files with raw data
		open(folder+files[file]);		name=File.nameWithoutExtension;
		
		trackID=substring(name, 0, indexOf(name,"_stats"));
		trackIDAll=Array.concat(trackIDAll,trackID);
		
		xAvg=Table.getColumn("x_avg");			xAvgAll=Array.concat(xAvgAll,xAvg);
		yAvg=Table.getColumn("y_avg");			yAvgAll=Array.concat(yAvgAll,yAvg);		
		numCell=Table.getColumn("#Nuclei");		numCellAll=Array.concat(numCellAll,numCell);
		
		run("Clear Results");		close(files[file]);
		
	} // IF statement to skip CSV files with raw data

	file=file+1;
}while(file<files.length) // DO-WHILE loop through files

trackLength=numCellAll.length/trackIDAll.length;

// these will be used to determine the nuclear cycle status 'flag'. See details below...
states=newArray(1, 2, 4, 8);	teloCounter=6;		count=0;

for (t=0; t<trackLength; t++){ // FOR loop for populating the final results table, one timepoint at a time
	
// First we'll calculate and write the average xy-coordinates of the center of masses of all the clusters,
// for that timepoint. This could be useful to cross-check if there is significant x-y drift.

// We'll also write the average number of nuclei.
	
	xAvg=0;		yAvg=0;		nAvg=0;
	for (id=0; id<trackIDAll.length; id++){
		xAvg=xAvg+xAvgAll[t+id*trackLength];
		yAvg=yAvg+yAvgAll[t+id*trackLength];
		nAvg=nAvg+numCellAll[t+id*trackLength];
	}
	xAvg=xAvg/trackIDAll.length;	yAvg=yAvg/trackIDAll.length;	nAvg=nAvg/trackIDAll.length;
	
	// Center of mass for all clusters
	setResult("x_avg", t, xAvg);	setResult("y_avg", t, yAvg);
	// average number of nuclei
	setResult("n_avg", t, nAvg);

// Now we determine the timepoints in which the nuclei move a lot. Typically these movements/timepoints
// occur around telophases. Empirically, the movements start a frame before any of the nuclei enter
// telophase, i.e., during anaphase, and go on for about 3 minutes after.
// Here, we are starting telophase as soon as any of the tracked nuclei divide. In general, the telophases
// start outside the field of view, but we have no clear way of telling exactly when. So, we are doing
// the best that we can.

// In theory, we can have a different definition of how we calculate the start and end of movements.
// Adding the flag, thus, also helps with calculations in the next phase, for the 'stats' file.

// Note that the question is, do nuclear clusters move more at around the time of mitosis. Thus, the
// definition of the phase of movement is centered around 'when mitosis takes place', rather than
// 'when nuclei move'.

//////// current definition of flag ////////
// The nuclear movements start at least one frame before any of the nuclei enter telophase.
// Presumably, this is also because of the extension of the spindles during anaphase. So, we'll identify
// the end of telophase, and go back 1 timepoint. (see below)
// Also, we are considering that the effect of telophase goes on for 3 minutes, after the telophase is
// over for all nuclear clusters. This would correspond to 6 frames. This duration is defined in the
// 'teloCounter' array above.
	
	// IF...ELSE statements to set the 'flag'
	
	if (nAvg==states[count]){ // all nuclei in interphase to anaphase
		setResult("flag", t, 0);
		teloCount=teloCounter;
	
	}else if (nAvg<states[count+1]){ // some nuclei in anaphase others in telophase
		setResult("flag", t, 1);
		teloCount=teloCounter;
		
	// Considering that the nuclear movements seem to start at least one frame before the
	// actual nuclear division, we will extend the 'flag' one frame back in time.
	// So, IF this is the first time 'flag' is set to 1, then we'll change the 'flag' of 
	// the previous timepoint to 1 as well.
		if (getResult("flag", t-1)==0){
			setResult("flag", t-1, 1);
		}
	
	}else{ // all nuclei either in telophase or the following interphase
		setResult("flag", t, 1);
		teloCount=teloCount-1;
		
	// Similar to above, just in case the telophase is synchronous across the entire embryo
		if (getResult("flag", t-1)==0){
			setResult("flag", t-1, 1);
		}
	
	} // IF...ELSE statements to set the 'flag'
	
	if (teloCount==0){
		count=count+1;
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
//////// Alternative definition of flag ////////
// Here, we are starting telophase as soon as any of the tracked nuclei divide. In general, the telophases
// start outside the field of view, but we have no clear way of telling exactly when. So, we are doing the best
// that we can. Also, we are considering that the effect of telophase goes on for 3, 4, and 5 minutes, for
// telophase 10, 11, and 12, respectively. This would correspond to 6, 8, and 10 frames, respectively.
// These durations are defined in the 'teloCounter' array above. The additional '12' is never realized, and
// is added for the sake of the code working properly.
				
//	if (nAvg==states[count]){
//		setResult("flag", t, 0); // not telophase
//		teloCount=teloCounter[count];
//	}else{
//		setResult("flag", t, 1); // telophase
//		teloCount=teloCount-1;
//	}
//
//	if (teloCount==0){
//		count=count+1;
//	}	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// We'll now write the xy-coordinates for the center of mass of various clusters, for that timepoint
	
	setResult(" ", t, ""); // spacer coloumn #1
	
	for (id=0; id<trackIDAll.length; id++){ // write x-coordinates
		setResult(trackIDAll[id]+"_x", t, xAvgAll[t+id*trackLength]);
	}
	
	setResult("  ", t, ""); // spacer coloumn #2
	
	for (id=0; id<trackIDAll.length; id++){ // write y-coordinates
		setResult(trackIDAll[id]+"_y", t, yAvgAll[t+id*trackLength]);
	}

// We'll now write the number of nuclei in the clusters, for that timepoint
		
	setResult("   ", t, ""); // spacer coloumn #3
	
	for (id=0; id<trackIDAll.length; id++){ // write number of nuclei
		setResult(trackIDAll[id]+"_n", t, numCellAll[t+id*trackLength]);
	}
	
} // FOR loop for populating the final results table, one timepoint at a time

saveAs("Results",target+"/"+embryoName+"_track-combined.csv");

open(target+"/"+embryoName+"_track-combined.csv");
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Now we start constructing a new file, which summarizes the data even further.

// Here, we'll calculate one parameter for the entire track. The parameter of choice is the 'averaged distances'.
// The distances will be calculated, relative to the straight-line fit through the coordinates. We'll use the 
// 'Fit.doFit(equation, xpoints, ypoints)' function for fitting the data. Both, x and y coordinates will be the
// 'ypoints' of the fit, while the 'xpoints' will be generated below, using 'Array.getSequence(n)'.

// We'll calculate this for the x and y coordinates, over time, to see how much the track "wiggled".
// We'll also do additional calculations, where we'll estimate the "wiggling", separately for timepoints that
// have 'flag' 0 vs 1. See the 'flag' definitions above.

idPrint=newArray(0);

xStdPrint=newArray(0);		xInterStdPrint=newArray(0);		xTeloStdPrint=newArray(0);
yStdPrint=newArray(0);		yInterStdPrint=newArray(0);		yTeloStdPrint=newArray(0);
xSlopePrint=newArray(0);	ySlopePrint=newArray(0);
// use of Std doesn't literally mean that we are calculating standard deviaions. It is just for sake of convenience.

// We'll construct arrays with 'distances' (dx and dy), and then calculate their average using
// the 'mean' from 'Array.getStatistics'

for (id=0; id<trackIDAll.length; id++){ // calculations FOR that track
	// Add the cluster ID
	idPrint=Array.concat(idPrint,trackIDAll[id]);
	
	// Now getColumns, and estimate the 'distances', over time
	
	x=Table.getColumn(trackIDAll[id]+"_x");			dx=newArray(x.length);		xpoints=Array.getSequence(x.length);
	Fit.doFit("Straight Line", xpoints, x);			
	
	xSlopePrint=Array.concat(xSlopePrint,Fit.p(1)*2); // multiplying by 2 as the frame rate is 1/2 min
	
	for (t=0; t<trackLength; t++) { // FOR loop to polulate the array with distances along AP.
		dx[t]=abs(x[t]-Fit.f(t));
	} // FOR loop to polulate the array with distances along AP.
	
	y=Table.getColumn(trackIDAll[id]+"_y");			dy=newArray(y.length);
	Fit.doFit("Straight Line", xpoints, y);			
	
	ySlopePrint=Array.concat(ySlopePrint,Fit.p(1)*2); // multiplying by 2 as the frame rate is 1/2 min
	
	for (t=0; t<trackLength; t++) { // FOR loop to polulate the array with distances along DV.
		dy[t]=abs(y[t]-Fit.f(t));
	} // FOR loop to polulate the array with distances along DV.
	
	// Calculating the average of these distances along AP axis (dx) and DV axis (dy).
	Array.getStatistics(dx, min, max, mean, stdDev);		xStdPrint=Array.concat(xStdPrint, mean);
	Array.getStatistics(dy, min, max, mean, stdDev);		yStdPrint=Array.concat(yStdPrint, mean);
	
	// Now we'll split the above arrays using the "flag" column, and perform the calculations separately

	xInter=newArray(0);		yInter=newArray(0); // for the low movement phase
	xTelo=newArray(0);		yTelo=newArray(0);  // for the high movement phase
	
	flag=Table.getColumn("flag");
	
	for (t=0; t<trackLength; t++){ // FOR loop for going through results table, one timepoint at a time
		
		if (flag[t]==0){
			// IF low movement
			xInter=Array.concat(xInter,dx[t]);		yInter=Array.concat(yInter,dy[t]);
			
		}else{
			// ELSE high movement
			xTelo=Array.concat(xTelo,dx[t]);		yTelo=Array.concat(yTelo,dy[t]);
			
		}
	} // FOR loop for going through results table, one timepoint at a time
	
	Array.getStatistics(xInter, min, max, mean, stdDev);		xInterStdPrint=Array.concat(xInterStdPrint, mean);
	Array.getStatistics(yInter, min, max, mean, stdDev);		yInterStdPrint=Array.concat(yInterStdPrint, mean);
	
	Array.getStatistics(xTelo, min, max, mean, stdDev);			xTeloStdPrint=Array.concat(xTeloStdPrint, mean);
	Array.getStatistics(yTelo, min, max, mean, stdDev);			yTeloStdPrint=Array.concat(yTeloStdPrint, mean);
	
} // calculations FOR that track

run("Clear Results");		close(embryoName+"_track-combined.csv");

for (id=0; id<trackIDAll.length; id++){ // write the data FOR that track
	setResult("TrackID", id, idPrint[id]);

	setResult("x_std", id, xStdPrint[id]);
	setResult("y_std", id, yStdPrint[id]);
	
	setResult("xInter_std", id, xInterStdPrint[id]);
	setResult("yInter_std", id, yInterStdPrint[id]);
	
	setResult("xTelo_std", id, xTeloStdPrint[id]);
	setResult("yTelo_std", id, yTeloStdPrint[id]);
	
	setResult("x_slope", id, xSlopePrint[id]);
	setResult("y_slope", id, ySlopePrint[id]);
	
} // write the data FOR that track

saveAs("Results",target+"/"+embryoName+"_track-stats.csv");

// an infinite DO...WHILE loop
}while (inf==0)

exit();

//////////////////////////////////////////////////// end of the code //////////////////////////////////////////////////////////////////////////////

