    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 
    use IEEE.math_real.all;

entity MUX is

	port(
		A: in std_logic_vector (31 downto 0);
		B: in std_logic_vector (31 downto 0);
		S: in std_logic;
		Z: out std_logic_vector (31 downto 0));
		
end MUX;
 
architecture main of MUX is
begin
	with S select Z <= A when '0', B when '1';
end main;
     
 