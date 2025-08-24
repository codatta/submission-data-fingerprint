// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SubmissionDataFingerprints} from "../src/SubmissionDataFingerprints.sol";

contract SubmissionDataFingerprintsScript is Script {
    SubmissionDataFingerprints public fingerprints;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        fingerprints = new SubmissionDataFingerprints();

        vm.stopBroadcast();
    }
}
