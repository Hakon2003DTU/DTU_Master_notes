library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_Write_Control is
    port (
        Reset        : in std_logic;
        Wclk         : in std_logic;
        Write_Enable : in std_logic;
        R_Sync       : in std_logic_vector(4 downto 0);
        Full         : out std_logic;
        Wen          : out std_logic;
        Fifo_occu_in : out std_logic_vector(4 downto 0);
        Waddr        : out std_logic_vector(3 downto 0);
        Wptr         : out std_logic_vector(4 downto 0)
    );
end FIFO_Write_Control;

architecture behavioral of FIFO_Write_Control is
    signal Memory_Full : std_logic := '0';
    signal Writepointer: std_logic_vector(4 downto 0) := "00000";
begin

   process(R_Sync,Writepointer)
   Begin
	    if (Writepointer(4) /= R_Sync(4)) and (Writepointer(3 downto 0) = R_Sync(3 downto 0)) then
                Memory_Full <= '1';
            else
                Memory_Full <= '0';
            end if;
    end process;


    process(Wclk, Reset)
    begin
        if (Reset = '1') then
            Full         <= '0';
            Wen          <= '0';
            Fifo_occu_in <= (others => '0');
            Waddr        <= (others => '0');
            Wptr         <= (others => '0');
            Writepointer <= (others => '0');

        elsif rising_edge(wclk) then
            
           
            if ((Write_Enable ='1') and (Memory_Full = '0')) then 
                Writepointer <= std_logic_vector(unsigned(Writepointer) + 1);
                Wen          <= '1';
            else
                Wen          <= '0';
            end if;

            Full         <= Memory_Full;
            Fifo_occu_in <= std_logic_vector(unsigned(Writepointer) - unsigned(R_Sync));
            Wptr         <= Writepointer;
            Waddr        <= Writepointer(3 downto 0);
        end if;
    end process;
end behavioral;
