

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This is a test 

entity This_is_a_test is 
    port (
        SW  : in  std_logic_vector(9 downto 0);
        LED : out std_logic_vector(9 downto 0)
    );
end entity This_is_a_test;

architecture Behavior of This_is_a_test is 
begin

    LED <= SW;

end architecture Behavior;

