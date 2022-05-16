pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    var numLeaves = 2**n;
    var j = 0;
    signal parents[numLeaves-1];
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component hashes[numLeaves-1];

    for (var i = 0; i < (numLeaves - 1); i++) hashes[i] = Poseidon(2);
    for (var i = 0; i < (numLeaves - 1); i += 2) {
        hashes[i/2].inputs[0] <== leaves[i];
        hashes[i/2].inputs[1] <== leaves[i+1]; 
        parents[i/2] <== hashes[i/2].out;
    }
    for (var i = numLeaves/2; i < (numLeaves - 1); i++) {
        hashes[i].inputs[0] <== parents[j].out;
        hashes[i].inputs[1] <== parents[j + 1].out;
        parents[i] <== hashes[i].out;
        j += 2;
    }

    root <== parents[numLeaves - 2].out;

}

template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal
    for (var i = 0; i < n; i++) 0 === path_index[i] * (1 - path_index[i]);

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component selectors[n];
    component hashes[n];

    for (var i = 0; i < n; i++) {
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashes[i - 1].out;
        selectors[i].in[1] <== path_elements[i];
        selectors[i].s <== path_index[i];

        hashes[i] = Poseidon(2);
        hashes[i].inputs[0] <== selectors[i].out[0];
        hashes[i].inputs[1] <== selectors[i].out[1];
    }

    root <== hashes[n-1].out;
}