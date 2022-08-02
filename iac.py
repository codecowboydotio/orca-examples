#!/usr/bin/python

import requests
import json
import os
import argparse

# api-endpoint
URL = f"https://app.au.orcasecurity.io/api"
URI = f"/user/session"

def do_login():
  LOGIN_URL=URL+URI
  API_KEY = os.environ.get("ORCA_API_KEY")
  if API_KEY == "None":
    sys.exit(1)

  data = {'security_token':API_KEY}
  r = requests.post(url = LOGIN_URL, data = data)
  newdata = json.loads(r.text)
  jwt = newdata['jwt']['access']
  return jwt


def create_iac_policy(policy_doc, jwt):
  LOGIN_URL=URL+"/shiftleft/iac/policies/"
  API_KEY = os.environ.get("ORCA_API_KEY")


  headers = {
    "Content-Type":"application/json",
    "Authorization":"Bearer " + jwt
  }
  data = policy_doc
  try:
    r = requests.post(url = LOGIN_URL, data = data, headers = headers)
    r.raise_for_status()
    print("Created new policy named: " + args.name)
  except requests.exceptions.HTTPError as err:
    print(err)
    print(r.text) 
  newdata = json.loads(r.text)
  return newdata


def get_iac_catalogue(jwt):
  headers = {
    "Content-Type":"text",
    "Authorization":"Bearer " + jwt
  }

  url = URL+"/shiftleft/iac/catalog/controls"
  r = requests.get(url, headers=headers)
  raw_returned = json.loads(r.text)
  return raw_returned 



jwt = do_login()
complete_catalogue = get_iac_catalogue(jwt)

#################
parser = argparse.ArgumentParser(description='Generate Orca IAC templates based on language.')
parser.add_argument('-p', '--platform', help='platform type: i.e. Ansible', required=True)
parser.add_argument('-n', '--name', help='Policy name', required=True)
parser.add_argument('-d', '--description', help='Policy description', required=True)
parser.add_argument('-e', '--enabled', help='Is policy enabled?', required=True)
args = parser.parse_args()
######################

if args.enabled == "True":
  disabled_flag=False
else:
  disabled_flag=True

new_iac_policy={
  "projects_ids": [],
  "policy_data": {
    "controls": [
    ],
    "frameworks": []
  },
  "name": args.name,
  "description": args.description,
  "disabled": disabled_flag,
  "priority_failure_threshold": "INFO",
  "warn_mode": False
}


# This is a complete hack and I'm sure there's a JSON way to do it - but meh
for item in complete_catalogue['controls']:
  string_platform=json.dumps(item['platforms'])
  if args.platform not in string_platform:
    new_iac_policy['policy_data']['controls'].append({"id":item['id'], "disabled": True, "priority": "INFO"})

iac_policy=json.dumps(new_iac_policy)
policy_output=create_iac_policy(iac_policy, jwt)
