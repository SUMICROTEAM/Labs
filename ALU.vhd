--------------------------------------------------------------------------------
--
-- LAB #4
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port(	DataIn1: in std_logic_vector(31 downto 0);
		DataIn2: in std_logic_vector(31 downto 0);
		ALUCtrl: in std_logic_vector(4 downto 0);
		Zero: out std_logic;
		ALUResult: out std_logic_vector(31 downto 0) );
end entity ALU;

architecture ALU_Arch of ALU is
	-- ALU components	
	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	component shift_register
		port(	datain: in std_logic_vector(31 downto 0);
		   	dir: in std_logic;
			shamt:	in std_logic_vector(4 downto 0);
			dataout: out std_logic_vector(31 downto 0));
	end component shift_register;
	
	signal AddSubRes,ShiftRes: std_logic_vector(31 downto 0);
begin
	AddSub: adder_subtracter PORT MAP(DataIn1,DataIn2,ALUCtrl(1),ALUResult,);
	
	Shift: shift_register PORT MAP(DataIn1,ALUCtrl(0),DataIn2,ALUResult)
	
	with ALUCtrl(4 downto 2) select 
	ALUResult <= AddSubRes when "000",
				 ShiftRes when "011",
				 DataIn1 AND DataIn2 when "001",
				 DataIn1 OR DataIn2 when "010",
				 DataIn2 when "100",
				 h(ZZZZZZZZ) when others;
	
	with ALUResult select
	Zero <= '1' when h(00000000),
			'0' when others;

end architecture ALU_Arch;


