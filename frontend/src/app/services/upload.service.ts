import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class UploadService {

  url: string = 'http://localhost:3000';

  constructor(private http: HttpClient) { 

  }

  upload(data: FormData) {
    return this.http.post(this.url + '/upload', data);
  }

  image8bits(type: String) {
    return this.http.post(this.url + '/image8bits', {'type': type});
  }

  segment(type: String) {
    return this.http.post(this.url + '/segment', {'type': type});
  }

}
