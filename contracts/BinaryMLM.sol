// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinaryMLM {
    struct User {
        address parent;
        address left;
        address right;
    }
    
    address public root;
    mapping(address => User) public users;

    function addUser(address userAddress, address refAddress) public {
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
}
