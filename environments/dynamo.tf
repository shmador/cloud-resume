resource "aws_dynamodb_table" "db" {
  name           = "dor-resume"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }
}