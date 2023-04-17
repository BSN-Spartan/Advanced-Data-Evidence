pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable@4.8.0/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.0/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Evidence is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    uint8 threshold; 

    mapping(address => Auditors) private auditors; 

    struct Auditors {
        bool status;
        bytes32 did;
    }

    address[] auditorsArray;

    mapping(bytes32 => SaveRequest) private saveRequests; 

    struct SaveRequest {
        bytes32 hash;
        address owner;
        address creator;
        uint8 voted;
        bytes remarks;
        uint256 timestamp;
        uint8 status;
        Voters[] voters;
    }

    struct Voters {
        address voter;
        bool status;
        bytes32 did;
    }

    struct Evidence {
        bytes32 hash;
        address owner;
        bytes remarks;
        uint256 timestamp;
        bool status;
    }

    event SetThreshold(address indexed operator, uint8 threshold); 

    event ConfigureAuditor(
        address indexed operator,
        address auditor,
        bool approvals
    ); 

    event CreateSaveRequest(
        address indexed operator,
        bytes32 hash,
        address owner
    ); 

    event DeleteSaveRequest(
        address indexed operator,
        bytes32 hash,
        address owner
    ); 
    
    event VoteSaveRequest(
        address indexed operator,
        bytes32 hash,
        address voter
    ); 
    
    event SetStatus(
        address indexed operator,
        bytes32 hash,
        bool status
    ); 

    modifier validateHash(bytes32 hash) {
        require(hash != 0, "Not a valid hash");
        _;
    }

    function setThreshold(uint8 number) public onlyOwner {
        threshold = number;

        emit SetThreshold(msg.sender, number);
    }

    function configureAuditor(address auditor, bool approval, bytes32 did) public onlyOwner {
        auditors[auditor].status = approval;
        auditors[auditor].did = did;

        auditorsArray.push(auditor);

        emit ConfigureAuditor(msg.sender, auditor, approval);
    }

    function createSaveRequest(
        bytes32 hash,
        address owner,
        bytes memory remarks
    ) public validateHash(hash) {
        saveRequests[hash].hash = hash;
        saveRequests[hash].owner = owner;
        saveRequests[hash].creator = msg.sender;
        saveRequests[hash].voted = 0;
        saveRequests[hash].remarks = remarks;
        saveRequests[hash].timestamp = block.timestamp;
        saveRequests[hash].status = 0;

        emit CreateSaveRequest(msg.sender, hash, owner);
    }

    function deleteSaveRequest(bytes32 hash) public {
        require(saveRequests[hash].hash == hash, "Request not found");

        SaveRequest storage request = saveRequests[hash];
        require(request.creator == msg.sender, "No permissions");

        require(request.status != 1, "Passed votes cannot be deleted");

        delete saveRequests[hash];

        emit DeleteSaveRequest(msg.sender, hash, request.owner);
    }

    function getRequestData(
        bytes32 hash
    ) public view returns (SaveRequest memory) {
        require(saveRequests[hash].hash == hash, "Request not found");
        SaveRequest storage request = saveRequests[hash];
        return request;
    }

    function voteSaveRequest(
        bytes32 hash,
        bool status
    ) public validateHash(hash) {
        require(auditors[msg.sender].status == true, "Not allowed to vote"); 
        require(saveRequests[hash].hash == hash, "Request not found"); 

        SaveRequest storage request = saveRequests[hash];

        bool voted = false;
        for (uint i = 0; i < request.voters.length; i++) {
            if (request.voters[i].voter == msg.sender) {
                voted = true;
                break;
            }
        }
        require(voted == false, "Voter already voted");

        require(request.status != 1, "Voter already voted"); 

        request.voters.push(Voters(msg.sender, status, auditors[msg.sender].did));
        request.voted++;

        uint8 voteStatus = 0;
        uint8 number = 0;
        for (uint i = 0; i < request.voters.length; i++) {
            if (request.voters[i].status == status) {
                if (status == true) {
                    number++;
                    if (number >= threshold) {
                        voteStatus = 1;
                        break;
                    }
                } else if (status == false) {
                    number++;
                    if (number > auditorsArray.length - threshold) {
                        voteStatus = 2;
                        break;
                    }
                }
            }
        }

        if (voteStatus == 1) {
            setData(hash, request.owner, request.remarks, block.timestamp);
        }
        request.status = voteStatus;

        emit VoteSaveRequest(msg.sender, hash, request.owner);
    }

    mapping(bytes32 => Evidence) private evidences;

    function setData(
        bytes32 hash,
        address owner,
        bytes memory remarks,
        uint256 timestamp
    ) private {
        require(hash != 0, "Not a valid hash");
        evidences[hash].hash = hash;
        evidences[hash].owner = owner;
        evidences[hash].remarks = remarks;
        evidences[hash].timestamp = timestamp;
        evidences[hash].status = true;
    }

    function getEvidence(bytes32 hash) public view returns (Evidence memory) {
        
        require(evidences[hash].hash == hash, "Evidence not found");
        require(evidences[hash].status == true, "The evidence has been disabled");
        return evidences[hash];
    }

    function setStatus(bytes32 hash, bool status) public {
        evidences[hash].status = status;
        
        emit SetStatus(msg.sender, hash, status);
    }


}
