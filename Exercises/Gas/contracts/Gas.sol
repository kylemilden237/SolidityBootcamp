// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;


contract GasContract {

    uint256 public totalSupply = 0; // cannot be updated
    uint256 paymentCounter;
    
    address owner;
    address[5] public administrators;

    mapping(address => uint256) public whitelist;
    mapping(address => uint256) balances;
    mapping(address => Payment[]) payments;
    
    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend
    }

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
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
        require(whitelist[msg.sender] < 4, "User's tier must be less than 4");
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
        require(balances[msg.sender] >= _amount, "Sender has insufficient balance");
        require(bytes(_name).length < 9, "Max length of 8 characters for recipient name");
        
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;

        payments[msg.sender].push(Payment(PaymentType.BasicPayment, ++paymentCounter, false, _name, _recipient, address(0), _amount));

        emit Transfer(_recipient, _amount);
    }

    function updatePayment(address _user, uint256 _ID, uint256 _amount, PaymentType _type) external onlyOwner onlyAdmin {
        require(_ID > 0, "ID must be greater than 0");
        require(_amount > 0, "Amount must be greater than 0");

        for (uint256 i = 0; i < payments[_user].length; i++) {
            if (payments[_user][i].paymentID == _ID) {
                payments[_user][i] = Payment(_type, paymentCounter, true, payments[_user][i].recipientName, payments[_user][i].recipient, _user, _amount);
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint8 _tier) external onlyOwner onlyAdmin {
        require(_tier > 0 && _tier < 4, "Tier level must be 1, 2, or 3");

        whitelist[_userAddrs] = _tier;
        if (_tier != 3) {
            whitelist[_userAddrs] = _tier;
        } 
    }

    function whiteTransfer(address _recipient, uint256 _amount, ImportantStruct calldata _struct) external isWhiteListed {
        require(_amount > 3, "Amount must be greater than 3");
        require(balances[msg.sender] >= _amount, "Sender has insufficient balance");
        
        balances[msg.sender] += whitelist[msg.sender];
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[_recipient] -= whitelist[msg.sender];
    }
}
