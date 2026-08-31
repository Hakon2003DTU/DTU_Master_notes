---------------------------------------------------------------------
-- Componant  : Scheduler
-- Description: Combinational scheduler for the FIFO_And_Crossbar.
--              For each of the four output columns it picks the
--              row whose crosspoint FIFO is the fullest (so that the
--              FIFO closest to overflow drains first), and breaks
--              ties on lower row index.
--
--              The score for row i at column j is:
--                  score(i,j) = rdusedw(i,j)
--                             + ('1' if En_Data_i='1' and
--                                Dst_Port_i = j  -- arriving here too)
--                                else '0')
--              i.e., the FIFO's current byte count plus a small
--              bonus when the source FCS is currently writing into
--              that same FIFO. The bonus only matters when two FIFOs
--              are tied on rdusedw.
--
--              A grant is only issued when the winning FIFO is
--              actually non-empty (rdusedw > 0); otherwise the
--              column stays idle this cycle.
--
--              rdusedw_grid packing matches FIFO_And_Crossbar:
--                  rdusedw(i, j) lives at
--                  rdusedw_grid( (i*4+j)*12+11 downto (i*4+j)*12 )
--
-- Made by    : Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scheduler is
    port (
        -- Inputs from the 4 FCS blocks (used as 'incoming-byte' hints)
        En_Data_out_1   : in  std_logic;
        En_Data_out_2   : in  std_logic;
        En_Data_out_3   : in  std_logic;
        En_Data_out_4   : in  std_logic;

        Dst_Port_out_1  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_2  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_3  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_4  : in  std_logic_vector(2 downto 0);

        -- 16 FIFO fill counters from the crossbar (flattened 4x4 grid)
        rdusedw_grid    : in  std_logic_vector(191 downto 0);

        -- Grants per output column
        Grant_Out_1     : out std_logic_vector(1 downto 0);
        Grant_Valid_1   : out std_logic;

        Grant_Out_2     : out std_logic_vector(1 downto 0);
        Grant_Valid_2   : out std_logic;

        Grant_Out_3     : out std_logic_vector(1 downto 0);
        Grant_Valid_3   : out std_logic;

        Grant_Out_4     : out std_logic_vector(1 downto 0);
        Grant_Valid_4   : out std_logic
    );
end Scheduler;

architecture behavioral of Scheduler is

    -- Pack the per-FCS scalars for indexed access in the loop
    type en_arr_t   is array (0 to 3) of std_logic;
    type dst_arr_t  is array (0 to 3) of std_logic_vector(2 downto 0);
    type sel_arr_t  is array (0 to 3) of std_logic_vector(1 downto 0);

    signal en_arr    : en_arr_t;
    signal dst_arr   : dst_arr_t;

    -- Helper: pull rdusedw(i, j) out of the flat grid as unsigned
    function get_usedw(rdusedw_grid : std_logic_vector(191 downto 0);
                       i, j : integer) return unsigned is
    begin
        return unsigned(rdusedw_grid( (i*4 + j)*12 + 11 downto (i*4 + j)*12 ));
    end function;

begin

    -- Pack inputs into arrays
    en_arr(0)  <= En_Data_out_1;
    en_arr(1)  <= En_Data_out_2;
    en_arr(2)  <= En_Data_out_3;
    en_arr(3)  <= En_Data_out_4;

    dst_arr(0) <= Dst_Port_out_1;
    dst_arr(1) <= Dst_Port_out_2;
    dst_arr(2) <= Dst_Port_out_3;
    dst_arr(3) <= Dst_Port_out_4;

    ---------------------------------------------------------------
    -- Combinational grant computation
    --
    -- For each output column j, we scan rows 0..3, build a 13-bit
    -- 'urgency score' = rdusedw + arrival-bonus, and remember the
    -- row with the highest score that is non-empty. Lower row index
    -- naturally wins ties because we only overwrite max_score on a
    -- strictly greater compare.
    ---------------------------------------------------------------
    process(en_arr, dst_arr, rdusedw_grid)
        variable score      : unsigned(12 downto 0);
        variable max_score  : unsigned(12 downto 0);
        variable max_row    : integer range 0 to 3;
        variable found      : boolean;
        variable grants     : sel_arr_t;
        variable valids     : std_logic_vector(3 downto 0);
        variable usedw_val  : unsigned(11 downto 0);
        variable bonus      : unsigned(12 downto 0);
    begin
        grants := (others => "00");
        valids := (others => '0');

        for j in 0 to 3 loop
            max_score := (others => '0');
            max_row   := 0;
            found     := false;

            for i in 0 to 3 loop
                usedw_val := get_usedw(rdusedw_grid, i, j);

                -- Bonus = 1 when the source FCS is currently writing
                -- a byte into this exact crosspoint
                if en_arr(i) = '1'
                   and to_integer(unsigned(dst_arr(i))) = j then
                    bonus := to_unsigned(1, 13);
                else
                    bonus := (others => '0');
                end if;

                score := resize(usedw_val, 13) + bonus;

                -- Only treat this row as a real candidate when the
                -- FIFO has at least one byte actually queued (we
                -- never grant a read on an empty FIFO, even if the
                -- bonus has bumped its score above zero).
                if usedw_val > 0 and score > max_score then
                    max_score := score;
                    max_row   := i;
                    found     := true;
                end if;
            end loop;

            if found then
                grants(j) := std_logic_vector(to_unsigned(max_row, 2));
                valids(j) := '1';
            else
                grants(j) := "00";
                valids(j) := '0';
            end if;
        end loop;

        -- Drive the discrete output ports
        Grant_Out_1   <= grants(0);
        Grant_Out_2   <= grants(1);
        Grant_Out_3   <= grants(2);
        Grant_Out_4   <= grants(3);

        Grant_Valid_1 <= valids(0);
        Grant_Valid_2 <= valids(1);
        Grant_Valid_3 <= valids(2);
        Grant_Valid_4 <= valids(3);
    end process;

end behavioral;
