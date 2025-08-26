import crypto from "crypto"
import fs from "fs"

function main() {
    if (!process.argv[2]) {
        console.error("no image path specified")
        return
    }

    let data = fs.readFileSync(process.argv[2])

    const hash = crypto.createHash("sha256").update(data).digest("hex")
    console.log(hash)
}

main()