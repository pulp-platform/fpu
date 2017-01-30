-------------------------------------------------------------------------------
-- Title      : Index Calculator for Logic Vectors
-- Project    : 
-------------------------------------------------------------------------------
-- File       : firstone.vhd
-- Author     : Michael Schaffner (schaffner@iis.ee.ethz.ch)
-- Company    : Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Description: 
--
-- determines the index of the first LSB which is nonzero in the vector Vector_DI. 
-- if needed, the vector can be flipped such that the index of the first nonzero 
-- MSB is calculated. this entity uses a tree structure to provide an acceptable 
-- combinatorial delay when large vectors are used. if there are no ones in the 
-- vector, the index is invalid and the signal NoOnes_SO will be asserted...
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author     Description
-- 2012/09/18  1.0      schaffner  created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.VHDLTools.all;


entity firstone is
  generic(
    G_VECTORLEN  : natural := 13;
    G_FLIPVECTOR : boolean := false
    );
  port (
    Vector_DI      : in  std_logic_vector(G_VECTORLEN-1 downto 0);
    FirstOneIdx_DO : out unsigned(log2ceil(G_VECTORLEN)-1 downto 0);
    NoOnes_SO      : out std_logic
    );
end firstone;

architecture RTL of firstone is
  
  constant C_NUM_LEVELS : natural := log2ceil(G_VECTORLEN);

  type   IndexLut_T is array (natural range <>) of unsigned(log2ceil(G_VECTORLEN)-1 downto 0);
  signal IndexLut_D : IndexLut_T(0 to G_VECTORLEN-1);

  signal SelNodes_D   : std_logic_vector(0 to 2**C_NUM_LEVELS-2);
  signal IndexNodes_D : IndexLut_T(0 to 2**C_NUM_LEVELS-2);

  signal TmpVector_D : std_logic_vector(Vector_DI'range);
  
begin

-----------------------------------------------------------------------------
--  flip vector if needed
-----------------------------------------------------------------------------
  
  noflip_g : if not G_FLIPVECTOR generate
    TmpVector_D <= Vector_DI;
  end generate noflip_g;

  flip_g : if G_FLIPVECTOR generate
    TmpVector_D <= VectorFliplr(Vector_DI);
  end generate flip_g;

-----------------------------------------------------------------------------
--  generate tree structure
-----------------------------------------------------------------------------

  index_lut_g : for k in 0 to G_VECTORLEN-1 generate
    IndexLut_D(k) <= to_unsigned(k, IndexLut_D(k)'length);
  end generate index_lut_g;

  levels_g : for level in 0 to C_NUM_LEVELS-1 generate
    --------------------------------------------------------------
    lower_levels_g : if level < C_NUM_LEVELS-1 generate
      nodes_on_level_g : for k in 0 to 2**level-1 generate
        SelNodes_D(2**level-1+k)   <= SelNodes_D(2**(level+1)-1+k*2) or SelNodes_D(2**(level+1)-1+k*2+1);
        IndexNodes_D(2**level-1+k) <= IndexNodes_D(2**(level+1)-1+k*2) when (SelNodes_D(2**(level+1)-1+k*2) = '1')
                                      else IndexNodes_D(2**(level+1)-1+k*2+1);
      end generate nodes_on_level_g;
    end generate lower_levels_g;
    --------------------------------------------------------------
    highest_level_g : if level = C_NUM_LEVELS-1 generate
      nodes_on_level_g : for k in 0 to 2**level-1 generate
        -- if two successive indices are still in the vector...
        both_valid_g : if k*2 < G_VECTORLEN-1 generate
          SelNodes_D(2**level-1+k)   <= TmpVector_D(k*2) or TmpVector_D(k*2+1);
          IndexNodes_D(2**level-1+k) <= IndexLut_D(k*2) when (TmpVector_D(k*2) = '1')
                                        else IndexLut_D(k*2+1);
        end generate both_valid_g;
        -- if only the first index is still in the vector...
        one_valid_g : if k*2 = G_VECTORLEN-1 generate
          SelNodes_D(2**level-1+k)   <= TmpVector_D(k*2);
          IndexNodes_D(2**level-1+k) <= IndexLut_D(k*2);
        end generate one_valid_g;
        -- if index is out of range
        none_valid_g : if k*2 > G_VECTORLEN-1 generate
          SelNodes_D(2**level-1+k)   <= '0';
          IndexNodes_D(2**level-1+k) <= (others => '0');
        end generate none_valid_g;
      end generate nodes_on_level_g;
    end generate highest_level_g;
    --------------------------------------------------------------
  end generate levels_g;

-----------------------------------------------------------------------------
--  connect output
-----------------------------------------------------------------------------

  FirstOneIdx_DO <= IndexNodes_D(0);
  NoOnes_SO      <= not SelNodes_D(0);

end RTL;

