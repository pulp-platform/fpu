-------------------------------------------------------------------------------
-- Title      : VHDL Tools Library
-- Project    : 
-------------------------------------------------------------------------------
-- File       : VHDLTools.vhd
-- Author     : Andreas P. Burg (apburg@iis.ee.ethz.ch)
-- Company    : Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Description: 
--
-- This package contains a set of functions and types to ease the
-- designers life with VHDL. 
--
-------------------------------------------------------------------------------
-- Copyright (c) 2014 Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author     Description
-- 2003        1.0      apburg     Created
-- 10.03.2004  1.1      apburg     First Release
-- 22.10.2010  1.2      schaffner  vector reverse function added
-- 17.02.2012  1.3      schaffner  vector logic functions added
-- 21.02.2012  1.4      schaffner  vector/scalar logic functions added
-- 12.12.2013  1.5      schaffner  vector reductions use tree structures now
-- 21.01.2014  1.6      schaffner  bool to std_logic conversion, divisible check
-- 14.03.2014  1.61     schaffner  hot encoding added
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package VHDLTools is

  -----------------------------------------------------------------------------
  -- ThermometerEncode(x)
  -----------------------------------------------------------------------------
  function ThermometerEncode (n         : unsigned) return std_logic_vector;
  
  function ThermEncodeUp (n : unsigned; len: natural; incl: boolean) return std_logic_vector;
  function ThermEncodeDn (n : unsigned; len: natural; incl: boolean) return std_logic_vector;
  
  -----------------------------------------------------------------------------
  -- Hot one encoding (for downto and to ranges...)
  -----------------------------------------------------------------------------
  function Hot1EncodeUp (n : unsigned; len: natural) return std_logic_vector;
  function Hot1EncodeDn (n : unsigned; len: natural) return std_logic_vector;
  
  -----------------------------------------------------------------------------
  -- Ceil(Log2(x))
  -----------------------------------------------------------------------------
  function log2ceil (n                  : natural) return natural;
  -----------------------------------------------------------------------------
  -- Floor(Log2(x))
  -----------------------------------------------------------------------------
  function log2floor (n                 : natural) return natural;
  function log2floor (n                 : unsigned) return unsigned;
  -----------------------------------------------------------------------------
  -- Max(n,m)
  -----------------------------------------------------------------------------
  function max (n                       : integer; m : integer) return integer;
  -----------------------------------------------------------------------------
  -- Minimum(n,m)
  -----------------------------------------------------------------------------
  function minimum (n                   : integer; m : integer) return integer;
  -----------------------------------------------------------------------------
  -- Reverse Byte Order
  -----------------------------------------------------------------------------
  function ReverseByteOrder (constant A : integer) return integer;

  -----------------------------------------------------------------------------
  -- Reverse Vector Bits
  -----------------------------------------------------------------------------   
  function VectorFliplr (inval : std_logic_vector) return std_logic_vector;
  function VectorFliplr (inval : unsigned) return unsigned;

  -----------------------------------------------------------------------------
  -- Boolean to std_logic
  -----------------------------------------------------------------------------   
  function to_std_logic ( inval: boolean; activeLow: boolean) return std_logic;
  
  -----------------------------------------------------------------------------
  -- divisibility check
  -----------------------------------------------------------------------------   
  function isDiv ( a: natural; b: natural) return natural;
  
  -----------------------------------------------------------------------------
  -- vector logic functions
  -----------------------------------------------------------------------------
  function VectorAND  (inval  : unsigned) return std_logic;
  function VectorNAND (inval  : unsigned) return std_logic;
  function VectorOR   (inval  : unsigned) return std_logic;
  function VectorNOR  (inval  : unsigned) return std_logic;
  function VectorXOR  (inval  : unsigned) return std_logic;
  function VectorXNOR (inval  : unsigned) return std_logic;
  function VectorAND  (inval  : std_logic_vector) return std_logic;
  function VectorNAND (inval  : std_logic_vector) return std_logic;
  function VectorOR   (inval  : std_logic_vector) return std_logic;
  function VectorNOR  (inval  : std_logic_vector) return std_logic;
  function VectorXOR  (inval  : std_logic_vector) return std_logic;
  function VectorXNOR (inval  : std_logic_vector) return std_logic;

  function VectorAND (inval1  : unsigned; inval2  : unsigned) return unsigned;
  function VectorNAND(inval1  : unsigned; inval2  : unsigned) return unsigned;
  function VectorOR  (inval1  : unsigned; inval2  : unsigned) return unsigned;
  function VectorNOR (inval1  : unsigned; inval2  : unsigned) return unsigned;
  function VectorAND (inval1  : std_logic_vector; inval2  : std_logic_vector) return std_logic_vector;
  function VectorNAND(inval1  : std_logic_vector; inval2  : std_logic_vector) return std_logic_vector;
  function VectorOR  (inval1  : std_logic_vector; inval2  : std_logic_vector) return std_logic_vector;
  function VectorNOR (inval1  : std_logic_vector; inval2  : std_logic_vector) return std_logic_vector;
  
  function VectScalAND (vect  : unsigned; scal : std_logic) return unsigned;
  function VectScalNAND(vect  : unsigned; scal : std_logic) return unsigned;
  function VectScalOR  (vect  : unsigned; scal : std_logic) return unsigned;
  function VectScalNOR (vect  : unsigned; scal : std_logic) return unsigned;
  function VectScalXOR (vect  : unsigned; scal : std_logic) return unsigned;
  
  function VectScalAND (vect  : std_logic_vector; scal : std_logic) return std_logic_vector;
  function VectScalNAND(vect  : std_logic_vector; scal : std_logic) return std_logic_vector;
  function VectScalOR  (vect  : std_logic_vector; scal : std_logic) return std_logic_vector;
  function VectScalNOR (vect  : std_logic_vector; scal : std_logic) return std_logic_vector;
  function VectScalXOR (vect  : std_logic_vector; scal : std_logic) return std_logic_vector;
  
  
  function VectorNOT (inval  : unsigned) return unsigned;
  function VectorNOT (inval  : std_logic_vector) return std_logic_vector;


  
end VHDLTools;

package body VHDLTools is

  -- purpose : do thermometer encoding of an unsigned number
  function ThermometerEncode (n : unsigned) return std_logic_vector is
    variable v_Out : std_logic_vector((2**n'length)-1-1 downto 0);
  begin
    for i in 0 to (2**(n'length))-1-1 loop
      if n > i then
        v_Out(i) := '1';
      else
        v_Out(i) := '0';
      end if;
    end loop;  -- i
    return v_Out;
  end ThermometerEncode;


  function ThermEncodeUp (n : unsigned; len: natural; incl: boolean) return std_logic_vector is
    variable v_Out : std_logic_vector(0 to len-1);
  begin
    
    if incl then
      for k in 0 to len-1 loop
        if k <= n then
          v_Out(k) := '1';
        else
          v_Out(k) := '0';
        end if;
      end loop;       
    else
      for k in 0 to len-1 loop
        if k < n then
          v_Out(k) := '1';
        else
          v_Out(k) := '0';
        end if;
      end loop;       
    end if;    
    
    return v_Out;
  end ThermEncodeUp;

  function ThermEncodeDn (n : unsigned; len: natural; incl: boolean) return std_logic_vector is
    variable v_Out : std_logic_vector(len-1 downto 0);
  begin
    
    if incl then
      for k in 0 to len-1 loop
        if k <= n then
          v_Out(k) := '1';
        else
          v_Out(k) := '0';
        end if;
      end loop;       
    else
      for k in 0 to len-1 loop
        if k < n then
          v_Out(k) := '1';
        else
          v_Out(k) := '0';
        end if;
      end loop;       
    end if;    
    
    return v_Out;
  end ThermEncodeDn;



  function Hot1EncodeDn (n : unsigned; len: natural) return std_logic_vector is
    variable v_Out : std_logic_vector(len-1 downto 0);
  begin
    v_Out := (others=>'0');
    if n < len then
    	v_Out(to_integer(n)) := '1';
    end if;
    return v_Out;
  end Hot1EncodeDn;

   function Hot1EncodeUp (n : unsigned; len: natural) return std_logic_vector is
    variable v_Out : std_logic_vector(0 to len-1);
  begin
    v_Out := (others=>'0');
    if n < len then
    	v_Out(to_integer(n)) := '1';
    end if;
    v_Out(to_integer(n)) := '1';
    return v_Out;
  end Hot1EncodeUp;
 
  -- purpose : computes ceil(log2(n)) to get "bit width"
  function log2ceil (n : natural) return natural is
  begin  -- log2ceil
    if n = 0 then
      return 0;
    end if;
    for index in 1 to 32 loop
      if (2**index >= n) then
        return index;
      end if;
    end loop;  -- n
  end log2ceil;

  -- purpose : computes floor(log2(n)) 
  function log2floor (n : natural) return natural is
    variable n_bit : unsigned(31 downto 0);
  begin  -- log2ceil
    n_bit := to_unsigned(n, 32);
    for i in 31 downto 0 loop
      if n_bit(i) = '1' then
        return i;
      end if;
    end loop;  -- i
    return 0;
  end log2floor;

  -- purpose : computes floor(log2(n)) 
  function log2floor (n : unsigned) return unsigned is
  begin  -- log2ceil
    for i in (n'length)-1 downto 0 loop
      if n(i+n'low) = '1' then
        return to_unsigned(i, log2ceil(n'length));
      end if;
    end loop;  -- i
    return to_unsigned(0, log2ceil(n'length));
  end log2floor;

  -- purpose : computes max(n,m)
  function max (n : integer; m : integer) return integer is
  begin  -- max(n,m)
    if n > m then
      return n;
    else
      return m;
    end if;
  end max;

  -- purpose : computes minimum(n,m)
  -- note: Avoiding name collision with VHDL's "min"
  function minimum (n : integer; m : integer) return integer is
  begin  -- minimum(n,m)
    if n < m then
      return n;
    else
      return m;
    end if;
  end minimum;

  -- purpose : ReverseByteOrder(integer) reverses the order of the bytes
  -- to convert between little and big-endian
  function ReverseByteOrder (
    constant A : integer)
    return integer is
    variable temp  : signed(32-1 downto 0);
    variable temp2 : signed(32-1 downto 0);
  begin
    temp                    := to_signed(A, temp'length);
    temp2(32-1 downto 32-8) := temp(8-1 downto 0);
    temp2(24-1 downto 24-8) := temp(16-1 downto 8);
    temp2(16-1 downto 16-8) := temp(24-1 downto 16);
    temp2(8-1 downto 8-8)   := temp(32-1 downto 24);
    return to_integer(temp2);
  end ReverseByteOrder;


  -- purpose : reverse bit order of std_logic_vectors
  function VectorFliplr (inval : std_logic_vector) return std_logic_vector is
    variable outval : std_logic_vector(inval'reverse_range);
  begin
    for i in inval'range loop
      outval(i) := inval(i);
    end loop;
    return outval;
  end VectorFliplr;



  function VectorFliplr (inval : unsigned) return unsigned is
  begin
    return unsigned(VectorFliplr(std_logic_vector(inval)));
  end VectorFliplr;



  function to_std_logic ( inval: boolean; activeLow: boolean) return std_logic is
    variable tmp : std_logic := '1';
  begin
    
    if activeLow then
      tmp := not tmp;
    end if;
    
    if inval then
      return tmp;
    else
      return not tmp;
    end if;  
  end to_std_logic;


  function isDiv ( a: natural; b: natural) return natural is
  begin
    if (a mod b) = 0 then
      return 1;
    else
      return 0;
    end if;  
  end isDiv;
  

  function VectorAND (inval1 : std_logic_vector; inval2 : std_logic_vector) return std_logic_vector is
    variable outval : std_logic_vector(inval1'range);
  begin
    for k in inval1'range loop
      outval(k) := inval1(k) and inval2(k);
    end loop;
    return outval;
  end VectorAND;


  function VectorAND (inval1 : unsigned; inval2 : unsigned) return unsigned is
  begin
    return unsigned(VectorAND(std_logic_vector(inval1),std_logic_vector(inval2)));
  end VectorAND;
  
  function VectorNAND (inval1 : std_logic_vector; inval2 : std_logic_vector) return std_logic_vector is
    variable outval : std_logic_vector(inval1'range);
  begin
    for k in inval1'range loop
      outval(k) := inval1(k) nand inval2(k);
    end loop;
    return outval;
  end VectorNAND;


  function VectorNAND (inval1 : unsigned; inval2 : unsigned) return unsigned is
  begin
    return unsigned(VectorNAND(std_logic_vector(inval1),std_logic_vector(inval2)));
  end VectorNAND;
  
  function VectorOR (inval1 : std_logic_vector; inval2 : std_logic_vector) return std_logic_vector is
    variable outval : std_logic_vector(inval1'range);
  begin
    for k in inval1'range loop
      outval(k) := inval1(k) or inval2(k);
    end loop;
    return outval;
  end VectorOR;


  function VectorOR (inval1 : unsigned; inval2 : unsigned) return unsigned is
  begin
    return unsigned(VectorOR(std_logic_vector(inval1),std_logic_vector(inval2)));
  end VectorOR;
  
  function VectorNOR (inval1 : std_logic_vector; inval2 : std_logic_vector) return std_logic_vector is
    variable outval : std_logic_vector(inval1'range);
  begin
    for k in inval1'range loop
      outval(k) := inval1(k) nor inval2(k);
    end loop;
    return outval;
  end VectorNOR;


  function VectorNOR (inval1 : unsigned; inval2 : unsigned) return unsigned is
  begin
    return unsigned(VectorNOR(std_logic_vector(inval1),std_logic_vector(inval2)));
  end VectorNOR;


  function VectorAND (inval : std_logic_vector) return std_logic is
    variable tmp    : std_logic_vector(inval'length-1 downto 0);
  begin
   
    -- init
    tmp := inval;
    
    for l in 1 to log2ceil(inval'length) loop
       for k in 0 to (inval'length-1)/2**(l-1) loop
         if k mod 2 = 0 then
         --report integer'image(l) & " -- " & integer'image(k/2); 
           tmp(k/2) := tmp(k);
         else
           tmp(k/2) := tmp(k-1) and tmp(k);
         end if;
       end loop;
    end loop;
    
    return tmp(0);
  end VectorAND;


  function VectorAND (inval : unsigned) return std_logic is
  begin
    return VectorAND(std_logic_vector(inval));
  end VectorAND;


  function VectorNAND (inval : std_logic_vector) return std_logic is
  begin
    return (not VectorAND(inval));
  end VectorNAND;


  function VectorNAND (inval : unsigned) return std_logic is
  begin
    return VectorNAND(std_logic_vector(inval));
  end VectorNAND;


  function VectorOR (inval : std_logic_vector) return std_logic is
      variable tmp    : std_logic_vector(inval'length-1 downto 0);
  begin
   
    -- init
    tmp := inval;
    
    for l in 1 to log2ceil(inval'length) loop
       for k in 0 to (inval'length-1)/2**(l-1) loop
         if k mod 2 = 0 then
         --report integer'image(l) & " -- " & integer'image(k/2); 
           tmp(k/2) := tmp(k);
         else
           tmp(k/2) := tmp(k-1) or tmp(k);
         end if;
       end loop;
    end loop;
    
    return tmp(0);
  end VectorOR;


  function VectorOR (inval : unsigned) return std_logic is
  begin
    return VectorOR(std_logic_vector(inval));
  end VectorOR;


  function VectorNOR (inval : std_logic_vector) return std_logic is
  begin
    return (not VectorOR(inval));
  end VectorNOR;


  function VectorNOR (inval : unsigned) return std_logic is
  begin
    return VectorNOR(std_logic_vector(inval));
  end VectorNOR;


  function VectorXOR (inval : std_logic_vector) return std_logic is
      variable tmp    : std_logic_vector(inval'length-1 downto 0);
  begin
   
    -- init
    tmp := inval;
    
    for l in 1 to log2ceil(inval'length) loop
       for k in 0 to (inval'length-1)/2**(l-1) loop
         if k mod 2 = 0 then
         --report integer'image(l) & " -- " & integer'image(k/2); 
           tmp(k/2) := tmp(k);
         else
           tmp(k/2) := tmp(k-1) xor tmp(k);
         end if;
       end loop;
    end loop;
    
    return tmp(0);
  end VectorXOR;


  function VectorXOR (inval : unsigned) return std_logic is
  begin
    return VectorXOR(std_logic_vector(inval));
  end VectorXOR;


  function VectorXNOR (inval : std_logic_vector) return std_logic is
  begin
    return (not VectorXOR(inval));
  end VectorXNOR;


  function VectorXNOR (inval : unsigned) return std_logic is
  begin
    return VectorXNOR(std_logic_vector(inval));
  end VectorXNOR;




  function VectScalAND(vect : std_logic_vector; scal : std_logic) return std_logic_vector is
    variable outval : std_logic_vector(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal and vect(k);
    end loop;
    return outval;
  end VectScalAND;

  function VectScalAND(vect : unsigned; scal : std_logic) return unsigned is
    variable outval : unsigned(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal and vect(k);
    end loop;
    return outval;
  end VectScalAND;


  function VectScalNAND(vect : std_logic_vector; scal : std_logic) return std_logic_vector is
    variable outval : std_logic_vector(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal nand vect(k);
    end loop;
    return outval;
  end VectScalNAND;

  function VectScalNAND(vect : unsigned; scal : std_logic) return unsigned is
    variable outval : unsigned(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal nand vect(k);
    end loop;
    return outval;
  end VectScalNAND;


  function VectScalOR(vect : std_logic_vector; scal : std_logic) return std_logic_vector is
    variable outval : std_logic_vector(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal or vect(k);
    end loop;
    return outval;
  end VectScalOR;

  function VectScalOR(vect : unsigned; scal : std_logic) return unsigned is
    variable outval : unsigned(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal or vect(k);
    end loop;
    return outval;
  end VectScalOR;


  function VectScalNOR(vect : std_logic_vector; scal : std_logic) return std_logic_vector is
    variable outval : std_logic_vector(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal nor vect(k);
    end loop;
    return outval;
  end VectScalNOR;

  function VectScalNOR(vect : unsigned; scal : std_logic) return unsigned is
    variable outval : unsigned(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal nor vect(k);
    end loop;
    return outval;
  end VectScalNOR;


  function VectScalXOR(vect : std_logic_vector; scal : std_logic) return std_logic_vector is
    variable outval : std_logic_vector(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal xor vect(k);
    end loop;
    return outval;
  end VectScalXOR;

  function VectScalXOR(vect : unsigned; scal : std_logic) return unsigned is
    variable outval : unsigned(vect'range);
  begin
    for k in vect'range loop
      outval(k) := scal xor vect(k);
    end loop;
    return outval;
  end VectScalXOR;

  
  function VectorNOT(inval : std_logic_vector) return std_logic_vector is
    variable outval : std_logic_vector(inval'range);
  begin
    for k in inval'range loop
      outval(k) := not inval(k);
    end loop;
    return outval;
  end VectorNOT;  

  function VectorNOT(inval : unsigned) return unsigned is
    variable outval : unsigned(inval'range);
  begin
    for k in inval'range loop
      outval(k) := not inval(k);
    end loop;
    return outval;
  end VectorNOT;  

end VHDLTools;


