


library ieee;
use ieee.std_logic_1164.all;

entity fcs_check_parallel_tb is
end fcs_check_parallel_tb;

architecture behavior of fcs_check_parallel_tb is

  -- componant used in testbench
  component fcs_check_parallel
    port(clk            : in  std_logic;
         reset          : in  std_logic;
         start_of_frame : in  std_logic;
         end_of_frame   : in  std_logic;
         data_in 	: in  std_logic_vector(7 downto 0);
         fcs_error      : out std_logic);
  end component;
  -- Signals
  signal Test_clk            : std_logic := '0';
  signal Test_reset          : std_logic := '0';
  signal Test_start_of_frame : std_logic := '0';
  signal Test_end_of_frame   : std_logic := '0';
  signal Test_data_in        : std_logic_vector(7 downto 0) := x"00";
  signal Test_fcs_error      : std_logic;

  -- Clock Speed
  constant clk_period : time := 1 ns;

  --  Ethernet packet (FCS checksum E6 C5 3D B2)
  constant Ethernet_packet : std_logic_vector(511 downto 0) := x"00_10_A4_7B_EA_80_00_12_34_56_78_90_08_00_45_00_00_2E_B3_FE_00_00_80_11_05_40_C0_A8_00_2C" &
                                                   x"C0_A8_00_04_04_00_04_00_00_1A_2D_E8_00_01_02_03_04_05_06_07_08_09_0A_0B_0C_0D_0E_0F_10_11_E6_C5_3D_B2";

begin

    Comp1 : fcs_check_parallel port map (
    clk            => Test_clk,
    reset          => Test_reset,
    start_of_frame => Test_start_of_frame,
    end_of_frame   => Test_end_of_frame,
    data_in        => Test_data_in,
    fcs_error      => Test_fcs_error
    );

  -- Clock generation
  Clk_Generator : process
  begin
    Test_clk <= '0';
    wait for clk_period / 2;
    Test_clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Data_Simulation
  Data_Sim : process
  begin
    -- Start by reseting everything
    Test_reset <= '1';
    wait for clk_period;
    Test_reset <= '0';
    -- Begin sending the data 
    for i in 63 downto 0 loop
      if i = 63 then
        Test_start_of_frame <= '1';
      else
        Test_start_of_frame <= '0';
      end if;

      Test_data_in <= Ethernet_packet(i*8+7 downto i*8);

      -- goes high when 32 bits remain(FCS)
      if i = 3 then
        Test_end_of_frame <= '1';
      else
        Test_end_of_frame <= '0';
      end if;
      wait for clk_period;
    end loop;
    Test_data_in <= x"00";

    wait;
  end process;

end;





