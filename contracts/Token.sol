//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IToken is IERC20 {
  function mint(address to_, uint256 amount_) external;
}

contract Token is IToken, ERC20Capped, Ownable {

  constructor(string memory name_, string memory symbol_, uint256 cap_) ERC20(name_, symbol_) ERC20Capped(cap_) {}

  function initialize() external onlyOwner {
    _mint(msg.sender, 1000);
  }

  function mint(address to_, uint256 amount_) external override onlyOwner {
    _mint(to_, amount_);
  }
}