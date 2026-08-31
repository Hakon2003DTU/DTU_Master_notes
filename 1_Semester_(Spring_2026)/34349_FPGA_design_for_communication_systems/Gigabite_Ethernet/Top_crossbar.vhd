---------------------------------------------------------------------
-- Componant  : Top_crossbar
-- Description: Combines the Scheduler and the FIFO_And_Crossbar
--              into a single block. Sits between the four FCS
--              modules and the four physical Tx ports.
--
--              Bytes arrive from the FCS side as (Data_in_X,
--              Dst_Port_X, En_Data_X) triples. They are written into
--              one of the 16 crosspoint FIFOs in FIFO_And_Crossbar,
--              chosen by Dst_Port_X (or replicated to all four FIFOs
--              of row X when Dst_Port_X = "111", i.e. broadcast).
--
--              Each Tx_Clk cycle the Scheduler looks at the 16 FIFO
--              fill counters (rdusedw_grid) plus the live En_Data /
--              Dst_Port signals and decides, per output column,
--              which row to drain. Grant_Out_X / Grant_Valid_X are
--              fed into FIFO_And_Crossbar; the corresponding FIFO's
--              q drives Tx_Data_X and Grant_Valid_X is forwarded
--              straight through as Tx_Valid_X (assumes showahead
--              FIFO mode; register Tx_Valid by one cycle if your
--              megafunction is in normal mode).
--
-- Made by    : Hakon Hlynsson
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_crossbar is
    port (
        -- Global
        Reset       : in  std_logic;
        Tx_Clk      : in  std_logic;

        -- Per-input write clocks (each FCS has its own Rx clock)
        Rx_Clk_1    : in  std_logic;
        Rx_Clk_2    : in  std_logic;
        Rx_Clk_3    : in  std_logic;
        Rx_Clk_4    : in  std_logic;

        -- Byte streams from the four FCS modules
        Data_in_1   : in  std_logic_vector(7 downto 0);
        Data_in_2   : in  std_logic_vector(7 downto 0);
        Data_in_3   : in  std_logic_vector(7 downto 0);
        Data_in_4   : in  std_logic_vector(7 downto 0);

        -- Destination port that the MAC learner / FCS assigned
        Dst_Port_1  : in  std_logic_vector(2 downto 0);
        Dst_Port_2  : in  std_logic_vector(2 downto 0);
        Dst_Port_3  : in  std_logic_vector(2 downto 0);
        Dst_Port_4  : in  std_logic_vector(2 downto 0);

        -- Per-FCS write-side valid strobes
        En_Data_1   : in  std_logic;
        En_Data_2   : in  std_logic;
        En_Data_3   : in  std_logic;
        En_Data_4   : in  std_logic;

        -- Four egress byte streams
        Tx_Data_1   : out std_logic_vector(7 downto 0);
        Tx_Data_2   : out std_logic_vector(7 downto 0);
        Tx_Data_3   : out std_logic_vector(7 downto 0);
        Tx_Data_4   : out std_logic_vector(7 downto 0);

        -- Per-output valid strobes (= Grant_Valid_X from Scheduler)
        Tx_Valid_1  : out std_logic;
        Tx_Valid_2  : out std_logic;
        Tx_Valid_3  : out std_logic;
        Tx_Valid_4  : out std_logic
    );
end Top_crossbar;

architecture behavioral of Top_crossbar is

    component Scheduler port (
        En_Data_out_1   : in  std_logic;
        En_Data_out_2   : in  std_logic;
        En_Data_out_3   : in  std_logic;
        En_Data_out_4   : in  std_logic;
        Dst_Port_out_1  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_2  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_3  : in  std_logic_vector(2 downto 0);
        Dst_Port_out_4  : in  std_logic_vector(2 downto 0);
        rdusedw_grid    : in  std_logic_vector(191 downto 0);
        Grant_Out_1     : out std_logic_vector(1 downto 0);
        Grant_Valid_1   : out std_logic;
        Grant_Out_2     : out std_logic_vector(1 downto 0);
        Grant_Valid_2   : out std_logic;
        Grant_Out_3     : out std_logic_vector(1 downto 0);
        Grant_Valid_3   : out std_logic;
        Grant_Out_4     : out std_logic_vector(1 downto 0);
        Grant_Valid_4   : out std_logic
    );
    end component;

    component FIFO_And_Crossbar port (
        Reset         : in  std_logic;
        Tx_Clk        : in  std_logic;
        Rx_Clk_1      : in  std_logic;
        Rx_Clk_2      : in  std_logic;
        Rx_Clk_3      : in  std_logic;
        Rx_Clk_4      : in  std_logic;
        Data_in_1     : in  std_logic_vector(7 downto 0);
        Data_in_2     : in  std_logic_vector(7 downto 0);
        Data_in_3     : in  std_logic_vector(7 downto 0);
        Data_in_4     : in  std_logic_vector(7 downto 0);
        Dst_Port_1    : in  std_logic_vector(2 downto 0);
        Dst_Port_2    : in  std_logic_vector(2 downto 0);
        Dst_Port_3    : in  std_logic_vector(2 downto 0);
        Dst_Port_4    : in  std_logic_vector(2 downto 0);
        En_Data_1     : in  std_logic;
        En_Data_2     : in  std_logic;
        En_Data_3     : in  std_logic;
        En_Data_4     : in  std_logic;
        Grant_Out_1   : in  std_logic_vector(1 downto 0);
        Grant_Out_2   : in  std_logic_vector(1 downto 0);
        Grant_Out_3   : in  std_logic_vector(1 downto 0);
        Grant_Out_4   : in  std_logic_vector(1 downto 0);
        Grant_Valid_1 : in  std_logic;
        Grant_Valid_2 : in  std_logic;
        Grant_Valid_3 : in  std_logic;
        Grant_Valid_4 : in  std_logic;
        Tx_Data_1     : out std_logic_vector(7 downto 0);
        Tx_Data_2     : out std_logic_vector(7 downto 0);
        Tx_Data_3     : out std_logic_vector(7 downto 0);
        Tx_Data_4     : out std_logic_vector(7 downto 0);
        rdusedw_grid  : out std_logic_vector(191 downto 0)
    );
    end component;

    -- Internal control / status bus between Scheduler and Crossbar
    signal usedw_int    : std_logic_vector(191 downto 0);

    signal grant_1_int  : std_logic_vector(1 downto 0);
    signal grant_2_int  : std_logic_vector(1 downto 0);
    signal grant_3_int  : std_logic_vector(1 downto 0);
    signal grant_4_int  : std_logic_vector(1 downto 0);

    signal valid_1_int  : std_logic;
    signal valid_2_int  : std_logic;
    signal valid_3_int  : std_logic;
    signal valid_4_int  : std_logic;

begin

    ---------------------------------------------------------------
    -- Scheduler watches the FIFO fill levels + the live FCS state
    -- and decides which row drives each output column.
    ---------------------------------------------------------------
    U_SCHED : Scheduler port map (
        En_Data_out_1   => En_Data_1,
        En_Data_out_2   => En_Data_2,
        En_Data_out_3   => En_Data_3,
        En_Data_out_4   => En_Data_4,

        Dst_Port_out_1  => Dst_Port_1,
        Dst_Port_out_2  => Dst_Port_2,
        Dst_Port_out_3  => Dst_Port_3,
        Dst_Port_out_4  => Dst_Port_4,

        rdusedw_grid    => usedw_int,

        Grant_Out_1     => grant_1_int,
        Grant_Valid_1   => valid_1_int,
        Grant_Out_2     => grant_2_int,
        Grant_Valid_2   => valid_2_int,
        Grant_Out_3     => grant_3_int,
        Grant_Valid_3   => valid_3_int,
        Grant_Out_4     => grant_4_int,
        Grant_Valid_4   => valid_4_int
    );

    ---------------------------------------------------------------
    -- 16-FIFO crossbar carries the data path
    ---------------------------------------------------------------
    U_XBAR : FIFO_And_Crossbar port map (
        Reset         => Reset,
        Tx_Clk        => Tx_Clk,

        Rx_Clk_1      => Rx_Clk_1,
        Rx_Clk_2      => Rx_Clk_2,
        Rx_Clk_3      => Rx_Clk_3,
        Rx_Clk_4      => Rx_Clk_4,

        Data_in_1     => Data_in_1,
        Data_in_2     => Data_in_2,
        Data_in_3     => Data_in_3,
        Data_in_4     => Data_in_4,

        Dst_Port_1    => Dst_Port_1,
        Dst_Port_2    => Dst_Port_2,
        Dst_Port_3    => Dst_Port_3,
        Dst_Port_4    => Dst_Port_4,

        En_Data_1     => En_Data_1,
        En_Data_2     => En_Data_2,
        En_Data_3     => En_Data_3,
        En_Data_4     => En_Data_4,

        Grant_Out_1   => grant_1_int,
        Grant_Out_2   => grant_2_int,
        Grant_Out_3   => grant_3_int,
        Grant_Out_4   => grant_4_int,

        Grant_Valid_1 => valid_1_int,
        Grant_Valid_2 => valid_2_int,
        Grant_Valid_3 => valid_3_int,
        Grant_Valid_4 => valid_4_int,

        Tx_Data_1     => Tx_Data_1,
        Tx_Data_2     => Tx_Data_2,
        Tx_Data_3     => Tx_Data_3,
        Tx_Data_4     => Tx_Data_4,

        rdusedw_grid  => usedw_int
    );

    ---------------------------------------------------------------
    -- Tx_Valid pins follow the per-column grant directly. The
    -- showahead FIFO has its head byte on q at the same cycle, so
    -- byte and valid arrive together. (Add a 1-cycle Tx_Clk
    -- register here if your megafunction is in normal mode.)
    ---------------------------------------------------------------
    Tx_Valid_1 <= valid_1_int;
    Tx_Valid_2 <= valid_2_int;
    Tx_Valid_3 <= valid_3_int;
    Tx_Valid_4 <= valid_4_int;

end behavioral;
