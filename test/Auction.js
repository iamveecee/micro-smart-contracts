// const { expect } = require("chai");
const { expect } = require("chai");


describe("Auction simple contract", function () {

    let contract;
    let owner;
    let user_1;
    let user_2;
    let user_3;
    let user_4;

    beforeEach(async function () {
        const AuctionSimple = await ethers.getContractFactory("Auction");
        const auctionSimple = await AuctionSimple.deploy();
        contract = await auctionSimple.deployed();    
         [owner, user_1, user_2, user_3, user_4] = await ethers.getSigners();
    });
    
    it("Make bids from 4 users", async function () {    
        const bal = await owner.getBalance();
        
        await contract.connect(user_1).placeBid({value:ethers.utils.parseEther("0.1")});
        await contract.connect(user_2).placeBid({value:ethers.utils.parseEther("0.2")});
        await contract.connect(user_3).placeBid({value:ethers.utils.parseEther("0.3")});
        await contract.connect(user_4).placeBid({value:ethers.utils.parseEther("0.4")});
       
        // expect(await contract.getBid(user_1.address)).to.equal(ethers.utils.parseEther("0.1"));
        // expect(await contract.getBid(user_2.address)).to.equal(ethers.utils.parseEther("0.2"));
        // expect(await contract.getBid(user_3.address)).to.equal(ethers.utils.parseEther("0.3"));
        // expect(await contract.getBid(user_4.address)).to.equal(ethers.utils.parseEther("0.4"));
    });

});