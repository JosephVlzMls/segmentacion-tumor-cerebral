import { Router } from 'express';

import IndexController from './index.controller';

const multipart = require('connect-multiparty');

class IndexRouter {

	router: Router;
	middleware: any;

	constructor() {
		this.router = Router();
		this.middleware = multipart({uploadDir: './octave/upload'});
		this.configure();
	}

	configure(): void {
		this.router.post('/image8bits', IndexController.image8bits);
		this.router.post('/upload', this.middleware, IndexController.upload);
		this.router.post('/segment', this.middleware, IndexController.segment);
	}

}

export default new IndexRouter().router;