
%% clear memory before starting
clear

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

%% open output file (defaults to directory of input file)
[outputfile, outputpath] = uiputfile('output2.txt', 'Choose an OUTPUT file:')
[outputID, message] = fopen([outputpath, outputfile], 'a');
if outputID == -1
	disp(message)
end

%% reset directory to original
cd(originalpath);

%% parse input header info
Levels = frac(1,1);
FracNum = frac(1,2);
minBox = frac(2,1);
maxBox = frac(2,2);
MapX = frac(3,1);
MapY = frac(3,2);

%% set some initial values and create needed arrays
Count_It = false;

if Levels == 1
	Mult = 1;
else
	Mult = (maxBox / minBox)^(1 / (Levels - 1));
end

boxSize = zeros(Levels, 1);
Count = zeros(Levels, 1);
VertexNum = zeros(FracNum,1);

%% parse number of vertices for each fracture trace
temp = 0.0;
for i = 1:1:FracNum
	VertexNum(i) = frac(3+i+temp,1);
	temp = temp + VertexNum(i);
end

for i = 1:1:Levels  %% i do-loop for box size
	
	boxSize(i) = maxBox / Mult^(i-1);	
	
	clear Counter edgeX edgeY Corner
	
	Counter = logical(zeros(ceil(eps + MapX/boxSize(i)), ceil(eps + MapY/boxSize(i))));
	
	edgeX = logical(zeros(1, ceil(eps + MapX/boxSize(i))));
	
	edgeY = logical(zeros(1, ceil(eps + MapY/boxSize(i))));
	
	Corner = false;
	
	temp = 0.0;
	
	for m = 1:1:FracNum  %% m do-loop for all fractures
		
		temp = temp + VertexNum(m);
		
		for n = (1-VertexNum(m)):1:(-1)  %% n do-loop for all fracture segments
			
			maxX = ceil(eps + max(frac(3+m+temp+n,1), frac(3+m+temp+n + 1,1))/boxSize(i));
			minX = ceil(eps + min(frac(3+m+temp+n,1), frac(3+m+temp+n + 1,1))/boxSize(i));
			
			maxY = ceil(eps + max(frac(3+m+temp+n,2), frac(3+m+temp+n + 1,2))/boxSize(i));
			minY = ceil(eps + min(frac(3+m+temp+n,2), frac(3+m+temp+n + 1,2))/boxSize(i));
			
			for j = minY:1:maxY  %% j do-loop for Y-direction
				
				y1 = (j-1) * boxSize(i);
				y2 = j * boxSize(i);
				
				for k = minX:1:maxX  %% k do-loop for X-direction
					
					x1 = (k-1) * boxSize(i);
					x2 = k * boxSize(i);
					
					if(frac(3+m+temp+n,1) == frac(3+m+temp+n + 1,1))
						if((x1 <= frac(3+m+temp+n,1)) && (frac(3+m+temp+n,1) < x2))
							Count_It = true;
						end
					elseif(frac(3+m+temp+n,2) == frac(3+m+temp+n + 1,2))
						if((y1 <= frac(3+m+temp+n,2)) && (frac(3+m+temp+n,2) < y2))
							Count_It = true;
						end
						
					else
						
						slope = (frac(3+m+temp+n + 1,2) - frac(3+m+temp+n,2)) / (frac(3+m+temp+n + 1,1) - frac(3+m+temp+n,1));
						intercept = frac(3+m+temp+n,2) - slope * frac(3+m+temp+n,1);
						
						if((y1 <= slope * x1 + intercept) && (slope * x1 + intercept < y2))
							Count_It = true;
						elseif((y1 <= slope * x2 + intercept) && (slope * x2 + intercept < y2))
							Count_It = true;
						elseif((x1 <= (y1 - intercept) / slope) && ((y1 - intercept) / slope < x2))
							Count_It = true;
						elseif((x1 <= (y2 - intercept) / slope) && ((y2 - intercept) / slope < x2))
							Count_It = true;
						end
						
					end
					
					if (Count_It == true)
						
						if (Counter(k,j) == false)
							if y2 <= MapY
								if x2 <= MapX
									Counter(k,j) = true;
								else
									edgeX(j) = true;
								end
							else
								if x2 <= MapX
									edgeY(k) = true;
								else
									Corner = true;
								end
							end
						end
						
						Count_It = false;
						
					end  %% if Count_It true
					
				end  %% k do-loop for X-direction
				
			end  %% j do-loop for Y-direction
			
		end  %% n do-loop for all frac segments
		
	end  %% m do-loop for all fractures
	
	Count(i) = sum(sum(Counter));
	Count(i) = Count(i) + sum(edgeX) * (MapX/boxSize(i) - floor(MapX/boxSize(i)));
	Count(i) = Count(i) + sum(edgeY) * (MapY/boxSize(i) - floor(MapY/boxSize(i)));
	Count(i) = Count(i) + Corner * (MapX/boxSize(i) - floor(MapX/boxSize(i))) * (MapY/boxSize(i) - floor(MapY/boxSize(i)));
	
	%% write results to output file and command window
	fprintf(outputID, '%20.12f\t %20.12f\n', boxSize(i), Count(i));
	
	printout = sprintf('%20.12f %20.12f', boxSize(i), Count(i));
	disp(printout);
	
end  %% i do-loop for box size

%% close input and output files
status = fclose('all');
