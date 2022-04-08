//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Auction {    

    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    enum State {Start, Running, Ended, Canceled}
    State public auctionState;

    uint highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;
    uint bidIncrement;

    constructor(){
        owner = payable(msg.sender);
        auctionState = State.Running;
        startBlock = block.number;
        endBlock= startBlock + 40320; // week duration
        ipfsHash = ""; // image of aution         
        bidIncrement= 100;
    }

    modifier notOwner(){
        require(msg.sender != owner, "Owner can place the bid");
        _;
    }

    modifier afterStart(){
        require(block.number >= startBlock, "Block number should be greater then start block");
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock, "Block number should be less the End block");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner");
        _;
    }
   
    function min(uint a, uint b) public pure returns(uint)
    {
        return (a<b) ? a : b ;
    }

    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd { 
        require(auctionState == State.Running, "Auction is not started yet or canceled");
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] += msg.value;
        require(currentBid > highestBindingBid , "Not highest bid");
        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement , bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid + bidIncrement , bids[highestBidder]);
            highestBidder = payable(msg.sender);
        }

    }

    function finalizeAuction() public {
        require(auctionState == State.Canceled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;
        if(auctionState == State.Canceled){
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else {
            if(msg.sender == owner){
                recipient = owner;
                value =highestBindingBid;

            }else{
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value =highestBindingBid;
                } else{
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
    bids[msg.sender] = 0;
    recipient.transfer(value);
    }

}