"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const index_controller_1 = __importDefault(require("./index.controller"));
const multipart = require('connect-multiparty');
class IndexRouter {
    constructor() {
        this.router = express_1.Router();
        this.middleware = multipart({ uploadDir: './octave/upload' });
        this.configure();
    }
    configure() {
        this.router.post('/image8bits', index_controller_1.default.image8bits);
        this.router.post('/upload', this.middleware, index_controller_1.default.upload);
        this.router.post('/segment', this.middleware, index_controller_1.default.segment);
    }
}
exports.default = new IndexRouter().router;
