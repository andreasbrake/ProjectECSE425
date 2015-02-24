LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity ADDER is

  port ( A: in std_logic_vector(31 downto 0);
	 B: in std_logic_vector(31 downto 0);
	 result: out std_logic_vector(31 downto 0));
         
end ADDER;


architecture behavior of ADDER is

BEGIN

    PROCESS(A, B)

	VARIABLE result_unsigned : unsigned(31 downto 0);
	VARIABLE A_unsigned : unsigned(31 downto 0);
	VARIABLE B_unsigned : unsigned(31 downto 0);

	BEGIN

	result_unsigned := (OTHERS => '0');
	A_unsigned := unsigned(A);
	B_unsigned := unsigned(B);
	
	result_unsigned := A_unsigned + B_unsigned;
	
	result <= std_logic_vector(result_unsigned);
	
  END process;


end behavior;