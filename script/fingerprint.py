import os
import json
import rfc8785
from web3 import Web3
from eth_abi import encode
from dotenv import load_dotenv
from pathlib import Path
import time
from web3.middleware import ExtraDataToPOAMiddleware

# Read ABI file
current_dir = Path(__file__).parent
abi_path = current_dir / "abi.json"
with abi_path.open("r", encoding="utf-8") as file:
    abi = json.load(file)

# Read contract address
deployment_path = current_dir / "deployment.json"
with deployment_path.open("r", encoding="utf-8") as file:
    contract_address = json.load(file)["fingerprints"]

# Load .env file
load_dotenv()

# Read environment variables
private_key = os.getenv("SUBMITTER_PRIVATE_KEY")
rpc_url = os.getenv("KITE_TEST_PRC_URL")

print(private_key)
print(contract_address)
print(rpc_url)

# Check if the environment variables are set
assert private_key and contract_address and rpc_url, "check your .env file"

# connect to the blockchain network
web3 = Web3(Web3.HTTPProvider(rpc_url))
print("connected:", web3.is_connected())
print("chain_id:", web3.eth.chain_id)

# create a contract instance
contract = web3.eth.contract(address=contract_address, abi=abi)
web3.middleware_onion.inject(ExtraDataToPOAMiddleware, layer=0)

# get address nonce
submitter = web3.eth.account.from_key(private_key)
nonce = web3.eth.get_transaction_count(submitter.address)

# get gas price
latest_block = web3.eth.get_block("latest")
base_fee_per_gas = latest_block["baseFeePerGas"]
fee_history = web3.eth.fee_history(1, "latest", [10])
priority_fees = fee_history["reward"][0]
max_priority_fee_per_gas = int(sum(priority_fees) / len(priority_fees))
max_fee_per_gas = base_fee_per_gas + max_priority_fee_per_gas * 2


# Simulated data
submissionID = 12341234
quality = "S"
userAddress = "0xEbB6C1d3dA9fb9bB75B5f6257c1C46E507C6be9c"
data = {
    "brand": "Homemade ",
    "images": [
      {
        "hash": "e6b024a0a5b3f202667300f3621190e666a52cadfd715664cd2e082cb0d3e03a"
      }
    ],
    "region": "PK",
    "foodName": "Paneer loded basan roll ",
    "quantity": "Individual (1 person)",
    "foodCategory": "Homemade food or snacks"
}
canonical_bytes = rfc8785.dumps(data)
print(canonical_bytes)
print(userAddress, "S", canonical_bytes)

# encode parameters
encodedData = encode(["address", "string", "bytes"], [userAddress, quality, canonical_bytes])
print(encodedData)

fingerprint = Web3.keccak(encodedData)

record_info = (submissionID, fingerprint)

# tx = contract.functions.submit(userAddress, record_info).build_transaction(
#     {
#         "from": submitter.address,
#         "nonce": nonce,
#         "maxPriorityFeePerGas": max_priority_fee_per_gas,
#         "maxFeePerGas": max_fee_per_gas,
#         "chainId": web3.eth.chain_id,
#         "type": 2,
#     }
# )

# Submit multiple at once, around 10 at most.
tx = contract.functions.batchSubmit([userAddress], [record_info]).build_transaction({
    "from": submitter.address,
    "nonce": nonce,
    "maxPriorityFeePerGas": max_priority_fee_per_gas,
    "maxFeePerGas": max_fee_per_gas,
    "chainId": web3.eth.chain_id,
    "type": 2,
})

# estimate gas
tx["gas"] = web3.eth.estimate_gas(tx)
signed_tx = web3.eth.account.sign_transaction(tx, private_key)
tx_hash = web3.eth.send_raw_transaction(signed_tx.raw_transaction)
receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

if receipt.status == 1:
    print("✅ Transaction executed successfully.")
else:
    print("❌ Transaction failed.（reverted）")
print(
    f"tx hash: {tx_hash.hex()}, block number: {receipt.blockNumber}, gas used: {receipt.gasUsed}"
)

result = contract.functions.getUserRecordBySubmissionId(userAddress, submissionID, 0, 10000).call()
print("Get user arena data", result)
