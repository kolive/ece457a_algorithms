function [x]=bintox(bin, ndimensions)
%split the binary number into equal parts and convert them
bin = reshape(bin, [], 2)';
x = zeros(1,size(bin,1));
for i=1:size(bin,1)
    bin(i,:);
    x(i) = bintodec(bin(i,:), [-1 1]);
end
x = x';