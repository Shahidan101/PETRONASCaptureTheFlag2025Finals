# Oblivion's Downlink
## Challenge:
<img width="545" height="537" alt="image" src="https://github.com/user-attachments/assets/6cb5c515-ff12-4a5a-a9cb-75288b5d4380" />

## Solution:
Download `oblivions_downlink.pcap`. Start with verifying the file type using `file <file>` command.
</br></br>
<img width="1471" height="896" alt="image" src="https://github.com/user-attachments/assets/0c5be29d-c669-4cb3-bdcd-2d7afe73a403" />
</br></br>
We are certain it's a PCAP file. Next, let's try to generate the strings from the PCAP using `strings <pcap file>`.
</br></br>
<img width="1467" height="419" alt="image" src="https://github.com/user-attachments/assets/aaeac63f-b120-45a9-9608-207f4623cdfe" />
</br></br>
<img width="1464" height="920" alt="image" src="https://github.com/user-attachments/assets/a5380acc-b187-4e5d-9dc0-cc48472add35" />
</br></br>
Something interesting at the end. There's a `flags.txt`. If we go further up, we'll notice a conversation.
</br></br>
<img width="1470" height="922" alt="image" src="https://github.com/user-attachments/assets/9d803181-5a00-4442-a3a5-dba3de425572" />
</br></br>
Something about data transfer at `10.13.37.10` and port `7331`. This is something we can filter out in Wireshark when we open the PCAP file. Let's do that.
</br></br>
<img width="1911" height="931" alt="image" src="https://github.com/user-attachments/assets/6d483f99-e13a-475c-8d01-160f64896332" />
</br></br>
At the filter section, enter `ip.addr == 10.13.37.10 && tcp.port == 7331`.
</br></br>
<img width="1919" height="925" alt="image" src="https://github.com/user-attachments/assets/7943eb8c-1adb-4faa-a0f7-b7304fa48917" />
</br></br>
As we move down to No. 128, we notice there's Data (1400 bytes) with "flags.txt" in it. If we click the "flags.txt" section of the data, it will the portion of the data for us to extract. For those of you who are familiar with ZIP file headers, you can see that the file is indeed a ZIP file containing flags.txt (starts with PK).
</br></br>
<img width="1911" height="806" alt="image" src="https://github.com/user-attachments/assets/407950de-703f-4e6e-b27b-bd31437cadd9" />
</br></br>
Right-click No. 128 and follow the TCP Stream (Right-click >> Follow >> TCP Stream). 
</br></br>
<img width="1277" height="916" alt="image" src="https://github.com/user-attachments/assets/b55030a5-ce61-4f0a-8bc3-0dbb89e7a676" />
</br></br>
We can save this chunk of data as a file. Click "Save As..." and save it somewhere. I named it as `output.zip`.
</br></br>
<img width="1473" height="932" alt="image" src="https://github.com/user-attachments/assets/abd4ee37-14de-4f8f-bf5a-2b5db43d853d" />
</br></br>
If we unzip the ZIP, we notice that it's password-protected. Remember during the `strings` section earlier, the conversation mentions that the archive is protected, and the password is 7 characters, all lowercase. You could consider brute-forcing all possibilities (that would be 8,031,810,176 possibilities), or we can use `hashcat`.
</br></br>
We must first generate the hashcat hash. We can use `zip2john` but convert it to hashcat format.
</br></br>
<img width="1468" height="925" alt="image" src="https://github.com/user-attachments/assets/0fa17407-2ea7-4a86-8627-03493566593d" />
</br></br>
Some explanation on the command `zip2john output.zip | cut -d: -f2 > hashcat_hash.txt`:
</br></br>
`zip2john output.zip` - Extracts the password hash from the encrypted ZIP file. Output `output.zip:$pkzip$1*1*2*0*6fd0*4f587*8adf19a3*0*43*8*6fd0*4269...*$/pkzip$`.
</br></br>
`cut` - A command-line utility for cutting out sections from files or input
</br>
`-d:` - Sets the delimiter to colon `:`
</br>
`-f2` - Selects the second field (the part after the first colon)
</br></br>
After the slicing, the hash output is `$pkzip$1*1*2*0*6fd0*4f587*8adf19a3*0*43*8*6fd0*4269...*$/pkzip$` instead of `output.zip:$pkzip$1*1*2*0*6fd0*4f587*8adf19a3*0*43*8*6fd0*4269...*$/pkzip$` from zip2john directly. This is done because hashcat expects only the hash data, not the filename.
</br></br>
After getting the hash file, we then use `hashcat` to recover the password.
</br></br>
<img width="1470" height="930" alt="image" src="https://github.com/user-attachments/assets/bb2bdbb6-d751-4191-b6c5-039fd38315bd" />
</br></br>
`-m` - Specifies the hash mode (type of hash to crack)
</br>
`17200` - The specific mode for PKZIP (Compressed). We know this after running `zip2john`.
</br>
`-a` - Specifies the attack mode
</br>
`3` - Brute-force attack (also called "mask attack")
</br>
`?l?l?l?l?l?l?l` - Mask pattern. `?l` represents one lowercase letter (a-z)
</br>
`--force` - I think this is optional in this case. I used it to force hashcat to run even if there are warnings
</br></br>
<img width="1479" height="437" alt="image" src="https://github.com/user-attachments/assets/e00ded5d-bf0f-44f3-946f-44945cbeef08" />
</br></br>
Disclaimer: I got a different output the first time I did hashcat. But either way, you should get the password recovered. To show the password, enter `hashcat -m 17200 --show hashcat_hash.txt`.
</br></br>
<img width="1468" height="927" alt="image" src="https://github.com/user-attachments/assets/63901e3c-3c6d-4bc4-8008-89c8b70572ab" />
</br></br>
At the end of the file, you'll notice `eclipse`, which is a 7-character, all lowercase word. Use that as the ZIP password.
</br></br>
<img width="1474" height="927" alt="image" src="https://github.com/user-attachments/assets/e72500ee-e52d-4787-b9dd-dc9a739d3611" />
</br></br>
Print out the contents of `flags.txt`. 
</br></br>
<img width="1472" height="931" alt="image" src="https://github.com/user-attachments/assets/2185200a-3887-4daa-8c06-b5cf487113df" />
</br></br>
There appears to be a bunch of encoded text. We can use [dCode Cipher Identifider](https://www.dcode.fr/cipher-identifier) to find out what it is. Let's try out the first line of text.
</br></br>
<img width="1586" height="823" alt="image" src="https://github.com/user-attachments/assets/ec675733-1865-44c6-9c3e-5db63f6460d1" />
</br></br>
It indicates that it's Base32. Decrypt the text from Base32.
</br></br>
<img width="1582" height="824" alt="image" src="https://github.com/user-attachments/assets/f448acf4-8169-452f-8940-6c5885ea9b57" />
</br></br>
The flag is `ZEROCODEKEY{TH3_D4RK_F4LLS_T0_L1GHT}`.
