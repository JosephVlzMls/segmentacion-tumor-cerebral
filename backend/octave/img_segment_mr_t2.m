pkg load image;
pkg load statistics;

function Z = img_convex_hull(I)
	k = 0;
	[n, m] = size(I);
	for i = 1 : n
		for j = 1 : m
			if(I(i, j))
				k += 1; X(k) = j; Y(k) = i;
			endif
		endfor
	endfor
	H = convhull(X, Y);
	Z = zeros(n, m);
	for i = 2 : length(H)
		Z(Y(H(i)), X(H(i))) = 1;	
		x1 = X(H(i-1));
		y1 = Y(H(i-1));	
		x2 = X(H(i));
		y2 = Y(H(i));
		a = double(y2) - double(y1);
		b = double(x2) - double(x1);
		c = b * double(y1) - a * double(x1);
		lx = min(x1, x2) + 1;
		ly = min(y1, y2) + 1;
		rx = max(x1, x2) - 1;
		ry = max(y1, y2) - 1;
		if(lx <= rx)
			for x = lx : rx
				y = round((c + a * double(x)) / b);
				Z(y, x) = 1;	
			endfor
		endif
		if(ly <= ry)
			for y = ly : ry
				x = round((c - b * double(y)) / -a);
				Z(y, x) = 1;	
			endfor
		endif
	endfor
	Z = imfill(Z, "holes");
endfunction

function sz = size_structuring_element(I)
	[n, m] = size(I);
	sz = floor(sqrt(min(n, m)) / 2);	
endfunction

function [A, M] = img_clean_background(I, size)
	M = imfill(I, "holes");
	M = im2bw(M, 0.08);
	M = imopen(M, strel("ball", size, 0));
	A = I .* M;
endfunction

%{
function [A, M] = img_remove_skull(I, S, size)
	M = (255 - I) .* S; 
	N = (1 - im2bw(M, 0.85)) .* S;
	M = (1 - im2bw(M, (double(max(max(M))) * 0.8) / 255)) .* S; 
	M = imopen(M, strel("ball", size, 0));
	M = imclose(M, strel("ball", size * 2, 0));
	M = imfill(M, "holes");
	A = I .* M;
endfunction
%}

function [A, M] = img_remove_skull(I, S, sz)
	M1 = (255 - I) .* S;
	N = (1 - im2bw(M1, 0.83)) .* S;
  	N = imerode(N, strel("ball", 2, 0));
	M = (1 - im2bw(M1, (double(max(max(M1))) * 0.77) / 255)) .* S; 
	M = imerode(M, strel("ball", 2, 0));
	M = imdilate(M, strel("ball", 1, 0));
	M = ((1 - M) .* S); 
	C = img_convex_hull(M);
	C = imerode(C, strel("ball", sz, 0));
	N = img_convex_hull(M .* C);
	M = (255 - I) .* N; 
	R = (1 - im2bw(M, 0.85)) .* N;
	M = (1 - im2bw(M, (double(max(max(M))) * 0.8) / 255)) .* N; 
  	M = imopen(M, strel("ball", 1, 0));
	M = imclose(M, strel("ball", 2, 0));
	M = imfill(M, "holes");
	N = imopen(M, strel("ball", sz, 0));
	N = imclose(N, strel("ball", sz, 0));
	M = imfill(N, "holes");
	A = I .* M;
endfunction

function M = img_segment(I, sz)
	A = I + imadjust(I, [0.6, 0.75]);
	D = reshape(double(A), [], 1);
	[indexes, centers] = kmeans(D, 4); 
	centers = sort(centers);
	t = (centers(4) + centers(3)) / 2;
	B = im2bw(I, t / 255); 
	B = imopen(B, strel("ball", round(sqrt(sz)) - 1, 0)); 
	C = bwconncomp(B);
	[biggest, index] = max(cellfun(@numel, C.PixelIdxList));
	M = zeros(size(I));
	M(C.PixelIdxList{index}) = 1;
endfunction

I0 = imread("octave/upload/preview.png");

sz = size_structuring_element(I0);

[I1, M1] = img_clean_background(I0, sz);
[I2, M2] = img_remove_skull(I1, M1, sz);
M3 = img_segment(I2, sz);

imwrite(M3, "octave/upload/segmentation.png");