


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Flip_flop is
port (
    Input : in std_logic_vector(3 downto 0);
    clk : in std_logic;
    Output : out std_logic_vector(3 downto 0)
);
end Flip_flop;

architecture behavioral of Flip_flop is
begin

process(clk) 
    begin
        
        if rising_edge(clk) then 
            Output <= Input; 
        end if;
    end process;

end behavioral;







