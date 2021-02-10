function B = img_scale(A)
	A = double(A);
	C = A - min(min(A));
	B = uint8(255 .* (C / max(max(C))));
endfunction

I = imread("octave/upload/original.png");

[n, m, c] = size(I);
if(c == 3) I = rgb2gray(I); endif
I = img_scale(I);

imwrite(I, "octave/upload/preview.png");