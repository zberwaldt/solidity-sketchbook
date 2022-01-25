import { expect } from "chai";
import { ethers } from "hardhat";
import { utils } from "ethers";

import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

describe("Capped Token", function () {
  it("Should deploy and give sender tokens", async () => {
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("A Token", "ATOK", 100000);
    const [owner] = await ethers.getSigners();

    const Txn = await token.initialize();
    await Txn.wait();

    const balance = await token.balanceOf(owner.address);

    expect(balance).to.equal(1000);
  });
});

describe("Distributor", function () {
  const users = [
    { address: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", amount: 10 },
    { address: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", amount: 10 },
    { address: "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", amount: 10 },
    { address: "0x90F79bf6EB2c4f870365E785982E1f101E93b906", amount: 10 }
  ]

  const elements = users.map((x) => utils.solidityKeccak256(["address", "uint256"], [x.address, x.amount]));

  it("should claim successfully for valid proof", async () => {
    // set up merkle tree.
    const merkletree = new MerkleTree(elements, keccak256, { sort: true });

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("A Token", "ATOK", 100000);
    await token.deployed();

    const root = merkletree.getHexRoot();

    const Distributor = await ethers.getContractFactory("Distributor");
    const distributor = await Distributor.deploy(token.address, root);
    await distributor.deployed();

    const Txn = await token.mint(distributor.address, 100);
    await Txn.wait();

    const leaf = elements[0];
    const proof = merkletree.getHexProof(leaf);

    await expect(
      distributor.claim(
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        10,
        proof
      )
    ).to.emit(distributor, "Claimed").withArgs(users[0].address, users[0].amount);
  });

  it("should revert fail with an invalid proof", async () => {
    // set up merkle tree.
    const merkletree = new MerkleTree(elements, keccak256, { sort: true });

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("A Token", "ATOK", 100000);
    await token.deployed();

    const root = merkletree.getHexRoot();

    const Distributor = await ethers.getContractFactory("Distributor");
    const distributor = await Distributor.deploy(token.address, root);
    await distributor.deployed();

    const Txn = await token.mint(distributor.address, 100);
    await Txn.wait();

    const leaf = elements[1];
    const proof = merkletree.getHexProof(leaf);

    await expect(
      distributor.claim(
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        10,
        proof
      )
    ).to.revertedWith("Distributor: Invalid proof.");
  });

  it("users can claim more than once.", async () => {
    // set up merkle tree.
    const merkletree = new MerkleTree(elements, keccak256, { sort: true });

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("A Token", "ATOK", 100000);
    await token.deployed();

    const root = merkletree.getHexRoot();

    const Distributor = await ethers.getContractFactory("Distributor");
    const distributor = await Distributor.deploy(token.address, root);
    await distributor.deployed();

    const Txn = await token.mint(distributor.address, 100);
    await Txn.wait();

    const leaf = elements[0];
    const proof = merkletree.getHexProof(leaf);

    await expect(
      distributor.claim(
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        10,
        proof
      )
    ).to.emit(distributor, "Claimed").withArgs(users[0].address, users[0].amount);

    await expect(
      distributor.claim(
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        10,
        proof
      )
    ).to.revertedWith("Distributor: already claimed.");
  });
});
