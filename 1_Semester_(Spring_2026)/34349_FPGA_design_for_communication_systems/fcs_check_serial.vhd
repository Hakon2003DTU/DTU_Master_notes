library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fcs_check_serial is
  port ( 
    clk            : in std_logic; 			-- system clock
    reset          : in std_logic; 			-- asynchronous reset
    start_of_frame : in std_logic; 			-- arrival of the first byte.
    end_of_frame   : in std_logic; 			-- arrival of the first byte in FCS.
    data_in 	   : in std_logic_vector(7 downto 0); 	-- input data.
    fcs_error      : out std_logic 			-- indicates an error.
  );
end fcs_check_serial;
architecture behavioral of fcs_check_serial is
  signal Reg           : std_logic_vector(31 downto 0); -- The 32 registers used to store data
  signal Counter       : unsigned(1 downto 0);		-- Counter that counts number of times 8 bits have been sendt
  signal Data_insert   : std_logic_vector(7 downto 0);	-- Data that should be inserted
  signal Checksum_Start: std_logic;			-- checksum goes high when the checksum is being inserted

begin

	-- Data insert process (The first and last 32 bits has due to the way  )
	process(start_of_frame,end_of_frame,data_in,Counter)
	Begin
		if(start_of_frame = '1' or end_of_frame = '1' or Counter < 3) then
			Data_insert <= not data_in;
		else
			Data_insert <= data_in;
		end if;
	end process;

	-- Parallel FCS setup
	process(clk,reset)
	Begin
		if (reset = '1') then -- reset the registor and the 
			Reg     <= (others => '0');
      			Counter <= (others => '0');
			fcs_error   <= '1';

		elsif rising_edge(clk) then
			if (end_of_frame = '1') then
				Checksum_Start <= '1';
			end if;
		
			if (start_of_frame = '1' or end_of_frame = '1') then 
				Counter <= (others => '0');
			elsif(Counter < 3) then 
				Counter <= Counter + 1;
			end if;

			Reg(0) <= Reg(24) xor Reg(30) xor Data_insert(0);
			Reg(1) <= Reg(24) xor Reg(25) xor Reg(30) xor Reg(31) xor Data_insert(1);
			Reg(2) <= Reg(24) xor Reg(25) xor Reg(26) xor Reg(30) xor Reg(31) xor Data_insert(2);
			Reg(3) <= Reg(25) xor Reg(26) xor Reg(27) xor Reg(31) xor Data_insert(3);
			Reg(4) <= Reg(24) xor Reg(26) xor Reg(27) xor Reg(28) xor Reg(30) xor Data_insert(4);
			Reg(5) <= Reg(24) xor Reg(25) xor Reg(27) xor Reg(28) xor Reg(29) xor Reg(30) xor Reg(31) xor Data_insert(5);
			Reg(6) <= Reg(25) xor Reg(26) xor Reg(28) xor Reg(29) xor Reg(30) xor Reg(31) xor Data_insert(6);
			Reg(7) <= Reg(24) xor Reg(26) xor Reg(27) xor Reg(29) xor Reg(31) xor Data_insert(7);
			Reg(8) <= Reg(0) xor Reg(24) xor Reg(25) xor Reg(27) xor Reg(28);
			Reg(9) <= Reg(1) xor Reg(25) xor Reg(26) xor Reg(28) xor Reg(29);
			Reg(10) <= Reg(2) xor Reg(24) xor Reg(26) xor Reg(27) xor Reg(29);
			Reg(11) <= Reg(3) xor Reg(24) xor Reg(25) xor Reg(27) xor Reg(28);
			Reg(12) <= Reg(4) xor Reg(24) xor Reg(25) xor Reg(26) xor Reg(28) xor Reg(29) xor Reg(30);
			Reg(13) <= Reg(5) xor Reg(25) xor Reg(26) xor Reg(27) xor Reg(29) xor Reg(30) xor Reg(31);
			Reg(14) <= Reg(6) xor Reg(26) xor Reg(27) xor Reg(28) xor Reg(30) xor Reg(31);
			Reg(15) <= Reg(7) xor Reg(27) xor Reg(28) xor Reg(29) xor Reg(31);
			Reg(16) <= Reg(8) xor Reg(24) xor Reg(28) xor Reg(29);
			Reg(17) <= Reg(9) xor Reg(25) xor Reg(29) xor Reg(30);
			Reg(18) <= Reg(10) xor Reg(26) xor Reg(30) xor Reg(31);
			Reg(19) <= Reg(11) xor Reg(27) xor Reg(31);
			Reg(20) <= Reg(12) xor Reg(28);
			Reg(21) <= Reg(13) xor Reg(29);
			Reg(22) <= Reg(14) xor Reg(24);
			Reg(23) <= Reg(15) xor Reg(24) xor Reg(25) xor Reg(30);
			Reg(24) <= Reg(16) xor Reg(25) xor Reg(26) xor Reg(31);
			Reg(25) <= Reg(17) xor Reg(26) xor Reg(27);
			Reg(26) <= Reg(18) xor Reg(24) xor Reg(27) xor Reg(28) xor Reg(30);
			Reg(27) <= Reg(19) xor Reg(25) xor Reg(28) xor Reg(29) xor Reg(31);
			Reg(28) <= Reg(20) xor Reg(26) xor Reg(29) xor Reg(30);
			Reg(29) <= Reg(21) xor Reg(27) xor Reg(30) xor Reg(31);
			Reg(30) <= Reg(22) xor Reg(28) xor Reg(31);
			Reg(31) <= Reg(23) xor Reg(29);
		
			if (Checksum_Start = '1' and Counter = 3) then
            		if (Reg = X"00000000") then
                		fcs_error <= '0';
            		else
                		fcs_error <= '1';
            		end if;
            	Checksum_Start <= '0'; 
        	end if;
		end if;
	end process;
end behavioral;
