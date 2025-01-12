# Data-Compression-with-Shannon-and-Huffman-Coding

This project demonstrates data compression techniques using **Shannon Binary Encoding** and **Huffman Coding**. The process includes reading a text file, calculating symbol probabilities, and performing both Shannon and Huffman encoding and decoding. The comparison of the efficiency of both methods is calculated and displayed.

## Files
- `trial.txt`: Input text file containing data to be encoded and decoded.
- `Main.m`: MATLAB script performing the compression and decompression.

## Process Overview

1. **Input File Reading**
   - The file `trial.txt` is read and the characters are extracted into the `data` variable.

2. **Probability Calculation**
   - Unique symbols in the data are identified, and their probabilities are calculated based on their frequency in the input file.

3. **Shannon Binary Encoding**
   - Shannon codes are generated based on symbol probabilities, and the efficiency of this encoding is calculated.
   - The file content is encoded using Shannon codes, and the encoded data is displayed.
   - The data is decoded and compared with the original data to check for any loss.

4. **Huffman Coding**
   - Huffman codes are generated for the symbols based on their probabilities.
   - The file content is encoded using Huffman codes, and the encoded data is displayed.
   - The data is decoded and compared with the original data to check for any loss.

5. **Efficiency Calculation**
   - The average code length for both Shannon and Huffman encoding methods is calculated.
   - The efficiency of both methods is computed and displayed.

## Functions

- `Shannon Encoding`: Implements the Shannon coding algorithm and computes its efficiency.
- `Huffman Encoding`: Implements the Huffman coding algorithm and computes its efficiency.
- `Entropy Calculation`: Computes the entropy of the input file data.

## Example

The input file `trial.txt` will be read, encoded using both Shannon and Huffman methods, and the results will be displayed in the command window. Efficiency metrics, including entropy and average code length, will also be shown for both encoding methods.


