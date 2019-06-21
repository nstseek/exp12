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
use IEEE.NUMERIC_STD.ALL;

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
			  transistor : out STD_LOGIC_VECTOR(0 TO 3);
			  rs : out STD_LOGIC;
			  enable_lcd : out STD_LOGIC;
			  lcd_data : out STD_LOGIC_VECTOR(0 TO 7)
			  );
end exp12;

architecture Behavioral of exp12 is

	constant debug_clk : INTEGER := 1000; -- debug config, should be 1 for everything to work.

	constant basic_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := "00111000";
	constant control_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := "00001111";
	constant desloc_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := "00000110";
	constant clear_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := "00000001";

	signal clk_1khz_counter : INTEGER := 0;
	signal clk_1khz : STD_LOGIC := '0';
	
	signal tmp_121_data : STD_LOGIC_VECTOR(0 TO 7) := "00000000";
	signal tmp_121_counter : INTEGER := 0;
	
	signal data_index : INTEGER := 0;

	signal display_counter : INTEGER := 0;

	signal tmp_121_integer : INTEGER := 0;
	
	signal write_to_lcd : STD_LOGIC := '0';
	signal write_done : STD_LOGIC := '0';
	signal lcd_ready : STD_LOGIC := '0';
	signal lcd_counter : INTEGER := 0;
	
	signal digit1 : STD_LOGIC_VECTOR(0 TO 7) := "00000000";
	signal digit2 : STD_LOGIC_VECTOR(0 TO 7) := "00000000";
	
	signal lcd_data_signal : STD_LOGIC_VECTOR(0 TO 7) := "00000000";
	
	signal rs_next_cycle : STD_LOGIC := '0';
	signal rs_counter : INTEGER := 0;
	signal rs_delay_done : STD_LOGIC := '0';
	signal rs_signal : STD_LOGIC := '0';
	signal rs_clk_signal : STD_LOGIC := '0';
	signal enable_signal : STD_LOGIC := '0';
	signal clk_enable : STD_LOGIC := '0';

begin
	
	rs <= rs_clk_signal;
	lcd_data <= lcd_data_signal;
	transistor <= "0000";
	cs_ad <= '1';
	clk_tmp121 <= clk_1khz;
	led(0) <= lcd_data_signal(0);
	led(1) <= lcd_data_signal(1);
	led(2) <= lcd_data_signal(2);
	led(3) <= lcd_data_signal(3);
	led(4) <= lcd_data_signal(4);
	led(5) <= lcd_data_signal(5);
	led(6) <= lcd_data_signal(6);
	led(7) <= rs_clk_signal;
	with enable_signal select 
	clk_enable <=
		clk_1khz when '1',
		'0' when others;
	enable_lcd <= clk_enable;
	
	tmp_121_integer <= to_integer(unsigned(tmp_121_data));

	proc_1khz: process(clk_in)
	begin
	  if clk_in'event and clk_in = '1' then
			if clk_1khz_counter < (50000*debug_clk) then
				 clk_1khz_counter <= clk_1khz_counter + 1;
			else
				 clk_1khz_counter <= 0;
			end if;

			if clk_1khz_counter < (25000*debug_clk) then
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
			if lcd_ready = '1' then
				if write_done = '1' and write_to_lcd = '1' then
					write_to_lcd <= '0';
				elsif tmp_121_counter < 310 or (tmp_121_counter >= 319 and tmp_121_counter < 350) then
					tmp_121_counter <= tmp_121_counter + 1;
				elsif tmp_121_counter = 310 then
					cs1 <= '0';
					tmp_121_counter <= tmp_121_counter + 1;
				elsif tmp_121_counter > 310 and tmp_121_counter < 319 and write_to_lcd = '0' and write_done = '0' then
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
				elsif tmp_121_counter > 310 and tmp_121_counter < 319 then
					null;
				else
					write_to_lcd <= '1';
					tmp_121_counter <= 0;
				end if;
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
	
	proc_rs: process(clk_in)
	begin
		if clk_in'event and clk_in = '1' then
			if rs_counter < (12500*debug_clk) and rs_delay_done = '0' then
				rs_counter <= rs_counter + 1;
			elsif rs_counter = (12500*debug_clk) and rs_delay_done = '0' then
				rs_delay_done <= '1';
				rs_counter <= 0;
			end if;
			
			if rs_delay_done = '1' then
				if rs_counter < (50000*debug_clk) then
					rs_counter <= rs_counter + 1;
				else
					rs_signal <= rs_next_cycle;
					rs_counter <= 0;
				end if;
				
				if rs_counter < (45000*debug_clk) then
					rs_clk_signal <= rs_signal;
				else
					rs_clk_signal <= '0';
				end if;
			end if;
		end if;
	end process;
	
	proc_lcd: process(clk_1khz)
	begin
		if clk_1khz'event and clk_1khz = '1' then
			if write_to_lcd = '1' or lcd_ready = '0' then
				enable_signal <= '1';
			else
				enable_signal <= '0';
			end if;
			
			if lcd_ready = '0' then
				case lcd_counter is
					when 0 => 
						rs_next_cycle <= '0';
						lcd_data_signal <= basic_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 1 =>
						rs_next_cycle <= '0';
						lcd_data_signal <= control_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 2 =>
						rs_next_cycle <= '0';
						lcd_data_signal <= desloc_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 3 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= clear_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 4 =>
						rs_next_cycle <= '0';
						lcd_data_signal <= "01010010";
						lcd_counter <= 0;
						lcd_ready <= '1';
					when others => null;
				end case;
			elsif write_to_lcd = '0' and write_done = '1' then
				write_done <= '0';
			elsif write_to_lcd = '1' then
				case lcd_counter is
					when 0 => 
						rs_next_cycle <= '1';
						lcd_data_signal <= clear_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 1 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= digit1;
						lcd_counter <= lcd_counter + 1;
					when 2 =>
						rs_next_cycle <= '0';
						lcd_data_signal <= digit2;
						lcd_counter <= 0;
						write_done <= '1';
					when others => null;
				end case;
			end if;
		end if;
	end process;

end Behavioral;

