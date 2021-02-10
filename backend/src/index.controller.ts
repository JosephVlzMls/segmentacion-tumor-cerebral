import fs from 'fs';
import { execSync } from 'child_process';
import { Request } from 'express';

class IndexController {

	upload(request: any, response: any) {
		let file = request.files.data;
		var type = file.type.split('/');
		if(type[0] == 'image') fs.rename(file.path, 'octave/upload/original.png', () => {});
		else fs.rename(file.path, 'octave/upload/original.dcm', () => {});
		response.send({status: true});
	}

	image8bits(request: Request, response: any) {
		var stdout = null;
		if(request.body.type == 'dicom') stdout = execSync('octave octave/img_8bits_dicom.m');
		else execSync('octave octave/img_8bits.m');
		var image = fs.readFileSync('octave/upload/preview.png');
		response.send({status: true, image: image, stdout: stdout?.toString()}); 
	}

	segment(request: Request, response: any) {
		execSync('octave octave/img_segment_' + request.body.type + '.m');
		var image = fs.readFileSync('octave/upload/segmentation.png');
		response.send({status: true, image: image});
	}

}

export default new IndexController();