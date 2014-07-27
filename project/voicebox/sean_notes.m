iterationList = [1:10:100];
j = 1;
for i = iterationList
	while(j < i)
		j
		j = j + 1;
	end
	endfortime = j
end

fileID = fopen('nine.bin','w');
fwrite(fileID,[1:9],'uint8');
fclose(fileID);

fileID = fopen('nine.bin');
A = fread(fileID, 'uint8')
whos A
fclose(fileID);