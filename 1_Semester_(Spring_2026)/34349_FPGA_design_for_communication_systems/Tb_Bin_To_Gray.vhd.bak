
library ieee;
use ieee.std_logic_1164.all;

entity tb_Bin_To_Gray is
end tb_Bin_To_Gray;

architecture behavior of tb_Bin_To_Gray is

  -- Component used in testbench
  component Bin_To_Gray
    port(
         B : in  std_logic_vector(3 downto 0);
         G : out std_logic_vector(3 downto 0)
         );
  end component;

  -- Signals to connect to the component under test
  signal Test_B : std_logic_vector(3 downto 0) := x"0";
  signal Test_G : std_logic_vector(3 downto 0) := x"0";

begin

  -- Instantiate the Unit Under Test (UUT)
  Comp1 : Bin_To_Gray port map (
            B => Test_B,
            G => Test_G
          );

  -- Simulation Process
  Sim : process
  begin
    Test_B <= x"0"; wait for 1 ns;
    Test_B <= x"1"; wait for 1 ns;
    Test_B <= x"2"; wait for 1 ns;
    Test_B <= x"3"; wait for 1 ns;
    Test_B <= x"4"; wait for 1 ns;		
    Test_B <= x"5"; wait for 1 ns;	
    Test_B <= x"6"; wait for 1 ns;  
    Test_B <= x"7"; wait for 1 ns;
    Test_B <= x"8"; wait for 1 ns;
    Test_B <= x"9"; wait for 1 ns;
    Test_B <= x"A"; wait for 1 ns;
    Test_B <= x"B"; wait for 1 ns;
    Test_B <= x"C"; wait for 1 ns;
    Test_B <= x"D"; wait for 1 ns;
    Test_B <= x"E"; wait for 1 ns;
    Test_B <= x"F"; wait for 1 ns;
    wait; -- Stop the simulation
  end process;

end behavior;