// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title NFT Sale with pausable transfers
 * @author Breakthrough Labs Inc.
 * @notice NFT, Sale, ERC721, Pausable
 * @custom:version 1.0.8
 * @custom:address 10
 * @custom:default-precision 0
 * @custom:simple-description NFT with a built in sale. The owner is
 * able to pause both NFT transactions, and the sale - primarily in the case of a problem.
 * @dev Pausable ERC721 NFT, including:
 *
 *  - Built-in sale with an adjustable price.
 *  - Reserve function for the owner to mint free NFTs.
 *  - Owner to pause or unpause NFT transfers.
 *  - Fixed maximum supply.
 *
 */

contract PausableNFT is ERC721, ERC721Enumerable, Pausable, Ownable {
    
    string private _baseURIextended;
    bool public saleIsActive = true;
    uint256 public immutable MAX_SUPPLY;
    /// @custom:precision 18
    uint256 public currentPrice;

    /**
     * @param _name NFT Name
     * @param _symbol NFT Symbol
     * @param _uri Token URI used for metadata
     * @param price Initial Price | precision:18
     * @param maxSupply Maximum # of NFTs
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 price,
        uint256 maxSupply
    ) payable ERC721(_name, _symbol) {
        _baseURIextended = _uri;
        MAX_SUPPLY = maxSupply;
        currentPrice = price;
    }

    /**
     * @dev An external method for users to purchase and mint NFTs. Requires that the sale
     * is active, that the minted NFTs will not exceed the `MAX_SUPPLY`, and that a
     * sufficient payable value is sent.
     * @param amount The number of NFTs to mint.
     */
    function mint(uint256 amount) external payable {
        uint256 ts = totalSupply();
        require(saleIsActive, "Sale must be active to mint tokens");
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(
            currentPrice * amount <= msg.value,
            "Value sent is not correct"
        );

        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    /**
     * @dev A way for the owner to reserve a specifc number of NFTs without having to
     * interact with the sale.
     * @param n The number of NFTs to reserve.
     */
    function reserve(uint256 n) external onlyOwner {
        uint256 supply = totalSupply();
        require(supply + n <= MAX_SUPPLY, "Purchase would exceed max tokens");
        for (uint256 i = 0; i < n; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    /**
     * @dev A way for the owner to withdraw all proceeds from the sale.
     */
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Updates the baseURI that will be used to retrieve NFT metadata.
     * @param baseURI_ The baseURI to be used.
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    /**
     * @dev Sets whether or not the NFT sale is active.
     * @param isActive Whether or not the sale will be active.
     */
    function setSaleIsActive(bool isActive) external onlyOwner {
        saleIsActive = isActive;
    }

    /**
     * @dev Sets the price of each NFT during the initial sale.
     * @param price The price of each NFT during the initial sale | precision:18
     */
    function setCurrentPrice(uint256 price) external onlyOwner {
        currentPrice = price;
    }

    /**
     * @dev Pauses the NFT, preventing any transfers. Only callable by the contract owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the NFT, allowing transfers to occur again. Only callable by the contract owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // Required Overrides

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

