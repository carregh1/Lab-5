--------------------------------------------------------------------------------
-- Diego Carregha
-- LAB #3
--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
-- full adder
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;

----------------------------------------------------------------------------------
-- 8 bit register
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;
architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	D0: bitstorage port map(datain(0),enout,writein, dataout(0));
	D1: bitstorage port map(datain(1),enout,writein, dataout(1));
	D2: bitstorage port map(datain(2),enout,writein, dataout(2));
	D3: bitstorage port map(datain(3),enout,writein, dataout(3));
	D4: bitstorage port map(datain(4),enout,writein, dataout(4));
	D5: bitstorage port map(datain(5),enout,writein, dataout(5));
	D6: bitstorage port map(datain(6),enout,writein, dataout(6));
	D7: bitstorage port map(datain(7),enout,writein, dataout(7));
end architecture memmy;
--------------------------------------------------------------------------------
-- 32 bit register
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	-- hint: you'll want to put register8 as a component here 
	-- so you can use it below
        signal w1,o1 : std_logic_vector(2 downto 0);
	component register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
	end component;
begin  
        w1(0) <= writein8  OR writein16 OR writein32; 
        w1(1) <= writein16 OR writein32;              
        w1(2) <= writein32;                           
	o1(0) <= enout8 AND enout16 AND enout32;     
        o1(1) <= enout16 AND enout32;
        o1(2) <= enout32;
	D0: register8 port map(datain(7 downto 0), o1(0),w1(0), dataout(7 downto 0));
	D1: register8 port map(datain(15 downto 8),o1(1),w1(1),dataout(15 downto 8));
	D2: register8 port map(datain(23 downto 16),o1(2),w1(2),dataout(23 downto 16));
	D3: register8 port map(datain(31 downto 24),o1(2),w1(2),dataout(31 downto 24));

end architecture biggermem;
--------------------------------------------------------------------------------
-- adder/subtracter
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
	component fulladder
		port (a : in std_logic;
		      b : in std_logic;
		      cin : in std_logic;
		      sum : out std_logic;
	              carry : out std_logic);
	end component;
	signal b : std_logic_vector (31 downto 0); 
	signal c : std_logic_vector (32 downto 0);
begin
	-- insert code here.
	with add_sub select 
	b <= not (datain_b) when '1',datain_b when others;
	c(0) <= add_sub;
	co <= c(32);
	adder: for i in 0 to 31 generate
		FA1: fulladder PORT MAP (datain_a(i), b(i), c(i), dataout(i), c(i+1));
	end generate;
end architecture calc;
--------------------------------------------------------------------------------
-- shift register
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port( datain: in std_logic_vector(31 downto 0);
    		dir: in std_logic;
		shamt: in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
	end entity shift_register;
architecture shifter of shift_register is
begin
	with dir & shamt select
		dataout <= 	datain(30 downto 0) & "0" when "000001", -- shifts right
				datain(29 downto 0) & "00" when "000010", 
				datain(28 downto 0) & "000" when "000011", 
				"0" & datain(31 downto 1) when "100001", -- shifts left
				"00" & datain(31 downto 2) when "100010", 
				"000" & datain(31 downto 3) when "100011",
				datain(31 downto 0) when others; 
end architecture shifter;