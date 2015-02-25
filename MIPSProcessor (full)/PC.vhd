library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use IEEE.math_real.all;
use ieee.std_logic_signed.all;



entity PC is

    port(input: in  std_logic_vector(7 downto 0);
         I,CLK,S,E: in  std_logic;
         ouput: out std_logic_vector(7 downto 0));
			
end pc;

architecture main of PC is

signal p:std_logic_vector(7 downto 0);
signal temp:std_logic_vector(2 downto 0);

	begin
		process(clk)
	begin
	
temp <=  I & S & E ;
if(clk'event and clk = '1')
then

 case temp is
   when "000" => ouput <= "ZZZZZZZZ";
   when "001" => ouput <= p;
   when "010" => p <= input; ouput <= "ZZZZZZZZ";
   when "011" => p <= input; ouput <= p;

   when "100" => p <= p + "00000001";ouput <= "ZZZZZZZZ";
   when "101" => p <= p + "00000001";ouput <= p;
   when "110" => p <= input;   ouput <= "ZZZZZZZZ";
   when "111" => p <= input;   ouput <= p;

   when others => ouput <= "XXXXXXXX";
 end case;
end if;
end process;
end main;
