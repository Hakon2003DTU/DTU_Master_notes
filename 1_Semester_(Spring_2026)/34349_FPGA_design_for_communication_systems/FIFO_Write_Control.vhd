library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_Write_Control is
port (
reset : in std_logic;
wclk : in std_logic;
write_enable : in std_logic;
write_data_in : in std_logic_vector(7 downto 0);
full : out std_logic;
wen : out std_logic;
fifo_occu_in : out std_logic_vector(4 downto 0);
waddr: out std_logic_vector(4 downto 0);
wptr: out std_logic_vector(4 downto 0)
);
end FIFO_Write_Control;--finished

architecture behavioral of FIFO_Write_Control is
 -- Insert signals 
begin
-- insert	


end behavioral;




