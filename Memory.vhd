--------------------------------------------------------------------------------
--
-- LAB #5 - Memory and Register Bank
--
--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic;
	 WE:      in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;

begin

  RamProc: process(Clock, Reset, OE, WE, Address) is

  begin
    if Reset = '1' then
      for i in 0 to 127 loop   
          i_ram(i) <= X"00000000";
      end loop;
    end if;

    if falling_edge(Clock) then -- write data to i_ram on falling edge
	-- Add code to write data to RAM
    -- Use to_integer(unsigned(Address)) to index the i_ram array
    
        if (WE = '1') then -- write data to i_ram when write enable = 1.	
            if (to_integer(unsigned(Address)) <= 127) then
                 i_ram (to_integer(unsigned(Address))) <= DataIn;
            end if;
        end if;
	
    end if;

    -- Rest of the RAM implementation
    
    if (OE='0' and (to_integer(unsigned(Address)) <=127)) then
	    DataOut <=  i_ram (to_integer(unsigned(Address)));
    else
	    Dataout <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    end if;

  end process RamProc;

end staticRAM;	


--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0); 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);
	 WriteData: in std_logic_vector(31 downto 0);
	 WriteCmd: in std_logic;
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
end entity Registers;

architecture remember of Registers is
	component register32
  	    port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
	end component;
    
	signal a0, a1, a2, a3, a4, a5, a6, a7: std_logic_vector (31 downto 0);
	signal write_in : std_logic_vector (7 downto 0);

begin


    -- Add your code here for the Register Bank implementation
	with ReadReg1 select
	ReadData1<= a0 when "01010",
		a1	when "01011",
		a2	when "01100",
		a3 	when "01101",
		a4	when "01110",
		a5	when "01111",
		a6	when "10000",
		a7	when "10001",
		X"00000000" when others;

	with ReadReg2 select
	ReadData2 <=a0	when "01010",
		a1	when "01011",
		a2	when "01100",
		a3 	when "01101",
		a4	when "01110",
		a5	when "01111",
		a6	when "10000",
		a7	when "10001",
		X"00000000" when others;

	with WriteCmd & WriteReg select
	write_in <="00000001" when "101010",
		"00000010" when "101011",
		"00000100" when "101100",
		"00001000" when "101101",
		"00010000" when "101110",
		"00100000" when "101111",
		"01000000" when "110000",
		"10000000" when "110001",
		"00000000" when others;

	y0: register32 port map(WriteData, '0', '1', '1', write_in(0), '0', '0', a0);
	y1: register32 port map(WriteData, '0', '1', '1', write_in(1), '0', '0', a1);
	y2: register32 port map(WriteData, '0', '1', '1', write_in(2), '0', '0', a2);
	y3: register32 port map(WriteData, '0', '1', '1', write_in(3), '0', '0', a3);
	y4: register32 port map(WriteData, '0', '1', '1', write_in(4), '0', '0', a4);
	y5: register32 port map(WriteData, '0', '1', '1', write_in(5), '0', '0', a5);
	y6: register32 port map(WriteData, '0', '1', '1', write_in(6), '0', '0', a6);
	y7: register32 port map(WriteData, '0', '1', '1', write_in(7), '0', '0', a7);




end remember;

-----------------------------------------------------------------------------------