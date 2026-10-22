library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_ctrl_tb is
end gc_ctrl_tb;

architecture sim of gc_ctrl_tb is
    component gc_ctrl port (
        i8, i9, i10, i11 : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr, we : out std_logic);
    end component;
    signal i8, i9, i10, i11 : std_logic := '0';
    signal is_ldi, is_add, is_and, is_xor, is_shr, we : std_logic;

    -- expected {is_ldi, is_add, is_and, is_xor, is_shr, we} for each opcode
    function expected (n : integer) return std_logic_vector is
    begin
        case n is
            when 1 => return "100001";   -- LDI
            when 2 => return "010001";   -- ADD
            when 4 => return "001001";   -- AND
            when 6 => return "000101";   -- XOR
            when 9 => return "000011";   -- SHR
            when others => return "000000";   -- NOP
        end case;
    end function;

    function name_of (n : integer) return string is
    begin
        case n is
            when 1 => return "LDI";
            when 2 => return "ADD";
            when 4 => return "AND";
            when 6 => return "XOR";
            when 9 => return "SHR";
            when others => return "NOP";
        end case;
    end function;
begin
    DUT : gc_ctrl port map (i8, i9, i10, i11, is_ldi, is_add, is_and, is_xor, is_shr, we);

    stim : process
        variable errors : integer := 0;
        variable ov : unsigned(3 downto 0);
        variable got : std_logic_vector(5 downto 0);
    begin
        for n in 0 to 15 loop
            ov := to_unsigned(n, 4);
            i8 <= ov(0); i9 <= ov(1); i10 <= ov(2); i11 <= ov(3);
            wait for 10 ns;
            got := is_ldi & is_add & is_and & is_xor & is_shr & we;
            if got = expected(n) then
                report "PASS  opcode " & integer'image(n) & "  " & name_of(n)
                       & "  we=" & std_logic'image(we);
            else
                errors := errors + 1;
                report "FAIL  opcode " & integer'image(n) & "  " & name_of(n) severity error;
            end if;
        end loop;

        if errors = 0 then
            report "CONTROL: ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;