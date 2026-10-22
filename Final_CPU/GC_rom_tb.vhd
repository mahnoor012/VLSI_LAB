library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_rom_tb is
end gc_rom_tb;

architecture sim of gc_rom_tb is
    component gc_rom port (
        p0, p1, p2, p3 : in std_logic;
        i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11 : out std_logic);
    end component;
    signal p0, p1, p2, p3 : std_logic := '0';
    signal i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11 : std_logic;

    function expected (n : integer) return std_logic_vector is
    begin
        case n is
            when 0 => return x"1F3";   -- LDI 0xF3
            when 1 => return x"43C";   -- AND 0x3C
            when 2 => return x"611";   -- XOR 0x11
            when 3 => return x"900";   -- SHR
            when 4 => return x"230";   -- ADD 0x30
            when 5 => return x"640";   -- XOR 0x40
            when others => return x"000";   -- NOP
        end case;
    end function;

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

    function hex12 (v : std_logic_vector(11 downto 0)) return string is
    begin
        return "0x" & hex4(v(11 downto 8)) & hex4(v(7 downto 4)) & hex4(v(3 downto 0));
    end function;
begin
    DUT : gc_rom port map (p0, p1, p2, p3, i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11);

    stim : process
        variable errors : integer := 0;
        variable av : unsigned(3 downto 0);
        variable got : std_logic_vector(11 downto 0);
    begin
        for n in 0 to 15 loop
            av := to_unsigned(n, 4);
            p0 <= av(0); p1 <= av(1); p2 <= av(2); p3 <= av(3);
            wait for 10 ns;
            got := i11 & i10 & i9 & i8 & i7 & i6 & i5 & i4 & i3 & i2 & i1 & i0;
            if got = expected(n) then
                report "PASS  address " & integer'image(n) & "  ROM=" & hex12(got);
            else
                errors := errors + 1;
                report "FAIL  address " & integer'image(n) & "  got " & hex12(got)
                       & "  expected " & hex12(expected(n)) severity error;
            end if;
        end loop;

        if errors = 0 then
            report "ROM: ALL TESTS PASSED" severity note;
        else
            report integer'image(errors) & " TEST(S) FAILED" severity error;
        end if;
        wait;
    end process;
end sim;