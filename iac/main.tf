module "bedrock" {
    source = "./modules/bedrock"
    // Add any required input variables for the bedrock module
}

module "lambda" {
    source = "./modules/lambda"
    // Add any required input variables for the lambda module
}

module "api-gw" {
    source = "./modules/api-gw"
    // Add any required input variables for the api-gw module
}