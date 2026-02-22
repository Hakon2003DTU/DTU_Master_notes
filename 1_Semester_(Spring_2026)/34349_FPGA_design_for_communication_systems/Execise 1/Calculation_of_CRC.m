
% polynomial
G = [1, 0,0,0,0,0,1,0,0, 1,1,0,0,0,0,0,1, 0,0,0,1,1,1,0,1, 1,0,1,1,0,1,1,1];

% degree
degree = 32;

%Data
Data = [0x00, 0x10, 0xA4, 0x7B, 0xEA, 0x80, 0x00, 0x12, ...
             0x34, 0x56, 0x78, 0x90, 0x08, 0x00, 0x45, 0x00, ...
             0x00, 0x2E, 0xB3, 0xFE, 0x00, 0x00, 0x80, 0x11, ...
             0x05, 0x40, 0xC0, 0xA8, 0x00, 0x2C, 0xC0, 0xA8, ...
             0x00, 0x04, 0x04, 0x00, 0x04, 0x00, 0x00, 0x1A, ...
             0x2D, 0xE8, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, ...
             0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, ...
             0x0E, 0x0F, 0x10, 0x11];

% convert from hex to binary vector
binStr = reshape(dec2bin(Data, 8).', 1, []); %Convert Hex to Binary string
M = double(binStr) - double('0'); % convert from ascii to numbers a binary vector

% inverts the first 32 bits 
M(1:degree) = 1 - M(1:degree);

% Adding 32 zeros for the division
M = [M, zeros(1, degree)];

% Xor when the leading bit is '1' throgh out the data (exept the last 32 bits)
for i = 1 : (length(M) - degree)
    if M(i) == 1
        M(i:i+degree) = xor(M(i:i+degree), G);
    end
end

% Find the last 32 bits and invert them
R = M(end-degree+1 : end);
R_final = 1 - R; % Final bitwise complement


%Display
% Select the last 32 bits and placeing them in a 8x4 matrix
bit_matrix = reshape(R_final(1:32), 8, 4)';  

powers_of_two = 2.^(7:-1:0)';% Creating a vector to convert to decimal 
decimal_values = bit_matrix * powers_of_two; % Decimal value

hex_bytes = dec2hex(decimal_values, 2); % Convert from decimal to hex

% write to terminal 
fprintf('Calculated Hex: 0x%s 0x%s 0x%s 0x%s\n', ...
hex_bytes(1,:), hex_bytes(2,:), hex_bytes(3,:), hex_bytes(4,:));

















