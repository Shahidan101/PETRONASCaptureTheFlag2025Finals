# Backup Protocol Omega
## Challenge:
<img width="651" height="720" alt="image" src="https://github.com/user-attachments/assets/37f06f67-85fb-4ed4-9694-428e8a93e139" />

## Solution:
Download `oblivion_backup.bin`. Check what `file` it is.
</br></br>
<img width="763" height="192" alt="image" src="https://github.com/user-attachments/assets/ffff542d-d2a7-4b71-9e60-5e4878a58311" />
</br></br>
It appears to be a ZIP file. Let's try unzipping it.
</br></br>
<img width="735" height="180" alt="image" src="https://github.com/user-attachments/assets/6ef12a83-0fb6-4c67-8de1-272944a46b92" />
</br></br>
Looks like something is wrong with the ZIP and we can't unzip it directly. Let's check the hex data to see anything interesting.
</br></br>
<img width="695" height="149" alt="image" src="https://github.com/user-attachments/assets/d1595d9f-3e81-4b14-ae0e-8846041c772d" />
</br></br>
There appears to be a `zerocode.txt` file in the ZIP. We also notice:
</br></br>
- Local File Header ✓ (present at offset 0x00)
- File Data ✓ (present, compressed with DEFLATE)
- Central Directory ✗ (missing!)
- End of Central Directory Record ✗ (missing!)

</br></br>
The end of the central directory record (marks the end of ZIP) should have a signature of `50 4B 05 06`. Our file ends with:</br>
`00000050: 2832 4ea9 0500                           (2N...`
</br></br>
We'll need to fix the ZIP file. A common way to do it is using `zip -FF` command.
</br></br>
<img width="699" height="165" alt="image" src="https://github.com/user-attachments/assets/2ce13f66-e31d-4008-afd9-c2bf56877796" />
</br></br>
The output ZIP file generated is `recovered.zip`. We can now try to unzip the file.
</br></br>
<img width="699" height="324" alt="image" src="https://github.com/user-attachments/assets/b22ea5fa-d232-47af-9df0-0b7669abad88" />
</br></br>
Print out the contents of `zerocode.txt`.
</br></br>
<img width="683" height="138" alt="image" src="https://github.com/user-attachments/assets/4776f34f-3f9e-4570-90a1-51b4c05e560a" />
</br></br>
The flag is `ZEROCODEKEY{C0rRuPt3d_Str4Ctur3s_R3St0r3d}`.
