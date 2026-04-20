# A0B Sensirion's sensors utilities

The a0b-sensirion crate provides essential low-level utilities for interfacing with Sensirion sensors, specifically focusing on the data integrity requirements of their communication protocols.
It offers specialized routines for CRC calculation and provides automated packet encoding and decoding logic that handles the insertion and deletion of CRC bytes.
By abstracting these boilerplate tasks, the crate ensures reliable data transmission and simplifies the implementation of drivers for any Sensirion hardware utilizing checksum-protected packets.
