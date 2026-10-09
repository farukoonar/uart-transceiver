--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- TESTBENCH ENTITY
--------------------------------------------------------------------------------
entity tb_uart_rx is
generic(
c_clkfreq 	: integer := 100_000_000;
c_baudrate 	: integer := 115_200
);
end tb_uart_rx;

--------------------------------------------------------------------------------
-- TESTBENCH ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of tb_uart_rx is

----------------------------------------------------------------------------
--  COMPONENT INSTANTIATION
----------------------------------------------------------------------------
component uart_rx is
generic(
c_clkfreq 	: integer 	:= 100_000_000;
c_baudrate 	: integer 	:= 115_200
);
port(
clk 			: in std_logic;
rx_i 			: in std_logic ;
dout_o 			: out std_logic_vector(7 downto 0);
rx_done_tick_o	: out std_logic
);
end component; 

----------------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------------
constant c_clkperiod 	: time := 10 ns;
constant c_baud115200 	: time := 8.68 us;
constant c_hexA5 		: std_logic_vector(9 downto 0) := '1' & x"A5" & '0';  -- stop bit, data, start bit
constant c_hex43 		: std_logic_vector(9 downto 0) := '1' & x"43" & '0';  -- stop bit, data, start bit

----------------------------------------------------------------------------
-- SIGNALS
----------------------------------------------------------------------------
signal clk 				: std_logic 					:= '0';                                   
signal rx_i 			:  std_logic 					:= '1';                                  
signal dout_o 			:  std_logic_vector(7 downto 0) := (others => '0');  
signal rx_done_tick_o	:  std_logic 					:= '0'    ;  

----------------------------------------------------------------------------
-- BEGIN
----------------------------------------------------------------------------
begin

----------------------------------------------------------------------------
-- UUT (Unit Under Test) 
----------------------------------------------------------------------------
UUT : uart_rx
generic map(
c_clkfreq  =>   c_clkfreq ,
c_baudrate =>   c_baudrate
)
port map(
clk            	=> clk           ,
rx_i           	=> rx_i          ,
dout_o         	=> dout_o        ,
rx_done_tick_o  => rx_done_tick_o 
);

----------------------------------------------------------------------------
-- CLOCK GENERATOR PROCESS
----------------------------------------------------------------------------
P_CLKGEN : process begin
clk <= '0';
wait for c_clkperiod/2;
clk <= '1';
wait for c_clkperiod/2;
end process;

----------------------------------------------------------------------------
-- STIMULUS PROCESS
----------------------------------------------------------------------------
P_STIMULI : process begin

wait for 10 us;

for i in 0 to 9 loop
    rx_i <= c_hex43(i);
    wait for c_baud115200;
end loop;

wait for 10 us;

for i in 0 to 9 loop
    rx_i <= c_hexA5(i);
    wait for c_baud115200;
end loop;

wait for 10 us;

assert false 
report "SIM DONE"
severity failure;

end process;
end Behavioral;
