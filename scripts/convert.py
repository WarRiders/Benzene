import json

with open("token_holders.json") as f:
    data = json.load(f)

    addresses = []
    for d in data:
        addresses.append(d['address'] + '\n')
    
    with open('token_holders.csv', mode='w') as fw:
        fw.writelines(addresses)