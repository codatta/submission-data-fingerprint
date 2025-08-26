import {ethers} from "ethers"

function main() {
    const address = "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1";                 // user address: address
    const quality = "S";             // quality: string
    const submissionData = '{"brand":"Homemade ","foodCategory":"Homemade food or snacks","foodName":"Paneer loded basan roll ","images":[{"hash":"e6b024a0a5b3f202667300f3621190e666a52cadfd715664cd2e082cb0d3e03a"}],"quantity":"Individual (1 person)","region":"PK"}'; // JCS-format submissionData: string

    const encoded = ethers.AbiCoder.defaultAbiCoder().encode(
        ["address", "string", "string"],
        [address, quality, submissionData]
    );
    console.log("encoded data: ", encoded)

    const hash = ethers.keccak256(encoded);
    console.log("fingerprint: ", hash);
}

main()