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

[paramscore, adaptedparams]=adaptiveAcoTweaking('audio2.wav', 'audio2.tag', 40, 10, 0.5, 1/8, 10)

% Fix the awkward reference to other sections. Use labels instead.