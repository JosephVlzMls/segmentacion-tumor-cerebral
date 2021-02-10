pkg load image;
pkg load statistics;

function B = img_scale(A)
	A = double(A);
	C = A - min(min(A));
	B = uint8(255 .* (C / max(max(C))));
endfunction

function sz = size_structuring_element(I)
	[n, m] = size(I);
	sz = floor(sqrt(min(n, m)) / 2);	
endfunction

function U = img_otsu(I)
	[n, m] = size(I);
	[Y, X] = imhist(I);
	Y /= n * m;
	Z = X .* Y;
	for k = 1 : 256
		P(k) = sum(Y(1 : k));
		M(k) = sum(Z(1 : k));	
	endfor	
	for k = 1 : 256
		V(k) = ((M(256) * P(k) - M(k)) ^ 2) / (P(k) * (1 - P(k)) + 0.000000001);
	endfor
	n = 0; maximum = max(V);
	for k = 1 : 256
		if(V(k) == maximum) A(++n) = k; endif
	endfor	
	k = sum(A) / n;
	U = im2bw(I, k / 255);
endfunction

function [A, M] = img_clean_background(I, sz)
	M = img_scale(double(I) .^ 5);
	M = img_otsu(M);
	M = imfill(M, "holes");
	M = imopen(M, strel("ball", sz, 0));
	A = I .* M;
endfunction

function [A, M] = img_remove_skull(I, S, sz)
	M = img_scale(double(I) .^ 8);
	M = img_otsu(M);
	M = (1 - M) .* S;
	M = imopen(M, strel("ball", round(sqrt(sz)), 0));
	M = imfill(M, "holes");
	M = imopen(M, strel("ball", sz, 0));
	M = imerode(M, strel("ball", round(sqrt(sz)), 0));
	C = bwconncomp(M);
	[biggest, index] = max(cellfun(@numel, C.PixelIdxList));
	M = zeros(size(I));
	M(C.PixelIdxList{index}) = 1;
	A = I .* M;
endfunction

function segmentada = img_segment(imagen_Original)
  [f,c,s] = size(imagen_Original);
  imData = reshape(double(imagen_Original),[],1);
  [idx,centers] = kmeans(imData,3);
  imidx = reshape(idx,size(imagen_Original));
  centers = sort(centers);
  T1 = centers(2) + ((centers(3) - centers(2))/2);
  im = double(imagen_Original);
  im2 = zeros(f,c);
  for i=1: f
     for j=1:c 
         if(im(i,j) > T1)
             im2(i,j)=imagen_Original(i,j);
         else
             im2(i,j)=0;
         end
     end
  end
  imgBin = im2bw(uint8(im2),im2double(((max(max(uint8(im2)))) / 255)*0.9));
  tmp = imgBin;
  CC = bwconncomp(tmp);
  numPixels = cellfun(@numel,CC.PixelIdxList);
  [biggest,idx] = max(numPixels);
  tmp(CC.PixelIdxList{idx}) = 0;
  segmentada = imgBin - tmp;
end

I0 = imread("octave/upload/preview.png");

sz = size_structuring_element(I0);

[I1, M1] = img_clean_background(I0, sz);
[I2, M2] = img_remove_skull(I1, M1, sz);
M3 = img_segment(imsmooth(I2, "Median", [3, 3]));

imwrite(M3, "octave/upload/segmentation.png");
