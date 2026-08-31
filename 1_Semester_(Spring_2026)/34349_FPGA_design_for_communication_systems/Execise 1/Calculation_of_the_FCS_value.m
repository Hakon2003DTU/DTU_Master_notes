%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of the FCS value (using the IEEE 802.3 MAC)
% 
% Description:  The following program calculates the FCS
%               value based on standard Ethernet CRC-32 rules.
%
% Made by: Hákon Hlynsson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generating Polynomial G(x)
G = [1,0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1];
degree = 32;

% 802.3 MAC format components
Preamble= [0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA];
Start_of_Frame=[0xAB];
Destination_MAC=[0x00,0x00,0x00,0x00,0x00,0x05]; % Select the Destination
Source_MAC=[0x00,0x00,0x00,0x00,0x00,0x01];      % Select the Source

% Data that you want to send 46-1500 bytes
Payload=repmat(uint8(0xAA),1,46);
EtherType_Length = [uint8(bitshift(uint16(length(Payload)), -8)), uint8(bitand(uint16(length(Payload)), 255))];

% FIX 1: The FCS computation applies ONLY to Destination, Source, Length, and Payload.
% Do NOT include the Preamble or Start_of_Frame here.
FCS_Data = [Destination_MAC, Source_MAC, EtherType_Length, Payload];

% Convert from hex to binary vector
binStr = reshape(dec2bin(FCS_Data, 8).', 1, []); % Convert Hex to string
M = double(binStr) - double('0'); % Convert from ascii to numbers as a binary vector

% FIX 2: "The first 32 bits of the frame are complemented."
M(1:32) = 1 - M(1:32);

% M(x) is multiplied by x^32 (Adding 32 zeros for the division)
M = [M, zeros(1, degree)];

% Xor division when the leading bit is '1' 
for i = 1 : (length(M) - degree)
    if M(i) == 1
        M(i:i+degree) = xor(M(i:i+degree), G);
    end
end

% Find the remainder R(x) of degree 31
R = M(end-degree+1 : end);

% FIX 3: "The bit sequence is complemented and the result is the CRC."
R_final = 1 - R; % Final bitwise complement

% Display formatting
% Select the last 32 bits and place them in an 8x4 matrix
bit_matrix = reshape(R_final(1:32), 8, 4)';  
powers_of_two = 2.^(7:-1:0)'; % Creating a vector to convert to decimal 
decimal_values = bit_matrix * powers_of_two; % Decimal value
hex_bytes = dec2hex(decimal_values, 2); % Convert from decimal to hex

% Write to terminal 
fprintf('Calculated Hex: 0x%s 0x%s 0x%s 0x%s\n', ...
hex_bytes(1,:), hex_bytes(2,:), hex_bytes(3,:), hex_bytes(4,:));