// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SubmissionDataFingerprints {
    struct Record {
        uint256 submissionID;
        uint256 taskID;
        bytes32 fingerPrint;
    }

    mapping(address=>Record[]) storedRecords;

    /**
        @notice: Submit a single piece of submission data
        @param user: the user address which the `record` belongs to
        @param record: submission data
    */
    function submit(address user, Record calldata record) public {
        storedRecords[user].push(record);
    }

    /**
        @notice: Submit submission data in batches
        @param users: user addresses which `records` belong to
        @param records: submission data
    */
    function batchSubmit(address[] users, Record[] calldata records) public {
        for (uint i = 0; i < records.length; i++) {
            storedRecords[user].push(records[i]);
        }
    }

    /**
        @notice: Returns the record of the specified address `user` and submission id `submissionID`
        @param user: the address to query
        @param submissionID: the submission id to query
    */
    function getRecord(address user, uint256 submissionID) public returns (Record memory, bool) {
        Record[] storage records = storedRecords[user];
        for (uint i = 0; i < records.length; i++) {
            if (records[i].submissionID == submissionID) {
                return (records[i], true);
            }
        }

        return (new Record(), false);
    }

    /**
        @notice: Returns the records of the specified address `user` in pages
        @param user: the address to query
        @param page: the page to query, starts from 0
        @param size: the size of a page
    */
    function getRecords(address user, uint256 page, uint256 size) public returns (Record[] memory, bool) {
        Record[] storage records = storedRecords[user];
        uint256 startIndex = page * size;
        uint256 endIndex = startIndex + size - 1;
        bool end = false;
        if (endIndex >= records.length - 1) {
            endIndex = records.length - 1;
            end = true;
        }

        Records[] memory rets = new Records[](endIndex - startIndex + 1);
        for (uint i = startIndex; i <= endIndex; i++) {
            rets[i - startIndex] = records[i];
        }

        return (rets, end);
    }
}
