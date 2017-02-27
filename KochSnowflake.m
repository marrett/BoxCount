
%% open output file
[outputfile, outputpath] = uiputfile('output.txt', 'Choose an OUTPUT file:')
[outputID, message] = fopen([outputpath, outputfile], 'w');
if outputID == -1
	disp(message)
end

%% set initial values and create needed array
Levels = 7;

R = 2 * 3^Levels;
Point = zeros(5^Levels,2);

Point(1,1) = R / 2;
Point(1,2) = R / 2;

N = 1;
Offset = R / 3;

for i = 1:1:Levels  %% i do-loop for order of snowflake
	
	for j = 1:1:N  %% j do-loop for propagation of points
		
		Point(N+(j-1)*4+1,1) = Point(j,1) + Offset;
		Point(N+(j-1)*4+1,2) = Point(j,2) + Offset;
		
		Point(N+(j-1)*4+2,1) = Point(j,1) + Offset;
		Point(N+(j-1)*4+2,2) = Point(j,2) - Offset;
		
		Point(N+(j-1)*4+3,1) = Point(j,1) - Offset;
		Point(N+(j-1)*4+3,2) = Point(j,2) - Offset;
		
		Point(N+(j-1)*4+4,1) = Point(j,1) - Offset;
		Point(N+(j-1)*4+4,2) = Point(j,2) + Offset;
		
	end  %% j do-loop for propagation of points
	
	N = N * 5;
	Offset = Offset / 3;
	
end  %% i-do loop for order of snowflake

%% write results to output file
for i = 1:1:5^Levels
	fprintf(outputID, '%g\t %g\n', Point(i,1), Point(i,2));
end
	
%% close output file
status = fclose('all');
