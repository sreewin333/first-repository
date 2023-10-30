//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {Helperconfig} from "./Helperconfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        Helperconfig helperconfig = new Helperconfig();
        address ethusdpricefeed = helperconfig.activenetworkconfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethusdpricefeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
