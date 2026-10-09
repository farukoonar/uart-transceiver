--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--------------------------------------------------------------------------------
-- TESTBENCH ENTITY
--------------------------------------------------------------------------------
entity tb_uart_tx is
generic(
c_clkfreq 	: integer 	:= 100_000_000;
c_baudrate 	: integer 	:= 10_000_000;
c_stopbit 	: integer 	:= 2 
);
end tb_uart_tx;

--------------------------------------------------------------------------------
-- TESTBENCH ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of tb_uart_tx is

----------------------------------------------------------------------------
--  COMPONENT INSTANTIATION
----------------------------------------------------------------------------
component uart_tx is
generic(
c_clkfreq 	: integer 	:= 100_000_000;
c_baudrate 	: integer 	:= 9600;
c_stopbit 	: integer 	:= 2 
);
port(
clk 			: in std_logic 						;
din_i 			: in std_logic_vector (7 downto 0) 	;
tx_start_i 		: in std_logic 						;
tx_o 			: out std_logic 					;
tx_done_tick_o 	: out std_logic 					
);
end component uart_tx;

----------------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------------
constant c_clkperiod : time := 10 ns;

----------------------------------------------------------------------------
-- SIGNALS
----------------------------------------------------------------------------
signal clk          	: std_logic 					:= '0';
signal din_i        	: std_logic_vector (7 downto 0) := (others => '0');
signal tx_start_i   	: std_logic 					:= '0';
signal tx_o         	: std_logic 					;
signal tx_done_tick_o	: std_logic 					;

----------------------------------------------------------------------------
-- BEGIN
----------------------------------------------------------------------------
begin

----------------------------------------------------------------------------
-- UUT (Unit Under Test) 
----------------------------------------------------------------------------
UUT : uart_tx
generic map(
c_clkfreq   	=> c_clkfreq,
c_baudrate  	=> c_baudrate,
c_stopbit   	=> c_stopbit
)
port map(
clk         	=> clk,
din_i       	=> din_i,
tx_start_i  	=> tx_start_i,
tx_o        	=> tx_o,
tx_done_tick_o 	=> tx_done_tick_o
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

din_i 		<= x"51";
tx_start_i 	<= '1';
wait for c_clkperiod;

tx_start_i 	<= '0';
wait for 1.2 us;

din_i 		<= x"A3";
tx_start_i 	<= '1';
wait for c_clkperiod;

tx_start_i 	<= '0';
wait for 1.2 us;

assert false 
report "SIM DONE"
severity failure;

end process;

end Behavioral;
