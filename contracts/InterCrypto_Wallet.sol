pragma solidity ^0.4.15;

// import "github.com/ugmo04/inter-crypto/contracts/InterCrypto_Interface.sol";
import "./InterCrypto_Interface.sol";

contract InterCrypto_Wallet is usingInterCrypto {

    event Deposit();
    event WithdrawalNormal();
    event WithdrawalInterCrypto(uint transactionID);

    address owner;
    mapping (address => uint) funds;

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function InterCrypto_Wallet() {
        owner = msg.sender;
    }

    function () payable {
      if (msg.value > 0) {
          funds[msg.sender] += msg.value;
          Deposit();
      }
    }

    function intercrypto_GetInterCryptoPrice() constant public returns (uint) {
        return interCrypto.getInterCryptoPrice();
    }

    function withdrawNormal() isOwner external {
        WithdrawalNormal();
        msg.sender.transfer(this.balance);
    }

    function intercrypto_SendToOtherBlockchain(string _coinSymbol, string _toAddress) external payable {
        funds[msg.sender] = 0;
        uint transactionID = interCrypto.sendToOtherBlockchain.value(funds[msg.sender] + msg.value)(_coinSymbol, _toAddress);
        WithdrawalInterCrypto(transactionID);
    }


    function intercrypto_Recover() isOwner external {
        interCrypto.recover(); // When interCrypto.pendingWithdrawals has an amount > 0, this function call fails with too high gas
        // Issue is in this line in recover() function "msg.sender.transfer(amount);"
        // Have tried checking amount value, changing function from public to external, changing to latest version of compiler
        // Next try using send instead of transfer
    }

    function intercrypto_amountRecoverable() isOwner public constant returns (uint) {
        return interCrypto.amountRecoverable();
    }

    function kill() isOwner external {
        selfdestruct(owner);
    }
}
