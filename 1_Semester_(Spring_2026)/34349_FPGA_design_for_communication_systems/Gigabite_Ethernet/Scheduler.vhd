



---------------------------------------------------------------------
-- Componant:   Scheduler 
-- Description: its task is to control the crossbar so there is an ideel 
--	     	throghput so that the VOQ gets emptied the fastest	   
-- Changes	:
--  		HH 18/3 creation of document and I/O
---------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scheduler is
    port (
	--Input
        Clk           : in std_logic;
	Full_signal   : in std_logic_vector(15 downto 0);-- unknown size (shows when the full VOQ) 
	
	--Output
	Select_Signal : out std_logic_vector(47 downto 0)-- unknown size  
	);
end Scheduler;

architecture behavioral of Scheduler is
-- Signal & Component Declaration


Begin









end behavioral;




