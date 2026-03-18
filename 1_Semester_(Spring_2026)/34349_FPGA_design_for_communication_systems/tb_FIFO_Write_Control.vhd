library ieee;
use ieee.std_logic_1164.all;

entity tb_FIFO_Write_Control is
end tb_FIFO_Write_Control;

architecture behavior of tb_FIFO_Write_Control is
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

  signal Test_Reset        : std_logic := '0';
  signal Test_Wclk         : std_logic := '0';
  signal Test_Write_Enable : std_logic := '0';
  signal Test_R_Sync       : std_logic_vector(4 downto 0) := "00000";
  signal Test_Full         : std_logic;
  signal Test_Wen          : std_logic;
  signal Test_Fifo_occu_in : std_logic_vector(4 downto 0);
  signal Test_Waddr        : std_logic_vector(3 downto 0);
  signal Test_Wptr         : std_logic_vector(4 downto 0);

  constant Wclk_period_1 : time := 1 ns;

begin
  Comp1 : FIFO_Write_Control port map (
        Reset        => Test_Reset,
        Wclk         => Test_Wclk,
        Write_Enable => Test_Write_Enable,
        R_Sync       => Test_R_Sync,
        Full         => Test_Full,
        Wen          => Test_Wen,
        Fifo_occu_in => Test_Fifo_occu_in,
        Waddr        => Test_Waddr,
        Wptr         => Test_Wptr
  );

  WClk_Generator : process
  begin
    Test_Wclk <= '0';
    wait for Wclk_period_1 / 2;
    Test_Wclk <= '1';
    wait for Wclk_period_1 / 2;
  end process;

  Data_Sim : process
  begin
    Test_Reset        <= '1';
    Test_Write_Enable <= '0';
    Test_R_Sync       <= "00000";
    wait for 5 ns;
    
    Test_Reset        <= '0';
    Test_Write_Enable <= '1'; 
    wait for Wclk_period_1;
    wait for Wclk_period_1;
    
    Test_R_Sync       <= "00001";
    wait;
  end process;
end behavior;
