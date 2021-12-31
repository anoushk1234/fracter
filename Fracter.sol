pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "hardhat/console.sol";

contract Fanvest is ERC1155, Ownable, ERC1155Supply {
    using Counters for Counters.Counter;
    uint256 public cutNumerator = 1;
    uint256 public cutDenominator = 10000;
    uint256 public supply = 0;
    uint256 public minted = 0;
    uint256 public rate = 0;
    address public own;
    address public thisContract;
    address payable dev = payable(0xDdA99bD35363c268B41aC741D9B7e1a95BCF9BF1);
    address[] fans;
    //0xDdA99bD35363c268B41aC741D9B7e1a95BCF9BF1
    Counters.Counter private _tokenIdCounter;

    struct FilmToken {
        string title;
        string data;
    }

    bool private isMinting = false;
    mapping(address => uint256) balances;
    mapping(address => FilmToken) tokenMap;
    FilmToken[] public tokenArray;

    constructor(address _owner) ERC1155("") {
        own = _owner;
        thisContract = address(this);
    }

    modifier onlyDev() {
        require(0xDdA99bD35363c268B41aC741D9B7e1a95BCF9BF1 == dev);
        _;
    }
    modifier onlyOwn(address sender) {
        require(own == sender);
        _;
    }

    function updateCut(uint256 numerator, uint256 denominator) public onlyDev {
        cutNumerator = numerator;
        cutDenominator = denominator;
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    function mintSupply(
        string calldata _title,
        string calldata _data,
        uint256 _rate,
        uint256 _totalSupply
    ) public payable onlyOwn(msg.sender) {
        //uint256 cut = msg.value * cutNumerator / cutDenominator;
        FilmToken memory _tempdata = FilmToken(_title, _data);
        tokenArray.push(_tempdata);
        // tokenMap[msg.sender].push(_tempdata);
        supply = _totalSupply;
        rate = _rate;
        dev.transfer((cutNumerator / cutDenominator) * (10**18));
    }

    function mint(uint256 id, uint256 amount) public payable {
        require(
            amount <= (supply - minted) && amount > 0,
            "Either amt entered is 0 which isnt allowed or the total supply has been minted or your amount is too large"
        );
        require(msg.value >= rate, "There isnt enough money in your wallet");
        console.log(string(tokenArray[0].data));
        _mint(msg.sender, id, amount, bytes(tokenArray[0].data));
        setURI(tokenArray[0].data);
        minted += amount;
        balances[msg.sender] += amount;
        fans.push(msg.sender);
        payable(own).transfer(rate);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        super._safeTransferFrom(from, to, id, amount, data);
    }

    function getSupply() public view returns (uint256) {
        return supply;
    }

    function getMinted() public view returns (uint256) {
        return minted;
    }

    function getFans() public view returns (address[] memory) {
        return fans;
    }

    function getBalances() public view returns (uint256) {
        return balances[msg.sender];
    }
}

contract FanvestFactory {
    mapping(address => Fanvest) public contracts;

    function create() public {
        Fanvest fanvest = new Fanvest(msg.sender);
        contracts[msg.sender] = fanvest;
    }

    function getContract()
        public
        view
        returns (
            address own,
            address thisContract,
            uint256 balance
        )
    {
        Fanvest fanvest = contracts[msg.sender];
        return (
            fanvest.own(),
            fanvest.thisContract(),
            address(fanvest).balance
        );
    }
}
