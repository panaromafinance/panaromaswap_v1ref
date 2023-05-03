pragma solidity 0.6.6;

import "./refWallet.sol";

interface IrefWallet{
    function initialize(address _user, address _parent) external;
}

contract refWalletFactory {
 
    struct bang{
        address LockPair;
        address Referal;
    }
    mapping(address => bang) getUser;
    address private owner;

    constructor() public {
        owner = msg.sender;
        address _pair;
        bytes memory bytecode = type(refWallet).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(0)));
        assembly {
          _pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IrefWallet(_pair).initialize(msg.sender, address(0));
        getUser[msg.sender].LockPair = _pair;
        getUser[msg.sender].Referal = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function createRefAddress(address _parent) external returns(address _pair){
        require(getUser[_parent].LockPair != address(0), "Invalid Referal Address!");
        require(msg.sender != _parent, "Cyclic Referal Restricted!");
        bytes memory bytecode = type(refWallet).creationCode;
        require(getUser[msg.sender].LockPair == address(0), "Referal Pair Exist!");
        _parent = (_parent == address(0))? address(0) : _parent;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _parent));
        assembly {
          _pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IrefWallet(_pair).initialize(msg.sender, _parent);
        getUser[msg.sender].LockPair = _pair;
        getUser[msg.sender].Referal = _parent;
    }

    function getUserInfo(address user) public view returns (address _pair, address _parent) {
        _pair = getUser[user].LockPair;
        _parent = getUser[user].Referal;
    }

}
