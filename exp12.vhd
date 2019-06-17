----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:52:15 06/17/2019 
-- Design Name: 
-- Module Name:    exp12 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity exp12 is
    Port ( do : in  STD_LOGIC;
           cs1 : out  STD_LOGIC;
           cs_ad : out  STD_LOGIC;
           clk_tmp121 : out  STD_LOGIC;
           led : out  STD_LOGIC_VECTOR(0 TO 7);
			  clk_in : in STD_LOGIC;
			  display : out STD_LOGIC_VECTOR(0 TO 5);
			  transistor : out STD_LOGIC_VECTOR(0 TO 3)
			  );
end exp12;

architecture Behavioral of exp12 is

	signal clk_1khz_counter : INTEGER := 0;
	signal clk_1khz : STD_LOGIC := '0';
	
	signal tmp_121_data : STD_LOGIC_VECTOR(0 TO 7);
	signal tmp_121_counter : INTEGER := 0;
	
	signal data_index : INTEGER := 0;

	signal display_counter : INTEGER := 0;

begin

	transistor <= "0000";
	cs_ad <= '1';
	clk_tmp121 <= clk_1khz;
	led <= tmp_121_data;

	proc_1khz: process(clk_in)
	begin
	  if clk_in'event and clk_in = '1' then
			if clk_1khz_counter < 50000 then
				 clk_1khz_counter <= clk_1khz_counter + 1;
			else
				 clk_1khz_counter <= 0;
			end if;

			if clk_1khz_counter < 25000 then
				 clk_1khz <= '0';
			else
				 clk_1khz <= '1';
			end if;
	  end if;
	end process;
	
	process_tmp121: process(clk_1khz)
	begin
		if clk_1khz'event and clk_1khz = '1' then
			if tmp_121_counter = 0 then
				cs1 <= '1';
			end if;
			
			if tmp_121_counter < 310 or (tmp_121_counter >= 319 and tmp_121_counter < 350) then
				tmp_121_counter <= tmp_121_counter + 1;
			elsif tmp_121_counter = 310 then
				cs1 <= '0';
				tmp_121_counter <= tmp_121_counter + 1;
			elsif tmp_121_counter > 310 and tmp_121_counter < 319 then
				case data_index is
					when 0 => tmp_121_data(0) <= do;
					when 1 => tmp_121_data(1) <= do;
					when 2 => tmp_121_data(2) <= do;
					when 3 => tmp_121_data(3) <= do;
					when 4 => tmp_121_data(4) <= do;
					when 5 => tmp_121_data(5) <= do;
					when 6 => tmp_121_data(6) <= do;
					when 7 => tmp_121_data(7) <= do;
					when others => null;
				end case;
				if data_index < 7 then
					data_index <= data_index + 1;
				else
					data_index <= 0;
				end if;
				tmp_121_counter <= tmp_121_counter + 1;
			else 
				tmp_121_counter <= 0;
			end if;
	  end if;
	end process;

	proc_display: process(clk_1khz)
	begin
		if clk_1khz'event and clk_1khz = '1' then
			if display_counter < 166 then
				display <= "011111";
			elsif display_counter >= 166 and display_counter < 332 then
				display <= "101111";
			elsif display_counter >= 332 and display_counter < 498 then
				display <= "110111";
			elsif display_counter >= 498 and display_counter < 664 then
				display <= "111011";
			elsif display_counter >= 664 and display_counter < 830 then
				display <= "111101";
			elsif display_counter >= 830 and display_counter < 996 then
				display <= "111110";
			else
				null;
			end if;
			
			if display_counter <= 996 then
				display_counter <= display_counter + 1;
			else
				display_counter <= 0;
			end if;
		end if;
	end process;

end Behavioral;

