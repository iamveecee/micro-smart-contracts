//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Vanar is ERC721, Ownable, ERC20Burnable {

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private supply;

    enum State  { PreStart, Start, Pause}
    State currentState;

    string metaDataBaseURI;
    
    uint public tokenPrice = 0.01 ether;
    uint public maxSupply = 1000;
    uint public maxQuantityPerTx = 2;
    uint public nftPerAddressLimit = 2;
    uint countwhitelistUsers;

    
    mapping(address => bool) whitelistUsers;    
    mapping(address => uint[]) receviersBalance;
    
    

    //TOOD 
    // Add roaylties     
    // Burnable tokens
    // Write TEST CASES
    
    constructor() ERC721("VANARS", "VARAS") {
        setMetaDataBaseURI("https://uri-schema.com/data.json");
        currentState = State.PreStart;
    }

    modifier mintObedience(uint tokenQuantity){
        // Check Valid token quantity;
        require(tokenQuantity > 0 && tokenQuantity <= maxQuantityPerTx, "Invalid mint quantity");
        //Check max supply 
        require(supply.current() + tokenQuantity <= maxSupply, "Max supply exceeded!");
        // Per address limit
        require(addressLimit(msg.sender) +  tokenQuantity <= nftPerAddressLimit, "Maximun token purchase limit");
        _;
    }

     modifier whenNotPaused() {
        require(currentState != State.Pause, "Pausable: paused");
        _;
    }
    
    function totalSupply() public view returns(uint) {
        return supply.current();
    }

    // Actual mint
    function mint(uint tokenQuantity) public payable mintObedience(tokenQuantity) {
        require(currentState != State.Pause, "Paused contract");
        require(msg.value >= tokenPrice * tokenQuantity, "Insufficient funds!");
        
        if(currentState == State.PreStart) {
            require(isWhiteListUser(msg.sender),"Only for whitelist");
        } 

        _startMint(msg.sender, tokenQuantity);
    }


   // Giveaway tokens
    function mintForAddress(address receiver, uint tokenQuantity) public mintObedience(tokenQuantity) onlyOwner {
        require(currentState != State.Pause, "Paused contract");
        _startMint(receiver, tokenQuantity);
    }

    
    // Whitelist user region
    function isWhiteListUser(address user) public view returns(bool) {
        return whitelistUsers[user];
    }

    function addWhitelist(address user) public onlyOwner {
        whitelistUsers[user] = true;
        countwhitelistUsers++;
    }

    function removeWhitelist(address user) public onlyOwner {
        whitelistUsers[user] = false;
        countwhitelistUsers--;
    }

    function getWhitelistUserCount() public view onlyOwner returns(uint) {
        return countwhitelistUsers ;
    }

    // endregion

    /// List user's tokens
    function getListOfTokenOwned(address _tokenOwner) public view returns(uint[] memory ) {
        return receviersBalance[_tokenOwner];
    }

    /// set price
    function setTokenPrice(uint _tokenPrice) public onlyOwner {
        tokenPrice = _tokenPrice;
    }

    /// set URI
    function setMetaDataBaseURI(string memory _URIString) public onlyOwner {
        metaDataBaseURI = _URIString;
    }

    /// set State
    function SetState(State contractState) public onlyOwner{
        currentState = contractState;
    }

    function getState() public view onlyOwner returns(string memory){
        string memory stateDef;
        if(currentState == State.PreStart){ stateDef = "Pre Start";}
        else if(currentState == State.Start){ stateDef = "Start";}
        else if(currentState == State.Pause){ stateDef = "Pause";}

        return stateDef;

    }

    // Get address's token holding limit
    function addressLimit(address _tokenOwner) public view returns(uint) {
        uint[] memory rlimit = receviersBalance[_tokenOwner];
        return rlimit.length;
    }

    // Pause contract
    function pause() public onlyOwner{
        currentState = State.Pause;
    }

    // Start contract
    function start() public onlyOwner{
        currentState = State.Start;
    }

    // Withdraw balance
    function withdraw() public onlyOwner {

        (bool osw, )= payable(owner()).call{value: address(this).balance}("");
        require(osw);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return metaDataBaseURI;
    }

    // private start mint
    function _startMint(address receiver, uint256 quantity) internal {
        for(uint256 i = 0; i < quantity; i++){            
            supply.increment();
            receviersBalance[receiver].push(supply.current());            
            _safeMint(receiver, supply.current());
        }
    }

    function tokenURI(uint256 _tokenId) public view virtual override  returns (string memory) {
    
        require( _exists(_tokenId), "ERC721Metadata: URI query for nonexistent token" );
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), ".json"))
            : "";
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

}