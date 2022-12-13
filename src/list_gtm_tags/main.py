from google.oauth2 import service_account
from google.cloud import bigquery
import google.auth.transport.requests
import requests
import json
import datetime
from google.auth import default

# ------------------------------------
RUN_AS_CLOUD_FUNCTION = False  # Change if deploy as cloud function
# ------------------------------------

"""
HOW TO RUN LOCALLY
$ pip install functions-framework
$ functions-framework --target my_function
Which will start a local development server at http://localhost:8080.

To invoke it locally for an HTTP function:

$ curl http://localhost:8080
For a background function with non-binary data:

$ curl -d '{"data": {"hi": "there"}}' -X POST \
-H "Content-Type: application/json" \
http://localhost:8080
"""


# Authentication settings
SCOPES = [
    "https://www.googleapis.com/auth/tagmanager.readonly",
    "https://www.googleapis.com/auth/cloud-platform",
]
SERVICE_ACCOUNT_FILE = "C:\\Users\\gustavo.lima_dp6\\credenciais-glima\\google\\chave-dp6-raft-suite\\dp6-raft-suite-5ab43936b9fa.json"  # optional
API_KEY = "AIzaSyBvG_HlAWbu3iLrGCA91jJ13REDFZRR588"  # Change values

# GTM info
GTM_ACCOUNT = "21165"  # Change values
GTM_CONTAINER = "22238"  # Change values
GTM_WORKSPACE = "1000120"  # Change values

# GCP info
PROJECT_NAME = "teste-gtm-api"  # Change values
DATASET_NAME = "dp6_media_quality"  # Change values
TABLE_NAME = "media-quality-gtm-tags"  # Change values


def bq_insert_to_table(data, table_id, client) -> None:
    r"""Insert data to Big Query table

    Args:
            data (list of JSON): data to be inserted into table
            table_id (string): table id from Big Query in format <projectId>.<datasetId>.<tableName>
    """

    table_obj = client.get_table(table_id)
    errors = client.insert_rows(table=table_obj, rows=data)
    if errors == []:
        print("New rows have been added.")
    else:
        print("Encountered errors while inserting rows: {}".format(errors))


def _get_credentials():
    r"""Get credentials from GCP.
    If constant RUN_AS_CLOUD_FUNCTION is true the credential will be acquired from GCP credential's default.

    If constant RUN_AS_CLOUD_FUNCTION is false the credential will be acquired from JSON file.

    """
    credentials = None
    # Creates a Credentials instance from a service account json file
    if RUN_AS_CLOUD_FUNCTION:
        credentials, _ = default(scopes=SCOPES)
    else:
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES
        )
    # Created authenticated session
    auth_req = google.auth.transport.requests.Request()
    # Refreshes token
    credentials.refresh(auth_req)
    # Return token
    return credentials


def list_tags(gtm_account, gtm_container, gtm_workspace, api_key, token):
    r"""List all GTM tags

    Args:
            gtm_account (string): Google Tag Manager account number
            gtm_container (string): Google Tag Manager container number
            gtm_workspace (string): Google Tag Manager workspace number
            api_key (string): API key create in GCP to interact with GTM API
            token (string): Token required for request

    Outputs:
            response_json (json): dictionary of tags from GTM

    """
    endpoint = f"https://tagmanager.googleapis.com/tagmanager/v2/accounts/{gtm_account}/containers/{gtm_container}/workspaces/{gtm_workspace}/tags?key={api_key}"
    headers = {"Accept": "application/json", "Authorization": f"Bearer {token}"}
    try:
        # Make a HTTP GET request
        response = requests.get(url=endpoint, headers=headers)
        response_json = response.json()
        return response_json
    except:
        raise Exception


def _parse_media_tags(list_of_tags):
    r"""Filter media tags and parse data

    Args:
            list_of_tags (json): dictionary with all tags

    Output:
            json with parsed data for media tags
    """

    media_json_list = []
    current_date = datetime.datetime.now()
    current_date_formatted = current_date.strftime("%Y-%m-%d")
    for tag in list_of_tags["tag"]:
        add_to_list = False
        tracking_id = "undefined"

        json_sanity_check = ("monitoringMetadata" in tag) and (
            "map" in tag["monitoringMetadata"]
        )

        if json_sanity_check == True:
            for param in tag["monitoringMetadata"]["map"]:
                if param.get("key") == "exclude" and param.get("value") == "false":
                    add_to_list = True
                if param.get("key") == "tracking_id":
                    tracking_id = param["value"]

        if add_to_list:
            reduced_json = {
                "account_id": tag["accountId"],
                "container_id": tag["containerId"],
                "firing_trigger_id": tag["firingTriggerId"][0],
                "workspace_id": tag["workspaceId"],
                "name": tag["name"],
                "tracking_id": tracking_id,
                "tag_id": tag["tagId"],
                "tag_type": tag["type"],
                "snapshot_date": current_date_formatted,
                "timestamp": current_date,
            }
            media_json_list.append(reduced_json)
    return media_json_list


def main(request):

    # Get credentials and token
    credentials = _get_credentials()
    token = credentials.token
    # Create Big Query client
    bq_client = bigquery.Client(credentials=credentials)
    # Get list of tags from Google Tag Manager (GTM)
    list_of_tags = list_tags(
        gtm_account=GTM_ACCOUNT,
        gtm_container=GTM_CONTAINER,
        gtm_workspace=GTM_WORKSPACE,
        api_key=API_KEY,
        token=token,
    )

    # Filter media tags and parse data
    media_json_list = _parse_media_tags(list_of_tags)
    print("LIST OF TAGS=", json.dumps(list_of_tags, indent=4))
    print("MEDIA_JSON_LIST=", media_json_list)
    # Save list of JSONs to Big Query table
    # bq_insert_to_table(data=media_json_list, table_id=f"{PROJECT_NAME}.{DATASET_NAME}.{TABLE_NAME}", client=bq_client)

    if RUN_AS_CLOUD_FUNCTION:
        return "Success", 200


if __name__ == "__main__":
    main("")
