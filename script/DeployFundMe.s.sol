// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    //Deploying
    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
        return fundme;
    }
}
