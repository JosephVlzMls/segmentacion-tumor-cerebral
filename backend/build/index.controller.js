"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = __importDefault(require("fs"));
const child_process_1 = require("child_process");
class IndexController {
    upload(request, response) {
        let file = request.files.data;
        var type = file.type.split('/');
        if (type[0] == 'image')
            fs_1.default.rename(file.path, 'octave/upload/original.png', () => { });
        else
            fs_1.default.rename(file.path, 'octave/upload/original.dcm', () => { });
        response.send({ status: true });
    }
    image8bits(request, response) {
        var stdout = null;
        if (request.body.type == 'dicom')
            stdout = child_process_1.execSync('octave octave/img_8bits_dicom.m');
        else
            child_process_1.execSync('octave octave/img_8bits.m');
        var image = fs_1.default.readFileSync('octave/upload/preview.png');
        response.send({ status: true, image: image, stdout: stdout === null || stdout === void 0 ? void 0 : stdout.toString() });
    }
    segment(request, response) {
        child_process_1.execSync('octave octave/img_segment_' + request.body.type + '.m');
        var image = fs_1.default.readFileSync('octave/upload/segmentation.png');
        response.send({ status: true, image: image });
    }
}
exports.default = new IndexController();
