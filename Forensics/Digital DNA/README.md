# Digital DNA
## Challenge:
<img width="690" height="690" alt="image" src="https://github.com/user-attachments/assets/b7fcb478-8540-4ede-9af2-696c86ac902a" />

## Solution:
Download `genetic_sequence_v2.fasta`. Check the contents of the file.
</br></br>
<img width="1463" height="171" alt="image" src="https://github.com/user-attachments/assets/180c0aed-5122-4f28-ab08-74e270387f28" />
</br></br>
Looks to contain interesting binary data. We can try decrypting the binary data using [CyberChef](https://gchq.github.io/CyberChef/).
</br></br>
<img width="1904" height="727" alt="image" src="https://github.com/user-attachments/assets/68c07e69-ed96-4d14-97ad-26302718cd19" />
</br></br>
We have a timestamp and an encoded payload. Let's first try decoding the payload.
</br></br>
<img width="1007" height="655" alt="image" src="https://github.com/user-attachments/assets/54eaf899-a9fe-45bb-addd-20f7e112d574" />
</br></br>
<img width="1022" height="632" alt="image" src="https://github.com/user-attachments/assets/d4656354-b7c6-4591-81a5-cc92762e210f" />
</br></br>
Decrypting it directly doesn't look to generate anything. Another recommendation was that it's using a XOR cipher.
</br></br>
<img width="989" height="702" alt="image" src="https://github.com/user-attachments/assets/b85b64b7-3b91-4461-8fe3-19e957bb417d" />
</br></br>
Doesn't look like anything useful.
</br></br>
Maybe the timestamp is useful. Some simple XOR encryptions use timestamps or random numbers generated with current time as seeds.
</br></br>
The timestamp appears to be hexadecimal (because if we tried decrypting it from hex, we get `21470704123456`, which hints to `2147-07-04 12:34:56`. The whole premise of this CTF is about being in the future around that year). We use the timestamp as the hexadecimal key.
</br></br>
<img width="1008" height="581" alt="image" src="https://github.com/user-attachments/assets/e5b94be4-c877-4ddd-ba29-10cadaced514" />
</br></br>
The flag is `ZEROCODEKEY{DN4_15_C00L}`.
