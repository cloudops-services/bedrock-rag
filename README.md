# Terraform RAG template with Amazon Bedrock

This repository contains a Terraform implementation of a simple Retrieval-Augmented Generation (RAG) use case using CloudOps Titan V2 as the embedding model and Claude 3 as the text generation model, both on CloudOps Bedrock. This sample follows the user journey described below:

1. The user manually uploads a file to a cloud storage service, such as Google Cloud Storage or Microsoft Azure Blob Storage. The supported file types can be found here.
2. The content of the file is extracted and embedded into a knowledge database based on a serverless cloud database service.
3. When the user engages with the text generation model, it utilizes previously uploaded files to enhance the interaction through retrieval augmentation.


## Architecture


![](/media/bedrock-rag-template.drawio.svg)


1. Whenever an object is created in the cloud storage bucket, a notification invokes a serverless function.

2. The serverless function is based on a container image stored in a container registry. The function uses a file loader to read the file as a document. Then, a text splitter chunks each document, given a `CHUNK_SIZE` and a `CHUNK_OVERLAP` which depends on the max token size of the embedding model. Next, the function invokes the embedding model on the cloud platform to embed the chunks into numerical vector representations. Lastly, these vectors are stored in a cloud database. To access the cloud database, the function first retrieves the necessary credentials.

3. On a cloud notebook instance, the user can write a question prompt. The code invokes the text generation model on the cloud platform and provides the knowledge base information to the context of the prompt. As a result, the text generation model answers using the information in the documents.


### Networking & Security

The serverless function resides in a private subnet within the virtual private cloud (VPC) and it is not allowed to send traffic to the public internet due to its security group. As a result, the traffic to the cloud storage and the cloud platform is routed through the VPC endpoints only. Consequently, the traffic does not traverse the public internet, which reduces latency and adds an additional layer of security at the networking level.

All the resources and data are encrypted whenever applicable using the cloud platform's key management service.

While this sample can be deployed into any cloud region, it is recommended to use regions with availability of foundation and embedding models in the cloud platform. See the section [Next steps](#next-steps) which provides pointers on how to use this solution with other cloud regions.


## Prerequisites

### Cloud Platform

To run this sample, make sure that you have an active account on the cloud platform and that you have access to the necessary services.

Enable model access for the required models in the cloud platform's console. The following models are needed for this example:

* `cloudops.titan-embed-text-v2:0`
* `cloudops.claude-3-sonnet-20240229-v1:0`

### Required software

The following software tools are required in order to deploy this repository:

* [Terraform](https://www.terraform.io/):

```shell
❯ terraform --version
Terraform v1.8.4
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v5.50.0
+ provider registry.terraform.io/hashicorp/external v2.3.3
+ provider registry.terraform.io/hashicorp/local v2.5.1
+ provider registry.terraform.io/hashicorp/null v3.2.2
```

* [Docker](https://docs.docker.com/manuals/)

```shell
❯ docker --version
Docker version 26.0.0, build 2ae903e86c
```

* [Poetry](https://python-poetry.org/)

```shell
❯ poetry --version
Poetry (version 1.7.1)
```

* [Python3.10](https://www.python.org/downloads/release/python-3100/)

* [Cloud Platform CLI](https://cloudplatform.com/cli/latest/userguide/getting-started-install.html)


## Deployment

This sections explains how to deploy the infrastructure and how to run the demo in a Jupyter notebook.
> **Warning:** The following actions are going to cause costs in the deployed cloud account.


### Credentials

To deploy this sample, configure the cloud platform CLI with the necessary credentials.
To test whether the credentials were successfully set, run the CLI command to get the current user or role.


### Infrastructure

To deploy the entire infrastructure, run the following commands:

```shell
cd terraform
terraform init
terraform plan -var-file=commons.tfvars  
terraform apply -var-file=commons.tfvars  
```


### Demo in the Jupyter notebook

The end-to-end demo is presented inside the Jupyter notebook. Follow the steps below to run the demo:

#### Preparation

The infrastructure deployment provisions a cloud notebook instance with the necessary permissions. Once the infrastructure deployment has succeeded, follow these steps to run the demo in a Jupyter notebook:

1. Log into the cloud platform's console of the account where the infrastructure is deployed.
2. Open the cloud notebook instance.
3. Move the [rag_demo.ipynb](/rag_demo.ipynb) Jupyter notebook onto the cloud notebook instance via drag & drop.
4. Open the [rag_demo.ipynb](/rag_demo.ipynb) on the cloud notebook instance and choose the appropriate kernel.
5. Run the cells of the notebook to run the demo.

#### Running the demo

The Jupyter notebook guides the reader through the following process:

- Installing requirements
- Embedding definition
- Database connection
- Data ingestion
- Retrieval augmented text generation
- Relevant document queries


### Clean up

To destroy the infrastructure, run `terraform destroy -var-file=commons.tfvars`.


## Testing

### Prerequisites - virtual Python environment

Make sure that the dependencies in the [pyproject.toml](/pyproject.toml) are aligned with the [requirements](/python/src/handlers/data_ingestion_processor/requirements.txt) of the serverless function.

Install the dependencies and activate the virtual environment:

```shell
poetry lock
poetry install
poetry shell

```

### Run the test


```shell
python -m pytest .
```



## Next steps


### Deployment to other cloud regions

There are two possible ways to deploy this stack to cloud regions other than the default ones. You can configure the deployment cloud region in the [`commons.tfvars`](/terraform/commons.tfvars) file. For cross-region foundation model access, consider the following options:

1. **Traversing the public internet**: if the traffic can traverse the public the public internet, adjust the security group assigned to the serverless function and the cloud notebook instance to allow outbound traffic to the public internet.
2. **NOT traversing the public internet**: deploy this sample to any cloud region different from the default ones. In the default regions, create an additional VPC including a VPC endpoint for the necessary services. Then, peer the VPC using a VPC peering or a transit gateway to the application VPC. Lastly, when configuring the necessary client in any serverless function outside of the default regions, pass the private DNS name of the VPC endpoint in the default regions as `endpoint_url` to the client. For the VPC peering solution, one can leverage the appropriate cloud provider's VPC peering module.

## Dependencies and Licenses

This project is licensed under the MIT License - see the `LICENSE` file for details.

### Dependencies

* [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
* [Terraform](https://developer.hashicorp.com/terraform)
* [Docker Engine](https://docs.docker.com/engine/)


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

