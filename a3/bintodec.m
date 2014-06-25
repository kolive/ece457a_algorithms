% Convert a binary string into a decimal number
function [dec]=bintodec(bin, range)
% Length of the string without sign
nn=length(bin)-1;
num=bin(2:end); % get the binary
% Sign=+1 if bin(l)=0; Sign=-l if bin(l)=l.
Sign=1-2*bin(1);
dec=0;
% floating point/decimal place in a binary string
dp=floor(log2(max(abs(range))));
for i=1:nn,
dec=dec+num(i)*2^(dp-i);
end
dec=dec*Sign;
