import os
import json
import hashlib
from time import time
from uuid import uuid4
from urllib.parse import urlparse
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

CHAIN_FILE = 'blockchain.json'

class Blockchain:
    def __init__(self):
        self.current_transactions = []
        self.chain = []
        self.nodes = set()
        self.users = {}
        
        if os.path.exists(CHAIN_FILE):
            try:
                with open(CHAIN_FILE, 'r') as f:
                    data = json.load(f)
                    if isinstance(data, list) and len(data) > 0:
                        self.chain = data
                    else:
                        self.create_genesis_block()
            except Exception:
                self.create_genesis_block()
        else:
            self.create_genesis_block()
    
    def create_genesis_block(self):
        genesis_block = {
            'index': 1,
            'timestamp': 1625000000,
            'transactions': [],
            'proof': 100,
            'previous_hash': '1'
        }
        self.chain = [genesis_block]
    
    def save_chain(self):
        with open(CHAIN_FILE, 'w') as f:
            json.dump(self.chain, f)
    
    def register_node(self, address: str):
        parsed_url = urlparse(address)
        self.nodes.add(parsed_url.netloc or parsed_url.path)
    
    def valid_chain(self, chain):
        last_block = chain[0]
        current_index = 1
        while current_index < len(chain):
            block = chain[current_index]
            if block['previous_hash'] != self.hash(last_block):
                return False
            if not self.valid_proof(last_block['proof'], block['proof'], self.hash(last_block)):
                return False
            last_block = block
            current_index += 1
        return True
    
    def resolve_conflicts(self):
        neighbours = self.nodes
        new_chain = None
        max_length = len(self.chain)
        for node in neighbours:
            try:
                response = requests.get(f'http://{node}/chain')
            except requests.exceptions.RequestException:
                continue
            if response.status_code == 200:
                length = response.json()['length']
                chain = response.json()['chain']
                if length > max_length and self.valid_chain(chain):
                    max_length = length
                    new_chain = chain
        if new_chain:
            self.chain = new_chain
            self.save_chain()
            return True
        return False
    
    def new_block(self, proof, previous_hash=None):
        block = {
            'index': len(self.chain) + 1,
            'timestamp': time(),
            'transactions': self.current_transactions,
            'proof': proof,
            'previous_hash': previous_hash or self.hash(self.chain[-1]),
        }
        self.current_transactions = []
        self.chain.append(block)
        self.save_chain()
        return block
    
    def new_transaction(self, sender, recipient, amount):
        if sender != "0" and self.get_balance(sender) < amount:
            return None
        self.current_transactions.append({'sender': sender, 'recipient': recipient, 'amount': amount})
        return self.last_block['index'] + 1
    
    def get_balance(self, address):
        balance = 0
        for block in self.chain:
            for tx in block.get('transactions', []):
                if tx['recipient'] == address:
                    balance += tx['amount']
                if tx['sender'] == address:
                    balance -= tx['amount']
        for tx in self.current_transactions:
            if tx['recipient'] == address:
                balance += tx['amount']
            if tx['sender'] == address:
                balance -= tx['amount']
        return balance
    
    @staticmethod
    def hash(block):
        return hashlib.sha256(json.dumps(block, sort_keys=True).encode()).hexdigest()
    
    @property
    def last_block(self):
        return self.chain[-1]
    
    def proof_of_work(self, last_proof, last_hash):
        proof = 0
        while not self.valid_proof(last_proof, proof, last_hash):
            proof += 1
        return proof
    
    @staticmethod
    def valid_proof(last_proof, proof, last_hash):
        guess_hash = hashlib.sha256(f'{last_proof}{proof}{last_hash}'.encode()).hexdigest()
        return guess_hash[:5] == "00000"
    
    def create_user(self):
        address, passphrase = str(uuid4())[:8], str(uuid4())[:8]
        self.users[address] = passphrase
        return address, passphrase
    
    def check_user_passphrase(self, address, passphrase):
        return self.users.get(address) == passphrase

app = FastAPI()
blockchain = Blockchain()

class MineRequest(BaseModel):
    miner_address: str
    miner_passphrase: str

@app.post("/mine")
def mine(request: MineRequest):
    if not blockchain.check_user_passphrase(request.miner_address, request.miner_passphrase):
        raise HTTPException(status_code=400, detail="Неверный passphrase")
    last_block = blockchain.last_block
    proof = blockchain.proof_of_work(last_block['proof'], blockchain.hash(last_block))
    blockchain.new_transaction("0", request.miner_address, 1)
    block = blockchain.new_block(proof)
    return block

@app.get("/chain")
def full_chain():
    return {"chain": blockchain.chain, "length": len(blockchain.chain)}

@app.get("/balance/{address}")
def get_balance(address: str):
    return {"address": address, "balance": blockchain.get_balance(address)}

@app.get("/register_user")
def register_user():
    address, passphrase = blockchain.create_user()
    return {"address": address, "passphrase": passphrase}

if __name__ == '__main__':
    import uvicorn 
    uvicorn.run(app)
    