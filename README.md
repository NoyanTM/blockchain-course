# blochain-course

Sample hardhat project:
```shell
npx hardhat init
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js

npx hardhat compile
```

## practice reports

### practice 1 - solidity and smart-contracts ethereum
0. Whitepapers
- http://www.ralphmerkle.com/papers/Thesis1979.pdf
- https://evervault.com/papers/chaum
1. Create Metamask crypto wallet
- https://metamask.io/
2. Link and connect Metamask wallet to Chainlist test blockchain network
https://chainlist.org
3. Receive test coins from faucet:
- https://testnet.bnbchain.org/faucet-smart / https://www.bnbchain.org/en/testnet-faucet
- https://faucet.quicknode.com/binance-smart-chain/bnb-testnet
- https://faucets.chain.link/bnb-chain-testnet
4. Results:
- Address - 0x6c66E93B7042Dda62049cbbe83C6f41977bFEBA0
- Transaction - https://testnet.bscscan.com/tx/0x12cf76f433e7d477a1740cf768087ab134ce11735ea9bc526d4c4dbed2256684
5. Remix IDE:
- https://github.com/ethereum/remix-desktop/releases
- Solidity compiler settings: compiler version-0.8.11, auto-compile, language - solidity, EVM version-default

### practice 2 - data types (bool, int, uint) in solidity
0. Solidity:
- language for writing smart contract with 
- object-oriented, high-level language for implementing smart
contracts
- smart contracts are programs that govern the behavior of accounts within the
Ethereum state

### practice 3
Objective of the Task: Research and analyze transactions, block structure, and fees in the Bitcoin, Ethereum, and Binance Smart Chain blockchain networks. Students are expected to gather data from each network and prepare a report with visualizations of this data.
Expected Outcome: A report with data visualizations of each blockchain network, which includes an analysis of transactions, block structure, and fees in each network. Students should provide a comparative analysis and draw conclusions.

Steps to Complete the Assignment:
Study the Theoretical Part:

1. Learn the basic information about the blockchain networks:
- Bitcoin: How the network works, the Proof of Work (PoW) consensus algorithm, block structure, how transactions occur, and how fees are calculated.
- Ethereum: Features of Ethereum (e.g., the use of smart contracts, Proof of Stake algorithm, gas system for transaction calculations).
- Binance Smart Chain (BSC): Characteristics of BSC, features of the Proof of Staked Authority (PoSA) consensus, how the network works, and how fees are calculated.

2. Data Collection:
For each network, choose tools or APIs to collect data about blocks, transactions, and fees. Use the following sources:
Bitcoin: Blockchain.com or Blockchair.
Ethereum: Etherscan for data on blocks and transactions.
Binance Smart Chain (BSC): BscScan for data on blocks and transactions.

Collect the following data:
Number of blocks per day (or month).
Average transaction fee.
Average transaction confirmation time.
Block sizes for each network.

Analysis of Block Structure:
For each blockchain, analyze the structure of blocks:
What data is contained in the blocks (hash, number of transactions, block time)?
Compare the average data size in one block for each network.

Analysis of Transactions:
- Analyze the types of transactions in each network:
- Simple transfers of funds.
- Smart contracts (especially in Ethereum and BSC).
Token transactions (ERC-20 for Ethereum and BEP-20 for BSC).
Calculate the average number of transactions occurring in blocks and their distribution by type.

Analysis of Fees:
Investigate how fees are formed in each network:
- In Bitcoin, fees depend on the transaction size and network congestion.
- In Ethereum, the gas system is used, and transaction costs depend on the complexity of the operation.
- In BSC, fees are fixed, but they are significantly lower than in Ethereum.
Compare the fees for identical types of transactions across different networks.

Data Visualization:
Create graphs and charts for:
- The average transaction fee in each network (e.g., for the past month).
- The average transaction confirmation time.
- Block sizes and their changes over time.
- Comparison of the number of transactions between networks.

Examples of Visualizations:
A graph showing the change in the average transaction fee per month for each network.
A diagram comparing the transaction confirmation times for each network.
A graph showing the change in block sizes for each network.
For data visualization, you can use Python with libraries such as Matplotlib, Seaborn, or Plotly.

Writing the Report:
Students should write a report that includes:
Theoretical Part: A description of each blockchain network, its consensus algorithm, and features.
Data Analysis: Study of block structure, transactions, and fees.
Visualization: Graphs and charts for comparing blockchains.
Conclusions: Comparative analysis and conclusions about each network (e.g., which network is faster, which has lower fees, etc.).

Preparation and Submission of the Work:
After completing the task, students should present a report with visualizations and a brief analysis.
The work should be submitted in the form of a PDF report or a presentation with graphs and diagrams.

### final project
Requirements: 
- only in solo
- example ideas: smart contracts, nft, архитектура для обеспечения безопасности, понимание для будущего проекта и применение к своим темам, для защиты мед порталы данных и персональных данных, финансовые системы, системы голосований, supply chain management / логистика, образовательные учереждения, судебные системы, гос учереждения, etc.
- can conduct ICOs, open votes, auctions, sell different values, issue their
own currency and, as it turns out, even create and sell cats.
- https://moodle.astanait.edu.kz/mod/assign/view.php?id=165117
