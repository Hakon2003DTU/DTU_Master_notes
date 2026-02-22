

% Parallel CRC implementation
% Polynomial
G = [1,0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1,0,1,1,0,1,1,1]; % 32 x1

% Degree
Degree = 32;

% UpperLeft 
v = zeros(31, 1);                           % Zero vector 31 x 1
I = eye(31);                                % Identity vectore 31 x 31 
upper_section_left = [v, I];                % Results in a 31 x 32 matrix
UpperLeft = [upper_section_left; fliplr(G(2:end))]; % Upper Left 

% UpperRight 
UpperRight  = zeros(32, 8);                 % the Upper Right matrix

% BottomRight 
A = zeros(1, 8);                            % Zero vector 1 x 8
A(8) = 1;                                   % Set the 8 element to 1
B=  zeros(7, 1);                            % Zero vector 7 x 1
I2 = eye(7);                                % Identity vectore 7 x 7
Bottom_right_merge= [I2,B];                 % Results in a 31 x 32 matrix
BottomRight=[A;Bottom_right_merge];         % The Bottom Right 

% BottomLeft  
BottomLeft=zeros(8, 32);                    % Zero vector 8 x 32
BottomLeft(1,1)=1;                          

% Combining the 4 parts of the matrix  
Combining = [UpperLeft,UpperRight;BottomLeft,BottomRight]   % The combined matrix 40 x 40         

% Calculate M^2 (M * M) bitwise
M2 = mod(Combining * Combining, 2);

% Calculate M^4 (M^2 * M^2) bitwise
M4 = mod(M2 * M2, 2);

% Calculate M^8 (M^4 * M^4) bitwise
Combining8 = mod(M4 * M4, 2);

for x = 1:size(Combining8,2)
    if x > 32
        break;
    end

    terms = {};

    for y = 1:size(Combining8,1)
        if Combining8(y, x) == 1
            if y > 32
                % Flip bit order in the byte: y=33->data_in(7) ... y=40->data_in(0)
                terms{end+1} = sprintf('data_in(%d)', 40 - y);
            else
                terms{end+1} = sprintf('Reg(%d)', y - 1);
            end
        end
    end

    if isempty(terms)
        rhs = '0';
    else
        rhs = strjoin(terms, ' xor ');
    end

    fprintf('Reg(%d) <= %s;\n', x - 1, rhs);
end
