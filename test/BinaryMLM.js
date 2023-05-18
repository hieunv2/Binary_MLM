const { expect } = require("chai");
const { ethers } = require("hardhat");
const archy = require("archy");

describe("BinaryMLM", function () {
  it("Should create users and correctly form the binary tree", async function () {
    const BinaryMLM = await ethers.getContractFactory("BinaryMLM");
    const binaryMLM = await BinaryMLM.deploy();
    await binaryMLM.deployed();

    async function constructTree(address) {
      let user = await binaryMLM.users(address);

      let node = { label: address, nodes: [] };

      if (user.left != ethers.constants.AddressZero) {
        node.nodes.push(await constructTree(user.left));
      }
      if (user.right != ethers.constants.AddressZero) {
        node.nodes.push(await constructTree(user.right));
      }

      return node;
    }

    const accounts = await ethers.getSigners();

    for (let i = 1; i < 15; i++) {
      console.log(i, accounts[i].address);
    }

    // Add first user (root)
    await binaryMLM.addUser(accounts[1].address, ethers.constants.AddressZero);
    expect(await binaryMLM.root()).to.equal(accounts[1].address);

    // Add second user under root
    await binaryMLM.addUser(accounts[2].address, accounts[1].address);
    let rootUser = await binaryMLM.users(accounts[1].address);
    expect(rootUser.left).to.equal(accounts[2].address);

    // Add third user under root
    await binaryMLM.addUser(accounts[3].address, accounts[1].address);
    rootUser = await binaryMLM.users(accounts[1].address);
    expect(rootUser.right).to.equal(accounts[3].address);

    // Add fourth user under second user
    await binaryMLM.addUser(accounts[4].address, accounts[2].address);
    let secondUser = await binaryMLM.users(accounts[2].address);
    expect(secondUser.left).to.equal(accounts[4].address);

    // Add five user under second user
    await binaryMLM.addUser(accounts[5].address, accounts[3].address);
    let threeUser = await binaryMLM.users(accounts[3].address);
    expect(threeUser.left).to.equal(accounts[5].address);

    // Add six user under second user
    await binaryMLM.addUser(accounts[6].address, accounts[3].address);
    threeUser = await binaryMLM.users(accounts[3].address);
    expect(threeUser.right).to.equal(accounts[6].address);

    // Add seven user under second user
    await binaryMLM.addUser(accounts[7].address, accounts[1].address);
    secondUser = await binaryMLM.users(accounts[2].address);
    expect(secondUser.right).to.equal(accounts[7].address);

    // Add eight user under second user
    await binaryMLM.addUser(accounts[8].address, accounts[6].address);
    sixUser = await binaryMLM.users(accounts[6].address);
    expect(sixUser.left).to.equal(accounts[8].address);

    // Add nine user under second user
    await binaryMLM.addUser(accounts[9].address, accounts[8].address);
    eightUser = await binaryMLM.users(accounts[8].address);
    expect(eightUser.left).to.equal(accounts[9].address);

    // Add ten user under second user
    await binaryMLM.addUser(accounts[10].address, accounts[8].address);
    eightUser = await binaryMLM.users(accounts[8].address);
    expect(eightUser.right).to.equal(accounts[10].address);

    // Add eleven user under second user
    await binaryMLM.addUser(accounts[11].address, accounts[7].address);
    sevenUser = await binaryMLM.users(accounts[7].address);
    expect(sevenUser.left).to.equal(accounts[11].address);

    await binaryMLM.addUser(accounts[12].address, accounts[1].address);
    fourUser = await binaryMLM.users(accounts[4].address);
    expect(fourUser.left).to.equal(accounts[12].address);

    await binaryMLM.addUser(accounts[13].address, accounts[1].address);
    fourUser = await binaryMLM.users(accounts[4].address);
    expect(fourUser.right).to.equal(accounts[13].address);

    await binaryMLM.addUser(accounts[14].address, accounts[1].address);
    sevenUser = await binaryMLM.users(accounts[7].address);
    expect(sevenUser.right).to.equal(accounts[14].address);

    await binaryMLM.addUser(accounts[15].address, accounts[1].address);
    fiveUser = await binaryMLM.users(accounts[5].address);
    expect(fiveUser.left).to.equal(accounts[15].address);

    await binaryMLM.addUser(accounts[16].address, accounts[1].address);
    fiveUser = await binaryMLM.users(accounts[5].address);
    expect(fiveUser.right).to.equal(accounts[16].address);

    await binaryMLM.addUser(accounts[17].address, accounts[1].address);
    sixUser = await binaryMLM.users(accounts[6].address);
    expect(sixUser.right).to.equal(accounts[17].address);

    await binaryMLM.addUser(accounts[18].address, accounts[1].address);
    user12 = await binaryMLM.users(accounts[12].address);
    expect(user12.left).to.equal(accounts[18].address);

    // Get parents
    const parentsOfFourthUser = await binaryMLM.getParents(
      accounts[5].address,
      4
    );
    console.log(parentsOfFourthUser);
    expect(parentsOfFourthUser[0]).to.equal(accounts[3].address);
    expect(parentsOfFourthUser[1]).to.equal(accounts[1].address);

    // Construct the tree object
    let tree = await constructTree(accounts[1].address);

    // Print the tree
    console.log(archy(tree));
  });
});
