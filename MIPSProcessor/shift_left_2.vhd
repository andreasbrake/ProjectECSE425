library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 
    use IEEE.math_real.all;
    
entity SHIFT_LEFT_2 is
	
	port(
		data_in: in unsigned (31 downto 0);
		data_out: out unsigned (31 downto 0));
		
	end SHIFT_LEFT_2;
	
	
architecture main of SHIFT_LEFT_2 is

begin 
		
	data_out <= data_in sll 2;
		
end main;