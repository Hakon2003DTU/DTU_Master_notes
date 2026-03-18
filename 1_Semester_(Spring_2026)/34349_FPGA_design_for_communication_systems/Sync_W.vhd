

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sync_W is
port (
ptr  : in std_logic_vector(4 downto 0);
Wclk : in std_logic;
Rclk : in std_logic;
sync : out std_logic_vector(4 downto 0)
);
end Sync_W;

architecture behavioral of Sync_W is
 -- Insert signals 
Signal line_1 :std_logic_vector(4 downto 0);
Signal line_2 :std_logic_vector(4 downto 0);
Signal line_3 :std_logic_vector(4 downto 0);
Signal line_4 :std_logic_vector(4 downto 0);

component Bin_To_Gray port (
    B : in std_logic_vector(4 downto 0);
    G : out std_logic_vector(4 downto 0)
);
end component;

component Flip_flop port (
    Input : in std_logic_vector(4 downto 0);
    clk : in std_logic;
    Output : out std_logic_vector(4 downto 0)
);
end component;

component Gray_To_Bin port (
    G : in std_logic_vector(4 downto 0);
    B : out std_logic_vector(4 downto 0)
);
end component;

begin

Comp1 : Bin_To_Gray port map (
            B => ptr,
            G => line_1
          );

Comp2 : Flip_flop port map (
            Input =>line_1,
    	    clk   =>Wclk,
   	    Output=>line_2 
          );

Comp3 : Flip_flop port map (
            Input =>line_2,
    	    clk   =>Rclk,
   	    Output=>line_3 
          );

Comp4 : Flip_flop port map (
            Input =>line_3,
    	    clk   =>Rclk,
   	    Output=>line_4 
          );

 
Comp5 : Gray_To_Bin port map (
            G => line_4,
            B => sync
          );
end behavioral;








