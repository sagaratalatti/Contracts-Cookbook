// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/**
 * @title Multi-Collection NFT with burnable NFTs and pausable transfers
 * @author Breakthrough Labs Inc.
 * @notice NFT, ERC1155, Pausable, Burnable
 * @custom:version 1.07
 * @custom:address 17
 * @custom:default-precision 0
 * @custom:simple-description An NFT that supports creating multiple collections, with
 * built in burn functionality to directly decrease supply, and ability for owner to pause
 * NFT transfers.
 * @dev ERC1155 NFT, the basic standard multi-token, with the following features:
 *
 *  - Burn feature that allow users to burn their NFTs. This directly decreases total supply.
 *  - Owner can pause or unpause NFT transfers.
 *  - Adjustable metadata.
 *  - Create multiple NFT collections with the same contract.
 *
 */

contract AdvancedERC1155 is
    ERC1155,
    Ownable,
    Pausable,
    ERC1155Burnable,
    ERC1155Supply
{
    /**
     * @param _uri NFT metadata URI
     */
    constructor(string memory _uri) payable ERC1155(_uri) {}

    /**
     * @dev Updates the base URI that will be used to retrieve metadata.
     * @param newuri The base URI to be used.
     */
    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    /**
     * @dev Pauses the contract, preventing any transfers. Only callable by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract, allowing transfers to occur again. Only callable by the contract owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev A method for the owner to mint new ERC1155 tokens.
     * @param account The account for new tokens to be sent to.
     * @param id The id of token type.
     * @param amount The number of this token type to be minted.
     * @param data additional data that will be used within the receiver's onERC1155Received method
     */
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        _mint(account, id, amount, data);
    }

    /**
     * @dev A method for the owner to mint a batch of new ERC1155 tokens.
     * @param to The account for new tokens to be sent to.
     * @param ids The ids of the different token types.
     * @param amounts The number of each token type to be minted.
     * @param data additional data that will be used within the receivers' onERC1155Received method
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

