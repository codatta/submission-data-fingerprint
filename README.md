# submission-data-fingerprint

The contract is used to store fingerprints of user contribution information and credential information of Submission data, in order to ensure data verifiability and immutability.

## Features

-   **Store**: Store fingerprints of user contribution information and credential information of Submission data.
-   **Retrieve**: Retrieve data of a user or of a specified submission id.

## Usage

### Dependencies

- **[Foundry](https://getfoundry.sh/introduction/installation/)**

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Contract Call

Enter the directory `script/`

```
cd script
```

#### Configuration

Copy `.env` from `.env.example`, edit `.env`

```
SUBMITTER_PRIVATE_KEY='' # the private key of the submitter
```

#### Execute

```
python fingerprint.py
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
