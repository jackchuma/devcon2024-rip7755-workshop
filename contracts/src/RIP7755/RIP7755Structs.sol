// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice Low-level call specs representing the desired transaction on destination chain
struct Call {
    /// @dev The address to call
    address to;
    /// @dev The calldata to call with
    bytes data;
    /// @dev The native asset value of the call
    uint256 value;
}

/// @notice A cross chain call request formatted following the RIP-7755 spec
struct CrossChainRequest {
    /// @dev The account submitting the cross chain request
    address requester;
    /// @dev Array of calls to make on the destination chain
    Call[] calls;
    /// @dev The source chain contract address that will verify state on the destination chain
    address proverContract;
    /// @dev The chainId of the destination chain
    uint256 destinationChainId;
    /// @dev The L2 contract on destination chain that's storage will be used to verify whether or not this call was made
    address inboxContract;
    /// @dev The L1 address of the contract that should have L2 block info stored
    address l2Oracle;
    /// @dev The storage key at which we expect to find the L2 block info on the l2Oracle
    bytes32 l2OracleStorageKey;
    /// @dev The address of the ERC20 reward asset to be paid to whoever proves they filled this call
    /// @dev Native asset specified as in ERC-7528 format
    address rewardAsset;
    /// @dev The reward amount to pay
    uint256 rewardAmount;
    /// @dev The minimum age of the L1 block used for the proof
    uint256 finalityDelaySeconds;
    /// @dev The nonce of this call, to differentiate from other calls with the same values
    uint256 nonce;
    /// @dev The timestamp at which this request will expire
    uint256 expiry;
    /// @dev An optional pre-check contract address on the destination chain
    /// @dev Zero address represents no pre-check contract desired
    /// @dev Can be used for arbitrary validation of fill conditions
    address precheckContract;
    /// @dev Arbitrary encoded precheck data
    bytes precheckData;
}
