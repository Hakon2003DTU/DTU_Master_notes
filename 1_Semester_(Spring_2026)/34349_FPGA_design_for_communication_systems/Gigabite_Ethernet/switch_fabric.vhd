library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity switch_fabric is
    port (
        -- Inputs from FCS blocks
        En_Data_out_1   : in  std_logic;
        En_Data_out_2   : in  std_logic;
        En_Data_out_3   : in  std_logic;
        En_Data_out_4   : in  std_logic;

        Dst_Port_out_1  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_2  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_3  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_4  : in  std_logic_vector(2 downto 0);

        Data_out_1      : in  std_logic_vector(7 downto 0);
        Data_out_2      : in  std_logic_vector(7 downto 0);
        Data_out_3      : in  std_logic_vector(7 downto 0);
        Data_out_4      : in  std_logic_vector(7 downto 0);

        -- Outputs to TX side
        Tx_Data_1       : out std_logic_vector(7 downto 0);
        Tx_Valid_1      : out std_logic;
        Tx_Data_2       : out std_logic_vector(7 downto 0);
        Tx_Valid_2      : out std_logic;
        Tx_Data_3       : out std_logic_vector(7 downto 0);
        Tx_Valid_3      : out std_logic;
        Tx_Data_4       : out std_logic_vector(7 downto 0);
        Tx_Valid_4      : out std_logic
    );
end switch_fabric;

architecture behavioral of switch_fabric is

    signal Grant_Out_1   : std_logic_vector(1 downto 0);
    signal Grant_Valid_1 : std_logic;
    signal Grant_Out_2   : std_logic_vector(1 downto 0);
    signal Grant_Valid_2 : std_logic;
    signal Grant_Out_3   : std_logic_vector(1 downto 0);
    signal Grant_Valid_3 : std_logic;
    signal Grant_Out_4   : std_logic_vector(1 downto 0);
    signal Grant_Valid_4 : std_logic;

begin

    U_SCHEDULER : entity work.scheduler
        port map (
            En_Data_out_1  => En_Data_out_1,
            En_Data_out_2  => En_Data_out_2,
            En_Data_out_3  => En_Data_out_3,
            En_Data_out_4  => En_Data_out_4,

            Dst_Port_out_1 => Dst_Port_out_1,
            Dst_Port_out_2 => Dst_Port_out_2,
            Dst_Port_out_3 => Dst_Port_out_3,
            Dst_Port_out_4 => Dst_Port_out_4,

            Grant_Out_1    => Grant_Out_1,
            Grant_Valid_1  => Grant_Valid_1,
            Grant_Out_2    => Grant_Out_2,
            Grant_Valid_2  => Grant_Valid_2,
            Grant_Out_3    => Grant_Out_3,
            Grant_Valid_3  => Grant_Valid_3,
            Grant_Out_4    => Grant_Out_4,
            Grant_Valid_4  => Grant_Valid_4
        );

    U_CROSSBAR : entity work.crossbar
        port map (
            Data_out_1     => Data_out_1,
            Data_out_2     => Data_out_2,
            Data_out_3     => Data_out_3,
            Data_out_4     => Data_out_4,

            En_Data_out_1  => En_Data_out_1,
            En_Data_out_2  => En_Data_out_2,
            En_Data_out_3  => En_Data_out_3,
            En_Data_out_4  => En_Data_out_4,

            Grant_Out_1    => Grant_Out_1,
            Grant_Valid_1  => Grant_Valid_1,
            Grant_Out_2    => Grant_Out_2,
            Grant_Valid_2  => Grant_Valid_2,
            Grant_Out_3    => Grant_Out_3,
            Grant_Valid_3  => Grant_Valid_3,
            Grant_Out_4    => Grant_Out_4,
            Grant_Valid_4  => Grant_Valid_4,

            Tx_Data_1      => Tx_Data_1,
            Tx_Valid_1     => Tx_Valid_1,
            Tx_Data_2      => Tx_Data_2,
            Tx_Valid_2     => Tx_Valid_2,
            Tx_Data_3      => Tx_Data_3,
            Tx_Valid_3     => Tx_Valid_3,
            Tx_Data_4      => Tx_Data_4,
            Tx_Valid_4     => Tx_Valid_4
        );

end behavioral;
