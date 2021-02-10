pkg load dicom;

function B = img_scale(A)
	A = double(A);
	C = A - min(min(A));
	B = uint8(255 .* (C / max(max(C))));
endfunction

I = dicomread("octave/upload/original.dcm");
I = img_scale(I);

D = dicominfo("octave/upload/original.dcm");
fprintf("%s-%s", D.Modality, D.SeriesDescription);

imwrite(I, "octave/upload/preview.png");