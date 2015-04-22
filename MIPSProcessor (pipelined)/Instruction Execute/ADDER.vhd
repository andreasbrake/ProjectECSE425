LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ADDER IS
    PORT ( A      : in std_logic_vector(9 downto 0);
	   B      : in integer;
	   result : out std_logic_vector(9 downto 0));
END ADDER;

ARCHITECTURE behavior of  ADDER is
    signal result_unsigned : Integer;
BEGIN

result_unsigned <= to_integer(signed(A)) + B;
result <= std_logic_vector(to_signed(result_unsigned, result'length));

end behavior;