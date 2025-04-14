//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interations.s.sol";

contract DeployRaffle is Script {
    function run() public {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptId == 0) {
            //create a subscript
            CreateSubscription createSubscription = new CreateSubscription();
            (uint256 subscriptId, address vrfCoordinator) = createSubscription
                .createSubscription(config.vrfCoordinator, config.account);
            config.subscriptId = subscriptId;
            config.vrfCoordinator = vrfCoordinator;
        }
        //fund it

        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            config.vrfCoordinator,
            config.subscriptId,
            config.link,
            config.account
        );
        vm.startBroadcast(config.account);

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptId,
            config.callbackGasLimit
        );

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptId,
            config.account
        );

        return (raffle, helperConfig);
    }
}
