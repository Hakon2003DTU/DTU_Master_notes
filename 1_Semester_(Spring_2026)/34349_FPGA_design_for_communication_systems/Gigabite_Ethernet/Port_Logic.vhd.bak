---------------------------------------------------------------------
-- Component:    Port_Logic
-- Description:  Controls how buffered frames leave the FCS block.
--
--               One descriptor is queued for every frame, in arrival
--               order, the moment the FCS check finishes:
--                 - Frame_Good (= En_Mac) : a good frame, must be
--                   forwarded to the crossbar.
--                 - Frame_Bad  (= Drop)   : a corrupt frame, must be
--                   flushed (drained from the FIFO but not forwarded).
--               Each descriptor also stores Package_Length, the
--               number of bytes that frame occupies in the data FIFO.
--
--               For good frames the destination port arrives later
--               from MAC learning on En_Port_in / Dst_Port_in. Those
--               are held in a second queue, in order; the Nth good
--               descriptor is paired with the Nth port answer.
--
--               Frames are served strictly in arrival order:
--                 - good  : FIFO_Rd and En_Data_out are held high for
--                           Package_Length cycles and Dst_Port_out is
--                           driven, so the frame reaches the crossbar.
--                 - flush : FIFO_Rd is held high for Package_Length
--                           cycles while En_Data_out stays low, so the
--                           corrupt bytes are drained out of the FIFO
--                           without ever reaching the crossbar.
--
-- Made by:      Hakon Hlynsson
---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Port_Logic is
    port (
        -- Input
        Reset          : in  std_logic;
        Tx_Clk         : in  std_logic;
        -- Frame-end markers from FCS_Reg (one pulse per frame, in order)
        Frame_Good     : in  std_logic;   -- frame passed the FCS check
        Frame_Bad      : in  std_logic;   -- frame failed the FCS check
        Package_Length : in  std_logic_vector(10 downto 0);
        -- Destination port from MAC learning (good frames only, in order)
        En_Port_in     : in  std_logic;
        Dst_Port_in    : in  std_logic_vector(2 downto 0);
        -- Output
        FIFO_Rd        : out std_logic;   -- FIFO read enable (forward AND flush)
        En_Data_out    : out std_logic;   -- crossbar enable   (forward only)
        Dst_Port_out   : out std_logic_vector(2 downto 0)
    );
end Port_Logic;

architecture behavioral of Port_Logic is

    constant QUEUE_DEPTH : integer := 24;

    -- Descriptor queue: one entry per frame, in arrival order
    type desc_entry_t is record
        is_flush   : std_logic;            -- '1' = corrupt frame, drain silently
        pkg_length : unsigned(10 downto 0);
    end record;
    type desc_array_t is array (0 to QUEUE_DEPTH-1) of desc_entry_t;

    -- Port queue: one entry per GOOD frame, in arrival order
    type port_array_t is array (0 to QUEUE_DEPTH-1)
                          of std_logic_vector(2 downto 0);

    signal descq : desc_array_t;
    signal portq : port_array_t;

    -- Descriptor-queue pointers / count
    signal d_wr  : integer range 0 to QUEUE_DEPTH-1 := 0;
    signal d_rd  : integer range 0 to QUEUE_DEPTH-1 := 0;
    signal d_cnt : integer range 0 to QUEUE_DEPTH   := 0;

    -- Port-queue pointers / count
    signal p_wr  : integer range 0 to QUEUE_DEPTH-1 := 0;
    signal p_rd  : integer range 0 to QUEUE_DEPTH-1 := 0;
    signal p_cnt : integer range 0 to QUEUE_DEPTH   := 0;

    -- Read-side control
    signal busy        : std_logic            := '0';
    signal clk_counter : unsigned(10 downto 0) := (others => '0');

begin

    process(Tx_Clk)
        variable d_add, d_rem : boolean;
        variable p_add, p_rem : boolean;
    begin
        if rising_edge(Tx_Clk) then
            if Reset = '1' then
                d_wr <= 0; d_rd <= 0; d_cnt <= 0;
                p_wr <= 0; p_rd <= 0; p_cnt <= 0;
                busy         <= '0';
                clk_counter  <= (others => '0');
                FIFO_Rd      <= '0';
                En_Data_out  <= '0';
                Dst_Port_out <= (others => '0');
            else
                d_add := false; d_rem := false;
                p_add := false; p_rem := false;

                ----------------------------------------------------------
                -- Enqueue a descriptor at every frame-end. Frame_Good and
                -- Frame_Bad are mutually exclusive, so is_flush = Frame_Bad.
                ----------------------------------------------------------
                if (Frame_Good = '1' or Frame_Bad = '1')
                   and d_cnt < QUEUE_DEPTH then
                    descq(d_wr).is_flush   <= Frame_Bad;
                    descq(d_wr).pkg_length <= unsigned(Package_Length);
                    if d_wr = QUEUE_DEPTH-1 then d_wr <= 0;
                    else d_wr <= d_wr + 1; end if;
                    d_add := true;
                end if;

                ----------------------------------------------------------
                -- Enqueue a destination port whenever MAC learning answers
                ----------------------------------------------------------
                if En_Port_in = '1' and p_cnt < QUEUE_DEPTH then
                    portq(p_wr) <= Dst_Port_in;
                    if p_wr = QUEUE_DEPTH-1 then p_wr <= 0;
                    else p_wr <= p_wr + 1; end if;
                    p_add := true;
                end if;

                ----------------------------------------------------------
                -- Serve the descriptor queue, strictly in arrival order
                ----------------------------------------------------------
                if busy = '1' then
                    -- currently draining a frame out of the data FIFO
                    if clk_counter > 0 then
                        clk_counter <= clk_counter - 1;
                    else
                        busy         <= '0';
                        FIFO_Rd      <= '0';
                        En_Data_out  <= '0';
                        Dst_Port_out <= (others => '0');
                    end if;

                elsif d_cnt > 0 then
                    if descq(d_rd).is_flush = '1' then
                        -- corrupt frame: drain the FIFO without forwarding
                        busy        <= '1';
                        clk_counter <= descq(d_rd).pkg_length - 1;
                        FIFO_Rd     <= '1';
                        En_Data_out <= '0';
                        if d_rd = QUEUE_DEPTH-1 then d_rd <= 0;
                        else d_rd <= d_rd + 1; end if;
                        d_rem := true;

                    elsif p_cnt > 0 then
                        -- good frame, and MAC learning has supplied its port
                        busy         <= '1';
                        clk_counter  <= descq(d_rd).pkg_length - 1;
                        FIFO_Rd      <= '1';
                        En_Data_out  <= '1';
                        Dst_Port_out <= portq(p_rd);
                        if d_rd = QUEUE_DEPTH-1 then d_rd <= 0;
                        else d_rd <= d_rd + 1; end if;
                        if p_rd = QUEUE_DEPTH-1 then p_rd <= 0;
                        else p_rd <= p_rd + 1; end if;
                        d_rem := true;
                        p_rem := true;
                    end if;
                    -- good frame at the head but no port yet -> wait
                end if;

                ----------------------------------------------------------
                -- Maintain the two queue counts (enqueue and serve can
                -- happen on the same cycle, so handle both)
                ----------------------------------------------------------
                if d_add and not d_rem then
                    d_cnt <= d_cnt + 1;
                elsif d_rem and not d_add then
                    d_cnt <= d_cnt - 1;
                end if;

                if p_add and not p_rem then
                    p_cnt <= p_cnt + 1;
                elsif p_rem and not p_add then
                    p_cnt <= p_cnt - 1;
                end if;

            end if;
        end if;
    end process;

end behavioral;
