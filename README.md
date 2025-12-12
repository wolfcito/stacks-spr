# Stacks SPR (Spray)

Claim-based Spray/Airdrop contract for the Stacks blockchain.

## Contracts

| Contract | Description |
|----------|-------------|
| `spray-token` | SIP-010 compliant FT for testing |
| `spray` | Main airdrop contract with claim window |

## Development

```bash
# Check contracts
clarinet check

# Run tests
npm test

# Start local devnet
clarinet devnet start

# Open REPL
clarinet console
```

## Deployment

### Testnet

| Contract | Address |
|----------|---------|
| `spray-token` | `ST_YOUR_ADDRESS.spray-token` |
| `spray` | `ST_YOUR_ADDRESS.spray` |

**Network:** Stacks Testnet
**Explorer:** https://explorer.hiro.so/?chain=testnet

## Deployment (Stacks Testnet)

- Network: Stacks Testnet
- Deployer: ST23SRWT9A0CYMPW4Q32D0D7KT2YY07PQAVJY3NJZ

Contracts:
- FT token (for tests): `ST23SRWT9A0CYMPW4Q32D0D7KT2YY07PQAVJY3NJZ.spray-to`
- Spray airdrop: `ST23SRWT9A0CYMPW4Q32D0D7KT2YY07PQAVJY3NJZ.spray`
- Test helpers (if any): `ST23SRWT9A0CYMPW4Q32D0D7KT2YY07PQAVJY3NJZ.spray_te`

Explorer:
- Spray contract: https://explorer.stacks.co/txid/<TXID_DEL_DEPLOY>?chain=testnet

### Deploy to Testnet

1. Configure `settings/Testnet.toml` with your mnemonic
2. Get testnet STX from [faucet](https://explorer.hiro.so/sandbox/faucet?chain=testnet)
3. Generate deployment plan:
   ```bash
   clarinet deployments generate --testnet --medium-cost
   ```
4. Apply deployment:
   ```bash
   clarinet deployments apply --testnet
   ```

## Contract Usage

### Admin Setup (owner only)

```clarity
;; Set token contract
(contract-call? .spray set-token-contract .spray-token none)

;; Set claim amount (e.g., 1000 tokens)
(contract-call? .spray set-claim-amount u1000000000)

;; Set claim window (start-block, end-block)
(contract-call? .spray set-claim-window u100000 u200000)
```

### User Claiming

```clarity
;; Claim tokens (once per address)
(contract-call? .spray claim)
```

### Read Functions

```clarity
;; Check if address has claimed
(contract-call? .spray has-claimed 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Check if claim window is active
(contract-call? .spray is-claim-active)

;; Get claim amount
(contract-call? .spray get-claim-amount)
```

## License

MIT
