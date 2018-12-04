
/**
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

pragma solidity 0.4.24;

import "zos-lib/contracts/Initializable.sol";

import "./Vault.sol";
import "./Bridge.sol";

contract DepositHandler is Initializable, Vault {

  event NewDeposit(
    uint32 indexed depositId, 
    address indexed depositor, 
    uint256 indexed color, 
    uint256 amount
  );

  struct Deposit {
    uint64 height;
    uint16 color;
    address owner;
    uint256 amount;
  }

  uint32 public depositCount;

  mapping(uint32 => Deposit) public deposits;

  function initialize(Bridge _bridge) public initializer {
    Vault.initialize(_bridge);
    depositCount = 0;
  }

   /**
   * @notice Add to the network `(_amountOrTokenId)` amount of a `(_color)` tokens
   * or `(_amountOrTokenId)` token id if `(_color)` is NFT.
   * @dev Token should be registered with the Bridge first.
   * @param _owner Account to transfer tokens from
   * @param _amountOrTokenId Amount (for ERC20) or token ID (for ERC721) to transfer
   * @param _color Color of the token to deposit
   */
  function deposit(address _owner, uint256 _amountOrTokenId, uint16 _color) public {
    require(tokens[_color].addr != address(0), "Token color not registered");
    tokens[_color].addr.transferFrom(_owner, this, _amountOrTokenId);

    bytes32 tipHash = bridge.tipHash();
    (,uint32 height,,) = bridge.periods(tipHash);

    depositCount++;
    deposits[depositCount] = Deposit({
      height: height,
      owner: _owner,
      color: _color,
      amount: _amountOrTokenId
    });
    emit NewDeposit(
      depositCount, 
      _owner, 
      _color, 
      _amountOrTokenId
    );
  }

}