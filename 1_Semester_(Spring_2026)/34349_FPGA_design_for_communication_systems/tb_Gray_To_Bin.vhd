


library ieee;
use ieee.std_logic_1164.all;

entity tb_Gray_To_Bin is
end tb_Gray_To_Bin;

architecture behavior of tb_Gray_To_Bin is

  -- Component used in testbench
  component Gray_To_Bin
    port(
         G : in  std_logic_vector(3 downto 0);
         B : out std_logic_vector(3 downto 0)
         );
  end component;

  -- Signals to connect to the component under test
  signal Test_B : std_logic_vector(3 downto 0) := x"0";
  signal Test_G : std_logic_vector(3 downto 0) := x"0";

begin

  -- Instantiate the Unit Under Test (UUT)
  Comp1 : Gray_To_Bin port map (
            B => Test_B,
            G => Test_G
          );

  -- Simulation Process
  Sim : process
  begin
    Test_G <= "0000"; wait for 1 ns;
    Test_G <= "0001"; wait for 1 ns;
    Test_G <= "0011"; wait for 1 ns;
    Test_G <= "0010"; wait for 1 ns;
    Test_G <= "0110"; wait for 1 ns;		
    Test_G <= "0111"; wait for 1 ns;	
    Test_G <= "0101"; wait for 1 ns;  
    Test_G <= "0100"; wait for 1 ns;
    Test_G <= "1100"; wait for 1 ns;
    Test_G <= "1101"; wait for 1 ns;
    Test_G <= "1111"; wait for 1 ns;
    Test_G <= "1110"; wait for 1 ns;
    Test_G <= "1010"; wait for 1 ns;
    Test_G <= "1011"; wait for 1 ns;
    Test_G <= "1001"; wait for 1 ns;
    Test_G <= "1000"; wait for 1 ns;
    wait; -- Stop the simulation
  end process;

end behavior;








