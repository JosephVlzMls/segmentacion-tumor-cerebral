import { Component, OnInit } from '@angular/core';
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';

import { UploadService } from '../../services/upload.service';

@Component({
  selector: 'app-upload',
  templateUrl: './upload.component.html',
  styleUrls: ['./upload.component.css']
})
export class UploadComponent implements OnInit {

  file: File = null;
  area: string = null;
  type: string = null;
  view: string = null;
  preview: SafeUrl = null;
  weighing: string = null;
  extension: string = null;
  segmenting: boolean = false;
  segmentation: SafeUrl = null;

  constructor(private uploadService: UploadService, private domSanitizer: DomSanitizer) {

  }

  ngOnInit(): void {
    
  }

  onExplore(): void {
    var explorer = document.getElementById('explorer') as HTMLInputElement;
    explorer.click();
  }

  onFileChange(event: any): void {
    var type = event.target.files[0].type.split('/');
    if(type[0] == 'image' || type[type.length-1] == 'dicom') {
      this.extension = type[type.length-1];
      this.file = event.target.files[0];
      var data: FormData = new FormData();
      data.append('data', this.file, this.file.name);
      this.uploadService.upload(data).subscribe((res) => {
        this.uploadService.image8bits(this.extension).subscribe((res) => {
          if(res['stdout']) {
            var info = res['stdout'].toLowerCase().split('-');
            if((this.type = info[0]) == 'mr') this.weighing = info[1][0] + info[1][1];
          }
          this.preview = this.decodeImage(res['image'].data);
        });
      });
    }
  }

  segment(): void {
    this.segmenting = true;
    var imageType = this.type + (this.weighing == null ? '' : '_' + this.weighing);
    this.uploadService.segment(imageType).subscribe((res) => {
      this.view = 'segmentation';
      this.area = res['stdout'];
      this.segmentation = this.decodeImage(res['image'].data);
      this.segmenting = false;
    });
  }

  decodeImage(data: any): SafeUrl {
    var buffer = new Uint8Array(data);
    var stringBuffer = buffer.reduce((data, byte) => { return data + String.fromCharCode(byte); }, '');
    var base64 = btoa(stringBuffer);
    return this.domSanitizer.bypassSecurityTrustUrl('data:image/png;base64,' + base64);
  }

  restart(): void {
    this.file = null;
    this.preview = this.segmentation = null;
    this.type = this.view = this.weighing = this.extension = null;
    this.segmenting = false;
  }

}
