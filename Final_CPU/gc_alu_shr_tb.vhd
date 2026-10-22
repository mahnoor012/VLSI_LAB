library ieee;
use ieee.std_logic_1164.all;

entity gc_alu_shr_tb is
end gc_alu_shr_tb;

architecture sim of gc_alu_shr_tb is
    component gc_alu port (
        a0,a1,a2,a3,a4,a5,a6,a7 : in std_logic;
        m0,m1,m2,m3,m4,m5,m6,m7 : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr : in std_logic;
        r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic);
    end component;

    signal a0,a1,a2,a3,a4,a5,a6,a7 : std_logic := '0';
    signal m0,m1,m2,m3,m4,m5,m6,m7 : std_logic := '0';
    signal is_ldi, is_add, is_and, is_xor, is_shr : std_logic;
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
    -- only the SHR instruction is selected in this testbench
    is_ldi <= '0';
    is_add <= '0';
    is_and <= '0';
    is_xor <= '0';
    is_shr <= '1';

    DUT : gc_alu port map (
        a0,a1,a2,a3,a4,a5,a6,a7,
        m0,m1,m2,m3,m4,m5,m6,m7,
        is_ldi, is_add, is_and, is_xor, is_shr,
        r0,r1,r2,r3,r4,r5,r6,r7);

    stim : process
        variable errors : integer := 0;

        procedure test (acc_v, imm_v, exp_r : std_logic_vector(7 downto 0)) is
            variable r_v : std_logic_vector(7 downto 0);
        begin
            a0 <= acc_v(0); a1 <= acc_v(1); a2 <= acc_v(2); a3 <= acc_v(3);
            a4 <= acc_v(4); a5 <= acc_v(5); a6 <= acc_v(6); a7 <= acc_v(7);
            m0 <= imm_v(0); m1 <= imm_v(1); m2 <= imm_v(2); m3 <= imm_v(3);
            m4 <= imm_v(4); m5 <= imm_v(5); m6 <= imm_v(6); m7 <= imm_v(7);
            wait for 10 ns;

            r_v := r7 & r6 & r5 & r4 & r3 & r2 & r1 & r0;
            if r_v = exp_r then
                report "PASS  SHR  ACC=" & hex8(acc_v) & "  IMM=" & hex8(imm_v)
                       & "  RESULT=" & hex8(r_v);
            else
                errors := errors + 1;
                report "FAIL  SHR  ACC=" & hex8(acc_v) & "  IMM=" & hex8(imm_v)
                       & "  got " & hex8(r_v) & "  expected " & hex8(exp_r) severity error;
            end if;
        end procedure;
    begin
        --   ACC     IMM   expected
        test(x"21", x"FF", x"10");
        test(x"01", x"FF", x"00");
        test(x"FF", x"00", x"7F");
        test(x"80", x"00", x"40");
        test(x"00", x"00", x"00");
        test(x"F3", x"00", x"79");

        if errors = 0 then
            report "SHR: ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;