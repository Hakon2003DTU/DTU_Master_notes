



library ieee;
use ieee.std_logic_1164.all;

entity tb_Sync_R is
end tb_Sync_R;

architecture behavior of tb_Sync_R is

  -- componant used in testbench
  component Sync_R
    port (
	ptr  : in std_logic_vector(3 downto 0);
	Wclk : in std_logic;
	Rclk : in std_logic;
	sync : out std_logic_vector(3 downto 0)
	);
  end component;
  -- Signals

	signal Test_ptr  : std_logic_vector(3 downto 0):= x"0";
	signal Test_Wclk : std_logic:= '0';
	signal Test_Rclk : std_logic:= '0';
	signal Test_sync : std_logic_vector(3 downto 0):= x"0";


  -- Clock Speed
  constant Wclk_period_1 : time := 1 ns;
  constant Rclk_period_1 : time := 3 ns;
  


begin

    Comp1 : Sync_R port map (
    ptr            => Test_ptr,
    Wclk           => Test_Wclk,
    Rclk 	   => Test_Rclk,
    sync           => Test_sync
    );

  -- Clock generation
  WClk_Generator : process
  begin
    Test_Wclk <= '0';
    wait for Wclk_period_1 / 2;
    Test_Wclk <= '1';
    wait for Wclk_period_1 / 2;
  end process;


  RClk_Generator : process
  begin
    Test_Rclk <= '0';
    wait for Rclk_period_1 / 2;
    Test_Rclk <= '1';
    wait for Rclk_period_1 / 2;
  end process;


  -- Data_Simulation
 Data_Sim : process
  begin
	wait for 20 ns;    
	Test_ptr<=X"5";
	wait for 20 ns;
	Test_ptr<=X"6";
	wait for 20 ns;
	Test_ptr<=X"7";
	wait for 20 ns;    
	Test_ptr<=X"8";
	wait for 20 ns;
	Test_ptr<=X"9";
	wait for 20 ns;
	Test_ptr<=X"A";
	



    wait;
  end process;
end;




