pragma solidity 0.6.6;

import "./interface/IERC20.sol";

contract Receiver {
    event ValueReceived(address user, uint amount);
    receive() external payable {
        emit ValueReceived(msg.sender, msg.value);
    }
}

contract refWallet is Receiver {

    address public creator;
    address public owner;
    uint256 public createdAt;
    struct parent {
        address referer;
    }
    mapping(address => parent) public users;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        creator = msg.sender;
        createdAt = now;
    }

    function initialize(address _user, address _parent) external {
        require(msg.sender == creator);
        owner = _user;
        users[_user].referer = _parent;
    }

    // callable by owner only, after specified time
    function withdraw() onlyOwner public {
       msg.sender.transfer(address(this).balance);  
    }

    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawTokens(address _tokenContract) onlyOwner public {
        IERC20(_tokenContract).transfer(owner, IERC20(_tokenContract).balanceOf(address(this)));      
    }

    function getBalance(address _tokenContract) public view returns(uint256 ){
        return IERC20(_tokenContract).balanceOf(address(this));
    }

    function checkReferral() public view returns(address referer){
        return (users[msg.sender].referer);
    }

}