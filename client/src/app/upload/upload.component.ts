import { Component, OnInit } from '@angular/core';
// import { FormBuilder, FormGroup } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import {Observable} from 'rxjs';
import {PostRequest} from '../models/postRequest.model';

@Component({
  selector: 'app-upload',
  templateUrl: './upload.component.html',
  styleUrls: ['./upload.component.css']
})
export class UploadComponent implements OnInit {
  SERVER_URL = 'https://b70jbm1mnl.execute-api.us-west-2.amazonaws.com/dev/temp-url';
  private selectedFile: File;
  private postRequest: PostRequest;

  constructor(private httpClient: HttpClient) { }

  ngOnInit() {
    this.getPostUrl().subscribe((data: PostRequest) => {
      console.log(data);
      this.postRequest = data;
    }, error => {
      console.error(error);
    });
  }

  getPostUrl(): Observable<PostRequest> {
    return this.httpClient.get<PostRequest>(this.SERVER_URL);
  }

  onFileChanged(event) {
    this.selectedFile = event.target.files[0];
  }

  onUpload() {
    const formData = new FormData();
    formData.append('key', this.postRequest.key);
    formData.append('AWSAccessKeyId', this.postRequest.AWSAccessKeyId);
    formData.append('policy', this.postRequest.policy);
    formData.append('Signature', this.postRequest.signature);
    formData.append('x-amz-security-token', this.postRequest['x-amz-security-token']);
    formData.append('file', this.selectedFile);

    console.log(formData);
    this.httpClient.post<any>('https://image-rekognition-file-uploads.s3.amazonaws.com/', formData).subscribe(
      (res) => console.log(res),
      (err) => console.log(err)
    );
  }

}
