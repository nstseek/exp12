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
			  display : out STD_LOGIC_VECTOR(0 TO 5) := "000000";
			  transistor : out STD_LOGIC_VECTOR(0 TO 3);
			  rs : out STD_LOGIC;
			  enable_lcd : out STD_LOGIC;
			  lcd_data : out STD_LOGIC_VECTOR(0 TO 7);
			  switch : in STD_LOGIC_VECTOR(0 TO 7)
			  );
end exp12;

architecture Behavioral of exp12 is

	signal debug_clk : INTEGER := 1; -- debug config, should be 1 for everything to work.

	constant basic_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := x"38";
	constant control_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := x"0F";
	constant desloc_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := x"06";
	constant clear_conf_lcd : STD_LOGIC_VECTOR(0 TO 7) := x"01";
	
	constant R : STD_LOGIC_VECTOR(0 TO 7) := x"52";
	constant a : STD_LOGIC_VECTOR(0 TO 7) := x"61";
	constant f : STD_LOGIC_VECTOR(0 TO 7) := x"66";
	constant e : STD_LOGIC_VECTOR(0 TO 7) := x"65";
	constant l : STD_LOGIC_VECTOR(0 TO 7) := x"6C";
	constant C : STD_LOGIC_VECTOR(0 TO 7) := x"43";
	constant T : STD_LOGIC_VECTOR(0 TO 7) := x"54";
	constant m : STD_LOGIC_VECTOR(0 TO 7) := x"6D";
	constant p : STD_LOGIC_VECTOR(0 TO 7) := x"70";
	constant min_r : STD_LOGIC_VECTOR(0 TO 7) := x"72";
	constant min_t : STD_LOGIC_VECTOR(0 TO 7) := x"74";
	constant u : STD_LOGIC_VECTOR(0 TO 7) := x"75";
	constant ascii_0 : STD_LOGIC_VECTOR(0 TO 7) := x"30";
	constant ascii_1 : STD_LOGIC_VECTOR(0 TO 7) := x"31";
	constant ascii_2 : STD_LOGIC_VECTOR(0 TO 7) := x"32";
	constant ascii_3 : STD_LOGIC_VECTOR(0 TO 7) := x"33";
	constant ascii_4 : STD_LOGIC_VECTOR(0 TO 7) := x"34";
	constant ascii_5 : STD_LOGIC_VECTOR(0 TO 7) := x"35";
	constant ascii_6 : STD_LOGIC_VECTOR(0 TO 7) := x"36";
	constant ascii_7 : STD_LOGIC_VECTOR(0 TO 7) := x"37";
	constant ascii_8 : STD_LOGIC_VECTOR(0 TO 7) := x"38";
	constant ascii_9 : STD_LOGIC_VECTOR(0 TO 7) := x"39";
	constant miasbola : STD_LOGIC_VECTOR(0 TO 7) := x"BA";

	signal clk_1khz_counter : INTEGER := 0;
	signal clk_1khz : STD_LOGIC := '0';
	
	signal tmp121_data : STD_LOGIC_VECTOR(0 TO 7) := "00000000";
	signal tmp121_count : INTEGER := 0;

	signal display_counter : INTEGER := 0;

	signal tmp121_integer : INTEGER := 0;
	signal tmp121_int_buf : INTEGER := 0;
	
	signal write_to_lcd : STD_LOGIC := '0';
	signal write_done : STD_LOGIC := '0';
	signal lcd_ready : STD_LOGIC := '0';
	signal lcd_counter : INTEGER := 0;
	
	signal digit1_int : INTEGER := 0;
	signal digit2_int : INTEGER := 0;
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
	signal cs1_sig : STD_LOGIC := '1';
	signal cs1_next_cycle : STD_LOGIC := '1';
	signal convert_sig : STD_LOGIC := '0';
	signal intbuf_saved : STD_LOGIC := '0';
	signal convert_done : STD_LOGIC := '0';

begin
	
	cs1 <= cs1_sig;
	rs <= rs_clk_signal;
	lcd_data <= lcd_data_signal;
	transistor <= "0000";
	cs_ad <= '1';
	clk_tmp121 <= clk_1khz;
	
	with digit1_int select
	digit1 <=
		ascii_0 when 0,
		ascii_1 when 1|10|100,
		ascii_2 when 2|20|200,
		ascii_3 when 3|30|300,
		ascii_4 when 4|40|400,
		ascii_5 when 5|50|500,
		ascii_6 when 6|60|600,
		ascii_7 when 7|70|700,
		ascii_8 when 8|80|800,
		ascii_9 when 9|90|900,
		x"58" when others;
		
	with digit2_int select
	digit2 <=
		ascii_0 when 0,
		ascii_1 when 1,
		ascii_2 when 2,
		ascii_3 when 3,
		ascii_4 when 4,
		ascii_5 when 5,
		ascii_6 when 6,
		ascii_7 when 7,
		ascii_8 when 8,
		ascii_9 when 9,
		x"58" when others;
	
	with switch select
	debug_clk <=
		1000 when "10000000" | "10010000",
		1 when others;
		
	with enable_signal select 
	clk_enable <=
		clk_1khz when '1',
		'0' when others;
		
	enable_lcd <= clk_enable;
	
	tmp121_integer <= to_integer(unsigned(tmp121_data));

	proc_info: process(clk_1khz)
	begin
		if switch(3) = '1' then
			led(0) <= lcd_data_signal(0);
			led(1) <= lcd_data_signal(1);
			led(2) <= lcd_data_signal(2);
			led(3) <= lcd_data_signal(3);
			led(4) <= lcd_data_signal(4);
			led(5) <= lcd_data_signal(5);
			led(6) <= lcd_data_signal(6);
			led(7) <= rs_clk_signal;
		else
			led <= tmp121_data;
		end if;
	end process;
	
	proc_convert: process(clk_in)
	begin
		if clk_in'event and clk_in = '1' then
			if write_to_lcd = '1' and write_done = '1' then
				digit1_int <= 0;
				digit2_int <= 0;
				write_to_lcd <= '0';
				convert_done <= '1';
			elsif convert_done = '1' and convert_sig = '0' then
				convert_done <= '0';
			elsif tmp121_count > 328 and convert_sig = '1' and write_to_lcd = '0' then
				if intbuf_saved = '0' then
					tmp121_int_buf <= tmp121_integer;
					intbuf_saved <= '1';
				elsif tmp121_int_buf >= 10 then
					tmp121_int_buf <= tmp121_int_buf - 10;
					digit1_int <= digit1_int + 1;
				else
					digit2_int <= tmp121_int_buf;
					write_to_lcd <= '1';
					intbuf_saved <= '0';
				end if;
			end if;
		end if;
	end process;
	
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
	
	proc_cs1: process(clk_1khz)
	begin
		if clk_1khz'event and clk_1khz = '0' then
			cs1_sig <= cs1_next_cycle;
		end if;
	end process;
	
	process_tmp121: process(clk_1khz)
	begin
		if clk_1khz'event and clk_1khz = '1' then
			
			if lcd_ready = '1' then
				if convert_sig = '1' and convert_done = '1' then
					convert_sig <= '0';
				else 
					-- realiza as operacoes
					case tmp121_count is
						when 0 to 318 => null; -- conta ate 320ms com cs em '1'
						when 319 => cs1_next_cycle <= '0'; -- ultimo ciclo da contagem alterando cs_next_cycle
						when 320 => null; -- atribui dados ate o 328 (enfia o 1 bit no cu)
						when 321 => tmp121_data(0) <= do;
						when 322 =>	tmp121_data(1) <= do;
						when 323 =>	tmp121_data(2) <= do;
						when 324 =>	tmp121_data(3) <= do;
						when 325 =>	tmp121_data(4) <= do;
						when 326 =>	tmp121_data(5) <= do;
						when 327 =>	tmp121_data(6) <= do;
						when 328 =>	
							tmp121_data(7) <= do;
							convert_sig <= '1';
						when 329 to 348 => null;-- espera ate fim dos 350ms
						when 349 => cs1_next_cycle <= '1'; -- ativa o cs_next_cycle
						when others => 
							null;
						
					end case;
					-- ajusta o counter
					case tmp121_count is
						when 0 to 348 =>
							tmp121_count <= tmp121_count + 1;
						when others =>
							tmp121_count <= 0;
					end case;
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
						rs_next_cycle <= '0';
						lcd_data_signal <= clear_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 4 to 6 => 
						lcd_counter <= lcd_counter + 1;
						lcd_data_signal <= x"00";
					when 7 =>
						lcd_counter <= lcd_counter + 1;
						rs_next_cycle <= '1';
					when 8 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= R;
						lcd_counter <= lcd_counter + 1;
					when 9 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= a;
						lcd_counter <= lcd_counter + 1;
					when 10 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= f;
						lcd_counter <= lcd_counter + 1;
					when 11 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= a;
						lcd_counter <= lcd_counter + 1;
					when 12 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= e;
						lcd_counter <= lcd_counter + 1;
					when 13 =>
						rs_next_cycle <= '0';
						lcd_data_signal <= l;						
						lcd_counter <= 0;
						lcd_ready <= '1';
					when others => null;
				end case;
			elsif write_to_lcd = '1' and write_done = '1' then
				null;
			elsif write_to_lcd = '0' and write_done = '1' then
				write_done <= '0';
			elsif write_to_lcd = '1' then
				case lcd_counter is
					when 0 => 
						rs_next_cycle <= '0';
						lcd_data_signal <= clear_conf_lcd;
						lcd_counter <= lcd_counter + 1;
					when 1 to 3 =>
						lcd_counter <= lcd_counter + 1;
						lcd_data_signal <= x"00";
					when 4 =>
						lcd_counter <= lcd_counter + 1;
						rs_next_cycle <= '1';
					when 5 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= digit1;
						lcd_counter <= lcd_counter + 1;
					when 6 =>
						rs_next_cycle <= '1';
						lcd_data_signal <= digit2;
						lcd_counter <= lcd_counter + 1;
					when 7 =>
						rs_next_cycle <= '0';
						lcd_data_signal <= C;
						lcd_counter <= 0;
						write_done <= '1';
					when others => null;
				end case;
			end if;
		end if;
	end process;

end Behavioral;

