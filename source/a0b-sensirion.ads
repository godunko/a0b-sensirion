--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package provides utilities to compute Sensirion's CRC, decode and
--  encode packets.

pragma Restrictions (No_Elaboration_Code);

with A0B.Types.Arrays;

package A0B.Sensirion with Pure is

   function Compute_CRC
     (Data : A0B.Types.Arrays.Unsigned_8_Array) return A0B.Types.Unsigned_8;
   function Compute_CRC
     (Byte_1 : A0B.Types.Unsigned_8;
      Byte_2 : A0B.Types.Unsigned_8) return A0B.Types.Unsigned_8;
   --  Compute CRC using Sensirion's algorithm

   procedure Decode_I2C_Packet
     (Packet  : A0B.Types.Arrays.Unsigned_8_Array;
      Data    : out A0B.Types.Arrays.Unsigned_8_Array;
      Length  : out A0B.Types.Unsigned_32;
      Success : in out Boolean;
      Unknown : Boolean := False);
   --  Decode `Packet` into `Data` buffer and sets `Length` to actual length
   --  of the decoded data, even if `Data` buffer is not enough to store all
   --  decoded data.
   --
   --  When `Unknown` set to `True`, `Packet` might be large than read length of
   --  the data, and decoding is processed till checksum is valid. Error is not
   --  reported in this case. Application is responsible to fill buffer to some
   --  pattern to violate checksum check (bytes 16#00# and 16#FF# works well).

   procedure Encode_I2C_Packet
     (Data   : A0B.Types.Arrays.Unsigned_8_Array;
      Packet : out A0B.Types.Arrays.Unsigned_8_Array;
      Length : out A0B.Types.Unsigned_32);
   --  Encode `Data` into `Packet` and sets `Length` to actual length of the
   --  encoded packet. `Length` is set to the length of the encoded packet,
   --  regardless of the actual length of `Packet` buffer. Application is
   --  responsible to ensure that `Packet` buffer is large enough to store
   --  the encoded packet.

end A0B.Sensirion;
