The hole folder "secrets" is included in the .gitignore file.

Place the Google Cloud Service Account .json and re-name it "gcloud-credentials.json", in the "secrets" folder.
This file is used by terraform.

In a terminal, run this command to generate an encoded version, so Kestra can use it.
```
echo SECRET_GCP_SERVICE_ACCOUNT=$(cat gcloud-credentials.json | base64 -w 0) >> .json_encoded
```
