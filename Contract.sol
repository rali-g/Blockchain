// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

interface ITarget {
    function getNum() external payable returns (uint256);
}

contract Caller {
    uint256 num = 5;

    event MoneyReceived(uint256);
    event AddressInteraction(string, address, address);
    event ResultReturned(bool, bytes);
    event CallerGasUsed(uint256);

    function transferMoney(address _addr, uint256 _amount) public {
        payable(_addr).transfer(_amount);
        emit AddressInteraction("Transfer", msg.sender, tx.origin);
    }

    function sendMoney(address payable _addr, uint256 _amount) public {
        bool success = _addr.send(_amount);
        require(success, "Batko, provali se transferut!");
        emit AddressInteraction("Send", msg.sender, tx.origin);
    }

    function callTarget(address payable _addr, uint256 _amount, uint256 _gasAmount) public {
        (bool success, bytes memory data) = _addr.call{gas: _gasAmount, value: _amount}(abi.encodeWithSignature("getNum()"));
        emit AddressInteraction("Call", msg.sender, tx.origin);
        emit ResultReturned(success, data);
    }

    function callSetNum(address _addr, uint256 _amount) public {
        (bool success, bytes memory data) = _addr.call(abi.encodeWithSignature("setNum(uint256)", _amount));
        emit AddressInteraction("Call(setNum)", msg.sender, tx.origin);
        emit ResultReturned(success, data);
    }

    function callWithRequire(address _addr, uint256 _input) public {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("checkPositive(uint256)", _input)
        );
        emit ResultReturned(success, data);
        emit AddressInteraction("Call(checkPositive)", msg.sender, tx.origin);
    }

    function callInterface(address _addr) public {
        emit CallerGasUsed(ITarget(_addr).getNum());
    }

    function callNamed(address _addr) public {
        Target target = Target(payable(_addr));
        emit CallerGasUsed(target.getNum());
    }

    function callDelegated(address _addr) public {
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("getNum()")
        );
        emit ResultReturned(success, data);
    }

    receive() external payable {
        emit MoneyReceived(msg.value);
        emit CallerGasUsed(gasleft());
    }

    fallback() external payable {
        emit MoneyReceived(msg.value);
    }

    function getNum() public view returns (uint256) {
        return num;
    }
}

contract Target {
    uint256 number = 42;

    function getNum() public view returns (uint256) {
        return number;
    }

    function setNum(uint256 _num) public {
        number = _num;
    }

    function checkPositive(uint256 _val) public pure returns (bool) {
        require(_val > 0, "Number must be positive!");
        return true;
    }

    receive() external payable {}

    fallback() external payable {}
}
