import json
import requests
from flask import Flask, request

app = Flask(__name__)

# Jira Configuration
JIRA_URL = "https://devopsarunvel.atlassian.net"
JIRA_USER = "csemanit2015@gmail.com"
JIRA_API_TOKEN = "ATATT3xFfGF0JA6KwB94L_s3_vraovAPDXsGlhWIWyy7w3cgY4Em_G2gci7NjioflwVzO-pyi_WvFWZbpS623ambsiSI10m1vuSrUMs5b1hyyP6KQNqDP6nRvn36FpJR9xlLuGRB_2WP1iyulMPrr9X4iGR-3OURZGkbfIxSNFk5fmLgkmwaaHg=56AF56D5"
JIRA_PROJECT = "EC2"

@app.route("/webhook", methods=["POST"])
def alertmanager_webhook():
    data = request.json
    print("Received Alert:", json.dumps(data, indent=2))

    for alert in data.get("alerts", []):
        summary = alert.get("annotations", {}).get("summary", "Instance Down")
        description = alert.get("annotations", {}).get("description", "No description provided.")
        
        create_jira_ticket(summary, description)

    return {"status": "success"}, 200

def create_jira_ticket(summary, description):
    url = f"{JIRA_URL}/rest/api/3/issue"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Basic {requests.auth._basic_auth_str(JIRA_USER, JIRA_API_TOKEN)}"
    }
    payload = {
        "fields": {
            "project": {"key": JIRA_PROJECT},
            "summary": summary,
            "description": description,
            "issuetype": {"name": "Task"}
        }
    }

    response = requests.post(url, headers=headers, json=payload)

    if response.status_code == 201:
        print("Jira ticket created successfully.")
    else:
        print(f"Failed to create Jira ticket: {response.text}")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
