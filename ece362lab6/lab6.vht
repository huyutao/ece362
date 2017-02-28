
-- VHDL Test Bench Created from source file lab6.vhd -- Wed Oct 05 19:35:37 2016
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Lattice recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "source->import"
-- menu in the ispLEVER Project Navigator to import the testbench.
-- Then edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
LIBRARY generics;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE generics.components.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT lab6
	PORT(
		tens_in : IN std_logic;
		ireq : IN std_logic;
		iclr : IN std_logic;
		dp_in : IN std_logic;
		D3 : IN std_logic;
		D2 : IN std_logic;
		D1 : IN std_logic;
		D0 : IN std_logic;          
		tens_out : OUT std_logic;
		irq : OUT std_logic;
		g : OUT std_logic;
		f : OUT std_logic;
		e : OUT std_logic;
		dp_out : OUT std_logic;
		d : OUT std_logic;
		c : OUT std_logic;
		b : OUT std_logic;
		a : OUT std_logic
		);
	END COMPONENT;

	SIGNAL tens_out :  std_logic;
	SIGNAL tens_in :  std_logic;
	SIGNAL irq :  std_logic;
	SIGNAL ireq :  std_logic;
	SIGNAL iclr :  std_logic;
	SIGNAL g :  std_logic;
	SIGNAL f :  std_logic;
	SIGNAL e :  std_logic;
	SIGNAL dp_out :  std_logic;
	SIGNAL dp_in :  std_logic;
	SIGNAL d :  std_logic;
	SIGNAL c :  std_logic;
	SIGNAL b :  std_logic;
	SIGNAL a :  std_logic;
	SIGNAL D3 :  std_logic;
	SIGNAL D2 :  std_logic;
	SIGNAL D1 :  std_logic;
	SIGNAL D0 :  std_logic;

BEGIN

	uut: lab6 PORT MAP(
		tens_out => tens_out,
		tens_in => tens_in,
		irq => irq,
		ireq => ireq,
		iclr => iclr,
		g => g,
		f => f,
		e => e,
		dp_out => dp_out,
		dp_in => dp_in,
		d => d,
		c => c,
		b => b,
		a => a,
		D3 => D3,
		D2 => D2,
		D1 => D1,
		D0 => D0
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
