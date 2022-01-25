//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Distributor {
  address public immutable token;
  bytes32 public immutable merkleRoot;

  mapping(address => bool) private claimed;

  event Claimed(address account, uint256 amount);

  constructor(address token_, bytes32 merkleRoot_) {
    token = token_;
    merkleRoot = merkleRoot_;
  }

  function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
    require(!claimed[account], "Distributor: already claimed.");

    // Verify the merkle proof.
    bytes32 node = keccak256(abi.encodePacked(account, amount));
    require(MerkleProof.verify(merkleProof, merkleRoot, node), "Distributor: Invalid proof.");

    claimed[account] = true;
    // Mark it claimed and send the token.
    require(IERC20(token).transfer(account, amount), "Distributor: Transfer failed.");

    emit Claimed(account, amount);
  }
}