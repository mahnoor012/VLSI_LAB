library ieee;
use ieee.std_logic_1164.all;

---------------- basic gates ----------------
entity gc_and2 is port (a, b : in std_logic; y : out std_logic); end gc_and2;
architecture rtl of gc_and2 is begin y <= a and b; end rtl;

library ieee; use ieee.std_logic_1164.all;
entity gc_xor2 is port (a, b : in std_logic; y : out std_logic); end gc_xor2;
architecture rtl of gc_xor2 is begin y <= a xor b; end rtl;

---------------- 1-bit full adder ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_fa is
    port (a, b, cin : in std_logic; sum, cout : out std_logic);
end gc_fa;
architecture rtl of gc_fa is
begin
    sum  <= a xor b xor cin;
    cout <= (a and b) or (cin and (a xor b));
end rtl;

---------------- D flip-flop, synchronous reset to 0 ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_dff is
    port (d, clk, reset : in std_logic; q : out std_logic);
end gc_dff;
architecture rtl of gc_dff is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then q <= '0'; else q <= d; end if;
        end if;
    end process;
end rtl;

---------------- D flip-flop, synchronous reset to 1 (for Z) ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_dffs is
    port (d, clk, reset : in std_logic; q : out std_logic);
end gc_dffs;
architecture rtl of gc_dffs is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then q <= '1'; else q <= d; end if;
        end if;
    end process;
end rtl;

---------------- 1. PC: 4 flip-flops + incrementer gates ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_pc is
    port (clk, reset : in std_logic; p0, p1, p2, p3 : out std_logic);
end gc_pc;
architecture struct of gc_pc is
    component gc_dff port (d, clk, reset : in std_logic; q : out std_logic); end component;
    signal s0, s1, s2, s3, n0, n1, n2, n3 : std_logic;
begin
    -- next = PC + 1
    n0 <= not s0;
    n1 <= s1 xor s0;
    n2 <= s2 xor (s1 and s0);
    n3 <= s3 xor (s2 and s1 and s0);

    PC0 : gc_dff port map (n0, clk, reset, s0);
    PC1 : gc_dff port map (n1, clk, reset, s1);
    PC2 : gc_dff port map (n2, clk, reset, s2);
    PC3 : gc_dff port map (n3, clk, reset, s3);

    p0 <= s0; p1 <= s1; p2 <= s2; p3 <= s3;
end struct;

---------------- 2. Program ROM as Boolean equations ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_rom is
    port (
        p0, p1, p2, p3 : in  std_logic;
        i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11 : out std_logic
    );
end gc_rom;
architecture rtl of gc_rom is
    signal a0, a1, a2, a3, a4, a5 : std_logic;   -- address decode
begin
    a0 <= not p3 and not p2 and not p1 and not p0;   -- address 0  LDI 0xF3  = 1F3
    a1 <= not p3 and not p2 and not p1 and     p0;   -- address 1  AND 0x3C  = 43C
    a2 <= not p3 and not p2 and     p1 and not p0;   -- address 2  XOR 0x11  = 611
    a3 <= not p3 and not p2 and     p1 and     p0;   -- address 3  SHR       = 900
    a4 <= not p3 and     p2 and not p1 and not p0;   -- address 4  ADD 0x30  = 230
    a5 <= not p3 and     p2 and not p1 and     p0;   -- address 5  XOR 0x40  = 640
                                                      -- other addresses: 000 (NOP)
    i11 <= a3;
    i10 <= a1 or a2 or a5;
    i9  <= a2 or a4 or a5;
    i8  <= a0 or a3;
    i7  <= a0;
    i6  <= a0 or a5;
    i5  <= a0 or a1 or a4;
    i4  <= a0 or a1 or a2 or a4;
    i3  <= a1;
    i2  <= a1;
    i1  <= a0;
    i0  <= a0 or a2;
end rtl;

---------------- 3. Control unit ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_ctrl is
    port (
        i8, i9, i10, i11 : in  std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr, we : out std_logic
    );
end gc_ctrl;
architecture rtl of gc_ctrl is
    signal l, a, n, x, s : std_logic;
begin
    l <= not i11 and not i10 and not i9 and     i8;   -- 0001 LDI
    a <= not i11 and not i10 and     i9 and not i8;   -- 0010 ADD
    n <= not i11 and     i10 and not i9 and not i8;   -- 0100 AND
    x <= not i11 and     i10 and     i9 and not i8;   -- 0110 XOR
    s <=     i11 and not i10 and not i9 and     i8;   -- 1001 SHR

    is_ldi <= l; is_add <= a; is_and <= n; is_xor <= x; is_shr <= s;
    we <= l or a or n or x or s;                        -- NOP: we = 0
end rtl;

---------------- 4a. ALU slice (1 bit) ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_alu_slice is
    port (
        a, imm, cin, ashr : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr : in std_logic;
        y, cout : out std_logic
    );
end gc_alu_slice;
architecture struct of gc_alu_slice is
    component gc_and2 port (a, b : in std_logic; y : out std_logic); end component;
    component gc_xor2 port (a, b : in std_logic; y : out std_logic); end component;
    component gc_fa   port (a, b, cin : in std_logic; sum, cout : out std_logic); end component;
    signal w_and, w_xor, w_sum : std_logic;
begin
    AND_U : gc_and2 port map (a, imm, w_and);
    XOR_U : gc_xor2 port map (a, imm, w_xor);
    FA_U  : gc_fa   port map (a, imm, cin, w_sum, cout);

    y <= (is_ldi and imm) or (is_and and w_and) or (is_xor and w_xor)
      or (is_add and w_sum) or (is_shr and ashr);
end struct;

---------------- 4b. ALU (8 slices) ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_alu is
    port (
        a0,a1,a2,a3,a4,a5,a6,a7 : in std_logic;
        m0,m1,m2,m3,m4,m5,m6,m7 : in std_logic;     -- immediate
        is_ldi, is_add, is_and, is_xor, is_shr : in std_logic;
        r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic
    );
end gc_alu;
architecture struct of gc_alu is
    component gc_alu_slice port (
        a, imm, cin, ashr : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr : in std_logic;
        y, cout : out std_logic);
    end component;
    signal c1,c2,c3,c4,c5,c6,c7,c8 : std_logic;
begin
    S0 : gc_alu_slice port map (a0,m0,'0',a1, is_ldi,is_add,is_and,is_xor,is_shr, r0,c1);
    S1 : gc_alu_slice port map (a1,m1,c1, a2, is_ldi,is_add,is_and,is_xor,is_shr, r1,c2);
    S2 : gc_alu_slice port map (a2,m2,c2, a3, is_ldi,is_add,is_and,is_xor,is_shr, r2,c3);
    S3 : gc_alu_slice port map (a3,m3,c3, a4, is_ldi,is_add,is_and,is_xor,is_shr, r3,c4);
    S4 : gc_alu_slice port map (a4,m4,c4, a5, is_ldi,is_add,is_and,is_xor,is_shr, r4,c5);
    S5 : gc_alu_slice port map (a5,m5,c5, a6, is_ldi,is_add,is_and,is_xor,is_shr, r5,c6);
    S6 : gc_alu_slice port map (a6,m6,c6, a7, is_ldi,is_add,is_and,is_xor,is_shr, r6,c7);
    S7 : gc_alu_slice port map (a7,m7,c7, '0',is_ldi,is_add,is_and,is_xor,is_shr, r7,c8);
end struct;

---------------- 5. ACC (8 flip-flops) and Z flag ----------------
library ieee; use ieee.std_logic_1164.all;
entity gc_acc is
    port (
        clk, reset, we : in std_logic;
        d0,d1,d2,d3,d4,d5,d6,d7 : in  std_logic;
        q0,q1,q2,q3,q4,q5,q6,q7 : out std_logic;
        z : out std_logic
    );
end gc_acc;
architecture struct of gc_acc is
    component gc_dff  port (d, clk, reset : in std_logic; q : out std_logic); end component;
    component gc_dffs port (d, clk, reset : in std_logic; q : out std_logic); end component;
    signal s0,s1,s2,s3,s4,s5,s6,s7 : std_logic;     -- ACC output
    signal m0,m1,m2,m3,m4,m5,m6,m7 : std_logic;     -- hold or load
    signal zs, zr, zm : std_logic;
begin
    -- we = 1: load result, we = 0: hold old value
    m0 <= (we and d0) or ((not we) and s0);
    m1 <= (we and d1) or ((not we) and s1);
    m2 <= (we and d2) or ((not we) and s2);
    m3 <= (we and d3) or ((not we) and s3);
    m4 <= (we and d4) or ((not we) and s4);
    m5 <= (we and d5) or ((not we) and s5);
    m6 <= (we and d6) or ((not we) and s6);
    m7 <= (we and d7) or ((not we) and s7);

    A0 : gc_dff port map (m0, clk, reset, s0);
    A1 : gc_dff port map (m1, clk, reset, s1);
    A2 : gc_dff port map (m2, clk, reset, s2);
    A3 : gc_dff port map (m3, clk, reset, s3);
    A4 : gc_dff port map (m4, clk, reset, s4);
    A5 : gc_dff port map (m5, clk, reset, s5);
    A6 : gc_dff port map (m6, clk, reset, s6);
    A7 : gc_dff port map (m7, clk, reset, s7);

    -- Z = 1 when the new value is 0
    zr <= not (d0 or d1 or d2 or d3 or d4 or d5 or d6 or d7);
    zm <= (we and zr) or ((not we) and zs);
    ZFF : gc_dffs port map (zm, clk, reset, zs);      -- reset sets Z to 1

    q0 <= s0; q1 <= s1; q2 <= s2; q3 <= s3;
    q4 <= s4; q5 <= s5; q6 <= s6; q7 <= s7;
    z  <= zs;
end struct;

---------------- Top: gate-level 8-bit CPU ----------------
library ieee; use ieee.std_logic_1164.all;
entity cpu8_gate is
    port (
        clk, reset              : in  std_logic;
        q0,q1,q2,q3,q4,q5,q6,q7 : out std_logic;     -- ACC
        z                       : out std_logic;     -- Z flag
        pc0,pc1,pc2,pc3         : out std_logic      -- PC
    );
end cpu8_gate;
architecture struct of cpu8_gate is
    component gc_pc port (clk, reset : in std_logic; p0, p1, p2, p3 : out std_logic); end component;
    component gc_rom port (
        p0, p1, p2, p3 : in std_logic;
        i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11 : out std_logic); end component;
    component gc_ctrl port (
        i8, i9, i10, i11 : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr, we : out std_logic); end component;
    component gc_alu port (
        a0,a1,a2,a3,a4,a5,a6,a7 : in std_logic;
        m0,m1,m2,m3,m4,m5,m6,m7 : in std_logic;
        is_ldi, is_add, is_and, is_xor, is_shr : in std_logic;
        r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic); end component;
    component gc_acc port (
        clk, reset, we : in std_logic;
        d0,d1,d2,d3,d4,d5,d6,d7 : in std_logic;
        q0,q1,q2,q3,q4,q5,q6,q7 : out std_logic;
        z : out std_logic); end component;

    signal p0,p1,p2,p3 : std_logic;
    signal i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11 : std_logic;
    signal is_ldi, is_add, is_and, is_xor, is_shr, we : std_logic;
    signal r0,r1,r2,r3,r4,r5,r6,r7 : std_logic;
    signal a0,a1,a2,a3,a4,a5,a6,a7 : std_logic;
begin
    U_PC   : gc_pc   port map (clk, reset, p0, p1, p2, p3);
    U_ROM  : gc_rom  port map (p0, p1, p2, p3, i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11);
    U_CTRL : gc_ctrl port map (i8, i9, i10, i11, is_ldi, is_add, is_and, is_xor, is_shr, we);
    U_ALU  : gc_alu  port map (a0,a1,a2,a3,a4,a5,a6,a7, i0,i1,i2,i3,i4,i5,i6,i7,
                               is_ldi, is_add, is_and, is_xor, is_shr,
                               r0,r1,r2,r3,r4,r5,r6,r7);
    U_ACC  : gc_acc  port map (clk, reset, we, r0,r1,r2,r3,r4,r5,r6,r7,
                               a0,a1,a2,a3,a4,a5,a6,a7, z);

    q0 <= a0; q1 <= a1; q2 <= a2; q3 <= a3;
    q4 <= a4; q5 <= a5; q6 <= a6; q7 <= a7;
    pc0 <= p0; pc1 <= p1; pc2 <= p2; pc3 <= p3;
end struct;