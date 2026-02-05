

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_This_is_a_test is
end entity;

architecture sim of tb_This_is_a_test is

    -- Signals to connect to DUT
    signal SW  : std_logic_vector(9 downto 0) := (others => '0');
    signal LED : std_logic_vector(9 downto 0);

begin

    -- DUT instance
    dut : entity work.This_is_a_test
        port map (
            SW  => SW,
            LED => LED
        );

    -- Stimulus + checks
    stim_proc : process
    begin
        -- Test 1: all zeros
        SW <= (others => '0');
        wait for 10 ns;
        assert (LED = SW)
            report "FAIL: LED /= SW for all zeros" severity error;

        -- Test 2: all ones
        SW <= (others => '1');
        wait for 10 ns;
        assert (LED = SW)
            report "FAIL: LED /= SW for all ones" severity error;

        -- Test 3: alternating pattern 1010...
        SW <= "1010101010";
        wait for 10 ns;
        assert (LED = SW)
            report "FAIL: LED /= SW for 1010101010" severity error;

        -- Test 4: another pattern
        SW <= "0101010101";
        wait for 10 ns;
        assert (LED = SW)
            report "FAIL: LED /= SW for 0101010101" severity error;

        -- Test 5: count up a few values using numeric_std
        for i in 0 to 15 loop
            SW <= std_logic_vector(to_unsigned(i, SW'length));
            wait for 10 ns;
            assert (LED = SW)
                report "FAIL: LED /= SW for i=" & integer'image(i) severity error;
        end loop;

        report "All tests PASSED." severity note;
        wait; -- stop the simulation
    end process;

end architecture;






