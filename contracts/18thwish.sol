// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EighteenthWish {

    event ReceivedETH(address from, uint256 amount);
    event WithdrawETH(address to, uint256 amount);
    event WithdrawTokens(address _tokenContract, address _to, uint _amount);

    address payable public creator;
    address payable public owner;
    uint public unlockDate;
    uint public createdAt;

    struct IPFSDetails{
        bytes32 HashP1;
        bytes32 HashP2;
    }

    IPFSDetails ipfsDetails;

    modifier onlyAuthorized {
        require(msg.sender == owner || msg.sender == creator);
        _;
    }


    constructor (address _creator, address _owner, uint _unlockDate, uint _createdAt, bytes32 _ipfsHashP1, bytes32 _ipfsHashP2){
        creator = payable(_creator);
        owner = payable(_owner);
        unlockDate = _unlockDate;
        createdAt = _createdAt;
        ipfsDetails.HashP1 = _ipfsHashP1;
        ipfsDetails.HashP2 = _ipfsHashP2;
    }

    function updateIPFSDetails(bytes32 _ipfsHashP1, bytes32 _ipfsHashP2) external onlyAuthorized{
        ipfsDetails.HashP1 = _ipfsHashP1;
        ipfsDetails.HashP2 = _ipfsHashP2;
    }

    receive () external payable { 
        emit ReceivedETH(msg.sender, msg.value);
    }

    function getInfo() external view returns(address, address, uint, uint, uint, IPFSDetails memory) {
        return (creator, owner, unlockDate, createdAt, address(this).balance, ipfsDetails);
    }

    function withdrawETHAll() onlyAuthorized external {

        withdrawETH(address(this).balance);
    }

    function withdrawETH(uint _amount) onlyAuthorized public {

        require(block.timestamp >= unlockDate, "Sorry, you cannot withdraw before your 18th birthday");

        require(_amount <= address(this).balance, "Sorry, you don't have enough eth balance");

        payable(msg.sender).transfer(_amount);

        emit WithdrawETH(msg.sender, _amount);
    }

    function withdrawTokensAll(address _tokenContract) onlyAuthorized external {

        IERC20 token = IERC20(_tokenContract);

        uint tokenBalance = token.balanceOf(address(this));

        withdrawTokens(_tokenContract, tokenBalance);

    }

    function withdrawTokens(address _tokenContract, uint _amount) onlyAuthorized public {

        require(block.timestamp >= unlockDate, "Sorry, you cannot withdraw before your 18th birthday");

        IERC20 token = IERC20(_tokenContract);

        require(_amount <= token.balanceOf(address(this)), "Sorry, you don't have enough token balance");

        token.transfer(msg.sender, _amount);
        emit WithdrawTokens(_tokenContract, msg.sender, _amount);
    }

}