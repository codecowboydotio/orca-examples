#!/usr/bin/python

import requests
import json
import os
import urllib

# api-endpoint
URL = f"https://api.orcasecurity.io/api"
URI = f"/user/session"

def do_login():
  LOGIN_URL=URL+URI
  API_KEY = os.environ.get("ORCA_API_KEY")

  data = {'security_token':API_KEY}
  r = requests.post(url = LOGIN_URL, data = data)
  newdata = json.loads(r.text)
  jwt = newdata['jwt']['access']
  return jwt

def run_sonar_query(jwt):
  headers = {
    "Content-Type":"text",
    "Authorization":"Bearer " + jwt
  }
  print("Example query: Vm with IngressPorts containing 22 AND HasPii and IsInternetFacing")
  print("Example query: Vm with IsInternetFacing")

  sonarq = input("Enter your sonar query: ")
  encoded_sonarq = urllib.parse.quote(sonarq)
  encoded_url = URL+"/sonar/query?query="+encoded_sonarq+"&get_results_and_count=true"
  r = requests.get(encoded_url, headers=headers)
  raw_returned = json.loads(r.text)
  total_returned = raw_returned['total_items']
  

  # This next bit is for demonstration purposes only but shows both the unsafe and safe URLs as well as the result
  print(r.text)
  print("\n\n")
  print("This is the unencoded URL")
  print(sonarq)
  print("\n")
  print("This is the encoded URL")
  print(encoded_sonarq)
  print("\n\n")
  print("Total number of items returned: {}" .format(total_returned))



jwt=do_login()
run_sonar_query(jwt)
