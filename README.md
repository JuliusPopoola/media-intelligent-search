# media-intelligent-search

To build LangChain library for the layer use the following:

```bash
docker pull public.ecr.aws/sam/public.ecr.aws/sam/build-python3.11:1.103.0-20231116223137

docker run -it -v $(pwd):/var/task public.ecr.aws/sam/public.ecr.aws/sam/build-python3.11:1.103.0-20231116223137

pip install langchain -t ./python

zip -r langchain.zip ./python
```

Also, the Lambda and the Layer architecture must be set to `arm64`

To run the application in the `infra` directory use 
```terraform apply -var-file=terraform.tfvars ```


The content of the `terraform.tfvars` is

```
region                             = "<REGION>"
account_id                         = "<ACCOUNT ID>"
environment                        = "<ENVIRONMENT>"
mediaconvert_label                 = "<MEDIA-CONVERT-LABEL>"
transcribe_label                   = "<TRANSCRIBE-LABEL>"
kendra_label                       = "<KENDRA-LABEL>"
lang_chain_llm_label               = "<LANG-CHAIN-LLM-LABEL>"
mediaconvert_lambda_handler_name   = "<MEDIA_CONVERT_FUNCTION>"
transcribe_lambda_handler_name     = "<TRANSCRIBE_FUNCTION>"
kendra_source_lambda_handler_name  = "<KENDRA_DATA_SOURCE_FUNCTION>"
lang_chain_llm_lambda_handler_name = "<LANG_CHAIN_LLM_FUNCTION>"
runtime                            = "python3.11"
timeout                            = "900"
instream_bucket_name               = "<RAW-VIDEO-BUCKET>"
outstream_bucket_name              = "<TRANSCODED-VIDEO-BUCKET>"
transcribe_bucket_name             = "<TRANSCRIBED-DOCUMENT-BUCKET>"
mediaconvert_endpoint              = "<MEDIA-CONVERT-URL>"
```

The `terraform.tfvars` should be in the `infra` directory
