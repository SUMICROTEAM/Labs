--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component Control
   	     Port( clk : in  STD_LOGIC;
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
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;
------------------------------------------------------------------------------------
--- ADDED SIGNALS ---
------------------------------------------------------------------------------------
-- Processor pathways
signal PC_Next,PC_Next4,Next_Inst,Branch_Out,Instruction,D1,D2,ImmOrD2,Imm_Out,ALUOut,DmemOut,RegWriteData: std_logic_vector(31 downto 0);
-- Control Lines
signal MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,BranchMuxSel: std_logic;
signal Ctrl_Branch, ImmGenerator: std_logic_vector(1 downto 0);
signal ALUCtrl: std_logic_vector(4 downto 0);
-- Other stuffs

signal trash,ALU_Zero: std_logic;



------------------------------------------------------------------------------------
begin

Program_Counter: ProgramCounter Port Map(reset,clock,Next_Inst,PC_Next); 

Add_4_to_PC: adder_subtracter Port Map(PC_Next,X"00000004",'0',PC_Next4,trash);

Branch_Adder: adder_subtracter Port Map(PC_Next,Imm_Out,'0',Branch_Out,trash);

Branch_Mux: BusMux2to1 Port Map(BranchMuxSel,PC_Next4,Branch_Out,Next_Inst);

I_mem: InstructionRAM Port Map(reset,clock,PC_Next,Instruction);

Controller: Control(clock,Instruction( downto ),Instruction( downto ),Instruction( downto ),Ctrl_Branch(1 downto 0),MemRead,MemtoReg,ALUCtrl(4 downto 0),MemWrite,ALUSrc,RegWrite,ImmGenerator(1 downto 0));

Our_Reg: Registers(Instruction(19 downto 15),Instruction(24 downto 20),Instruction(11 downto 7),RegWriteData(31 downto 0),RegWrite,D1(31 downto 0),D2(31 downto 0);

ALU_multiplexor: BusMux2to1(ALUSrc,D2(31 downto 0),Imm_Out(31 downto 0),ImmOrD2(31 downto 0));

Processor_ALU: ALU(D1(31 downto 0),ImmOrD2(31 downto 0),ALUCtrl(4 downto 0),Zero,ALUOut(31 downto 0));

Data_Memory: RAM(reset,clock,  ,  ,D2(31 downto 0),ALUOut(31 downto 0),DmemOut(31 downto 0));

Register_Write_Mux: BusMux2to1(MemtoReg,ALUOut(31 downto 0),DmemOut(31 downto 0),RegWriteData(31 downto 0);



-- BRANCH HANDLER -- 
with Ctrl_Branch & ALU_Zero select
BranchMuxSel <= '1' when "011" OR "100",
				'0' when others;
				


end holistic;

