import express, { Application } from 'express';
import morgan from 'morgan';
import cors from 'cors';

import IndexRouter from './index.router';

class Backend {

	app: Application;

	constructor() {
		this.app = express();
		this.configure();
		this.routes();
	}

	configure(): void {
		this.app.set('port', process.env.port || 3000);
		this.app.use(morgan('dev'));
		this.app.use(cors());
		this.app.use(express.json());
	}

	routes(): void {
		this.app.use('/', IndexRouter);
	}

	start(): void {
		this.app.listen(this.app.get('port'), () => {
			console.log('server on port', this.app.get('port'));
		});
	}

}

const backend = new Backend();
backend.start();
