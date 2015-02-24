    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 
    use IEEE.math_real.all;
    
  entity SIGN_EXTEND is

  port ( data_in_16 : in std_logic_vector(15 downto 0);
         data_out_32 : out std_logic_vector(31 downto 0));
         
end SIGN_EXTEND;


architecture main of SIGN_EXTEND is

begin

  data_out_32 <= std_logic_vector(resize(signed(data_in_16), data_out_32'length));

end main;