
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY tb_Main_Memory IS
END tb_Main_Memory;
 
ARCHITECTURE behavior OF tb_Main_Memory IS 
 
	type state_type is (init, read_mem1, read_mem2, write_mem1, write_mem2, dum, fin);
	Constant Num_Bits_in_Byte: integer := 8; 
		Constant Num_Bytes_in_Word: integer := 4; 
	Constant Memory_Size:integer := 256; 
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
	 COMPONENT Main_Memory
	generic (
			File_Address_Read : string :="Init.dat";
			File_Address_Write : string :="MemCon.dat";
			Mem_Size_in_Word : integer:=256;	
			Num_Bytes_in_Word: integer:=4;
			Num_Bits_in_Byte: integer := 8; 
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
		 );
    PORT(
         clk : IN  std_logic;
         address : IN  integer;
			Word_Byte: in std_logic;
         we : IN  std_logic;
         wr_done : OUT  std_logic;
         re : IN  std_logic;
         rd_ready : OUT  std_logic;
         data : INOUT  std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
        
         initialize : IN  std_logic;
         dump : IN  std_logic
        );
    END COMPONENT;
    
	
   --Inputs
   signal clk : std_logic := '0';
   signal address : integer := 0;
   signal we : std_logic := '0';
   signal re : std_logic := '0';
   signal data : std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0) := (others => 'Z');
   signal initialize : std_logic := '0';
   signal dump : std_logic := '0';

 	--Outputs
   signal wr_done : std_logic;
   signal rd_ready : std_logic;
   

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	-- Tests Simulation State 
	signal state:	state_type:=init;
	
	--Memory Data Read
	signal MDR: std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Main_Memory 
	generic map (
			File_Address_Read =>"Init.dat",
			File_Address_Write =>"MemCon.dat",
			Mem_Size_in_Word =>256,
			Num_Bytes_in_Word=>4,
			Num_Bits_in_Byte=>8,
			Read_Delay=>0,
			Write_Delay=>0
		 )
		PORT MAP (
          clk => clk,
          address => address,
			 Word_Byte => '0',
          we => we,
          wr_done => wr_done,
          re => re,
          rd_ready => rd_ready,
          data => data,          
          initialize => initialize,
          dump => dump
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process (clk)
   begin		
      if(clk'event and clk='1') then
			data <= (others=>'Z');
			case state is
				when init =>
					initialize <= '1'; --triggerd.
					state <= read_mem1;					
				when read_mem1 =>
		      
					we <='0';
					re <='1';
					initialize <= '0';
					dump <= '0';
					state <= read_mem2;
				when read_mem2 =>
				  re <='1';
				  if (rd_ready = '1') then -- the output is ready on the memory bus
						MDR <= data;
						state <= write_mem1; --read finished go to test state write 
						address <= address + 4;
						re <='0';
					else
						state <= read_mem2; -- stay in this state till you see rd_ready='1';
					end if;
					
				when write_mem1 =>
					address <= 12;
					we <='1';
					re <='0';
					initialize <= '0';
					dump <= '0';
					data <= "ZZZZZZZZZZZZZZZZZZZZZZZZ00001100";
					state <= write_mem2;
				when write_mem2 =>
					address <= address +4;
					we <='1';
					re <='0';
					initialize <= '0';
					dump <= '0';
					data <= "ZZZZZZZZZZZZZZZZZZZZZZZZ00001111";
					
					if (wr_done = '1') then -- the output is ready on the memory bus
						state <= dum; --write finished go to the dump state 
					else
						state <= write_mem2; -- stay in this state till you see rd_ready='1';
					end if;	
					
				when dum =>
					initialize <= '0'; 
					re<='0';
					we<='0';
					dump <= '1'; --triggerd
					state <= fin;
				when fin =>
					initialize <= '0'; 
					re<='0';
					we<='0';
					dump <= '0'; 
				when others =>
			end case;
			
		end if;
   end process;

END;
