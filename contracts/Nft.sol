// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NftWhitelist is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public price = 0.001 ether;  //your Nft floor price
  uint256 public maxSupply = 25;   //Final Supply of your Contract
  uint256 public MintAmountPerPerson = 5; //per person Mint
  bool public paused = true;  //by default your contract will be paused
  bytes32 public merkleRoot= 0xec5757362df6b26ed556999af5342892293d8e5a960c1559fd86bc35421e2cfd ; //root of the merkel Tree
  mapping(address => bool) public whitelistClaimed;
  mapping(address=>bool) minted; //the person can only mint a single time with the total amount he wants to mint


  constructor(
    string memory _TokenName,   //your contract name
    string memory _TokenSymbol, //your contract symbol
    string memory _initBaseURI  //your ipfs uri
  ) ERC721(_TokenName, _TokenSymbol) {
    setBaseURI(_initBaseURI);
 
  }

     modifier OnlyNotPaused(){
      require(!paused);
      _;
    }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function whitelistMint(bytes32[] calldata _merkleProof,uint256 _mintAmount) public OnlyNotPaused {
        require(!whitelistClaimed[msg.sender], "Address already claimed");
        uint256 supply = totalSupply();
        require(_mintAmount <= MintAmountPerPerson);
        require(supply + _mintAmount <= maxSupply);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalid Merkle Proof."
        );
        whitelistClaimed[msg.sender] = true;
         for (uint256 i = 1; i <= _mintAmount; i++) {
           _safeMint(msg.sender, supply + i);
    }
    
    }

  function PublicMint(uint256 _mintAmount) public payable OnlyNotPaused {
    require(minted[msg.sender]=false && (_mintAmount > 0));
    uint256 supply = totalSupply();
    require(_mintAmount <=MintAmountPerPerson);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
      require(msg.value >= price * _mintAmount);
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
    minted[msg.sender]=true;
  }



  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }


  
  function setPrice(uint256 _newCost) public onlyOwner {
    price= _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    MintAmountPerPerson = _newmaxMintAmount;
  }
  

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);

  }
}
