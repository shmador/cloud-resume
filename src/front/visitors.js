const API_BASE   = "https://doratar.com/production";
const TABLE_NAME = "dor-resume";
const VISITOR_ID = "0";

async function bumpVisitorCount() {
  const payload = {
    TableName: TABLE_NAME,
    Key: { id: { N: VISITOR_ID } },

    UpdateExpression: "SET #c = if_not_exists(#c, :zero) + :inc",
    ExpressionAttributeNames:  { "#c": "count" },
    ExpressionAttributeValues: { ":inc": { N: "1" }, ":zero": { N: "0" } },
    ReturnValues: "UPDATED_NEW"
  };

  const resp = await fetch(`${API_BASE}/visitors`, {
    method: "PUT",                                // <-- PUT
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  if (!resp.ok) {
    throw new Error(`HTTP ${resp.status}\n${await resp.text()}`);
  }
  const data  = await resp.json();
  const count = Number(data.Attributes.count.N);
  console.log("visitor count =", count);
}

bumpVisitorCount().catch(console.error);
