//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 public depth;
    uint256 public length;
    uint256 public constant totalNodes = 15;
    uint256 public constant totalLeaves = 8;

    constructor() {
        hashes = new uint256[](totalNodes);
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint256 i = 0; i < totalLeaves; i++) {
            hashes[i] = 0;
        }
        uint256 j = 0;
        for (uint256 i = totalNodes / 2 + 1; i < (totalNodes); i++) {
            uint256[2] memory input;
            input[0] = hashes[j];
            input[1] = hashes[j + 1];
            hashes[i] = (PoseidonT3.poseidon(input));
            j += 2;
        }
        root = hashes[totalNodes - 1];
        depth = 3;
        length = hashes.length;
    }

    function returnHashElement(uint256 index) public view returns (uint256) {
        return hashes[index];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        require(
            index <= totalLeaves,
            "Merkle tree is full. No more leaves can be added"
        );
        // uint256[totalNodes] memory cpHashes;
        uint256 currIndex = index;
        hashes[currIndex] = hashedLeaf;

        uint256 j = 0;
        for (uint256 i = totalNodes / 2 + 1; i < (totalNodes); i++) {
            uint256[2] memory input;
            input[0] = hashes[j];
            input[1] = hashes[j + 1];
            hashes[i] = PoseidonT3.poseidon(input);
            j += 2;
        }
        root = hashes[totalNodes - 1];
        index = currIndex + 1;
        return 0;
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        return root == input[0] && verifyProof(a, b, c, input) == true;
    }
}
