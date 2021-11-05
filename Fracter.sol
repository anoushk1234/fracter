// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.3.2/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.3.2/access/Ownable.sol";

contract Market is ERC1155, Ownable {
    TokenFract[] supplies;
    uint256[] minted;
    //uint256[] rates;
    uint256 globalTokenFractID;
    //address private devaddress=0xc751A985DA804f97fa2Da87a12B0Ac7b5376fd1A;
    constructor() ERC1155("https://api.mysite.com/tokens/{id}") {
        globalTokenFractID=0;
        
    }

    function getValue() public view returns (uint256) {        
        return globalTokenFractID;        
        } 
    function getSupplies(uint256 _id) public view returns (TokenFract memory){
        return supplies[--_id];
    }
    function getTokenMinters() public view returns (address[] memory){
        return tokenMinters;
    }
    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    struct TokenFract{
        string name;
        string data;
        uint256 rate;
        address creator;
        uint256 TokenFractID;
        uint256 totalSupply;
    }
    mapping(address => TokenFract) public resultMapping;
    address[] public tokenMinters;
    
    function mintSupply(string memory _name, string memory _data,uint _rate,uint256 _totalSupply)public payable{
        resultMapping[msg.sender]=TokenFract(_name,_data,_rate,msg.sender,++globalTokenFractID,_totalSupply);
        //supplies.push(resultMapping[msg.sender]);
        supplies.push(resultMapping[msg.sender]);
        tokenMinters.push(msg.sender);
        minted.push(0);
    }

    function mint(uint256 _id, uint256 _amount)
        public
        payable
    {
        require(msg.value >= 0.001 ether,"Not enough token to mint");
        require(_id <= supplies.length,"NO supply exists");
        require(_id > 0,"NO token exists");
        
        uint256 index = _id-1;
        require(minted[index] + _amount <= supplies[index].totalSupply,"not enough supply");
        require(msg.value>= _amount*supplies[index].rate,"not enough token in ur wallet");
        
        _mint(msg.sender, _id, _amount,bytes(supplies[index].name));
        payable(owner()).transfer(0.001 ether);
        payable(supplies[index].creator).transfer(msg.value);
        minted[index] += _amount;
    }
    function withdraw() public payable onlyOwner{
        require(address(this).balance>0,"balance is 0");
        payable(owner()).transfer(address(this).balance);
    }
    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //     public
    // {
    //     _mintBatch(to, ids, amounts, data);
    // }
}
