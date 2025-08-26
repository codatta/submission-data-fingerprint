// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SubmissionDataFingerprints is Ownable {
    struct Record {
        uint256 submissionID;
        bytes32 fingerPrint;
    }

    mapping(address=>Record[]) private storedRecords;
    address private submitter;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error NotSubmitter(address account);

    /**
     * @dev The length of arguments not equal.
     */
    error ParameterLengthNotEqual(uint256 lengthOfUsers, uint256 lengthOfRecords);

    /**
     * @dev Throws if called by any account other than the submitter.
     */
    modifier onlySubmitter() {
        if (msg.sender != submitter) {
            revert NotSubmitter(msg.sender);
        }
        _;
    }

    constructor(address _owner, address _submitter) Ownable(_owner) {
        submitter = _submitter;
    }

    /**
        @notice Submit a single piece of submission data
        @param user the user address which the `record` belongs to
        @param record submission data
    */
    function submit(address user, Record calldata record) public onlySubmitter {
        storedRecords[user].push(record);
    }

    /**
        @notice Submit submission data in batches
        @param users: user addresses which `records` belong to
        @param records: submission data
    */
    function batchSubmit(address[] calldata users, Record[] calldata records) public onlySubmitter {
        if (users.length != records.length) {
            revert ParameterLengthNotEqual(users.length, records.length);
        }

        for (uint i = 0; i < records.length; i++) {
            storedRecords[users[i]].push(records[i]);
        }
    }

    /**
        @notice Returns the record count of a user
        @param user the address to query
        @return count the record count
     */
    function getRecordCount(address user) public view returns (uint256 count) {
        count = storedRecords[user].length;
    }

    /**
        @notice Returns the record of the specified address `user` and submission id `submissionID`
        @param user the address to query
        @param submissionID the submission id to query
        @param page the page to query, starts from 0
        @param size the size of a page, MUST be larger than 0
        @return found if the record is found
        @return record the record found
        @return end if to the end
    */
    function getRecord(address user, uint256 submissionID, uint256 page, uint256 size) public view returns (bool found, Record memory record, bool end) {
        Record[] storage records = storedRecords[user];
        if (records.length == 0) {
            return (false, Record(0,bytes32(0)), true);
        }

        uint256 startIndex = page * size;
        uint256 endIndex = startIndex + size - 1;
        end = false;
        if (endIndex >= records.length - 1) {
            endIndex = records.length - 1;
            end = true;
        }

        found = false;
        record = Record(0,bytes32(0));
        for (uint i = startIndex; i <= endIndex; i++) {
            if (records[i].submissionID == submissionID) {
                found = true;
                record = records[i];
            }
        }
    }

    /**
        @notice Returns the records of the specified address `user` in pages
        @param user the address to query
        @param page the page to query, starts from 0
        @param size the size of a page
        @return rets the records matched
        @return end if to the end
    */
    function getRecords(address user, uint256 page, uint256 size) public view returns (Record[] memory rets, bool end) {
        Record[] storage records = storedRecords[user];
        if (records.length == 0) {
            return (new Record[](0), true);
        }

        uint256 startIndex = page * size;
        uint256 endIndex = startIndex + size - 1;
        end = false;
        if (endIndex >= records.length - 1) {
            endIndex = records.length - 1;
            end = true;
        }

        rets = new Record[](endIndex - startIndex + 1);
        for (uint i = startIndex; i <= endIndex; i++) {
            rets[i - startIndex] = records[i];
        }
    }

    function setSubmitter(address _submitter) public onlyOwner {
        submitter = _submitter;
    }
}
