// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SubmissionDataFingerprints} from "../src/SubmissionDataFingerprints.sol";

contract SubmissionDataFingerprintsTest is Test {
    SubmissionDataFingerprints public fingerprints;

    address internal owner;
    address internal submitter;

    uint256 internal ownerKey;
    uint256 internal submitterKey;

    function setUp() public {
        (owner, ownerKey) = makeAddrAndKey("owner");
        (submitter, submitterKey) = makeAddrAndKey("submitter");

        fingerprints = new SubmissionDataFingerprints(owner, submitter);
    }

    function test_submit_with_notSubmitter() public {
        (address hacker, ) = makeAddrAndKey("hacker");
        SubmissionDataFingerprints.Record memory record = SubmissionDataFingerprints.Record(0, bytes32(0));
        vm.prank(hacker);
        vm.expectRevert(abi.encodeWithSelector(SubmissionDataFingerprints.NotSubmitter.selector, hacker));
        fingerprints.submit(hacker, record);
    }

    function test_submit_with_submitter() public {
        SubmissionDataFingerprints.Record memory record = SubmissionDataFingerprints.Record(0, bytes32(0));
        vm.prank(submitter);
        vm.expectEmit(true, false, false, true);
        emit SubmissionDataFingerprints.SubmissionDataSubmitted(submitter, 0, bytes32(0));
        fingerprints.submit(submitter, record);
    }

    function test_batchSubmit_with_notSubmitter() public {
        (address hacker, ) = makeAddrAndKey("hacker");
        vm.prank(hacker);
        vm.expectRevert(abi.encodeWithSelector(SubmissionDataFingerprints.NotSubmitter.selector, hacker));
        address[] memory users = new address[](1);
        users[0] = hacker;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](1);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        fingerprints.batchSubmit(users, records);
    }

    function test_batchSubmit_with_parameterLengthNotEqual() public {
        vm.prank(submitter);
        address[] memory users = new address[](1);
        users[0] = submitter;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](2);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        vm.expectRevert(abi.encodeWithSelector(SubmissionDataFingerprints.ParameterLengthNotEqual.selector, users.length, records.length));
        fingerprints.batchSubmit(users, records);
    }

    function test_batchSubmit_with_submitter() public {
        vm.prank(submitter);
        address[] memory users = new address[](3);
        users[0] = submitter;
        users[1] = owner;
        users[2] = submitter;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](3);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        records[1] = SubmissionDataFingerprints.Record(1, bytes32(uint256(1)));
        records[2] = SubmissionDataFingerprints.Record(2, bytes32(uint256(2)));
        vm.expectEmit(true, false, false, true);
        emit SubmissionDataFingerprints.SubmissionDataSubmitted(submitter, 0, bytes32(0));
        vm.expectEmit(true, false, false, true);
        emit SubmissionDataFingerprints.SubmissionDataSubmitted(owner, 1, bytes32(uint256(1)));
        vm.expectEmit(true, false, false, true);
        emit SubmissionDataFingerprints.SubmissionDataSubmitted(submitter, 2, bytes32(uint256(2)));
        fingerprints.batchSubmit(users, records);
    }

    function test_getRecordCount_with_userNotFound() public view {
        uint256 count = fingerprints.getRecordCount(submitter);
        vm.assertEq(count, 0);
    }

    function test_getRecordCount() public {
        vm.prank(submitter);
        address[] memory users = new address[](1);
        users[0] = submitter;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](1);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        fingerprints.batchSubmit(users, records);

        uint256 count = fingerprints.getRecordCount(submitter);
        vm.assertEq(count, 1);
    }

    function test_getRecord_with_userNotFound() public view {
        (bool found, SubmissionDataFingerprints.Record memory record, bool end) = fingerprints.getRecord(submitter, 0, 0, 1000);
        vm.assertEq(found, false);
        vm.assertEq(end, true);
        vm.assertEq(record.submissionID, 0);
    }

    function test_getRecord_with_recordNotInPage() public {
        vm.prank(submitter);
        address[] memory users = new address[](2);
        users[0] = submitter;
        users[1] = submitter;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](2);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        records[1] = SubmissionDataFingerprints.Record(1, bytes32(uint256(1)));
        fingerprints.batchSubmit(users, records);

        (bool found, SubmissionDataFingerprints.Record memory record, bool end) = fingerprints.getRecord(submitter, 1, 0, 1);
        vm.assertEq(found, false);
        vm.assertEq(end, false);
        vm.assertEq(record.submissionID, 0);
    }

    function test_getRecord() public {
        vm.prank(submitter);
        address[] memory users = new address[](2);
        users[0] = submitter;
        users[1] = submitter;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](2);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        records[1] = SubmissionDataFingerprints.Record(1, bytes32(uint256(1)));
        fingerprints.batchSubmit(users, records);

        (bool found, SubmissionDataFingerprints.Record memory record, bool end) = fingerprints.getRecord(submitter, 1, 1, 1);
        vm.assertEq(found, true);
        vm.assertEq(end, true);
        vm.assertEq(record.submissionID, 1);
    }

    function test_getRecords_with_userNotFound() public view {
        (SubmissionDataFingerprints.Record[] memory records, bool end) = fingerprints.getRecords(submitter, 0, 1000);
        vm.assertEq(end, true);
        vm.assertEq(records.length, 0);
    }

    function test_getRecords() public {
        vm.prank(submitter);
        address[] memory users = new address[](3);
        users[0] = submitter;
        users[1] = submitter;
        users[2] = submitter;
        SubmissionDataFingerprints.Record[] memory records = new SubmissionDataFingerprints.Record[](3);
        records[0] = SubmissionDataFingerprints.Record(0, bytes32(0));
        records[1] = SubmissionDataFingerprints.Record(1, bytes32(uint256(1)));
        records[1] = SubmissionDataFingerprints.Record(2, bytes32(uint256(2)));
        fingerprints.batchSubmit(users, records);

        // all in one page
        bool end = false;
        (records, end) = fingerprints.getRecords(submitter, 0, 1000);
        vm.assertEq(end, true);
        vm.assertEq(records.length, 3);

        // not in one page
        end = false;
        uint256 page = 0;
        uint256 recordCount = 0;
        while (!end) {
            (records, end) = fingerprints.getRecords(submitter, page, 1);
            recordCount += records.length;
            page++;
        }
        vm.assertEq(recordCount, 3);
    }
}
