library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_Read_Control is
    port (
		reset : in std_logic;
		rclk : in std_logic;
		read_enable : in std_logic;
		W_sync : in std_logic_vector(3 downto 0);
		empty : out std_logic;
		ren : out std_logic;
		fifo_occu_out : out std_logic_vector(4 downto 0);
		raddr: out std_logic_vector(4 downto 0);
		rptr: out std_logic_vector(4 downto 0)
    );
end FIFO_Read_Control;--finished

architecture behavioral of FIFO_Read_Control is

    -- Signals would be declared here

	signal Readpointer: std_logic_vector(4 downto 0); 



begin




process(rclk,reset)
	begin
		if (reset = '1') then
		
		elsif rising_edge(rclk) then


		
			-- Defining when the the system is empty  
			if (wptr == W_sync) then 
				empty <= '1'; 
			else 
				empty <='0';
			end if;
		end if;
		fifo_occu_out <= W_sync - Readpointer;
		rptr <= Readpointer;
	end process


end behavioral;
