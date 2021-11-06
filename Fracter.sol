// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
contract FractMarket is ERC1155, Ownable {
    TokenFract[] supplies;
    uint256[] minted;
    //uint256[] rates;
    uint256 globalTokenFractID;
    event StringFailure(string stringFailure);
    event BytesFailure(bytes bytesFailure);
    //address private devaddress=0xc751A985DA804f97fa2Da87a12B0Ac7b5376fd1A;
    constructor() ERC1155("https://api.mysite.com/tokens/{id}") {
        globalTokenFractID = 0;
    }
     
   
    function getValue() public view returns (uint256) {
        return globalTokenFractID;
    }

    function getSupplies(uint256 _id) public view returns (TokenFract memory) {
        return supplies[--_id];
    }

    function getTokenMinters() public view returns (address[] memory) {
        return tokenMinters;
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    struct TokenFract {
        string name;
        string data;
        uint256 rate;
        address creator;
        uint256 TokenFractID;
        uint256 totalSupply;
    }
    struct tokenBuyersData {
        address buyer;
        uint256 id;
        uint256 amount;
        uint256 price;
    }
    mapping(address => TokenFract) public resultMapping;
    address[] public tokenMinters;
    mapping(address => tokenBuyersData) public tokenBuyers;
    tokenBuyersData[] public tokenBuyersDataArray;

    function mintSupply(
        string memory _name,
        string memory _data,
        uint256 _rate,
        uint256 _totalSupply
    ) public  {
        resultMapping[msg.sender] = TokenFract(
            _name,
            _data,
            _rate,
            msg.sender,
            ++globalTokenFractID,
            _totalSupply
        );
        //supplies.push(resultMapping[msg.sender]);
        supplies.push(resultMapping[msg.sender]);
        tokenMinters.push(msg.sender);
        minted.push(0);
        console.log('msg.sender:',msg.sender);
    }

    function mint(uint256 _id, uint256 _amount) public payable {
        uint256 index = _id - 1;
        console.log(_amount,supplies[index].rate,(_amount * (supplies[index].rate*10**18)/1 ether),msg.value);
        console.log((msg.value*(10**18)),supplies[index].creator);
        require(msg.value >= 0.001 ether , "Not enough token to mint");//gave
        require(_id <= supplies.length, "NO supply exists");
        require(_id > 0, "NO token exists");

        
        require(
            minted[index] + _amount <= supplies[index].totalSupply,
            "not enough supply"
        );//gave
        
        require(
            (msg.value/1 ether) >= (_amount * (supplies[index].rate*10**18)/1 ether),
            "not enough token in ur wallet"
        );//didnt give

        _mint(msg.sender, _id, _amount, bytes("hello"));
        console.log("minted!");
        
        //payable(owner()).transfer(0.001 ether);
        bool sent = payable(supplies[index].creator).send(msg.value);
        require(sent,"txn failed");
        minted[index] += _amount;
        tokenBuyers[msg.sender] = tokenBuyersData(
            msg.sender,
            _id,
            _amount,
            msg.value
        );
        tokenBuyersDataArray.push(tokenBuyers[msg.sender]);
    }

    function withdraw() public payable onlyOwner {
        require(address(this).balance > 0, "balance is 0");
        payable(owner()).transfer(address(this).balance);
    }
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override
        onlyOwner
    {
        // for(uint256 i=0;i<ids.length;i++){
        // require(minted[ids[i]]==supplies[ids[i]].totalSupply,"sale not over");
        // }
        //require(minted[ids[0]]==supplies[ids[0]].totalSupply,"sale not over");
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
    
    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //     public
    // {
    //     _mintBatch(to, ids, amounts, data);
    // }
}
