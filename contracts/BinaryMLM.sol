// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
