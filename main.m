clc;
clear;
close all;
file = fopen('trial.txt', 'r'); % Read file
data = fscanf(file, '%c'); % Store file data
fclose(file); % Close file

%% Calculate probabilities of each symbol
symbols = unique(data); % Remove symbols repetition
probabilities = zeros(size(symbols)); 
for i = 1:length(symbols)
    probabilities(i) = sum(data == symbols(i)) / length(data); % Probability of each symbol
end

%% Calculate information and entropy
info = -log2(probabilities); % Information for each symbol
info_to_ent = -probabilities .* log2(probabilities); % Info x Probability for entropy

entropy = sum(info_to_ent(isfinite(info_to_ent))); % Entropy of the source

% Display information and entropy
disp('Symbol | Probability | Information');
for i = 1:length(symbols)
    fprintf('%c | %.5f | %.4f\n', symbols(i), probabilities(i), info(i));
end
disp('------------------------------------------');
fprintf('Entropy: %.4f bits/symbol\n', entropy);

%% Shannon Binary Encoding
% Sort probabilities and symbols in descending order
[probabilities, idx] = sort(probabilities, 'descend');
symbols = symbols(idx);

% Initialize variables for Shannon Encoding
alpha = zeros(1, length(probabilities));
shannonDict = containers.Map('KeyType', 'char', 'ValueType', 'char');
totalCodeLength = 0;

% Generate Shannon codes
for i = 1:length(probabilities)
    if i > 1
        alpha(i) = alpha(i-1) + probabilities(i-1); % Cumulative probability
    end

    % Convert alpha to binary
    binaryAlpha = '';
    decimal = alpha(i);
    while length(binaryAlpha) < 16 % Ensure 16-bit precision
        decimal = decimal * 2;
        binaryAlpha = strcat(binaryAlpha, num2str(floor(decimal)));
        decimal = decimal - floor(decimal);
        if decimal == 0
            break;
        end
    end

    Li = ceil(-log2(probabilities(i))); % Code length

    % Ensure binaryAlpha has at least Li bits
    if length(binaryAlpha) < Li
        binaryAlpha = pad(binaryAlpha, Li, 'right', '0');
    end
    code = binaryAlpha(1:Li);

    % Add the code to the dictionary
    shannonDict(symbols(i)) = code;
    totalCodeLength = totalCodeLength + Li * probabilities(i); % Weighted sum
end

% Calculate Shannon efficiency
entropyShannon = -sum(probabilities .* log2(probabilities));
efficiencyShannon = entropyShannon / totalCodeLength * 100;
disp('------------------------------------------');

% Display Shannon Dictionary 
disp('Shannon Dictionary:');
disp('Symbol  |   Codeword');
for i = 1:length(symbols)
    fprintf('%c       |    %s\n', symbols(i), shannonDict(symbols(i)));
end

disp('------------------------------------------');
fprintf('Code average length (Shannon): %.4f bits/symbol\n', totalCodeLength);
disp('------------------------------------------');
fprintf('Efficiency (Shannon) %.2f\n', efficiencyShannon);

%% Encode the file content using Shannon
encoded_shannon = cell(1, length(data));
for i = 1:length(data)
    encoded_shannon{i} = shannonDict(data(i));
end

% Convert the encoded data to a string for display
transmitted_binary_shannon = strjoin(encoded_shannon, '');

% Display the Transmitted Binary Code for Shannon
disp('------------------------------------------');
disp('Transmitted Binary Code (Shannon):');
disp(transmitted_binary_shannon);

% Decode the data using Shannon Encoding
reverseShannonDict = containers.Map(values(shannonDict), keys(shannonDict)); 
decoded_shannon = char(zeros(1, length(data))); % Initialize decoded data
stream = ''; % Accumulate binary digits to match codewords

for i = 1:length(encoded_shannon)
    stream = [stream, encoded_shannon{i}];
    if isKey(reverseShannonDict, stream)
        decoded_shannon(i) = reverseShannonDict(stream); % Decode and reset stream
        stream = '';
    end
end

% Display the decoded data for Shannon
%disp('------------------------------------------');
%disp('Decoded Data (Shannon):');
%disp(decoded_shannon);

% Compare between input files and output files
disp('------------------------------------------');
if strcmp(data, decoded_shannon)
    disp('No Lost Data');
else
    disp('Some data is lost');
end

%% Huffman Coding
codeword_length = length(probabilities);
codeword = cell(1, codeword_length); % Empty cells for codeword
x = zeros(codeword_length, codeword_length); % Empty matrix for Huffman algorithm

% Temporary probability to keep the original without change
temp_p = probabilities;

% Huffman matrix
for a = 1:codeword_length-1
    [~, idx] = sort(temp_p); 
    temp_p(idx(2)) = temp_p(idx(1)) + temp_p(idx(2)); % Add the smallest 2 probs
    x(idx(1), a) = 11;  % First smallest p
    x(idx(2), a) = 10;  % Second smallest p
    temp_p(idx(1)) = nan; % Mark the combined nodes with NaN
end

% Generate the dictionary based on the Huffman matrix
for a = codeword_length-1:-1:1
    code_1 = find(x(:, a) == 11);
    code_0 = find(x(:, a) == 10);

    % Concatenate strings using string concatenation
    codeword{code_1} = [codeword{code_0}, '1'];
    codeword{code_0} = [codeword{code_0}, '0'];
end

% Encode the file content using Huffman
encoded_huffman = strings(1, length(data));
for i = 1:length(data)
    for j = 1:length(symbols)
        if data(i) == symbols(j)
            encoded_huffman(i) = codeword{j};
        end
    end
end

% Convert codeword cell array to a regular array for display
codeword_char = char(codeword);
disp('------------------------------------------');
disp('huffman Dictionary:');
disp('Symbol  |   Codeword');
for i = 1:length(symbols)
    fprintf('%c       |    %s\n', symbols(i), codeword_char(i, :));
end

% Transmitted Binary Code for Huffman
str = strjoin(encoded_huffman);
str = strrep(str, ' ', '');
disp('------------------------------------------');
disp('Transmitted Binary Code (Huffman):');
disp(str);

% Decoded Symbols for Huffman
decoded_huffman = [];  % Initialize an empty string for decoded data
stream = [];  % Initialize an empty string to accumulate binary digits

for i = 1:length(encoded_huffman)
    stream = [stream, encoded_huffman(i)];
    index = find(strcmp(stream, codeword));

    if ~isempty(index)
        decoded_huffman = [decoded_huffman, symbols(index)];
        stream = []; % Reset stream for next codeword
    end
end
%disp('------------------------------------------');
%disp('Decoded Data (Huffman):');
%disp(decoded_huffman);

% Calculate average code length for Huffman
L = cellfun(@numel, codeword);
L = L.'; % Convert to a column vector
Code_average_length = sum(probabilities .* L');

disp('------------------------------------------');
fprintf('Code average length (Huffman): %.4f bits/symbol\n', Code_average_length);
disp('------------------------------------------');

% Calculate Huffman Efficiency
Efficiency_huffman = (entropy / Code_average_length) * 100;
fprintf('Efficiency (Huffman): %.2f\n', Efficiency_huffman);
disp('------------------------------------------');

% Compare between input files and output files
if strcmp(data, decoded_huffman)
    disp('No Lost Data');
else
    disp('Some data is lost');
end
