// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BinaryMLM is Ownable {
    struct User {
        address parent;
        address left;
        address right;
    }
    
    address public root;
    mapping(address => User) public users;
    mapping(address => bool) public allowedAddresses;

    modifier onlyAllowed() {
        require(allowedAddresses[msg.sender], "Caller is not allowed");
        _;
    }

    function allowAddress(address _address) public onlyOwner {
        allowedAddresses[_address] = true;
    }

    function disallowAddress(address _address) public onlyOwner {
        allowedAddresses[_address] = false;
    }

    function addUser(address userAddress, address refAddress) public onlyAllowed {
        require(users[userAddress].parent == address(0), "User already added");
        
        if(root == address(0)) {
            root = userAddress;
        } else {
            require(users[refAddress].parent != address(0) || refAddress == root, "Referrer not found");
            address nextNode = findNextNode(refAddress);
            if(users[nextNode].left == address(0)) {
                users[nextNode].left = userAddress;
            } else {
                users[nextNode].right = userAddress;
            }
            users[userAddress].parent = nextNode;
        }
    }

    function findNextNode(address startNode) private view returns(address) {
        require(users[startNode].parent != address(0) || startNode == root, "Start node not found");
        address[] memory nodes = new address[](1024); // Assuming we won't go deeper than 1024 nodes
        nodes[0] = startNode;
        uint256 front = 0;
        uint256 rear = 1;
        
        while(front < rear) {
            if(users[nodes[front]].left == address(0) || users[nodes[front]].right == address(0)) {
                return nodes[front];
            }

            nodes[rear] = users[nodes[front]].left;
            rear++;
            nodes[rear] = users[nodes[front]].right;
            rear++;
            front++;
        }

        revert("No eligible parent found under referrer");
    }

    function getParents(address userAddress, uint256 upToLevels) public view returns (address[] memory) {
        require(users[userAddress].parent != address(0) || userAddress == root, "User not found");
        address[] memory parents = new address[](upToLevels);
        address currentUser = userAddress;
        for(uint256 i = 0; i < upToLevels; i++) {
            if(currentUser == address(0)) {
                break;
            }
            parents[i] = users[currentUser].parent;
            currentUser = users[currentUser].parent;
        }
        return parents;
    }

    function getTree(address userAddress) public view returns (address[] memory) {
    User memory user = users[userAddress];
    address[] memory tree = new address[](1);
    tree[0] = userAddress;
    if (user.left != address(0)) {
        address[] memory leftTree = getTree(user.left);
        tree = mergeArrays(tree, leftTree);
    }
    if (user.right != address(0)) {
        address[] memory rightTree = getTree(user.right);
        tree = mergeArrays(tree, rightTree);
    }
    return tree;
}

function mergeArrays(address[] memory a, address[] memory b) public pure returns (address[] memory) {
    address[] memory merged = new address[](a.length + b.length);
    for (uint i = 0; i < a.length; i++) {
        merged[i] = a[i];
    }
    for (uint i = 0; i < b.length; i++) {
        merged[i + a.length] = b[i];
    }
    return merged;
}

}
