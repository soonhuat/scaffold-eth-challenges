// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  uint256 public constant threshold = 1 ether;
  uint256 private constant duration = 72 * 60 * 60;
  uint256 public deadline;
  
  mapping ( address => uint256 ) public balances;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + duration;
  }
  
  event Stake(address caller, uint256 amount);

  modifier notExpired() {
    require(block.timestamp < deadline, "already expired");
    _;
  }
  
  modifier expired() {
    require(block.timestamp >= deadline, "not yet expired");
    _;
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), "staking event completed");
    _;
  }

  function _stake(address caller, uint amount) internal {
    balances[caller] += amount;
    emit Stake(caller, amount);
  }

  function _withdraw(address caller) internal {
    require(address(this).balance < threshold, "more than threshold");

    uint amount = balances[caller];
    (bool sent, ) = caller.call{value: amount}("");
    require(sent, "Failed withdraw Ether");
  }


  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() external payable notExpired {
    _stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() external expired notCompleted {
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      _withdraw(msg.sender);
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() external expired notCompleted {
    _withdraw(msg.sender);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() view external returns (uint) {
    if (block.timestamp >= deadline) return 0;
    return deadline - block.timestamp;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable notExpired {
    _stake(msg.sender, msg.value);
  }

}
