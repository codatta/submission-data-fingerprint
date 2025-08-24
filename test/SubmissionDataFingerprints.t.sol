// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SubmissionDataFingerprints} from "../src/SubmissionDataFingerprints.sol";

contract SubmissionDataFingerprintsTest is Test {
    SubmissionDataFingerprints public fingerprints;

    function setUp() public {
        fingerprints = new SubmissionDataFingerprints();
    }
}
