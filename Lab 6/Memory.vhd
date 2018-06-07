
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
	signal out32, out16, out8: std_logic := '0';
	
	type read_data is array (8 downto 0) of std_logic_vector(31 downto 0);
	signal read_dataout: read_data;
	signal ActualWriteCmd: std_logic_vector(8 downto 0);
	signal readtemp1, readtemp2: std_logic_vector(4 downto 0);
	
begin
--Control Signal Logic
with ReadReg1 select
readtemp1 <= "00000" when "00000",
			 "00001" when "01010",
			 "00010" when "01011",
			 "00011" when "01100",
			 "00100" when "01101",
			 "00101" when "01110",
			 "00110" when "01111",
			 "00111" when "10000",
			 "01000" when "10001",
			 "ZZZZZ" when others;

with ReadReg2 select
readtemp2 <= "00000" when "00000",
			 "00001" when "01010",
			 "00010" when "01011",
			 "00011" when "01100",
			 "00100" when "01101",
			 "00101" when "01110",
			 "00110" when "01111",
			 "00111" when "10000",
			 "01000" when "10001",
			 "ZZZZZ" when others;
			 
-- 0 is for x0, 1-8 is for a0-a7
--Instantiate The reg32 for all 9

Gen1: for I in 0 to 8 generate
	RegI : register32 Port Map(WriteData,out32,out16,out8,ActualWriteCmd(I),ActualWriteCmd(I),ActualWriteCmd(I),read_dataout(I));
End generate;

--Write Data To Reg
process(WriteCmd)
begin
	if (rising_edge(WriteCmd)) then
		if    WriteReg = "10001" then
			ActualWriteCmd <= '1' & "00000000"; 
		elsif WriteReg = "10000" then
			ActualWriteCmd <= '0' & '1' & "0000000";
		elsif WriteReg = "01111" then
			ActualWriteCmd <= "00" & '1' & "000000";
		elsif WriteReg = "01110" then
			ActualWriteCmd <= "000" & '1' & "00000";
		elsif WriteReg = "01101" then
			ActualWriteCmd <= "0000" & '1' & "0000";
		elsif WriteReg = "01100" then
			ActualWriteCmd <= "00000" & '1' & "000";
		elsif WriteReg = "01011" then
			ActualWriteCmd <= "000000" & '1' & "00";
		elsif WriteReg = "01010" then
			ActualWriteCmd <= "0000000" & '1' & '0';
		elsif WriteReg = "00000" then
			ActualWriteCmd <= "000000000";
		end if;
	else
		ActualWriteCmd <= "000000000";
	end if;
end process;

--Read Data Out
ReadData1 <= read_dataout(to_integer(unsigned(readtemp1)));
ReadData2 <= read_dataout(to_integer(unsigned(readtemp2)));




end remember;