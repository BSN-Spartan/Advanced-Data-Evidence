# Advanced Data Evidence Contract

[![Smart Contract](https://badgen.net/badge/smart-contract/Solidity/orange)](https://soliditylang.org/) 

Electronic evidence is a means used to preserve evidence, and there are many application scenarios. For example, in the copyright field, an author can save the signature of his/her work to an evidence service, and when a copyright dispute arises, the dispute can be resolved through forensics. The key part of evidence and forensics is the electronic evidence service. How to ensures its trustworthiness? Will the depository itself damage the evidence data? The traditional centralized depository is difficult to solve this problem. In blockchain technology, a ledger is jointly maintained by various nodes, and its content is determined by the consensus algorithm, so that a single node cannot tamper with the ledger that has reached consensus. This tamper-proof feature is the core of the decentralized electronic evidence solution. In this example, the evidence data is no longer stored in a single institution, but is distributed and stored on all blockchain nodes.

## Prerequisite

Before using this smart contract, it is important to have a basic understanding of Ethereum and Solidity.   


## Overview

Electronic evidence is a way to record the whole process of "user identity verification - data creation - data storage - data transmission", and apply a series of security technologies to ensure the authenticity, integrity and security of data in all aspects, which has complete legal effect in justice.

The use of blockchain + smart contract for evidence has the following advantages:

* Tamper-proof mechanism: the use of blockchain technology will preserve evidence data and strengthen the tamper-proof nature of evidence.
* Recognition of the validity of evidence: judicial institutions, as nodes on the chain, are involved in recognizing and signing the evidence data, and the validity of the data can be confirmed by the blockchain.
* Continuous validity of service: After the data is submitted to the chain, it will be permanently preserved and valid even if some validation nodes withdraw from the blockchain.



## Design of the Upgradeable Contract


The contract is designed to achieve the upgradeable logic contract through ERC1967 and UUPS (EIP-1822: Universal Upgradeable Proxy Standard) modes.

Logic contract:

- Inherit UUPSUpgradable. This class library implements an upgradeable mechanism for UUPS proxy design.
- Add the initialize() function, which is called when the proxy contract is deployed to perform the initialization of the contract.

The deployment process of the proxy contract is as follows:

- Deploy the logic contract.
- Deploy the proxy contract ERC1967Proxy. During deployment, construct a  signature for writing parameters to the logic contract address and initialize function, and implement its mapping and initialization operations with the logic contract.

The upgrade process of the logic contract is as follows:

- Deploy a new version of the logic contract.
- Call `upgradeTo` function in the proxy contract. When executing, a new logic contract address is passed in to map it to the new version of the logic contract, while keeping the same address of the proxy contract.

## Usage

Get the smart contract from [GitHub](https://github.com/BSN-Spartan/NFT-Fractional-Contract/tree/main/contracts), or get the source code by command:

```
$ git clone https://github.com/BSN-Spartan/Advanced-Data-Evidence.git
```

For beginners, the contracts in this application can be deployed by the steps in [Spartan Quick Testing](https://www.spartan.bsn.foundation/main/quick-testing#step1).

In this application, there are two contracts: evidence and ERC1967Proxy. Follow steps below to deploy and use them:

1. Deploy evidence.sol contract.
2. Deploy ERC1967Proxy.sol contract. This contract is imported when compiling evidence.sol contract. When deploying this contract, input the address of evidence.sol contract in the first blank and input the parameter "0x8129fc1c" in the second blank. "0x8129fc1c" is the signature of initialize() function, which can achieve the initialization operation and the mapping between the proxy contract and evidence.sol contract.
3. If you use Remix IDE, after successfully deploying evidence.sol contract and the proxy contract, please compile evidence.sol contract again and find the "At Address" button in the deployment section. Fill in the address of the proxy contract and click the button. Then, all functions in evidence.sol contract are listed in the proxy contract and are ready to use.
4. The contract owner calls `setThreshold` function to set the threshold that approves the uploading of the evidence to the chain.
5. The contract owner calls `configureAuditor` function to add auditors that can vote on requests. 
6. The depositor calls `createSaveRequest` function to submit a deposit request. The request information can be found by calling `getRequestData` function.
7. The auditors call `voteSaveRequest` function to vote on the  request. If the number of approvals is greater than or equal to the voting threshold, the request will be approved and the evidence will be recorded on the chain. The evidence information can be found by calling `getEvidence` function.

## Main Functions

### setThreshold

The owner of the contract calls this function to set the threshold for passing the vote.

```
function setThreshold(uint8 number) 
```

### configureAuditor

The owner of the contract calls this function to create auditors for reviewing requests and voting.

```
function configureAuditor(address auditor, bool approval, bytes32 did)
```

1. `auditor` is the wallet address of the auditor.
2. `approval` can be set as "true" or "false". This can set or change the auditor's voting permission. To change the permission, change the parameter and call this function again.
3. `did` is a string in the form of bytes32. For example, "0x270c40c6328b3debed2b84a82f56db95845fb03a66797a4e3302170c7b9562de".

### createSaveRequest

The depositor calls this function to upload the evidence to the chain. The evidence stored here is the data digest generated by hashing the original file.

```
createSaveRequest(bytes32 hash, address owner, bytes memory remarks)
```

1. `hash` is the data digest of the evidence, and is written in the form of bytes32. For example, "0xc28420804472751c9473a468de1c38cd89dabadd2da7788511036b4ad5fb4fe0".
2. `owner` is the owner of the evidence.
3. `remarks` is the description of the evidence, and is and is written in the form of bytes32. For example, "0xf4dcaf61f8f073e68b35b4c91f4ebdc42a2cf8e66b5c04decd6874aaf3e61fa3".

### deleteSaveRequest

The depositor calls this function to delete the request data that fails to pass the vote.

```
deleteSaveRequest(bytes32 hash)
```

### getRequestData

This function can check the information of the request, including the evidence, the depositor, the owner, the remarks and the timestamp of raising the request.

```
getRequestData(bytes32 hash)
```

### voteSaveRequest

The auditor calls this function to vote for the request.

```
voteSaveRequest(bytes32 hash, bool status)
```

1. `hash` is the evidence.
2. `status` can be set as "true" to approve the vote, and "false" to against the vote.

### getEvidence

This function can check the information of the evidence, including the evidence, the depositor, the remarks, the timestamp of passing the vote, and the status of the evidence.

```
getEvidence(bytes32 hash)
```

### setStatus

The owner of the contract calls this function to enable/disable the evidence.

```
setStatus(bytes32 hash, bool status)
```

1. `hash` is the evidence.
2. `status` can be set as "true" to enable the evidence and "false" to disable the evidence.

## License

Spartan-Evidence Contract is released under the [Spartan License](https://github.com/BSN-Spartan/Beginner-Level-Contracts/blob/main/Spartan%20License.md).

