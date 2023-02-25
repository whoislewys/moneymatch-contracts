## Deploy
```bash
npx hardhat run --network localhost scripts/deploy.ts
```

## Generate TypeScript bindings w/ TypeChain
```bash
find ./artifacts -name '*.json' ! -name '*dbg.json' ! -path './artifacts/build-info/*' | xargs npx typechain --target ethers-v5
```

# Sample Hardhat Project
This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```bash
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

