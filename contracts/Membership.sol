//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Membership is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721("Membership", "MEM") {}

  function grantMembership(
    address grantee_, 
    string memory uri_
  ) public 
    returns (uint256) 
  {
    _tokenIds.increment(); // auto-increment;
    uint256 newTokenId = _tokenIds.current(); // get the current value;

    _mint(grantee_, newTokenId); // mint token to grantee_ address use current tokenId from counter as next id.
    _setTokenURI(newTokenId, uri_); // set uri_ to newTokenId;

    return newTokenId; // return newItemId;
  }
}