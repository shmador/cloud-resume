import boto3, json, traceback
dynamo = boto3.client("dynamodb")

def respond(err=None, res=None):
    if err:
        # Prefer ClientError's message if present, else str(err)
        msg = getattr(err, "response", {}).get("Error", {}).get("Message", str(err))
        body = {"error": msg}
        status = 400
    else:
        body = res
        status = 200

    return {
        "statusCode": status,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "GET,POST,PUT,OPTIONS"
        },
    }

def lambda_handler(event, _ctx):
    operations = {
        "DELETE": lambda x: dynamo.delete_item(**x),
        "GET":    lambda x: dynamo.scan(**x),
        "POST":   lambda x: dynamo.put_item(**x),
        "PUT":    lambda x: dynamo.update_item(**x),
    }

    op = event.get("httpMethod", "")
    try:
        payload = (event.get("queryStringParameters") or {}) if op == "GET" \
                  else json.loads(event.get("body") or "{}")
        if op in operations:
            return respond(None, operations[op](payload))
        return respond(ValueError(f"Unsupported method {op}"), code_if_err="405")
    except Exception as e:
        # Optional: log full traceback for debugging
        print("ERROR:", traceback.format_exc())
        return respond(e, code_if_err="500")
# Testing GH Actions CI
