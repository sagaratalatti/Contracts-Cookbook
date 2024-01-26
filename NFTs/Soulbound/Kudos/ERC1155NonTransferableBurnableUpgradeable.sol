// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";


interface ICommunityRegistry {
    function doesCommunityExist(string memory uniqId)
        external
        view
        returns (bool);

    function communityIdToAdminOneIndexIndices(
        string memory uniqId,
        address admin
    ) external view returns (uint256);
}

contract ERC1155NonTransferableBurnableUpgradeable is
    ERC1155Upgradeable,
    ERC1155SupplyUpgradeable
{
    /// @dev Override of the token transfer hook that blocks all transfers BUT mints and burns.
    ///        This is a precursor to non-transferable tokens.
    ///        We may adopt something like ERC1238 in the future.
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) {
        require(
            (from == address(0) || to == address(0)),
            "Only mint and burn transfers are allowed"
        );
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
