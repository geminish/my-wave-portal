// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;
    mapping(address => uint256) waveAddressCnt;
    mapping(address => uint256) public lastWavedAt;
    event NewWave(address indexed from, uint256 timestamp, string message);
    struct WaveRecord {
        address addr;
        string message;
        uint256 timestamp;
    }
    WaveRecord[] waves;
    constructor() payable{
        console.log("New contract starting...");
        seed = (block.timestamp + block.difficulty) % 100;
    }
    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 1 minutes < block.timestamp,
            "Please wait after 15m to wave again"
        );
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        waveAddressCnt[msg.sender] += 1;
        waves.push(WaveRecord(msg.sender, _message, block.timestamp));
        console.log("%s has waved!", msg.sender);
        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        if (seed <= 50) {
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        // emit the event to log
        emit NewWave(msg.sender, block.timestamp, _message);

    }
    function getAllWaves() public view returns (WaveRecord[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        console.log("You have waved %d times!", waveAddressCnt[msg.sender]);
        console.log("\n");
        return totalWaves;
    }

}