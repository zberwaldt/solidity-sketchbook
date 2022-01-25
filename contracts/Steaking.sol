//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Steaking {
  using SafeMath for uint256;
  // SafeERC20 adds wrapper functions that will throw failures when a token contract returns fals.
  using SafeERC20 for IERC20;

  // who controls the contract?
  address public owner;

  // immutable, but what if the token gets updated?
  IERC20 public immutable steak_token;
  IERC721 public immutable membership_token;

  // What is the threshold to buy in?
  // Based of typical ERC20 decimal.
  uint256 public constant buyInFee = 35000 * 10**18; 

  // Steaking contract is 'owner' of pre-minted membership tokens.

  // what if someone steaks more than the buy in? Double membership? extra voting power?
  mapping(address => uint256) public steak_balances;

  // is the token available? better way to do this?
  // maybe straight minting would be better? but more constly?
  mapping(uint256 => bool) public token_available;

  // need events to log when a user steaks.
  // EVENTS
  event Steaked(address indexed user, uint256 amount);

  constructor (address steak_token_, address membership_token_) {
    require(steak_token_ != address(0), "Steak token: address 0");
    steak_token = IERC20(steak_token_);
    require(membership_token_ != address(0), "Membership token: address 0");
    membership_token = IERC721(membership_token_);
  }

  // User can stake arbitrary amount of ERC20
  function steak(uint256 amount_) public {
    console.log("Steaking", amount_);
    
    // but they must stake more than none. AND have enough balance of ERC20.
    require(amount_ > 0, "Don't be a tease, give us some mooooney");
    require(steak_token.balanceOf(msg.sender) > 0, "You don't have any steak");

    // What if they've steaked enough? can see omitting this.
    require(steak_balances[msg.sender] < buyInFee, "You've already steaked enough");

    // transfer steak token to this contract.
    steak_token.safeTransferFrom(msg.sender, address(this), amount_);

    // update senders steaked balance.
    steak_balances[msg.sender] = steak_balances[msg.sender].add(amount_);

    // Steaking tracks how much is steaked.
    if (steak_balances[msg.sender] >= buyInFee) { // if user has steaked enough transfer the nft.
      
      uint256 token_id = getAvailableMembershipToken(); // get the first available token.

      token_available[token_id] = false; // mark as membership granted.
      
      // ERC721 safeTransferFrom will check if id exists. and if from (this contract) owns said nft.

      membership_token.safeTransferFrom(address(this), msg.sender, token_id); // now transfer token.
    }

    emit Steaked(msg.sender, amount_);
  }

  // marked as view, but will change after implementation.
  function unsteak(uint256 id_) external view {
    console.log("Unstaking", id_);
    // User can trade back their NFT, recieve "buy back" amount of ERC20.
    // Steaking must have enough ERC20 to trade back.
  }

  function getAvailableMembershipToken() internal view returns (uint256) {
    // get the first available token.
  }

  // TODO: create a utility function that will hold the logic for nft transfers.

}