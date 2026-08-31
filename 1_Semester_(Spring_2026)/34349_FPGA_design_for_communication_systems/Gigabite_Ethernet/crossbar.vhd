library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity crossbar is
    port (
        -- Data from FCS blocks
        Data_out_1      : in  std_logic_vector(7 downto 0);
        Data_out_2      : in  std_logic_vector(7 downto 0);
        Data_out_3      : in  std_logic_vector(7 downto 0);
        Data_out_4      : in  std_logic_vector(7 downto 0);

        En_Data_out_1   : in  std_logic;
        En_Data_out_2   : in  std_logic;
        En_Data_out_3   : in  std_logic;
        En_Data_out_4   : in  std_logic;

        -- Scheduler grants
        Grant_Out_1     : in  std_logic_vector(1 downto 0);
        Grant_Valid_1   : in  std_logic;

        Grant_Out_2     : in  std_logic_vector(1 downto 0);
        Grant_Valid_2   : in  std_logic;

        Grant_Out_3     : in  std_logic_vector(1 downto 0);
        Grant_Valid_3   : in  std_logic;

        Grant_Out_4     : in  std_logic_vector(1 downto 0);
        Grant_Valid_4   : in  std_logic;

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
end crossbar;

architecture behavioral of crossbar is
begin
    process(Data_out_1, Data_out_2, Data_out_3, Data_out_4,
            En_Data_out_1, En_Data_out_2, En_Data_out_3, En_Data_out_4,
            Grant_Out_1, Grant_Valid_1,
            Grant_Out_2, Grant_Valid_2,
            Grant_Out_3, Grant_Valid_3,
            Grant_Out_4, Grant_Valid_4)
    begin
        -- defaults
        Tx_Data_1  <= (others => '0');
        Tx_Valid_1 <= '0';
        Tx_Data_2  <= (others => '0');
        Tx_Valid_2 <= '0';
        Tx_Data_3  <= (others => '0');
        Tx_Valid_3 <= '0';
        Tx_Data_4  <= (others => '0');
        Tx_Valid_4 <= '0';

        -- Output 1
        if Grant_Valid_1 = '1' then
            case Grant_Out_1 is
                when "00" => Tx_Data_1 <= Data_out_1; Tx_Valid_1 <= En_Data_out_1;
                when "01" => Tx_Data_1 <= Data_out_2; Tx_Valid_1 <= En_Data_out_2;
                when "10" => Tx_Data_1 <= Data_out_3; Tx_Valid_1 <= En_Data_out_3;
                when "11" => Tx_Data_1 <= Data_out_4; Tx_Valid_1 <= En_Data_out_4;
                when others => null;
            end case;
        end if;

        -- Output 2
        if Grant_Valid_2 = '1' then
            case Grant_Out_2 is
                when "00" => Tx_Data_2 <= Data_out_1; Tx_Valid_2 <= En_Data_out_1;
                when "01" => Tx_Data_2 <= Data_out_2; Tx_Valid_2 <= En_Data_out_2;
                when "10" => Tx_Data_2 <= Data_out_3; Tx_Valid_2 <= En_Data_out_3;
                when "11" => Tx_Data_2 <= Data_out_4; Tx_Valid_2 <= En_Data_out_4;
                when others => null;
            end case;
        end if;

        -- Output 3
        if Grant_Valid_3 = '1' then
            case Grant_Out_3 is
                when "00" => Tx_Data_3 <= Data_out_1; Tx_Valid_3 <= En_Data_out_1;
                when "01" => Tx_Data_3 <= Data_out_2; Tx_Valid_3 <= En_Data_out_2;
                when "10" => Tx_Data_3 <= Data_out_3; Tx_Valid_3 <= En_Data_out_3;
                when "11" => Tx_Data_3 <= Data_out_4; Tx_Valid_3 <= En_Data_out_4;
                when others => null;
            end case;
        end if;

        -- Output 4
        if Grant_Valid_4 = '1' then
            case Grant_Out_4 is
                when "00" => Tx_Data_4 <= Data_out_1; Tx_Valid_4 <= En_Data_out_1;
                when "01" => Tx_Data_4 <= Data_out_2; Tx_Valid_4 <= En_Data_out_2;
                when "10" => Tx_Data_4 <= Data_out_3; Tx_Valid_4 <= En_Data_out_3;
                when "11" => Tx_Data_4 <= Data_out_4; Tx_Valid_4 <= En_Data_out_4;
                when others => null;
            end case;
        end if;
    end process;
end behavioral;


