--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin

with selector select
Result <= In1 when '1',
		  In0 when '0',
		  "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others;
		  
end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
           MemWrite : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
           ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
end Control;

architecture Boss of Control is

signal fc3opcode: std_logic_vector(9 downto 0);
signal fc7fc3opcode: std_logic_vector(16 downto 0);
signal Wactive: std_logic;

begin

fc3opcode <= funct3 & opcode;
fc7fc3opcode <= funct7 & funct3 & opcode;
-- Need to try and have order to this, One Blocked section per output signal.
-------------------------------------------------------------------------------------
-- OUTPUT: BRANCH -------------------------------------------------------------------
with fc3opcode select 
	Branch <= "01" when "0001100011", --Test for BEQ
			  "10" when "0011100011", --Test for BNE
			  "00" when others; --For all others Branch is 00 as defined by our truth table

-------------------------------------------------------------------------------------
-- OUTPUT: MemRead -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with opcode select
	MemRead <= '1' when "0100011",
			   '0' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: MemtoReg -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with opcode select 
	MemtoReg <= '1' when "0000011",
				'0' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: ALUCtrl THIS ONE
-------------------------------------------------------------------------------------
with fc7fc3opcode select
	ALUCtrl <= "11101" when "-------1010110011", --srl/srli
			   "11101" when "-------1010010011",
			   "00010" when "-------1110110011", -- and/andi
			   "00010" when "-------1110010011",
			   "00011" when "-------1100110011", -- or/ori
			   "00011" when "-------1100010011",
			   "11110" when "-------0010110011", --sll/slli
			   "11110" when "-------0010010011",
			   "10000" when "01000000000110011", --sub
			   "00000" when others; --add
-------------------------------------------------------------------------------------
-- OUTPUT: MemWrite -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with opcode select
	MemWrite <= '1' when "0100011",
			   '0' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: ALUSrc THIS ONE
-------------------------------------------------------------------------------------
with fc7fc3opcode select
	ALUSrc <= '0' when "00000000000110011",
			  '0' when "01000000000110011",
			  '0' when "00000001100110011",
			  '0' when "00000001110110011",
			  '0' when "00000000010110011",
			  '0' when "00000001010110011",
			  '1' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: RegWrite THIS ONE
-------------------------------------------------------------------------------------
with fc3opcode select
	Wactive <= '0' when "0001100011", 
	           '0' when "0011100011",
	           '0' when "0100100011",
			   '1' when others;
with clk select
	RegWrite <= Wactive when '0',
				'0' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: ImmGen -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with opcode select	
	ImmGen <= "10" when "0110111",
			  "01" when "1100011",
			  "00" when others;
end Boss;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is
begin

process (Reset,Clock)
	begin
	
	if(Reset = '1') then
		PCout <= X"00400000";
	end if;
	
	if rising_edge(Clock) then
		PCout <= PCin;
	end if;
end process;

end executive;
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ImmGen is
    Port(FullInstruction: in std_logic_vector(31 downto 0);
	 ImmGen: in std_logic_vector(1 downto 0);
	 Modified_Imm: out std_logic_vector(31 downto 0));
end entity ImmGen;

architecture Generator of ImmGen is

signal TBE: std_logic_vector(11 downto 0);

begin
with FullInstruction(14 downto 12)&FullInstruction(6 downto 0) select
TBE <=  FullInstruction(31 downto 25)&FullInstruction(11 downto 7) when "0100100011",
		FullInstruction(24)&FullInstruction(24)&FullInstruction(24)&FullInstruction(24)&FullInstruction(24)&FullInstruction(24)&FullInstruction(24)&FullInstruction(24 downto 20) when ("0010010011" OR "1010010011"), -- SRLI SLLI
		FullInstruction(31 downto 20) when others;

with ImmGen select 
Modified_Imm  <= FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) &FullInstruction(31) & FullInstruction(7) & FullInstruction(30 downto 25) & FullInstruction(11 downto 8) & '0' when "01",
				 FullInstruction(31 downto 12)& "000000000000" when "10",
				 TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11)&TBE(11 downto 0) when others;

end Generator;
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BranchSel is
	Port( BSel: in std_logic_vector(2 downto 0);
	BRes: out std_logic);
end entity BranchSel;

architecture BranchSelection of BranchSel is

begin
with BSel select
BRes <= '1' when ("011" OR "100"),
				'0' when others;
				
end BranchSelection;