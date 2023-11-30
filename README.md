# media-intelligent-search

To build LangChain library for the layer use the following:

```bash
docker pull public.ecr.aws/sam/public.ecr.aws/sam/build-python3.11:1.103.0-20231116223137

docker run -it -v $(pwd):/var/task public.ecr.aws/sam/public.ecr.aws/sam/build-python3.11:1.103.0-20231116223137

pip install langchain -t ./python

zip -r langchain.zip ./python
```

Also, the Lambda and the Layer architecture must be set to `arm64`