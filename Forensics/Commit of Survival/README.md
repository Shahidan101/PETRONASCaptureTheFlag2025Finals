# Commit of Survival
## Challenge:
<img width="714" height="669" alt="image" src="https://github.com/user-attachments/assets/e2fbdcb0-ed1c-4bb5-a44d-470cbde87783" />

## Solution:
Download `oblivion_repo.tar.gz`. Extract the archive file.
</br></br>
<img width="1479" height="688" alt="image" src="https://github.com/user-attachments/assets/213ba745-230a-47ab-ad97-1cd0029b97de" />
</br></br>
Appears to be a Git repo and has a `.git` hidden folder (if we do `ls`, we won't see the folder. If we do `ls -la`, we'll see the folder).
</br></br>
Enter the directory and check the contents.
</br></br>
<img width="727" height="569" alt="image" src="https://github.com/user-attachments/assets/4899c1d7-5891-47ec-befb-329790b0347e" />
</br></br>
Let's check the contents of `COMMIT_EDITMSG`.
</br></br>
<img width="1016" height="135" alt="image" src="https://github.com/user-attachments/assets/0060f7f1-228e-4a00-82a6-b77a86362f9b" />
</br></br>
Looks to have interesting encoded text with indication of "Zero Code". Identify the encoded text using [dCode Cipher Identifier](https://www.dcode.fr/cipher-identifier). It's ASCII Code. Decrypt it.
</br></br>
<img width="984" height="420" alt="image" src="https://github.com/user-attachments/assets/9921aa06-3783-4e6d-bc66-0d86d514e547" />
</br></br>
The flag is `ZEROCODEKEY{G1T_H1ST0RY_N3V3R_L13S}`.
