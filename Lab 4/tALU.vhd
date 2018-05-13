--------------------------------------------------------------------------------
--
-- Test Bench for LAB #4
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY testALU_vhd IS
END testALU_vhd;

ARCHITECTURE behavior OF testALU_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ALU
		Port(	DataIn1: in std_logic_vector(31 downto 0);
			DataIn2: in std_logic_vector(31 downto 0);
			ALUCtrl: in std_logic_vector(4 downto 0);
			Zero: out std_logic;
			ALUResult: out std_logic_vector(31 downto 0) );
	end COMPONENT ALU;

	--Inputs
	SIGNAL datain_a : std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL datain_b : std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL control	: std_logic_vector(4 downto 0)	:= (others=>'0');

	--Outputs
	SIGNAL result   :  std_logic_vector(31 downto 0);
	SIGNAL zeroOut  :  std_logic;

	-- test/debug signals
	signal t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5 : std_logic_vector(31 downto 0) := x"00000000";
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: ALU PORT MAP(
		DataIn1 => datain_a,
		DataIn2 => datain_b,
		ALUCtrl => control,
		Zero => zeroOut,
		ALUResult => result
	);
	

	tb : PROCESS
	BEGIN
		-- Wait 100 ns for global reset to finish
		wait for 100 ns;
		-- Test addi
		control <= "00001"; -- opcode "000" for add/sub  funct2 "01" for addi
		
		datain_a <= x"00000000";
		datain_b <= x"00000002";
		wait for 5 ns;
		t0 <= result; -- addi t0,zero,2   Expect t0 = 00000002
		wait for 20 ns;
		
		control <= "00001"; -- opcode "000" for add/sub  funct2 "01" for addi
		
		datain_a <= x"00000000";
		datain_b <= x"000004dd";
		wait for 5 ns;
		t1 <= result; -- addi t1,zero,1245  Expect t1 = 000004dd
		wait for 20 ns; 
		
		-- Test add 
		control  <= "00000"; -- opcode "000" for add/sub  funct2 "00" for add
	
		datain_a <= t1;
		datain_b <= t0;
		wait for 5 ns;
		t2 <= result; -- add t2,t1,t0   Expect 000004df
		wait for 20 ns; 

		-- Test Sub
		control <= "00010"; -- opcode "000" for add/sub  funct2 "10" for sub
		
		datain_a <= t1;
		datain_b <= t2;
		wait for 5 ns;
		t3 <= result; -- sub t3,t2,t1 Expect FFFFFFFFE
		wait for 20 ns; 
		
		-- Test and
		control <= "00100"; -- opcode "001" for and/i  funct2 "00" for and
		
		datain_a <= t3;
		datain_b <= t2;
		wait for 5 ns;
		t4 <= result; -- and t4,t3,t2   Expect 000004de
		wait for 20 ns; 
		
		-- Test andi
		control <= "00110"; -- opcode "001" for and/i  funct2 "10" for andi
		
		datain_a <= t4;
		datain_b <= x"0000003f";
		wait for 5 ns;
		t5 <= result; -- andi t5,t4,63   Expect 0000001e
		wait for 20 ns; 
		
		-- Test or
		control <= "01000"; -- opcode "010" for or/i  funct2 "00" for or
		
		datain_a <= t5;
		datain_b <= t4;
		wait for 5 ns;
		t6 <= result; -- or t6,t5,t4  Expect 000004de
		wait for 20 ns; 
		
		-- Test ori
		control <= "01010"; -- opcode "010" for add/sub  funct2 "10" for ori
		
		datain_a <= t6;
		datain_b <= x"00000238";
		wait for 5 ns;
		a0 <= result; -- ori a0,t6,568   Expect 000006fe
		wait for 20 ns; 
		
		-- Test sll
		control <= "01100"; -- opcode "011" for sll/i, srl/i funct2 "00" for sll
		
		datain_a <= a0;
		datain_b <= t0;
		wait for 5 ns;
		a1 <= result; -- sll a1,a0,t0   Expect 00001bf8
		wait for 20 ns;
		
		-- Test slli
		control <= "01110"; -- opcode "011" for sll/i, srl/i funct2 "10" for slli
		
		datain_a <= a1;
		datain_b <= x"00000002";
		wait for 5 ns;
		a2 <= result; -- slli a2,a1,2 Expect 00006fe0
		wait for 20 ns; 
		
		-- Test srl 
		control <= "01101"; -- opcode "011" for sll/i, srl/i funct2 "01" for srl
		
		datain_a <= a2;
		datain_b <= t0;
		wait for 5 ns;
		a3 <= result; -- srl a3,a2,t0   Expect 00001bf8
		wait for 20 ns; 
		
		-- Test srli
		control <= "01111"; -- opcode "011" for sll/i, srl/i funct2 "11" for srli
		
		datain_a <= a3;
		datain_b <= x"00000002";
		wait for 5 ns;
		a4 <= result; -- srli a4,a3,2 Expect 000006fe
		wait for 20 ns; 
		
		-- Test Data 2 passthrough and zero line
		control <= "10000"; -- Opcode "100" for d2 pass through funct2 "00" to default
		
		datain_a <= a4;
		datain_b <= x"00000000";
		wait for 5 ns;
		a5 <= result;
		-- Wait 100ns to exit
		wait for 100 ns;
		
	END PROCESS;

END;