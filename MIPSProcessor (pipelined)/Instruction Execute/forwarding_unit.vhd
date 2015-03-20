library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use IEEE.math_real.all;
use ieee.std_logic_signed.all;

entity forwarding_unit is

    port(ex_mem_rd, id_ex_rs, id_ex_rt, mem_wb_rd : in  std_logic_vector(4 downto 0);
         mem_wb_regwrite, ex_mem_regwrite : in std_logic;
         ForwardA, ForwardB: out std_logic_vector(1 downto 0));
			
end forwarding_unit;

architecture main of forwarding_unit is

begin
 
 -- FORWARD LOGIC! FORWARD TO VICTORY!!!!
ForwardA <= "10" when (ex_mem_regwrite = '1') and (ex_mem_rd /= "00000") and (ex_mem_rd = id_ex_rs) else
            "01" when (mem_wb_regwrite = '1') and (mem_wb_rd /= "00000") and (mem_wb_rd = id_ex_rs) and  (ex_mem_rd /= id_ex_rs) else
            "00";  
  
ForwardB <= "10" when (ex_mem_regwrite = '1') and (ex_mem_rd /= "00000") and (ex_mem_rd = id_ex_rt) else
            "01" when (mem_wb_regwrite = '1') and (mem_wb_rd /= "00000") and (mem_wb_rd = id_ex_rt) and  (ex_mem_rd /= id_ex_rt) else
            "00";   
  


end main;

