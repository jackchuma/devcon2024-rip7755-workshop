-include .env

setup:
	cd contracts && forge install && forge build && chmod +x setupContracts.sh
	cd services/demo && bun install
	cd services/fulfiller && bun install
	cd services/syncer && bun install

start-mock-L1:
	cd contracts && anvil

start-mock-base:
	cd contracts && anvil --port 8546 --chain-id 111111

start-mock-arbitrum:
	cd contracts && anvil --port 8547 --chain-id 111112

setup-contracts:
	cd contracts && forge script script/rollups/DeployRollup.s.sol:DeployRollup --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_L1_URL) --broadcast -vvvv
	cd contracts && forge script script/rollups/DeployRollup.s.sol:DeployRollup --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_L1_URL) --broadcast -vvvv
	cd contracts && forge script script/rollups/DeployMockEIP4788.s.sol:DeployMockEIP4788 --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_BASE_URL) --broadcast -vvvv
	cd contracts && forge script script/rollups/DeployMockEIP4788.s.sol:DeployMockEIP4788 --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_ARBITRUM_URL) --broadcast -vvvv
	cd contracts && forge script script/RIP7755/DeployRIP7755.s.sol:DeployRIP7755 --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_BASE_URL) --broadcast -vvvv
	cd contracts && forge script script/RIP7755/DeployRIP7755.s.sol:DeployRIP7755 --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_ARBITRUM_URL) --broadcast -vvvv
	cd contracts && forge script script/DeployNFT.s.sol:DeployNFT --private-key $(PRIVATE_KEY) --rpc-url $(MOCK_ARBITRUM_URL) --broadcast -vvvv

start-syncer:
	cd services/syncer && MOCK_BASE_KEY=$(MOCK_BASE_KEY) MOCK_ARBITRUM_KEY=$(MOCK_ARBITRUM_KEY) bun run index.ts

start-fulfiller:
	cd services/fulfiller && PRIVATE_KEY=$(PRIVATE_KEY) bun run index.ts

demo:
	cd services/demo && PRIVATE_KEY=$(PRIVATE_KEY) bun run index.ts