pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  // ToDo: create a payable buyTokens() function:
  function buyTokens() external payable {
    uint amountOfTokens = msg.value * tokensPerEth;
    require(amountOfTokens > 0, "not enough to buy any tokens");
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external payable onlyOwner {
    (bool succces, ) = msg.sender.call{value: address(this).balance}("");
    require(succces, "Failed to withdraw Ether");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amount) external payable {
    bool succcesTransferToken = yourToken.transferFrom(msg.sender, address(this), amount);
    require(succcesTransferToken, "Failed to sell back token");
    uint amountOfEth = amount / tokensPerEth;
    (bool succcesTransferEth, ) = msg.sender.call{value: amountOfEth}("");
    require(succcesTransferEth, "Failed to transfer Ether");
    emit SellTokens(msg.sender, amount, amountOfEth);
  }
}
