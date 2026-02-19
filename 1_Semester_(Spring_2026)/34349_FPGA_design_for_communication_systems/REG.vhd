library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG is
    port (
	start_of_frame : in  std_logic; -- Start of frame
        clk      : in  std_logic; -- system clock
        reset    : in  std_logic; -- asynchronous reset
        data_in  : in  std_logic; -- serial input data.
        data_out : out std_logic  -- serial output data.
    );
end REG;

architecture Behavioral of REG is 
begin
    process(clk, reset)
    begin
        if reset = '1' or start_of_frame= '1' then
            data_out <= '0';
        elsif rising_edge(clk) then
            data_out <= data_in;
        end if;
    end process;    
end Behavioral;