# tools for submission-data-fingerprint contracts

When using the contract for verification, users often need to process the input and intermediate data.
This repository provides a minimal set of tools to help users with verification needs.
Developers who wish to build their own verification programs can also refer to the implementation here.

## Prerequisites

- node: >= v20

## Install

```
npm install
```

## Usage

### Image Hash

The following command will calculate the hash of a specified image using the SHA-256 algorithm.

```
node sha256.js <PATH_OF_IMAGE>
```

`<PATH_OF_IMAGE>` is the path of the image you want to calculate hash for, you can use `./image.example.png` for example.

### CJS Data

The following command will encode the result in CJS format.

```
node cjs.js <PAHT_OF_FILE>
```

`<PATH_OF_FILE>` is the path of the original json file to be encoded, you can use `./data.example.json` for example.

### Fingerprint

The following command will calculate the fingerprint.

```
node fingerprint.js
```

**NOTE**: You should modify the parameters `address`, `quality`, `cjsData` in `fingerprint.js` before execution