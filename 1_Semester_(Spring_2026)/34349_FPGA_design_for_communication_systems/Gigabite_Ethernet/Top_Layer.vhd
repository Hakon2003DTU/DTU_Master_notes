---------------------------------------------------------------------
-- Componant:   Top_Layer
-- Description: On Rx_Data_1 transition 0xFF -> 0x00, transmit a
--              fixed Ethernet frame on Tx_Data_1 (MSB first).
-- Changes :
-- Hakon
---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MAC_PKG.all;  -- defines t_flag_array, t_mac_array, t_port_array

entity Top_Layer is
    port (
        --Input
        Reset      : in std_logic;
        Rx_Data_1  : in std_logic_vector(7 downto 0);
        Rx_Clk_1   : in std_logic;
        Rx_Valid_1 : in std_logic;
        Rx_Data_2  : in std_logic_vector(7 downto 0);
        Rx_Clk_2   : in std_logic;
        Rx_Valid_2 : in std_logic;
        Rx_Data_3  : in std_logic_vector(7 downto 0);
        Rx_Clk_3   : in std_logic;
        Rx_Valid_3 : in std_logic;
        Rx_Data_4  : in std_logic_vector(7 downto 0);
        Rx_Clk_4   : in std_logic;
        Rx_Valid_4 : in std_logic;
        --Output
        Tx_Clk     : out std_logic;
        Tx_Data_1  : out std_logic_vector(7 downto 0);
        Tx_Valid_1 : out std_logic;
        Tx_Data_2  : out std_logic_vector(7 downto 0);
        Tx_Valid_2 : out std_logic;
        Tx_Data_3  : out std_logic_vector(7 downto 0);
        Tx_Valid_3 : out std_logic;
        Tx_Data_4  : out std_logic_vector(7 downto 0);
        Tx_Valid_4 : out std_logic
    );
end Top_Layer;

architecture behavioral of Top_Layer is

    -- Frame constants (sent MSB first)
    constant Preamble        : std_logic_vector(55 downto 0) := x"AAAAAAAAAAAAAA";
    constant Start_of_Frame  : std_logic_vector(7 downto 0)  := x"AB";
    constant Destination_MAC : std_logic_vector(47 downto 0) := x"000000000002";
    constant Source_MAC      : std_logic_vector(47 downto 0) := x"000000000001";
    constant Ethernetlength  : std_logic_vector(15 downto 0) := x"002E";
    constant FCS_1           : std_logic_vector(31 downto 0) := x"A3338135";

    -- The full frame is a flat vector. Total length in bytes:
    --   Preamble  7
    --   SoF       1
    --   Dst MAC   6
    --   Src MAC   6
    --   Length    2
    --   FCS       4
    --  ----------
    --            26 bytes
    constant FRAME_BYTES : integer := 26;

    constant Frame : std_logic_vector(FRAME_BYTES*8-1 downto 0) :=
        Preamble & Start_of_Frame & Destination_MAC &
        Source_MAC & Ethernetlength & FCS_1;

    -- Transmit state
    signal sending     : std_logic := '0';
    signal byte_index  : integer range 0 to FRAME_BYTES := 0;

    -- Edge detection: remember previous value of Rx_Data_1
    signal Rx_Data_1_prev : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- Drive the transmit clock from the receive clock of port 1
    Tx_Clk <= Rx_Clk_1;

    -- Unused transmit ports held inactive
    Tx_Data_2  <= (others => '0');
    Tx_Valid_2 <= '0';
    Tx_Data_3  <= (others => '0');
    Tx_Valid_3 <= '0';
    Tx_Data_4  <= (others => '0');
    Tx_Valid_4 <= '0';

    ------------------------------------------------------------------
    -- Transmit process
    ------------------------------------------------------------------
    process (Rx_Clk_1, Reset)
    begin
        if Reset = '1' then
            sending        <= '0';
            byte_index     <= 0;
            Tx_Data_1      <= (others => '0');
            Tx_Valid_1     <= '0';
            Rx_Data_1_prev <= (others => '0');

        elsif rising_edge(Rx_Clk_1) then

            -- Detect the 0xFF -> 0x00 transition on Rx_Data_1
            if (sending = '0') and
               (Rx_Data_1_prev = x"FF") and (Rx_Data_1 = x"00") then
                sending    <= '1';
                byte_index <= 0;
            end if;

            -- Output the frame, one byte per clock, MSB first
            if sending = '1' then
                if byte_index < FRAME_BYTES then
                    -- Slice the next byte off the top of the frame vector.
                    -- byte 0 = MSB byte (bits 207..200), byte 1 next, etc.
                    Tx_Data_1 <= Frame(
                        (FRAME_BYTES - byte_index)*8 - 1
                        downto
                        (FRAME_BYTES - byte_index - 1)*8 );
                    Tx_Valid_1 <= '1';
                    byte_index <= byte_index + 1;
                else
                    -- Frame complete
                    Tx_Data_1  <= (others => '0');
                    Tx_Valid_1 <= '0';
                    sending    <= '0';
                    byte_index <= 0;
                end if;
            else
                Tx_Data_1  <= (others => '0');
                Tx_Valid_1 <= '0';
            end if;

            -- Update edge-detection register
            Rx_Data_1_prev <= Rx_Data_1;

        end if;
    end process;

end behavioral;
