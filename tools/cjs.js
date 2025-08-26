import { canonicalize, canonicalizeEx } from 'json-canonicalize'
import fs from 'fs'

function main() {
    if (!process.argv[2]) {
        console.error("no file path specified")
        return
    }

    let data = fs.readFileSync(process.argv[2])
    let jsonData = JSON.parse(data.toString())

    const result = canonicalize(jsonData)
    console.log(result)
}

main()