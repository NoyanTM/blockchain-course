<script setup>
import { computed, onMounted, ref } from 'vue';
import { ethers } from 'ethers';

const provider = computed(() => new ethers.providers.Web3Provider(window.ethereum));
const signer = computed(() => provider.value.getSigner());
const contract = ref(null);
const account = ref('');
const tasks = ref([]);
const userInfo = ref({ rating: 0, is_active: false });
const balance = ref(0);
const isConnecting = ref(false);

// Form data
const newTask = ref({
  description: '',
  reward: '',
  deadline: '',
  limit: ''
});

const taskStatuses = ['Pending', 'InProgress', 'Completed', 'Canceled'];

// BSC Testnet Configuration
const NETWORK_CONFIG = {
  chainId: '0x61', // BSC Testnet Chain ID in hex
  chainName: 'BSC Testnet',
  nativeCurrency: {
    name: 'tBNB',
    symbol: 'tBNB',
    decimals: 18
  },
  rpcUrls: ['https://data-seed-prebsc-1-s1.binance.org:8545/'],
  blockExplorerUrls: ['https://testnet.bscscan.com/']
};

const CONTRACT_ADDRESS = '0x7626E70F38a80C82e13e31bfA08E53B6005ba861';
const CONTRACT_ABI = [{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"FundsDeposited","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"FundsWithdrawn","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"taskId","type":"uint256"},{"indexed":false,"internalType":"address","name":"worker","type":"address"}],"name":"TaskAssigned","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"taskId","type":"uint256"},{"indexed":false,"internalType":"address","name":"worker","type":"address"}],"name":"TaskCompleted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"taskId","type":"uint256"},{"indexed":false,"internalType":"string","name":"description","type":"string"},{"indexed":false,"internalType":"uint256","name":"reward","type":"uint256"},{"indexed":false,"internalType":"address","name":"creator","type":"address"}],"name":"TaskCreated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"int256","name":"change","type":"int256"}],"name":"UserRated","type":"event"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"balances","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"taskId","type":"uint256"},{"internalType":"string","name":"report","type":"string"}],"name":"completeTask","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"description","type":"string"},{"internalType":"uint256","name":"reward","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint256","name":"limit","type":"uint256"}],"name":"createTask","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"depositFunds","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"getTasks","outputs":[{"components":[{"internalType":"string","name":"description","type":"string"},{"internalType":"uint256","name":"reward","type":"uint256"},{"internalType":"address","name":"creator","type":"address"},{"internalType":"address","name":"worker","type":"address"},{"internalType":"enum OutsourceKZ.TaskStatus","name":"status","type":"uint8"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint256","name":"limit","type":"uint256"},{"internalType":"address[]","name":"participants","type":"address[]"},{"internalType":"string","name":"report","type":"string"}],"internalType":"struct OutsourceKZ.Task[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"taskId","type":"uint256"}],"name":"participateInTask","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"taskId","type":"uint256"}],"name":"pickTaskWorker","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"register","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"tasks","outputs":[{"internalType":"string","name":"description","type":"string"},{"internalType":"uint256","name":"reward","type":"uint256"},{"internalType":"address","name":"creator","type":"address"},{"internalType":"address","name":"worker","type":"address"},{"internalType":"enum OutsourceKZ.TaskStatus","name":"status","type":"uint8"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint256","name":"limit","type":"uint256"},{"internalType":"string","name":"report","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"users","outputs":[{"internalType":"int256","name":"rating","type":"int256"},{"internalType":"bool","name":"is_active","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"withdrawFunds","outputs":[],"stateMutability":"nonpayable","type":"function"}];

async function switchToBscTestnet() {
  try {
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: NETWORK_CONFIG.chainId }],
    });
  } catch (switchError) {
    // This error code indicates that the chain has not been added to MetaMask
    if (switchError.code === 4902) {
      try {
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [NETWORK_CONFIG],
        });
      } catch (addError) {
        throw new Error('Failed to add BSC Testnet to MetaMask');
      }
    } else {
      throw switchError;
    }
  }
}

async function connectWallet() {
  if (isConnecting.value) return;
  isConnecting.value = true;

  try {
    if (!window.ethereum) {
      alert('Please install MetaMask!');
      return;
    }

    // Switch to BSC Testnet
    await switchToBscTestnet();

    // Request accounts
    const accounts = await window.ethereum.request({
      method: 'eth_requestAccounts'
    });

    if (!accounts || accounts.length === 0) {
      throw new Error('No accounts found');
    }

    // Set up provider and signer
    account.value = accounts[0];

    // Initialize contract
    contract.value = new ethers.Contract(
      CONTRACT_ADDRESS,
      CONTRACT_ABI,
      signer.value
    );

    await Promise.all([loadUserData(), loadTasks()]);
  } catch (error) {
    console.error('Error connecting wallet:', error);
    alert('Failed to connect wallet: ' + error.message);
  } finally {
    isConnecting.value = false;
  }
}

async function loadUserData() {
  try {
    if (!contract.value || !account.value) return;
    
    const [rating, is_active] = await contract.value.users(account.value);
    userInfo.value = { 
      rating: rating.toNumber(), 
      is_active 
    };
    
    const userBalance = await contract.value.balances(account.value);
    balance.value = ethers.utils.formatEther(userBalance);
  } catch (error) {
    console.error('Error loading user data:', error);
  }
}

async function loadTasks() {
  try {
    if (!contract.value) return;
    
    const tasksList = await contract.value.getTasks();
    tasks.value = tasksList.map(task => ({
      ...task,
      reward: task.reward.toString()
    }));
  } catch (error) {
    console.error('Error loading tasks:', error);
  }
}

async function register() {
  try {
    if (!contract.value) throw new Error('Contract not initialized');
    
    const tx = await contract.value.register();
    await tx.wait();
    await loadUserData();
    alert('Successfully registered!');
  } catch (error) {
    console.error('Error registering:', error);
    alert('Failed to register: ' + error.message);
  }
}

async function createTask() {
  try {
    if (!contract.value) throw new Error('Contract not initialized');
    
    const tx = await contract.value.createTask(
      newTask.value.description,
      ethers.utils.parseEther(newTask.value.reward.toString()),
      newTask.value.deadline,
      newTask.value.limit
    );
    await tx.wait();
    await loadTasks();
    alert('Task created successfully!');
    // Reset form
    newTask.value = { description: '', reward: '', deadline: '', limit: '' };
  } catch (error) {
    console.error('Error creating task:', error);
    alert('Failed to create task: ' + error.message);
  }
}

async function participateInTask(taskId) {
  try {
    if (!contract.value) throw new Error('Contract not initialized');
    
    const tx = await contract.value.participateInTask(taskId);
    await tx.wait();
    await loadTasks();
    alert('Successfully participated in task!');
  } catch (error) {
    console.error('Error participating in task:', error);
    alert('Failed to participate in task: ' + error.message);
  }
}

// Handle account changes
async function handleAccountsChanged(accounts) {
  if (accounts.length === 0) {
    // User disconnected
    account.value = '';
    userInfo.value = { rating: 0, is_active: false };
    balance.value = 0;
    contract.value = null;
    signer.value = null;
    provider.value = null;
  } else if (accounts[0] !== account.value) {
    // Account changed
    account.value = accounts[0];
    await connectWallet();
  }
}

async function depositFunds(amountInEth) {
  try {
    if (!contract.value) throw new Error('Contract not initialized');
    if (!account.value) throw new Error('Wallet not connected');

    // Convert ETH to wei (since ETH is 18 decimal, we use ethers.utils.parseEther)
    const amountInWei = ethers.utils.parseEther(amountInEth.toString());

    // Ensure the amount is greater than 10000 Gwei (10^7 wei)
    if (amountInWei.lt(ethers.utils.parseUnits("0.01", "ether"))) {
      alert("You must send at least 10000 Gwei (0.01 ETH)");
      return;
    }

    const tx = await contract.value.depositFunds({
      value: amountInWei,
    });

    await tx.wait(); // Wait for the transaction to be mined
    alert("Deposit successful!");
    await loadUserData(); // Reload user data (balance) after deposit
  } catch (error) {
    console.error("Error depositing funds:", error);
    alert("Failed to deposit funds: " + error.message);
  }
}

async function withdrawFunds(amountInEth) {
  try {
    if (!contract.value) throw new Error('Contract not initialized');
    if (!account.value) throw new Error('Wallet not connected');

    // Convert ETH to wei (since ETH is 18 decimal, we use ethers.utils.parseEther)
    const amountInWei = ethers.utils.parseEther(amountInEth.toString());

    // Ensure the user has enough funds
    if (amountInWei.gt(balance.value)) {
      alert("Insufficient balance to withdraw");
      return;
    }

    const tx = await contract.value.withdrawFunds(amountInWei);

    await tx.wait(); // Wait for the transaction to be mined
    alert("Withdrawal successful!");
    await loadUserData(); // Reload user data (balance) after withdrawal
  } catch (error) {
    console.error("Error withdrawing funds:", error);
    alert("Failed to withdraw funds: " + error.message);
  }
}

onMounted(() => {
  if (window.ethereum) {
    window.ethereum.on('accountsChanged', handleAccountsChanged);
    window.ethereum.on('chainChanged', () => {
      window.location.reload();
    });
  }
});
</script>

<template>
  <div class="container py-4">
    <h1 class="mb-4">OutsourceKZ DApp</h1>
    
    <!-- Wallet Connection -->
    <div class="card mb-4">
      <div class="card-body">
        <h5 class="card-title">Wallet Connection</h5>
        <button 
          v-if="!account" 
          @click="connectWallet" 
          class="btn btn-primary"
          :disabled="isConnecting"
        >
          {{ isConnecting ? 'Connecting...' : 'Connect Wallet' }}
        </button>
        <div v-else>
          <p><strong>Connected Account:</strong> {{ account }}</p>
          <p><strong>Balance:</strong> {{ balance }} ETH</p>
          <p><strong>Rating:</strong> {{ userInfo.rating }}</p>
          <p><strong>Status:</strong> {{ userInfo.is_active ? 'Active' : 'Inactive' }}</p>
          <button @click="depositFunds(0.01)" class="btn btn-primary">Deposit 0.01 ETH</button>
          <button @click="withdrawFunds(0.01)" class="btn btn-primary">Withdraw 0.01 ETH</button>
        </div>
      </div>
    </div>

    <!-- Registration -->
    <div v-if="account && !userInfo.is_active" class="card mb-4">
      <div class="card-body">
        <h5 class="card-title">Registration</h5>
        <button @click="register" class="btn btn-success">
          Register
        </button>
      </div>
    </div>

    <!-- Create Task -->
    <div v-if="account && userInfo.is_active" class="card mb-4">
      <div class="card-body">
        <h5 class="card-title">Create New Task</h5>
        <form @submit.prevent="createTask" class="needs-validation">
          <div class="mb-3">
            <label class="form-label">Description</label>
            <input 
              v-model="newTask.description" 
              type="text" 
              class="form-control" 
              required
              placeholder="Enter task description"
            >
          </div>
          <div class="mb-3">
            <label class="form-label">Reward (ETH)</label>
            <input 
              v-model="newTask.reward" 
              type="number" 
              step="0.000000000000000001" 
              class="form-control" 
              required
              placeholder="Enter reward amount"
            >
          </div>
          <div class="mb-3">
            <label class="form-label">Deadline (seconds)</label>
            <input 
              v-model="newTask.deadline" 
              type="number" 
              class="form-control" 
              required
              placeholder="Enter deadline in seconds"
            >
          </div>
          <div class="mb-3">
            <label class="form-label">Participant Limit</label>
            <input 
              v-model="newTask.limit" 
              type="number" 
              class="form-control" 
              required
              placeholder="Enter participant limit"
            >
          </div>
          <button type="submit" class="btn btn-primary">Create Task</button>
        </form>
      </div>
    </div>

    <!-- Tasks List -->
    <div class="card">
      <div class="card-body">
        <h5 class="card-title">Available Tasks</h5>
        <div class="table-responsive">
          <table class="table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Description</th>
                <th>Reward</th>
                <th>Status</th>
                <th>Creator</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(task, index) in tasks" :key="index">
                <td>{{ index }}</td>
                <td>{{ task.description }}</td>
                <td>{{ ethers.utils.formatEther(task.reward) }} ETH</td>
                <td>{{ taskStatuses[task.status] }}</td>
                <td>{{ task.creator }}</td>
                <td>
                  <button 
                    v-if="task.status === 0 && account && account !== task.creator"
                    @click="participateInTask(index)"
                    class="btn btn-sm btn-primary"
                  >
                    Participate
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>