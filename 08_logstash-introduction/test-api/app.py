#!myapp/bin/python

import json
#from random import randint
#import requests
from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def homepage():
	message = "Hello, world! This is a plain string."
	return(message)

@app.route('/json/')
def jsonpage():
	message = {"message":"Hello, world!", "message_type":"This is a JSON structure."}
	return(json.dumps(message))

@app.route('/new_api_request')
def requestapipage():
	#new_key = randint(1000000,9999999)
	#message = {"new_key":f"{new_key}"}
	# placeholder - send to sqlite db
	message = {"new_key":"b33fb33f"}
	return(json.dumps(message))

@app.route('/validate', methods=['POST'])
def validateapipage():
	d = request.get_json(force=True)
	api_key = d["api_key"]
	# placeholder - check sqlite
	return(json.dumps({"status":"valid"}))

@app.route('/api/fleet/outputs', methods=['POST'])
def fleetapipage():
	d = request.get_json(force=True)
	#api_key = d["api_key"]
	# placeholder - check sqlite
	#return(json.dumps({"status":"ok"}))
	return(json.dumps(d))

if __name__ == "__main__":
	app.run(debug=True, ssl_context="adhoc")
