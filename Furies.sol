// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import-erc1155
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
//import-Ownable
import "@openzeppelin/contracts/access/Ownable.sol";
//import-Counter
import "@openzeppelin/contracts/utils/Counters.sol";
//just like how we have ERC721URIStorage for ERC721 we have IERC1155MetadataURI for ERC1155
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

//"is" is used to inherit
contract OmegaNovaFurries is ERC1155,Ownable, ERC1155URIStorage{
    //name
    string public name;
    //symbol
    string public symbol;
    //cost_per_NFT
    uint256[] public costPerNft;
    //minted
    uint256[] public minted;
    //supply
    uint256[] public supply;
    //who minted
    mapping(uint256=>string) public tokenIdsUri;
    //initialising Counters
    using Counters for Counters.Counter;
    Counters.Counter private _Counter;

    //events
    event NewFurry(string URI, uint256 indexed tokenId);
    event MintedFury(address indexed, uint256 tokenId);
    event withdrawnSuccess(bool success,address adr);



    constructor(uint256 _supply, string memory _uri,uint256 _price) ERC1155("") {
        name="Omega Nova Furries";
        symbol="ONF";
        addNewFurry(_uri,_price,_supply);
    }


    //add a new ERC1155 so others can mint
    function addNewFurry(string memory URI,uint256 costOfNft,uint256 Maxsupply) public onlyOwner{
        //add URI and assicated tokenId-URItokenIdsUri
        uint256 tokenId = _Counter.current();
        tokenIdsUri[tokenId]=URI;
        //events
        emit NewFurry(URI, tokenId);
        //append costPerNft
        costPerNft.push(costOfNft);//should be in Wei
        //append minted
        minted.push(0);
        //set supply
        supply.push(Maxsupply);
        _Counter.increment();

    }

    //minting means creating an NFT from something already owned by the contract.
    function mint(uint256 id) public payable{
        //check if id is present (+1 as token starts with 0)
        require(id<supply.length, "Token Id does not exist");
        //check if you have enough funds
        require(supply[id]>minted[id], "Supply limit reached");
        //you dont have to worry about money as they send the money when calling the function, you just have to check if it matches
        require(msg.value>=costPerNft[id], "insufficient funds");
        //update minted
        minted[id]+=1;
        //mint -> in the backend calls the uri(id) method and retireves the IPFS's CID
        _mint(msg.sender, id, 1, "");
       emit MintedFury(msg.sender,id);


    }

    //withdraw the funds in the contract
    function withdraw() public onlyOwner{
        require(address(this).balance>0,"you have no balance in this contract");
        (bool success,)=msg.sender.call{value:address(this).balance}("");
        require(success,"Transfer failed");
       emit withdrawnSuccess(success,msg.sender);

    }

    //! THIS IS VERY IMPORTNAT
    //how does the mint function know what tokenId is for what uri
    //for that we need to override a function
    //!!! uri function that is provided in the ERC1155 contract that we inherited from Openzeppelin.
     function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return tokenIdsUri[tokenId];
    }

}