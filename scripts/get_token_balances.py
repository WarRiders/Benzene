from collections import defaultdict
from decimal import Decimal
from functools import total_ordering
import os
import json
import time
import requests

bzn_tokens = [
    "0x6524B87960c2d573AE514fd4181777E7842435d4",
    "0x85171d9cD1CfD8B10072096763674392176f039b",
    "0x1BD223e638aEb3A943b8F617335E04f3e6B6fFfa",
]
start_blocks = [
    8481230,
    8249453,
    5638231
]
banned_addresses = [
    "0xF99240d814ab87F59dEFCf7E78b41b5a165ebb7a".lower(),
    "0x54cD51e63bfdDeded12763aAe609f38C005F99Ab".lower()
]
INFURA_KEY = "v3/b3b08fefe30e4579b62be25152d77044"

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        # 👇️ if passed in object is instance of Decimal
        # convert it to a string
        if isinstance(obj, Decimal):
            return str(obj)
        # 👇️ otherwise use the default behavior
        return json.JSONEncoder.default(self, obj)

def get_rpc_response(method, params=[]):
    while True:
        try:
            url = "https://mainnet.infura.io/{}".format(INFURA_KEY)
            params = params or []
            data = {"jsonrpc": "2.0", "method": method, "params": params, "id": 1}
            headers = {"Content-Type": "application/json"}
            response = requests.post(url, headers=headers, json=data)
            data = response.json()
            print(data)
            return data
        except Exception as e:
            print("Got error")
            print(e)
            print("Will try again in 10 seconds")
            time.sleep(10)


# 24,765,965.6485

def get_contract_transfers(address, decimals=18, from_block=None, to_block='latest'):
    """Get logs of Transfer events of a contract"""
    from_block = from_block or "0x0"
    transfer_hash = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
    params = [{"address": address, "fromBlock": from_block, "toBlock": to_block, "topics": [transfer_hash]}]
    logs = get_rpc_response("eth_getLogs", params)['result']
    decimals_factor = Decimal("10") ** Decimal("-{}".format(decimals))
    for log in logs:
        log["amount"] = Decimal(str(int(log["data"], 16))) * decimals_factor
        log["from"] = log["topics"][1][0:2] + log["topics"][1][26:]
        log["to"] = log["topics"][2][0:2] + log["topics"][2][26:]
    return logs


def get_balances(transfers):
    balances = defaultdict(Decimal)
    for t in transfers:
        balances[t["from"].lower()] -= t["amount"]
        balances[t["to"].lower()] += t["amount"]
    bottom_limit = Decimal("0.000000000000000001")
    balances = {k: balances[k] for k in balances if balances[k] > bottom_limit}
    return balances


def get_balances_list(transfers):
    balances = get_balances(transfers)
    balances = [{"address": a, "amount": b} for a, b in balances.items()]
    balances = sorted(balances, key=lambda b: -abs(b["amount"]))
    return balances

token_holders = {}
batch_size = 1500
total_airdropped = Decimal("0")
bzn_index = 0
for bzn in bzn_tokens:
    current_block = start_blocks[bzn_index]
    last_block = 15067123
    print("getting transfers for {} bzn token".format(bzn))
    all_transfers = []
    while current_block < last_block:
        print("Searching blocks {} -> {} -- {} blocks left".format(current_block, current_block + batch_size, last_block - current_block))
        transfers = get_contract_transfers(bzn, from_block=hex(current_block), to_block=hex(current_block + batch_size))
        all_transfers = all_transfers + transfers
        current_block += batch_size
    
    balances = get_balances(all_transfers)
    for address, balance in balances.items():
        if address in banned_addresses:
            print("Token holder {} is banned, skipping..".format(address))
            continue

        if address not in token_holders:
            print("New token holder {}, balance: {}".format(address, balance))
            token_holders[address] = balance
        else:
            print("Non-migrated tokens from holder {}, balance: {}".format(address, balance))
            token_holders[address] += balance
        
        total_airdropped += balance
    
    bzn_index += 1

print("Will airdrop: {}".format(total_airdropped))
print("Saving balance sheet")
with open('balances.json', mode='w') as f:
    json.dump(token_holders, f, cls=DecimalEncoder)

print("Saving token holder array")
balance_list = [{"address": a, "amount": b} for a, b in token_holders.items()]
balance_list = sorted(balance_list, key=lambda b: -abs(b["amount"]))
with open("token_holders.json", mode='w') as f:
    json.dump(balance_list, f, cls=DecimalEncoder)