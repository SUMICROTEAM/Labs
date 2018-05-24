--------------------------------------------------------------------------------
-- LAB #5 - Memory and Register Bank --
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
 
    if (falling_edge(Clock) AND WE = '1' AND Address < b"00000000000000000000010000000") then -- WE in this spot could cause issues, move if no function, Use to_integer(unsigned(Address)) to index the i_ram array
		i_ram(to_integer(unsigned(Address))) <= DataIn;
    end if;

	if ((OE = '0') AND Address < b"00000000000000000000010000000") then
		DataOut <= i_ram(to_integer(unsigned(Address)));
	else
		DataOut <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";  
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
	signal out32, out16, out8: std_logic := '1';
	
	signal ActualRead1,ActualRead2,ActualWrite: std_logic_vector(4 downto 0);
	type read_data is array (8 downto 0) of std_logic_vector(31 downto 0);
	signal read_dataout: read_data;
	signal ActualWriteCmd: std_logic_vector(8 downto 0);
	signal readtemp1, readtemp2,writetemp: std_logic_vector(4 downto 0);
	
begin
--Control Signal Logic
with ReadReg1 Select
readtemp1 <= ReadReg1 when ("00000"OR"00001"OR"00010"OR"00011"OR"00100"OR"00101"OR"00110"OR"00111"OR"01000"),
			"ZZZZZ" when others;
			
with ReadReg2 Select
readtemp2 <= ReadReg2 when ("00000"OR"00001"OR"00010"OR"00011"OR"00100"OR"00101"OR"00110"OR"00111"OR"01000"),
			"ZZZZZ" when others;
			
with WriteReg Select
writetemp <= WriteReg when ("00001"OR"00010"OR"00011"OR"00100"OR"00101"OR"00110"OR"00111"OR"01000"),
			"00000" when others;

-- 0 is for x0, 1-8 is for a0-a7
--Instantiate The reg32 for all 9

Gen1: for I in 0 to 8 generate
	RegI : register32 Port Map(WriteData,out32,out16,out8,ActualWriteCmd(I),ActualWriteCmd(I),ActualWriteCmd(I),read_dataout(I));
End generate;

--Write Data To Reg
process(WriteCmd)
begin
	if (falling_edge(WriteCmd) AND  writetemp /= "00000") then
		if    WriteCmd = "01000" then
			ActualWriteCmd <= WriteCmd & "00000000";
		elsif WriteCmd = "00111" then
			ActualWriteCmd <= "0" & WriteCmd & "0000000";
		elsif WriteCmd = "00110" then
			ActualWriteCmd <= "00" & WriteCmd & "000000";
		elsif WriteCmd = "00101" then
			ActualWriteCmd <= "000" & WriteCmd & "00000";
		elsif WriteCmd = "00100" then
			ActualWriteCmd <= "0000" & WriteCmd & "0000";
		elsif WriteCmd = "00011" then
			ActualWriteCmd <= "00000" & WriteCmd & "000";
		elsif WriteCmd = "00010" then
			ActualWriteCmd <= "000000" & WriteCmd & "00";
		elsif WriteCmd = "00001" then
			ActualWriteCmd <= "0000000" & WriteCmd & "0";
		end if;
	end if;
end process;

--Read Data Out
ReadData1 <= read_dataout(to_integer(unsigned(readtemp1)));
ReadData2 <= read_dataout(to_integer(unsigned(readtemp2)));




end remember;
-------------------------------------------------------------------------------------------------------------------------------------------------
-- ALL CODE BELOW IS 32 BIT REGISTER IMPLEMENTATION NO EDITS NEEDED --
----------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	component register8 
		port(datain: in std_logic_vector(7 downto 0);
			enout:  in std_logic;
			writein: in std_logic;
			dataout: out std_logic_vector(7 downto 0));
	end component register8; 
	signal en8,en16,en32: std_logic := '1';
	signal write8,write16,write32: std_logic := '0';
begin

	en32 <= enout32;
	en16 <= enout32 AND enout16;
	en8 <= enout32 AND enout16 AND enout8;

	write32 <= writein32;
	write16 <= writein32 OR writein16;
	write8 <= writein32 OR writein16 OR writein8;


	B1: register8 port map (datain(7 downto 0),en8,write8,dataout(7 downto 0));
	B2: register8 port map (datain(15 downto 8),en16,write16,dataout(15 downto 8));
	B3: register8 port map (datain(23 downto 16),en32,write32,dataout(23 downto 16));
	B4: register8 port map (datain(31 downto 24),en32,write32,dataout(31 downto 24));
end architecture biggermem;
---------------------------------------------------------------------------------------------------------------------------------------------------------
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
	
	signal i: integer RANGE 0 to 7 := 0;
	
begin

GenCommand:	for i in 0 to 7 generate
		Li: bitstorage port map (datain(i),enout,writein,dataout(i));
	end generate;
	
end architecture memmy;
---------------------------------------------------------------------------------------------------------------------------------------------------------
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

