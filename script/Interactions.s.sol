//SPDX-License-Identifier:MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundme is Script {
    uint256 send_value = 0.1 ether;

    function fundfundme(address mostrecentlydeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentlydeployed)).fund{value: send_value}();
        vm.stopBroadcast();
        console.log("funded fundme with %s", send_value);
    }

    function run() external {
        address mostrecentlydeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundfundme(mostrecentlydeployed);
    }
}

contract Withdrawfundme is Script {}
