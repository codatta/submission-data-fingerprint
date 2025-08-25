// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SubmissionDataFingerprints} from "../src/SubmissionDataFingerprints.sol";

contract SubmissionDataFingerprintsScript is Script {
    SubmissionDataFingerprints public fingerprints;

    function setUp() public {}

    function run() public {
        uint256 owner = vm.envUint("PRIVATE_KEY");
        address ownerAddress = vm.addr(owner);
        address submitterAddress = vm.envAddress("SUBMITTER");
        vm.startBroadcast(owner);

        fingerprints = new SubmissionDataFingerprints(ownerAddress, submitterAddress);

        vm.stopBroadcast();

        string memory root = vm.projectRoot();
        string memory deployPath = string.concat(
            root,
            "/script/deployment.json"
        );
        if (vm.exists(deployPath)) {
            vm.removeFile(deployPath);
        }
        vm.writeFile(
            deployPath,
            vm.serializeAddress("", "fingerprints", address(fingerprints))
        );
    }
}
