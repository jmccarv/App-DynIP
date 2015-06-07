#!/bin/bash

curl -sS -k -H x-auth-token:admin_token https://dyn.example.com/admin/$1
