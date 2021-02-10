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

function [A, M] = img_clean_background(I, sz)
	M = img_scale(double(I) .^ 10);
	M = im2bw(M, (double(max(max(M))) * 0.5) / 255); 
	M = imfill(M, "holes");
	M = imopen(M, strel("ball", sz, 0));
	A = I .* M;
endfunction

function [A, M] = img_remove_skull(I, S, sz)
	M = im2bw(I, (double(max(max(I))) * 0.9) / 255);
	M = (1 - M) .* S;
	M = imopen(M, strel("ball", 2, 0));
	M = imfill(M, "holes");
	M = imerode(M, strel("ball", round(sqrt(sz)), 0));
	A = I .* M;
endfunction

function M = img_segment(I)
	D = reshape(double(I), [], 1);
	[indexes, centers] = kmeans(D, 3);
	centers = sort(centers);
	t = (centers(2) + centers(3)) / 2;
	A = im2bw(I .* im2bw(I, t / 255), 0.5); 
	C = bwconncomp(A);
	[biggest, index] = max(cellfun(@numel, C.PixelIdxList));
	M = zeros(size(I));
	M(C.PixelIdxList{index}) = 1;
endfunction

I0 = imread("octave/upload/preview.png");

sz = size_structuring_element(I0);

[I1, M1] = img_clean_background(I0, sz);
[I2, M2] = img_remove_skull(I1, M1, sz);
M3 = img_segment(imsmooth(I2, "Median", [3, 3]));

imwrite(M3, "octave/upload/segmentation.png");
