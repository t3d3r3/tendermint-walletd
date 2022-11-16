# tendermint-walletd

## Requirements
- unix env (including windows wsl)
- jq (parsing json)
- tendermint binary (ex. terrad, download latest release from official repo)

## Notes
- do not share your keys or mnemo with anyone
- .env file contains values that can be changed, example is for terra test chain, see ENV
- you need to add the source wallet key to your local keyring (use test backend when adding so the script will not ask for pass) 
```
../terrad keys add wallet_from --recover --keyring-backend=test
```

## Disclaimer
- this script is intended to help people that have been tricked into sharing their mnemonics have a fighting chance to recover locked funds (unstaking, unvesting) without sharing wallet access to even more people
- this script is provided as-is without support or liability whatsoever
- this script does not guarantee that you will recover your funds, attackers may run something similar or better
- briefly tested on terra2 test (pisco-1) chain, please report issues

## ENV

Change the .env file according to your needs:
- EXEC_PATH = full path to chain binary (see requirements)
- EXEC_BIN = binary name (should wotk for all tendermint based chains)
- RPC = public RPC node to use
- DENOM = base denom to watch for
- THRESHOLD = amount to wait for before transfering (in base denom, ex uluna. 1 luna=1000000 uluna)
- FEES = amount reserved for fees, should be enough or transaction will fail. This is deducted from the available wallet amount along with a gas adjustment coefficient of 1.4. 

## Run
- the script will check some stuff, if it exits at least a setting is wrong
- the script will check the balance against a rpc and if balance raises above the set threshold it will transfer everything to the new wallet

```
./walletd.sh wallet_from address_to
```