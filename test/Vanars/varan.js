const { expect } = require("chai");

describe("Vanars NFT contract", function () {

    let nftContract;
    let owner;
    let user_1;
    let user_2;
    let user_3;
    let user_4;
    let user_5;
    let user_6;
    let user_7;

    it('Should deploy contract', async function () {
        const VanarsContractFile = await ethers.getContractFactory("Vanar");
        const vanarsContract = await VanarsContractFile.deploy();
        nftContract = await vanarsContract.deployed();    
        [owner, user_1, user_2, user_3, user_4, user_5, user_6,  user_7] = await ethers.getSigners();
        // TODO: get name ans token symbol

    });
    
    it('New contract instance should have no minted tokens', async function () {
        const totalSupply = (await nftContract.totalSupply()).toString()
        expect(totalSupply).to.equal('0')
    });

    it("Update BASE-URI", async function () { 
        newURI = 'https://gateway.pinata.cloud/ipfs/QmXTtsnoT7ZswvzYtfYxtMN3JweuhCcuMzN6iDuzLd28Vq/'; 
        await nftContract.setMetaDataBaseURI(newURI);
    });

    it("Should add 4 whitelist users and remove 1 user ", async function () {
         await nftContract.addWhitelist(user_1.address);
         await nftContract.addWhitelist(user_2.address);
         await nftContract.addWhitelist(user_3.address);
         await nftContract.addWhitelist(user_4.address);
         await nftContract.removeWhitelist(user_4.address);
         
         const countWhiteListUsers = (await nftContract.getWhitelistUserCount()).toString();
         console.log(countWhiteListUsers);
         expect(countWhiteListUsers).to.equal('3')
    }); 

    it("Should mint for whitelist user user_1 in pre-start state", async function () { 
        await nftContract.connect(user_1).mint(1, {value:ethers.utils.parseEther("0.1")});
        
        expect( await nftContract.balanceOf(user_1.address)).to.equal(1);
    });

    it("Should revert disabled whitelist user user_4 in pre-start state", async function () {
        await expect( nftContract.connect(user_4).mint(1, {value:ethers.utils.parseEther("0.1")}) ).to.be.revertedWith('Only for whitelist');
    });

    
    it("Should revert mint from regular user user_5 in pre-start state", async function () { 
        await expect( nftContract.connect(user_5).mint(1, {value:ethers.utils.parseEther("0.1")}) ).to.be.revertedWith('Only for whitelist');

    });

    it("Should Pause contract ", async function () {  
        await nftContract.pause();
        expect( await nftContract.getState()).to.equal('Pause');
    });

    it("Should revert mint in pause state for both whitelist and normal", async function () { 
        await expect( nftContract.connect(user_1).mint(1, {value:ethers.utils.parseEther("0.1")}) ).to.be.revertedWith('Paused contract');
        await expect( nftContract.connect(user_5).mint(1, {value:ethers.utils.parseEther("0.1")}) ).to.be.revertedWith('Paused contract');
    });
    

    it("Should  start contract and giveaway tokens to users", async function () {
        await nftContract.start();
        await nftContract.mintForAddress(user_6.address, 2);
        expect(await nftContract.balanceOf(user_6.address)).to.equal(2);
     });
       
     it("Transfer token from user_6 to user_4", async function () { 
        
        const ownedToken = await nftContract.getListOfTokenOwned(user_6.address);
        //console.log(ownedToken);
        // Approve operator        
        await nftContract.connect(user_6).approve(user_4.address, 2);
        //Transfer tokens
        await nftContract.connect(user_4)["safeTransferFrom(address,address,uint256)"](user_6.address, user_4.address, 2);
            
        expect(await nftContract.balanceOf(user_4.address)).to.equal(1);
    });    
    
    it("Get token URI ", async function () { 
        const tk = await nftContract.tokenURI(2);
        console.log(tk);
      });
    
    //it("Get the total minted and list token for user_3 and user_1", async function () {  / test content */  });
    // it("Get the total minted token for user_3 and user_1", async function () {  / test content */  });    
    // it("withdraw balance from contract", async function () {  / test content */  });
      

});