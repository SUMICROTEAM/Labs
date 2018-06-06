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

with slector select
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

signal fc3opcode: std_logic_vector(9 downto 0);
signal fc7fc3opcode: std_logic_vector(16 downto 0);

architecture Boss of Control is
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
-- OUTPUT: ALUCtrl -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with fc7fc3opcode select
	ALUCtrl <= "11101" when "-------1010110011" or "-------1010010011", --srl/srli
			   "00010" when "-------1110110011" or "-------1110010011", -- and/andi
			   "00011" when "-------1100110011" or "-------1100010011", -- or/ori
			   "11110" when "-------0010110011" or "-------0010010011", --sll/slli
			   "10000" when "01000000000110011" --sub
			   "00000" when others; --add
-------------------------------------------------------------------------------------
-- OUTPUT: MemWrite -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with opcode select
	MemWrite <= '1' when "0100011",
			   '0' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: ALUSrc -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with fc7fc3opcode select
	ALUSrc <= '0' when "00000000000110011" or "01000000000110011" or 
					   "00000001100110011" or "00000001110110011" or
					   "00000000010110011" or "00000001010110011",
			  '1' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: RegWrite -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with fc3opcode & clk select
	RegWrite <= '0' when "00011000111" or "00111000111" or "01001000111";
				'1' when others;
-------------------------------------------------------------------------------------
-- OUTPUT: ImmGen -------------------------------------------------------------------
-------------------------------------------------------------------------------------
with opcode select	
	ImmGen <= "10" when "0110111"
			  "01" when "1100011"
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
begin

with ImmGen select 
Modified_Imm  <=      when "01",
					  when "10",
					  when others;





end Generator;