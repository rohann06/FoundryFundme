// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

//importing contract from github
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConveter {
    // Get ETH price
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //ABI
        //Address
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10); //Type casting in to uint256
    }

    // Get conversion rate
    function getConversioinRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
