library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_switch_fabric is
end tb_switch_fabric;

architecture Behavioral of tb_switch_fabric is

    -- Inputs to DUT
    signal test_En_Data_out_1   : std_logic := '0';
    signal test_En_Data_out_2   : std_logic := '0';
    signal test_En_Data_out_3   : std_logic := '0';
    signal test_En_Data_out_4   : std_logic := '0';

    signal test_Dst_Port_out_1  : std_logic_vector(2 downto 0) := (others => '0');
    signal test_Dst_Port_out_2  : std_logic_vector(2 downto 0) := (others => '0');
    signal test_Dst_Port_out_3  : std_logic_vector(2 downto 0) := (others => '0');
    signal test_Dst_Port_out_4  : std_logic_vector(2 downto 0) := (others => '0');

    signal test_Data_out_1      : std_logic_vector(7 downto 0) := (others => '0');
    signal test_Data_out_2      : std_logic_vector(7 downto 0) := (others => '0');
    signal test_Data_out_3      : std_logic_vector(7 downto 0) := (others => '0');
    signal test_Data_out_4      : std_logic_vector(7 downto 0) := (others => '0');

    -- Outputs from DUT
    signal test_Tx_Data_1       : std_logic_vector(7 downto 0);
    signal test_Tx_Valid_1      : std_logic;
    signal test_Tx_Data_2       : std_logic_vector(7 downto 0);
    signal test_Tx_Valid_2      : std_logic;
    signal test_Tx_Data_3       : std_logic_vector(7 downto 0);
    signal test_Tx_Valid_3      : std_logic;
    signal test_Tx_Data_4       : std_logic_vector(7 downto 0);
    signal test_Tx_Valid_4      : std_logic;

begin

    DUT: entity work.switch_fabric
        port map (
            En_Data_out_1  => test_En_Data_out_1,
            En_Data_out_2  => test_En_Data_out_2,
            En_Data_out_3  => test_En_Data_out_3,
            En_Data_out_4  => test_En_Data_out_4,

            Dst_Port_out_1 => test_Dst_Port_out_1,
            Dst_Port_out_2 => test_Dst_Port_out_2,
            Dst_Port_out_3 => test_Dst_Port_out_3,
            Dst_Port_out_4 => test_Dst_Port_out_4,

            Data_out_1     => test_Data_out_1,
            Data_out_2     => test_Data_out_2,
            Data_out_3     => test_Data_out_3,
            Data_out_4     => test_Data_out_4,

            Tx_Data_1      => test_Tx_Data_1,
            Tx_Valid_1     => test_Tx_Valid_1,
            Tx_Data_2      => test_Tx_Data_2,
            Tx_Valid_2     => test_Tx_Valid_2,
            Tx_Data_3      => test_Tx_Data_3,
            Tx_Valid_3     => test_Tx_Valid_3,
            Tx_Data_4      => test_Tx_Data_4,
            Tx_Valid_4     => test_Tx_Valid_4
        );

    stimulus : process
    begin
	
   	test_En_Data_out_1 <='0';
       	test_En_Data_out_2 <='0';
        test_En_Data_out_3 <='0';
        test_En_Data_out_4 <='0';

        wait for 20 ns;



        En_Data_out_1  <= '0';
        Dst_Port_out_1 <= "000";
        Data_out_1     <= x"00";

        wait for 20 ns;

        En_Data_out_1  <= '1';
        Dst_Port_out_1 <= "001";
        Data_out_1     <= x"A1";

        En_Data_out_2  <= '1';
        Dst_Port_out_2 <= "010";
        Data_out_2     <= x"B2";

        En_Data_out_3  <= '1';
        Dst_Port_out_3 <= "011";
        Data_out_3     <= x"C3";

        En_Data_out_4  <= '1';
        Dst_Port_out_4 <= "100";
        Data_out_4     <= x"D4";

        wait for 20 ns;

        En_Data_out_1  <= '0';
        En_Data_out_2  <= '0';
        En_Data_out_3  <= '0';
        En_Data_out_4  <= '0';

        Dst_Port_out_1 <= "000";
        Dst_Port_out_2 <= "000";
        Dst_Port_out_3 <= "000";
        Dst_Port_out_4 <= "000";

        Data_out_1     <= x"00";
        Data_out_2     <= x"00";
        Data_out_3     <= x"00";
        Data_out_4     <= x"00";

        wait for 20 ns;


        wait;
    end process;

end Behavioral;
