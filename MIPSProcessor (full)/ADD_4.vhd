-- Adder for PC. 8-bit wide, adds constant integer 4

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ADD_4 is

  port ( data_in: in std_logic_vector(7 downto 0);
	 result: out std_logic_vector(7 downto 0));
         
end ADD_4;

architecture main of ADD_4 is

signal data_temp : unsigned(7 downto 0);
signal result_temp : unsigned(7 downto 0);

constant FOUR : unsigned(7 downto 0):= (2 => '1', others => '0');

begin
	data_temp <= unsigned(data_in);
	result_temp <= data_temp + FOUR;
	result <= std_logic_vector(result_temp);
end main;