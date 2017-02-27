
%% open input file and read data
[inputfile, inputpath] = uigetfile('*.txt', 'Choose an INPUT file:')
[inputID, message] = fopen([inputpath, inputfile], 'r');
if inputID == -1
	disp(message)
end

frac = fscanf(inputID, '%g %g', [2 inf]);
frac = frac';

%% change directory to source of input
originalpath = cd;
cd(inputpath);

%% open output file
[outputfile, outputpath] = uiputfile('output.txt', 'Choose an OUTPUT file:')
[outputID, message] = fopen([outputpath, outputfile], 'a');
if outputID == -1
	disp(message)
end

%% reset directory to original
cd(originalpath);

%% parse INPUT header info
Levels = frac(1,1);
FracNum = frac(1,2);
minBox = frac(2,1);
maxBox = frac(2,2);
MapX = frac(3,1);
MapY = frac(3,2);

%% set some initial values and create needed arrays
Count_It = false;

x1 = 0.0;
x2 = 0.0;
y1 = 0.0;
y2 = 0.0;
		
Mult = exp(log(maxBox / minBox) / (Levels - 1));

boxSize = zeros(Levels, 1);
Count = zeros(Levels, 1);

for i = 1:1:Levels  %% i do-loop for box size
	
	if i == 1
		boxSize(i) = maxBox;
	else
		boxSize(i) = boxSize(i-1) / Mult;
	end
	
	Count(i) = 0;
	
	for j = 1:1:(floor(MapY / boxSize(i)) + 1)  %% j do-loop for Y-direction
		
		y1 = y2;
		y2 = j * boxSize(i);
		
		for k = 1:1:(floor(MapX / boxSize(i)) + 1)  %% k do-loop for X-direction
			
			x1 = x2;
			x2 = k * boxSize(i);
			
			for m = 4:1:(FracNum+3)  %% m do-loop for all fractures
				
				if(((x1 <= frac(m,1)) && (frac(m,1) < x2)) && ((y1 <= frac(m,2)) && (frac(m,2) < y2)))
					Count_It = true;
				end
				
				if Count_It == true
					break
				end  %% don't bother checking the rest
				
			end  %% m do-loop for all fractures
			
			if Count_It == true
				
				if x2 > MapX
					if y2 > MapY
						area = (MapX - x1) * (MapY - y1) / (boxSize(i) * boxSize(i));
					else
						area = (MapX - x1) / boxSize(i);
					end
				elseif y2 > MapY
					area = (MapY - y1) / boxSize(i);
				else
					area = 1.0;
				end
				
				Count(i) = Count(i) + area;
				Count_It = false;
				
			end  %% if Count_It true
			
		end  %% k do-loop for X-direction
		
		x1 = 0.0;
		x2 = 0.0;
		
	end  %% j do-loop for Y-direction
	
	y1 = 0.0;
	y2 = 0.0;
	
	%% write results to output file and command window
	fprintf(outputID, '%20.12f\t %20.12f\n', boxSize(i), Count(i));
	
	printout = sprintf('%20.12f %20.12f', boxSize(i), Count(i));
	disp(printout);
	
end  %% i-do loop for box size

%% close input and output files
status = fclose('all');
