#!/usr/bin/python

import requests
import json
import os
import urllib
from openpyxl import Workbook

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

def get_compliance_frameworks(jwt):
  headers = {
    "Content-Type":"text",
    "Authorization":"Bearer " + jwt
  }

  encoded_url = URL+"/compliance/catalog?custom=false"
  r = requests.get(encoded_url, headers=headers)
  json_returned = json.loads(r.text)

  # This next bit is for demonstration purposes only but shows both the unsafe and safe URLs as well as the result
  print("Pulled compliance frameworks\n")
  #print(json_returned['data']['frameworks'])

  print("Name  Display Name  Total Sections  Framework ID")
  for item in json_returned['data']['frameworks']:
    if (item['custom'] == False):
      print(item['name'] + " " + item['display_name'] + " " + str(item['total_sections']) + " " + item['framework_id'])
      for count in range(0,item['total_sections']):
        print(item['sections'][count]['name'])
        for test_count in range(0,item['sections'][count]['total_tests']):
          #print(item['sections'][count]['tests'])
          print(item['sections'][count]['tests'][test_count]['rule_id'], end=" ")
          print(item['sections'][count]['tests'][test_count]['reference_id'])
          print(item['sections'][count]['tests'][test_count]['name'], end=" ")

def create_workbook(path):
    for item in json_data:
      print(item)
    workbook = Workbook()
    sheet = workbook.active
    sheet["A1"] = "Hello"
    sheet["A2"] = "from"
    sheet["A3"] = "OpenPyXL"
    workbook.save(path) 

jwt=do_login()
get_compliance_frameworks(jwt)
#create_workbook("foo.xls")
