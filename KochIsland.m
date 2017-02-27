
%% open output file
[outputfile, outputpath] = uiputfile('output.txt', 'Choose an OUTPUT file:')
[outputID, message] = fopen([outputpath, outputfile], 'w');
if outputID == -1
	disp(message)
end

%% set initial values and create needed array
Levels = 7;

R = 2 * 3^(Levels-1);
OldPoint = zeros(3*4^(Levels-2)+1,2);
NewPoint = zeros(3*4^(Levels-1)+1,2);

N = 3;

NewPoint(1,1) = 1;
NewPoint(1,2) = 1 + R * sqrt(3)/2;

NewPoint(2,1) = 1 + R;
NewPoint(2,2) = 1 + R * sqrt(3)/2;

NewPoint(3,1) = 1 + R / 2;
NewPoint(3,2) = 1;

NewPoint(4,1) = 1;
NewPoint(4,2) = 1 + R * sqrt(3)/2;

for i = 1:1:(Levels-1)  %% i do-loop for order of island
	
	for j = 1:1:N+1
		
		OldPoint(j,1) = NewPoint(j,1);
		OldPoint(j,2) = NewPoint(j,2);
		
	end
	
	NewPoint(1,1) = OldPoint(1,1);
	NewPoint(1,2) = OldPoint(1,2);
	
	for j = 1:1:N  %% j do-loop for propagation of points
		
		NewPoint((j-1)*4+2,1) = (2*OldPoint(j,1) + OldPoint(j+1,1))/3;
		NewPoint((j-1)*4+2,2) = (2*OldPoint(j,2) + OldPoint(j+1,2))/3;
		
		NewPoint((j-1)*4+3,1) = (OldPoint(j,1) + OldPoint(j+1,1))/2 + (OldPoint(j,2) - OldPoint(j+1,2))/sqrt(12);
		NewPoint((j-1)*4+3,2) = (OldPoint(j,2) + OldPoint(j+1,2))/2 + (OldPoint(j+1,1) - OldPoint(j,1))/sqrt(12);
		
		NewPoint((j-1)*4+4,1) = (OldPoint(j,1) + 2*OldPoint(j+1,1))/3;
		NewPoint((j-1)*4+4,2) = (OldPoint(j,2) + 2*OldPoint(j+1,2))/3;
		
		NewPoint((j-1)*4+5,1) = OldPoint(j+1,1);
		NewPoint((j-1)*4+5,2) = OldPoint(j+1,2);
		
	end  %% j do-loop for propagation of points
	
	N = N * 4;
	
end  %% i-do loop for order of island

%% write results to output file
fprintf(outputID, '%g\t %g\n', N+1, 1);
for i = 1:1:N+1
	fprintf(outputID, '%g\t %20.12f\n', NewPoint(i,1), NewPoint(i,2));
end
	
%% close output file
status = fclose('all');
