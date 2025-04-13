-include .env

build:; forge build

ds:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv --private-key $(PRIVATE_KEY)