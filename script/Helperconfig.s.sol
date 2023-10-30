//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract Helperconfig is Script {
    Networkconfig public activenetworkconfig;
    uint8 public constant _decimals = 8;
    int256 public constant _initialanswer = 2000e8;
    struct Networkconfig {
        address PriceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activenetworkconfig = getsepoliaethconfig();
        } else if (block.chainid == 1) {
            activenetworkconfig = getetheriumethconfig();
        } else {
            activenetworkconfig = getanvilethconfig();
        }
    }

    function getsepoliaethconfig() public pure returns (Networkconfig memory) {
        Networkconfig memory sepoliaconfig = Networkconfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return sepoliaconfig;
    }

    function getetheriumethconfig() public pure returns (Networkconfig memory) {
        Networkconfig memory etheriumnetworkconfig = Networkconfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        return etheriumnetworkconfig;
    }

    function getanvilethconfig() public returns (Networkconfig memory) {
        if (activenetworkconfig.PriceFeed != address(0)) {
            return activenetworkconfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPricefeed = new MockV3Aggregator(
            _decimals,
            _initialanswer
        );
        vm.stopBroadcast();
        Networkconfig memory anvilnetworkconfig = Networkconfig(
            address(mockPricefeed)
        );

        return anvilnetworkconfig;
    }
}
