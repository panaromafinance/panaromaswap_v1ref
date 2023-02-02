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
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function createRefAddress(address _parent) external returns(address _pair){
        // __user = new refWallet(msg.sender, _user);
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