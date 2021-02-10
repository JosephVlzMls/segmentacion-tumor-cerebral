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

function sz = size_structuring_element(I)
	[n, m] = size(I);
	sz = floor(sqrt(min(n, m)) / 2);	
endfunction

function [A, M] = img_clean_background(I, size)
	M = imfill(I, "holes");
	M = im2bw(M, double(max(max(I))) * 0.08 / 255);
	M = imopen(M, strel("ball", size, 0));
	A = I .* M;
endfunction

function [A, M] = img_remove_skull(I, S, size)
	M = imbothat(I, strel("ball", size * 2, 0)) .* S; 
    M = (M - imtophat(I, strel("ball", size * 2, 0))) .* S;
	M = im2bw(M, 0.001);
	M = imclose(M, strel("ball", 2, 0));
    M = imfill(M, "holes");
    M = imopen(M, strel("ball", size, 0));
	M = imerode(M, strel("ball", size + mod(size, 2) + 2, 0));
	M = img_convex_hull(M);
	A = I .* M;
endfunction

function im = img_segment(imagen_Original)
  [f,c] = size(imagen_Original);
  i1 = img_enhancement(imagen_Original, 9);
  i2 = img_enhancement(imagen_Original, 11);
  i3 = imagen_Original; 
  im = imadjust(i3,[0.26,0.32]);    
  im = ((i3 .- i1) + im);
  imData = reshape(double(im),[],1);
  [idx,centers] = kmeans(imData,3);
  centers = sort(centers);
  T1 = centers(2) + ((centers(2) - centers(1))/2);
  T2 = centers(1);
  im2 = zeros(f,c);
  for i=1:f
     for j=1:c
         if((im(i,j) < T1) && (im(i,j) > T2))
             im2(i,j)=imagen_Original(i,j);
         else
             im2(i,j)=0;
         end
     end
  end
  im3 = i3 .- im2;
  im3 = im3 .- imadjust(i2);
  im3 = im2bw(im3,0);
  tmp = im3;
  CC = bwconncomp(tmp);
  numPixels = cellfun(@numel,CC.PixelIdxList);
  [biggest,idx] = max(numPixels);
  tmp(CC.PixelIdxList{idx}) = 0;
  im = im3 - tmp;
end

function A = img_enhancement(imagen_Original,n)
  background = imopen(imagen_Original, strel("disk", n, 0));
  I2 = imagen_Original - background;
  I3 = imadjust(I2);
  A = imagen_Original - I3;
end

I0 = imread("octave/upload/preview.png");

sz = size_structuring_element(I0);

[I1, M1] = img_clean_background(I0, sz);
[I2, M2] = img_remove_skull(I1, M1, sz);
M3 = img_segment(I2, sz);

imwrite(M3, "octave/upload/segmentation.png");