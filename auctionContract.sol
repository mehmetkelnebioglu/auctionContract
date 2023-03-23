// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract auction {
    address payable public beneficiary;
    uint public aucionEndTime;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public pendingReturs;
    bool anded;

    event highestBidIncreased(address bidder, uint amount);
    event auctionAnded(address winner, uint amount);

    constructor(address payable _beneficary, uint _auctionEndTime) {
        (beneficiary, aucionEndTime) = (
            _beneficary,
            block.timestamp + _auctionEndTime
        );
    }

    function bid() public payable {
        if (block.timestamp > aucionEndTime) {
            revert("auction is aldready done");
        }

        if (msg.value <= highestBid) {
            revert("there is aldreay a highest or equal bid");
        }

        if (highestBid != 0) {
            pendingReturs[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit highestBidIncreased(msg.sender, msg.value);
    }

    function getReminingTime() public view returns (uint) {
        return aucionEndTime - block.timestamp;
    }

    function endAuction() public {
        if (aucionEndTime > block.timestamp) {
            revert("auction not anded");
        }
        if (anded) {
            revert("auction aldready ended");
        }
        anded = true;

        beneficiary.transfer(highestBid);

        emit auctionAnded(highestBidder, highestBid);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturs[msg.sender];

        if (amount > 0) {
            pendingReturs[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturs[msg.sender] = amount;
                return false;
            }
        }

        return false;
    }
}
