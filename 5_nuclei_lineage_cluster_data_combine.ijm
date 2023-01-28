//run("Set Measurements...", "area mean centroid center redirect=None decimal=6");
//run("Set Measurements...", "area centroid perimeter shape redirect=None decimal=6");
run("Set Measurements...", "area mean standard centroid center perimeter shape redirect=None decimal=6");			

print("\\Clear");
numFiles=getNumber("Number of repeats =", 10); // This should be the number of embryos

do{
	File.openDialog("Open the CSV file to be combined");
	numFiles=numFiles-1;

}while (numFiles>0)

list=getInfo("log");
data_files=split(list, "\n");

print("\\Clear");		run("Clear Results");

xStdPrint="x_std";		xInterStdPrint="xInter_std";		xTeloStdPrint="xTelo_std";		xSlopePrint="xSlope";
yStdPrint="y_std";		yInterStdPrint="yInter_std";		yTeloStdPrint="yTelo_std";		ySlopePrint="ySlope";

repeats=0;
do{ // an DO...WHILE loop over embryos
	
	open(data_files[repeats]);		name=File.name;
	
	tracks=Table.getColumn("TrackID");
	
	xStdPrint=xStdPrint+"\ne"+(repeats+1);					x_std=Table.getColumn("x_std");
	yStdPrint=yStdPrint+"\ne"+(repeats+1);					y_std=Table.getColumn("y_std");
	
	xInterStdPrint=xInterStdPrint+"\ne"+(repeats+1);		xInter_std=Table.getColumn("xInter_std");
	yInterStdPrint=yInterStdPrint+"\ne"+(repeats+1);		yInter_std=Table.getColumn("yInter_std");
	
	xTeloStdPrint=xTeloStdPrint+"\ne"+(repeats+1);			xTelo_std=Table.getColumn("xTelo_std");
	yTeloStdPrint=yTeloStdPrint+"\ne"+(repeats+1);			yTelo_std=Table.getColumn("yTelo_std");
	
	xSlopePrint=xSlopePrint+"\ne"+(repeats+1);				x_slope=Table.getColumn("x_slope");
	ySlopePrint=ySlopePrint+"\ne"+(repeats+1);				y_slope=Table.getColumn("y_slope");
	
	run("Clear Results");		close(name);
	
	for(track=0; track<tracks.length; track++){
		
		xStdPrint=xStdPrint+","+x_std[track];
		yStdPrint=yStdPrint+","+y_std[track];
		
		xInterStdPrint=xInterStdPrint+","+xInter_std[track];
		yInterStdPrint=yInterStdPrint+","+yInter_std[track];
		
		xTeloStdPrint=xTeloStdPrint+","+xTelo_std[track];
		yTeloStdPrint=yTeloStdPrint+","+yTelo_std[track];
		
		xSlopePrint=xSlopePrint+","+x_slope[track];
		ySlopePrint=ySlopePrint+","+y_slope[track];
		
	}
	
repeats=repeats+1;
}while (repeats<data_files.length) // an DO...WHILE loop over embryos

print(xStdPrint);		print(yStdPrint);
print(xInterStdPrint);	print(yInterStdPrint);
print(xTeloStdPrint);	print(yTeloStdPrint);
print(xSlopePrint);		print(ySlopePrint);

target=getDirectory("Choose a folder to save the data");

selectWindow("Log");
saveAs("Text...",target+"/nuclear clusters data 2.csv");

exit();
//////////////////////////////////////////////////// end of the code //////////////////////////////////////////////////////////////////////////////
