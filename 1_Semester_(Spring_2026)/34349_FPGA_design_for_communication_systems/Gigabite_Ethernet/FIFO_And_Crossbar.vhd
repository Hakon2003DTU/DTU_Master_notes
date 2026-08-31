---------------------------------------------------------------------
-- Componant  : FIFO_And_Crossbar
-- Description: 4 x 4 crossbar with one dual-clock FIFO at every
--              crosspoint - 16 FIFOs in total.
--
--              Row i is the byte stream coming from FCS i. Column j
--              is the wire going out to Tx port j. A byte arriving
--              on input i with Dst_Port = j is written into
--              FIFO(i, j); the Scheduler then picks which row drives
--              each output column via the Grant_Out_X / Grant_Valid_X
--              bus.
--
--              Broadcast: Dst_Port = "111" replicates the byte into
--              all four FIFOs of row i, so every output port gets its
--              own copy that drains independently.
--
--              Status output: rdusedw_grid is a 192-bit packed vector
--              carrying the 12-bit fill counter of every FIFO. The
--              packing is contiguous - bits ((i*4+j)*12+11 downto
--              (i*4+j)*12) hold the rdusedw of FIFO(i, j). The
--              Scheduler unpacks the same scheme.
--
--              Read latency assumption: showahead FIFO mode. The
--              head of the selected FIFO is on q before Grant_Valid
--              is asserted; the rdreq advances to the next byte at
--              the same clock edge. If your FIFO is in normal mode,
--              register Tx_Valid by one Tx_Clk in Top_crossbar.
--
--              The instantiated FIFO is the same Altera/Intel
--              dual-clock megafunction used by FCS.vhd. With a
--              12-bit usedw it holds up to 4096 bytes, comfortably
--              above the 3036-byte (= 2 x max-frame) requirement.
--
-- Made by    : Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_And_Crossbar is
    port (
        Reset       : in  std_logic;
        Tx_Clk      : in  std_logic;

        -- One write clock per input port (each FCS has its own Rx_Clk)
        Rx_Clk_1    : in  std_logic;
        Rx_Clk_2    : in  std_logic;
        Rx_Clk_3    : in  std_logic;
        Rx_Clk_4    : in  std_logic;

        -- Byte streams from the four FCS modules
        Data_in_1   : in  std_logic_vector(7 downto 0);
        Data_in_2   : in  std_logic_vector(7 downto 0);
        Data_in_3   : in  std_logic_vector(7 downto 0);
        Data_in_4   : in  std_logic_vector(7 downto 0);

        Dst_Port_1  : in  std_logic_vector(2 downto 0);
        Dst_Port_2  : in  std_logic_vector(2 downto 0);
        Dst_Port_3  : in  std_logic_vector(2 downto 0);
        Dst_Port_4  : in  std_logic_vector(2 downto 0);

        En_Data_1   : in  std_logic;
        En_Data_2   : in  std_logic;
        En_Data_3   : in  std_logic;
        En_Data_4   : in  std_logic;

        -- Grants from the Scheduler (one per output column)
        Grant_Out_1 : in  std_logic_vector(1 downto 0);
        Grant_Out_2 : in  std_logic_vector(1 downto 0);
        Grant_Out_3 : in  std_logic_vector(1 downto 0);
        Grant_Out_4 : in  std_logic_vector(1 downto 0);

        Grant_Valid_1 : in std_logic;
        Grant_Valid_2 : in std_logic;
        Grant_Valid_3 : in std_logic;
        Grant_Valid_4 : in std_logic;

        -- Outgoing byte streams to the four Tx ports
        Tx_Data_1   : out std_logic_vector(7 downto 0);
        Tx_Data_2   : out std_logic_vector(7 downto 0);
        Tx_Data_3   : out std_logic_vector(7 downto 0);
        Tx_Data_4   : out std_logic_vector(7 downto 0);

        -- 16 x 12-bit FIFO fill counters packed: ((i*4+j)*12+11..(i*4+j)*12)
        rdusedw_grid : out std_logic_vector(191 downto 0)
    );
end FIFO_And_Crossbar;

architecture behavioral of FIFO_And_Crossbar is

    -- The same dual-clock FIFO megafunction used inside FCS.vhd
    component FIFO port (
        aclr      : in  std_logic := '0';
        data      : in  std_logic_vector(7 downto 0);
        rdclk     : in  std_logic;
        rdreq     : in  std_logic;
        wrclk     : in  std_logic;
        wrreq     : in  std_logic;
        q         : out std_logic_vector(7 downto 0);
        rdempty   : out std_logic;
        rdusedw   : out std_logic_vector(11 downto 0);
        wrfull    : out std_logic;
        wrusedw   : out std_logic_vector(11 downto 0)
    );
    end component;

    -- 4x4 grids of byte / single-bit signals
    type byte_grid_t  is array (0 to 3, 0 to 3) of std_logic_vector(7 downto 0);
    type bit_grid_t   is array (0 to 3, 0 to 3) of std_logic;
    type usedw_grid_t is array (0 to 3, 0 to 3) of std_logic_vector(11 downto 0);

    type byte_array_t is array (0 to 3) of std_logic_vector(7 downto 0);
    type port_array_t is array (0 to 3) of std_logic_vector(2 downto 0);
    type clk_array_t  is array (0 to 3) of std_logic;
    type sel_array_t  is array (0 to 3) of std_logic_vector(1 downto 0);

    signal q_grid     : byte_grid_t;
    signal empty_grid : bit_grid_t;
    signal wrreq_grid : bit_grid_t;
    signal rdreq_grid : bit_grid_t;
    signal usedw_grid : usedw_grid_t;

    signal data_arr   : byte_array_t;
    signal dst_arr    : port_array_t;
    signal en_arr     : std_logic_vector(3 downto 0);
    signal wrclk_arr  : clk_array_t;

    signal grant_arr  : sel_array_t;
    signal valid_arr  : std_logic_vector(3 downto 0);

    signal tx_data_arr : byte_array_t;

begin

    ---------------------------------------------------------------
    -- Pack the discrete input ports into arrays
    ---------------------------------------------------------------
    data_arr(0) <= Data_in_1;
    data_arr(1) <= Data_in_2;
    data_arr(2) <= Data_in_3;
    data_arr(3) <= Data_in_4;

    dst_arr(0) <= Dst_Port_1;
    dst_arr(1) <= Dst_Port_2;
    dst_arr(2) <= Dst_Port_3;
    dst_arr(3) <= Dst_Port_4;

    en_arr(0) <= En_Data_1;
    en_arr(1) <= En_Data_2;
    en_arr(2) <= En_Data_3;
    en_arr(3) <= En_Data_4;

    wrclk_arr(0) <= Rx_Clk_1;
    wrclk_arr(1) <= Rx_Clk_2;
    wrclk_arr(2) <= Rx_Clk_3;
    wrclk_arr(3) <= Rx_Clk_4;

    grant_arr(0) <= Grant_Out_1;
    grant_arr(1) <= Grant_Out_2;
    grant_arr(2) <= Grant_Out_3;
    grant_arr(3) <= Grant_Out_4;

    valid_arr(0) <= Grant_Valid_1;
    valid_arr(1) <= Grant_Valid_2;
    valid_arr(2) <= Grant_Valid_3;
    valid_arr(3) <= Grant_Valid_4;

    ---------------------------------------------------------------
    -- 16 FIFOs and their wrreq / rdreq logic
    ---------------------------------------------------------------
    Row_Gen : for i in 0 to 3 generate
        Col_Gen : for j in 0 to 3 generate

            -- Write FIFO(i, j) when input i has a valid byte AND its
            -- destination is exactly column j, OR the destination is
            -- the broadcast value "111" (in which case all four FIFOs
            -- in row i write simultaneously and each output drains
            -- its own copy).
            wrreq_grid(i, j) <=
                en_arr(i) when (to_integer(unsigned(dst_arr(i))) = j
                                or dst_arr(i) = "111")
                else '0';

            -- Read FIFO(i, j) when the Scheduler has matched output j
            -- to input i this cycle.
            rdreq_grid(i, j) <=
                valid_arr(j) when (to_integer(unsigned(grant_arr(j))) = i)
                else '0';

            FIFO_inst : FIFO port map (
                aclr    => Reset,
                data    => data_arr(i),
                rdclk   => Tx_Clk,
                rdreq   => rdreq_grid(i, j),
                wrclk   => wrclk_arr(i),
                wrreq   => wrreq_grid(i, j),
                q       => q_grid(i, j),
                rdempty => empty_grid(i, j),
                rdusedw => usedw_grid(i, j),
                wrfull  => open,
                wrusedw => open
            );

            -- Pack this FIFO's rdusedw into the flat 192-bit vector
            rdusedw_grid( (i*4 + j)*12 + 11 downto (i*4 + j)*12 )
                <= usedw_grid(i, j);

        end generate Col_Gen;
    end generate Row_Gen;

    ---------------------------------------------------------------
    -- 4-to-1 output mux per column. Tx_Data(j) takes its bytes
    -- from FIFO( Grant_Out(j), j ). The Scheduler guarantees that
    -- this FIFO is non-empty whenever Grant_Valid(j) = '1', so
    -- under showahead operation the byte is on q immediately.
    ---------------------------------------------------------------
    Mux_Gen : for j in 0 to 3 generate
        tx_data_arr(j) <= q_grid(
            to_integer(unsigned(grant_arr(j))),
            j
        );
    end generate Mux_Gen;

    Tx_Data_1 <= tx_data_arr(0);
    Tx_Data_2 <= tx_data_arr(1);
    Tx_Data_3 <= tx_data_arr(2);
    Tx_Data_4 <= tx_data_arr(3);

end behavioral;
