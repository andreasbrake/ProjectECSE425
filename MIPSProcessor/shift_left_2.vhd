
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 
    use IEEE.math_real.all;
    
entity SHIFT_LEFT_2 is
	
	port(
		data_in: in std_logic_vector (7 downto 0);
		data_out: out std_logic_vector (9 downto 0));
		
	end SHIFT_LEFT_2;
	
	
architecture main of SHIFT_LEFT_2 is
  
  signal data_temp : unsigned(9 downto 0);
  
	begin 
	  
	  
		data_temp (9 downto 2) <= unsigned(data_in);
		data_temp (1 downto 0) <= "00";
		data_out <= std_logic_vector(data_temp);
		
	end main;