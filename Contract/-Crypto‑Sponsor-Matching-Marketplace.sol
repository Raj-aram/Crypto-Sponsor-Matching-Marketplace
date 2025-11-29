// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Crypto-Sponsor Matching Marketplace
 * @dev A decentralized platform for matching sponsors with content creators and projects
 */
contract Project {
    
    // Struct to represent a Creator/Project seeking sponsorship
    struct Creator {
        address creatorAddress;
        string name;
        string category;
        uint256 fundingGoal;
        uint256 fundsReceived;
        bool isActive;
        uint256 timestamp;
    }
    
    // Struct to represent a Sponsorship deal
    struct Sponsorship {
        address sponsor;
        address creator;
        uint256 amount;
        uint256 timestamp;
        bool isActive;
    }
    
    // State variables
    mapping(address => Creator) public creators;
    mapping(uint256 => Sponsorship) public sponsorships;
    address[] public creatorList;
    uint256 public sponsorshipCounter;
    
    // Events
    event CreatorRegistered(address indexed creator, string name, uint256 fundingGoal);
    event SponsorshipCreated(uint256 indexed sponsorshipId, address indexed sponsor, address indexed creator, uint256 amount);
    event FundsWithdrawn(address indexed creator, uint256 amount);
    
    /**
     * @dev Register as a creator/project seeking sponsorship
     * @param _name Name of the creator or project
     * @param _category Category (e.g., "Gaming", "Art", "Music", "Tech")
     * @param _fundingGoal Target funding amount in wei
     */
    function registerCreator(
        string memory _name,
        string memory _category,
        uint256 _fundingGoal
    ) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_fundingGoal > 0, "Funding goal must be greater than 0");
        require(!creators[msg.sender].isActive, "Creator already registered");
        
        creators[msg.sender] = Creator({
            creatorAddress: msg.sender,
            name: _name,
            category: _category,
            fundingGoal: _fundingGoal,
            fundsReceived: 0,
            isActive: true,
            timestamp: block.timestamp
        });
        
        creatorList.push(msg.sender);
        
        emit CreatorRegistered(msg.sender, _name, _fundingGoal);
    }
    
    /**
     * @dev Sponsor a creator by sending funds
     * @param _creatorAddress Address of the creator to sponsor
     */
    function sponsorCreator(address _creatorAddress) public payable {
        require(msg.value > 0, "Sponsorship amount must be greater than 0");
        require(creators[_creatorAddress].isActive, "Creator is not active");
        require(_creatorAddress != msg.sender, "Cannot sponsor yourself");
        
        // Update creator's funds
        creators[_creatorAddress].fundsReceived += msg.value;
        
        // Record sponsorship
        sponsorships[sponsorshipCounter] = Sponsorship({
            sponsor: msg.sender,
            creator: _creatorAddress,
            amount: msg.value,
            timestamp: block.timestamp,
            isActive: true
        });
        
        emit SponsorshipCreated(sponsorshipCounter, msg.sender, _creatorAddress, msg.value);
        sponsorshipCounter++;
    }
    
    /**
     * @dev Allow creators to withdraw their received funds
     */
    function withdrawFunds() public {
        Creator storage creator = creators[msg.sender];
        require(creator.isActive, "Creator is not registered");
        require(creator.fundsReceived > 0, "No funds to withdraw");
        
        uint256 amount = creator.fundsReceived;
        creator.fundsReceived = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit FundsWithdrawn(msg.sender, amount);
    }
    
    // View functions
    
    /**
     * @dev Get creator details
     * @param _creatorAddress Address of the creator
     * @return name The creator's name
     * @return category The creator's category
     * @return fundingGoal The creator's funding goal
     * @return fundsReceived The funds received by the creator
     * @return isActive Whether the creator is active
     */
    function getCreator(address _creatorAddress) public view returns (
        string memory name,
        string memory category,
        uint256 fundingGoal,
        uint256 fundsReceived,
        bool isActive
    ) {
        Creator memory creator = creators[_creatorAddress];
        return (
            creator.name,
            creator.category,
            creator.fundingGoal,
            creator.fundsReceived,
            creator.isActive
        );
    }
    
    /**
     * @dev Get total number of registered creators
     * @return Number of creators
     */
    function getTotalCreators() public view returns (uint256) {
        return creatorList.length;
    }
    
    /**
     * @dev Get sponsorship details
     * @param _sponsorshipId ID of the sponsorship
     * @return sponsor The address of the sponsor
     * @return creator The address of the creator
     * @return amount The sponsorship amount
     * @return timestamp The timestamp of the sponsorship
     * @return isActive Whether the sponsorship is active
     */
    function getSponsorship(uint256 _sponsorshipId) public view returns (
        address sponsor,
        address creator,
        uint256 amount,
        uint256 timestamp,
        bool isActive
    ) {
        Sponsorship memory sponsorship = sponsorships[_sponsorshipId];
        return (
            sponsorship.sponsor,
            sponsorship.creator,
            sponsorship.amount,
            sponsorship.timestamp,
            sponsorship.isActive
        );
    }
}

