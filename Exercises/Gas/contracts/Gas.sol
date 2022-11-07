// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;


contract GasContract {

    uint256 public totalSupply = 0; // cannot be updated
    
    address owner;
    address[5] public administrators;

    mapping(address => uint256) public whitelist;
    mapping(address => uint256) balances;
    mapping(address => Payment[]) payments;

    struct Payment {
        uint8 paymentType;
        uint256 amount;
    }
    
    struct ImportantStruct {
        uint16 valueA; // max 3 digits
        uint256 bigValue;
        uint16 valueB; // max 3 digits
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == msg.sender) {
                _;
            }
        }
    }

    modifier isWhiteListed() {
        require(whitelist[msg.sender] > 0, "User is not whitelisted");
        _;
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;
        administrators = _admins;
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        return balances[_user];
    }

    function getTradingMode() public pure returns (bool mode_) {
        return true;
    }

    function getPayments(address _user) external view returns (Payment[] memory payments_) {
        return payments[_user];
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) external {        
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;

        payments[msg.sender].push(Payment(1, _amount));

        emit Transfer(_recipient, _amount);
    }

    function updatePayment(address _user, uint256 _ID, uint256 _amount, uint8 _type) external onlyOwner {
        payments[_user][0] = Payment(_type, _amount);
    }

    function addToWhitelist(address _userAddrs, uint8 _tier) external onlyAdmin {
        whitelist[_userAddrs] = _tier;
    }

    function whiteTransfer(address _recipient, uint256 _amount, ImportantStruct calldata _struct) external isWhiteListed {
        balances[msg.sender] += whitelist[msg.sender];
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[_recipient] -= whitelist[msg.sender];
    }
}
