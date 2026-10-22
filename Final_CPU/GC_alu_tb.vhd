library ieee;
use ieee.std_logic_1164.all;

entity gc_alu_tb is
end gc_alu_tb;

architecture sim of gc_alu_tb is
    component gc_alu port (
        a0,a1,a2,a3,a4,a5,a6,a7 : in std_logic;
        m0,m1,m2,m3,m4,m5,m6,m7 : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr : in std_logic;
        r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic);
    end component;

    signal a0,a1,a2,a3,a4,a5,a6,a7 : std_logic := '0';
    signal m0,m1,m2,m3,m4,m5,m6,m7 : std_logic := '0';
    signal is_ldi, is_add, is_and, is_xor, is_shr : std_logic := '0';
    signal r0,r1,r2,r3,r4,r5,r6,r7 : std_logic;

    function hex4 (v : std_logic_vector(3 downto 0)) return character is
    begin
        case v is
            when "0000" => return '0'; when "0001" => return '1';
            when "0010" => return '2'; when "0011" => return '3';
            when "0100" => return '4'; when "0101" => return '5';
            when "0110" => return '6'; when "0111" => return '7';
            when "1000" => return '8'; when "1001" => return '9';
            when "1010" => return 'A'; when "1011" => return 'B';
            when "1100" => return 'C'; when "1101" => return 'D';
            when "1110" => return 'E'; when "1111" => return 'F';
            when others => return 'X';
        end case;
    end function;

    function hex8 (v : std_logic_vector(7 downto 0)) return string is
    begin
        return "0x" & hex4(v(7 downto 4)) & hex4(v(3 downto 0));
    end function;
begin
    DUT : gc_alu port map (
        a0,a1,a2,a3,a4,a5,a6,a7,
        m0,m1,m2,m3,m4,m5,m6,m7,
        is_ldi, is_add, is_and, is_xor, is_shr,
        r0,r1,r2,r3,r4,r5,r6,r7);

    stim : process
        variable errors : integer := 0;

        -- op: 0 = LDI, 1 = ADD, 2 = AND, 3 = XOR, 4 = SHR, 5 = nothing selected
        procedure test (name : string; op : integer;
                        acc_v, imm_v, exp_r : std_logic_vector(7 downto 0)) is
            variable r_v : std_logic_vector(7 downto 0);
        begin
            a0 <= acc_v(0); a1 <= acc_v(1); a2 <= acc_v(2); a3 <= acc_v(3);
            a4 <= acc_v(4); a5 <= acc_v(5); a6 <= acc_v(6); a7 <= acc_v(7);
            m0 <= imm_v(0); m1 <= imm_v(1); m2 <= imm_v(2); m3 <= imm_v(3);
            m4 <= imm_v(4); m5 <= imm_v(5); m6 <= imm_v(6); m7 <= imm_v(7);
            if op = 0 then is_ldi <= '1'; else is_ldi <= '0'; end if;
            if op = 1 then is_add <= '1'; else is_add <= '0'; end if;
            if op = 2 then is_and <= '1'; else is_and <= '0'; end if;
            if op = 3 then is_xor <= '1'; else is_xor <= '0'; end if;
            if op = 4 then is_shr <= '1'; else is_shr <= '0'; end if;
            wait for 10 ns;

            r_v := r7 & r6 & r5 & r4 & r3 & r2 & r1 & r0;
            if r_v = exp_r then
                report "PASS  " & name & "  ACC=" & hex8(acc_v) & "  IMM=" & hex8(imm_v)
                       & "  RESULT=" & hex8(r_v);
            else
                errors := errors + 1;
                report "FAIL  " & name & "  ACC=" & hex8(acc_v) & "  IMM=" & hex8(imm_v)
                       & "  got " & hex8(r_v) & "  expected " & hex8(exp_r) severity error;
            end if;
        end procedure;
    begin
        --         name      op   ACC         IMM         expected
        test("LDI  ",  0, x"55", x"F3", x"F3");   -- ACC is ignored
        test("LDI  ",  0, x"FF", x"00", x"00");

        test("ADD  ",  1, x"10", x"30", x"40");
        test("ADD  ",  1, x"7F", x"01", x"80");
        test("ADD  ",  1, x"FF", x"01", x"00");   -- 256, carry is discarded
        test("ADD  ",  1, x"C8", x"64", x"2C");   -- 200 + 100 = 300 -> 44
        test("ADD  ",  1, x"00", x"00", x"00");

        test("AND  ",  2, x"F3", x"3C", x"30");
        test("AND  ",  2, x"FF", x"00", x"00");
        test("AND  ",  2, x"AA", x"0F", x"0A");

        test("XOR  ",  3, x"30", x"11", x"21");
        test("XOR  ",  3, x"40", x"40", x"00");   -- same value gives 0
        test("XOR  ",  3, x"FF", x"00", x"FF");
        test("XOR  ",  3, x"AA", x"55", x"FF");

        test("SHR  ",  4, x"21", x"00", x"10");
        test("SHR  ",  4, x"01", x"00", x"00");   -- LSB is lost
        test("SHR  ",  4, x"FF", x"00", x"7F");   -- 0 enters the MSB
        test("SHR  ",  4, x"80", x"00", x"40");

        test("NONE ",  5, x"AA", x"55", x"00");   -- nothing selected -> 0

        if errors = 0 then
            report "ALU: ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;