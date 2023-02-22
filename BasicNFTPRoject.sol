// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BasicProjectNFT is ERC721, ERC721Enumerable, Pausable, Ownable {
    /* This are the functions that we going to use on the contracts */
    /* A mapping that we are going to use on the put people on the white list */
    mapping (address => bool) userAddr;
    /* 
        this both variables are been used to declare 
        if the public mint is open or if the white list 
        is open and the people that are indeer can buy 
    */
    bool private whiteList = false;
    bool private publicmint = false;
    
    /* 
        These are nft functions that openzeppelin 
        provide to us to made easier the nft creation 
    */
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("BasicProjectNFT", "BPN") {}

    function _baseURI() internal pure override returns (string memory) {
        /* 
            these is the ipfs that we provide that tells 
            to the contract these are the images that I wanna use 
        */
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    // with this functions we put on stop everything in case that we found an error 
    function pause() public onlyOwner {
        _pause();
    }
    // with this function we unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }
    
    /*
        With this function we open or close 
        the public mint and the white list
    */
    function StateOpen(bool _whiteList, bool _publicMint) external onlyOwner {
        whiteList = _whiteList;
        publicmint = _publicMint;
    }

    /*
        with this function we open the white list 
        and the people that are allowed will could buy
    */
    function whiteListMint() payable public {
        require(whiteList, "The allow list isn't open");
        require(userAddr[msg.sender] == true, "You're not on white list");
        require(msg.value == 0.001 ether, "you need to pay 0.001 ether to buy an nft");
        interMint();
    }

    /*
        When the public mint is open everybody can buy
    */
    function publicMint() public payable{
        require(msg.value == 0.01 ether, "You need to pay 0.01 ether");
        require(totalSupply() < 200, "Sold out all NFTS");
        require(publicmint, "The public mint isn't open");
        interMint();
    }   
    
    /*
        I made this function to make the gas fees cheapers
    */
    function interMint() internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    /*
        With this function we put people in the white list
    */
    function whitelistAddress (address[] calldata users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            userAddr[users[i]] = true;
        }
    }

    /*
        With this function we withdraw 
        the money that we earn selling the nfts
    */
    function withdraw() public onlyOwner returns(bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }

    /*
        with this function we transfer 
        the ownership of the contract to another person this mean 
        that the owner will be another person
    */
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /* 
        These are nft functions that openzeppelin 
        provide to us to made easier the nft creation 
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}