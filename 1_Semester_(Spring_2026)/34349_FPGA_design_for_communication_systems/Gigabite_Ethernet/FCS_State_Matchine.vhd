
---------------------------------------------------------------------
-- Componant:   FCS_State_Machine 
-- Description: This is a statemachine which task is to control the 
--	        	entire FCS block 	   
-- Changes	:
--  		HH 20/3: creation of document and I/O and inserted basic state machine
---------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FCS_State_Machine is
    port (
        Reset           : in    std_logic;
        Rx_Clk          : in    std_logic;
        Rx_Data         : in    std_logic_vector(7 downto 0);
        Rx_Valid        : in    std_logic;
        Counter         : in    std_logic_vector(11 downto 0);
        Eth_Len         : in    std_logic_Vector(11 downto 0);
        Dst_MAC         : out   std_logic_vector(47 downto 0);
        Src_MAC         : out   std_logic_vector(47 downto 0);

        output      : out   std_logic
    );
end FCS_State_Machine;

architecture behavioral of FCS_State_Machine is
    type state_type is (IDLE, Praemble,Start_Frame,Destionation_MAC,Source_MAC, Ethernet_Length,Payload,FCS,Dummy);
    signal current_state, next_state : state_type;
begin

    -- Makes the next state the current state
    sync_p: process(Rx_Clk, Reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(Rx_Clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Process 2: The Combinational Logic (Next State Logic)
    -- This determines where we go based on inputs.
    comb_p: process(current_state, Rx_Valid,Rx_Data,Counter)
    begin

       
        next_state <= current_state; -- Default
        case current_state is
            when IDLE =>
                if Rx_Valid = '1' and Rx_Data = 0xAA then
                    next_state <= Preamble;
                end if;

            when Praemble =>
                if Rx_Data /= 0xAA then 
                    next_state <= IDLE;   
                elsif Rx_Data=0xAA and Counter > 5 then
                    next_state <= Start_Frame;
                end if;
            when Start_Frame =>
                if Rx_Data /= 0xAB then 
                    next_state <= IDLE;   
                else Rx_Data=0xAB and Counter > 6 then
                    next_state <= Destionation_MAC;
                end if; 
            when Destionation_MAC =>
                if count = 13 then 
                    next_state <= Source_MAC;
                end if;    
            when Source_MAC =>
                if count = 19 then 
                    next_state <= Ethernet_Length;
                end if; 
            when Ethernet_Length =>
                if count = 21
                    next_state <= Payload;
                end if;
            when Payload
                if count =(21+ )

            when others =>
                next_state <= IDLE;
        end case;
    end process;

end architecture;



