library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity async_fifo is
    port (
        Reset          : in std_logic;
        Wclk           : in std_logic;
        Rclk           : in std_logic;
        Write_enable   : in std_logic;
        Read_enable    : in std_logic;
        Write_data_in  : in std_logic_vector(7 downto 0);
        Full           : out std_logic;
        Empty          : out std_logic;
        Fifo_occu_in   : out std_logic_vector(4 downto 0);
        Fifo_occu_out  : out std_logic_vector(4 downto 0);
        Read_data_out  : out std_logic_vector(7 downto 0)
    );
end async_fifo;

architecture behavioral of async_fifo is

    -- Component Declaration
   component Duel_Port_Memory
       PORT(	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		wraddress	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		wrclock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
   end component; 

   component Sync_R
       port (  ptr  : in std_logic_vector(4 downto 0); -- Fixed: Was 3 downto 0
        Wclk : in std_logic;
        Rclk : in std_logic;
        sync : out std_logic_vector(4 downto 0) -- Fixed: Was 3 downto 0
        );
    end component; 

   component Sync_W
       port (  ptr  : in std_logic_vector(4 downto 0); -- Fixed: Was 3 downto 0
        Wclk : in std_logic;
        Rclk : in std_logic;
        sync : out std_logic_vector(4 downto 0) -- Fixed: Was 3 downto 0
        );
    end component; 

   component FIFO_Read_Control
    port (  Reset         : in std_logic;
            Rclk          : in std_logic;
            Read_enable   : in std_logic;
            W_sync        : in std_logic_vector(4 downto 0);
            Empty         : out std_logic;
            Ren           : out std_logic;
            Fifo_occu_out : out std_logic_vector(4 downto 0);
            Raddr         : out std_logic_vector(3 downto 0);
            Rptr          : out std_logic_vector(4 downto 0)
    );
   end component;

   component FIFO_Write_Control 
    port (
        Reset        : in std_logic;
        Wclk         : in std_logic;
        Write_Enable : in std_logic;
        R_Sync       : in std_logic_vector(4 downto 0);
        Full         : out std_logic;
        Wen          : out std_logic;
        Fifo_occu_in : out std_logic_vector(4 downto 0);
        Waddr        : out std_logic_vector(3 downto 0);
        Wptr         : out std_logic_vector(4 downto 0)
    );
    end component;


-- Internal signals
    signal W_ptr, R_ptr: std_logic_vector(4 downto 0);
    signal W_ptr_Sync, R_ptr_Sync: std_logic_vector(4 downto 0);
    signal W_addr, R_addr : std_logic_vector(3 downto 0);
    signal Wen,Ren: std_logic;
begin


    -- RAM Instantiation
    Comp1 : Duel_Port_Memory 
        port map (
                data      => write_data_in,
                rdaddress => r_addr,
                rdclock   => Rclk,
		rden	  => Ren,
                wraddress => w_addr,
                wrclock   => wclk,
                wren      => Wen,
                q         => read_data_out
        );


    Comp2 : FIFO_Write_Control
    port map (  
        Reset        => Reset,
        Wclk         => Wclk,
        Write_Enable => write_enable,
        R_Sync       => R_ptr_Sync,
        Full         => Full,
        Wen          => Wen,
        Fifo_occu_in => Fifo_occu_in,
        Waddr        => W_addr,
        Wptr         => W_ptr
    );


    Comp3 : Sync_W
    port map(
        ptr  => w_ptr,
        Wclk => Wclk,
        Rclk => Rclk,
        sync => W_ptr_Sync
        );


    Comp4 : Sync_R
    port map(
        ptr  => R_ptr,
        Wclk => Wclk,
        Rclk => Rclk,
        sync => R_ptr_Sync
        );


    Comp5 : FIFO_Read_Control
    port map(
        Reset         => Reset,
        Rclk          => Rclk,
        Read_enable   => Read_enable,
        W_sync        => W_ptr_Sync,
        Empty         => Empty,
        Ren           => Ren,
        Fifo_occu_out => Fifo_occu_out,
        Raddr         => R_addr,
        Rptr          => R_ptr
        );
end behavioral;
