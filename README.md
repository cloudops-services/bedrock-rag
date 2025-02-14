# bedrock-rag

## Introduction
Bedrock-rag is a project demonstrating the use of the Bedrock framework with OpenSearch Serverless, API Gateway, and AWS Lambda. This project sets up a knowledge base (KB) that can be queried via an API Gateway, with Lambda functions handling the retrieve and generate commands.

## Features
- Easy setup and configuration
- Modular architecture
- Scalable and maintainable codebase
- Integration with OpenSearch Serverless
- API Gateway and Lambda for backend processing

## Folder Structure

bedrock-rag/ ├── src/ │ ├── handlers/ │ │ ├── retrieve.js │ │ └── generate.js │ ├── utils/ │ │ └── opensearch.js │ └── index.js ├── tests/ │ ├── retrieve.test.js │ └── generate.test.js ├── .gitignore ├── package.json ├── README.md └── serverless.yml



## Installation
To get started with bedrock-rag, follow these steps:

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/bedrock-rag.git
    ```
2. Navigate to the project directory:
    ```sh
    cd bedrock-rag
    ```
3. Install the dependencies:
    ```sh
    npm install
    ```

## Usage
To deploy the project, use the following command:
```sh
serverless deploy


## API Endpoints

Retrieve Command: GET /retrieve
Generate Command: POST /generate
Contributing
We welcome contributions to bedrock-rag! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.


## License
This project is licensed under the MIT License. See the LICENSE file for more details.