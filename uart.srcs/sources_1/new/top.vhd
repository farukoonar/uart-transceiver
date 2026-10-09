--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity top is
generic(
c_clkfreq 	: integer := 100_000_000;
c_baudrate 	: integer := 9600;
c_stopbit 	: integer := 2 
);
port(
clk 		: in std_logic ;
rx_i 		: in std_logic ;
tx_start_i 	: in std_logic ;
din_i 		: in std_logic_vector(7 downto 0);
dout_o 		: out std_logic_vector (15 downto 0);
tx_o 		: out std_logic 
);
end top;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of top is

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------
constant c_debtime_ms 	: integer := 10;         
constant c_initval 		: std_logic := '0';  

--------------------------------------------------------------------------------
-- COMPONENT DECLARATIONS
--------------------------------------------------------------------------------
component uart_tx is
generic(
c_clkfreq 		: integer := 100_000_000;
c_baudrate 		: integer := 9600;
c_stopbit 		: integer := 2 
);
port(
clk 			: in std_logic ;
din_i 			: in std_logic_vector (7 downto 0);
tx_start_i 		: in std_logic ;
tx_o 			: out std_logic ;
tx_done_tick_o 	: out std_logic 
);
end component;

component uart_rx is
generic(
c_clkfreq 		: integer := 100_000_000;
c_baudrate 		: integer := 9600
);
port(
clk 			: in std_logic;
rx_i 			: in std_logic;
dout_o 			: out std_logic_vector(7 downto 0);
rx_done_tick_o	: out std_logic
);
end component;

component debounce is
generic(
c_clkfreq 		: integer := 100_000_000;
c_debtime_ms 	: integer := 10;
c_initval 		: std_logic := '0'
);
port(
CLK 			: in std_logic;
signal_i 		: in std_logic;
signal_o 		: out std_logic
);
end component;
 
--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
signal tx_start_deb 		: std_logic := '0';
signal tx_start_deb_prev	: std_logic  :='0';

signal rx_done_tick_o 		: std_logic := '0';
signal tx_done_tick_o 		: std_logic := '0';

signal tx_start 			: std_logic  := '0';
signal leds_internal 		: std_logic_vector(15 downto 0) := (others => '0');
signal dout		 			: std_logic_vector(7 downto 0) := (others => '0');

--------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------	
begin

--------------------------------------------------------------------------------
-- COMPONENT INSTANTIATIONS
--------------------------------------------------------------------------------
i_debounce: debounce 
generic map(
c_clkfreq 		=> c_clkfreq,
c_debtime_ms 	=> c_debtime_ms,
c_initval 		=> c_initval
)
port map(
CLK      		=> clk,
signal_i 		=> tx_start_i,
signal_o 		=> tx_start_deb
);

i_uart_tx: uart_tx 
generic map(
c_clkfreq  		=> c_clkfreq ,
c_baudrate 		=> c_baudrate,
c_stopbit  		=> c_stopbit 
)
port map(
clk         	=> clk,
din_i       	=> din_i,
tx_start_i  	=> tx_start,
tx_o        	=> tx_o,
tx_done_tick_o 	=> tx_done_tick_o
);

i_uart_rx : uart_rx 
generic map(
c_clkfreq  		=> c_clkfreq,
c_baudrate 		=> c_baudrate
)
port map(
clk          	=> clk,
rx_i         	=> rx_i,    
dout_o         	=> dout,   
rx_done_tick_o 	=> rx_done_tick_o
);

--------------------------------------------------------------------------------
-- PROCESS STATEMENTS 
-- NOTE: Process blocks work concurrently with each other
--------------------------------------------------------------------------------
-- SEQUENTIAL PROCESS
-- main process
P_MAIN : process(clk) begin
if(rising_edge(clk)) then
	
	tx_start <= '0';
    tx_start_deb_prev <= tx_start_deb;
    
    
    if(tx_start_deb_prev = '0' and tx_start_deb = '1') then
        tx_start <= '1';
    end if;

    if(rx_done_tick_o = '1') then
        leds_internal(15 downto 8) 	<= leds_internal(7 downto 0);
        leds_internal(7 downto 0) 	<= dout;        
         
    end if;
    
    dout_o <= leds_internal;
    
end if;
end process;
end Behavioral;
