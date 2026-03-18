


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Gray_To_Bin is
port (
    G : in std_logic_vector(4 downto 0);
    B : out std_logic_vector(4 downto 0)
);
end Gray_To_Bin;

architecture behavioral of Gray_To_Bin is
signal lines: std_logic_vector(2 downto 0);

begin	
	--Calculateing the lines
	lines(0)<=G(3) xor G(4);
	lines(1)<=lines(0) xor G(2);
	lines(2)<=lines(1) xor G(1);
	
	--Setting outputs
	B(4) <= G(4);
	B(3) <= lines(0);
	B(2) <= lines(1);
	B(1) <= lines(2);
	B(0) <= lines(2) xor G(0); 
		
end behavioral;

