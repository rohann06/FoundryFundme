// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    using PriceConveter for uint256;
    AggregatorV3Interface private s_priceFeed;

    // Variable to store the last withdrawal timestamp
    uint256 public lastWithdrawalTime;

    //Set minimum fundings
    uint256 public minimumUSD = 5e18;
    address[] public funders; //all funders
    mapping(address => uint256) public  addressToAmountFunded; //Maooing the funders and their fund

    //Setiing the owner 
    address public  owner;

    constructor(address priceFeed){
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    //Get Fund from users
    function find() public payable {

        // 1. How send eth to the contract?
        require(msg.value.getConversioinRate(s_priceFeed) >= minimumUSD, "Send minimum 1 ETH"); // used Library
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;

    }
    
    //Withdraw funds
    function withdraw() public payable onlyOwner {
        
        // Grt money from the contarct
        payable(msg.sender).transfer(address(this).balance);

         // Record the time of the withdrawal
        lastWithdrawalTime = block.timestamp;
    }

    //Creating a modifire
    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }
    
    // Function to get the total balance of the contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

}
