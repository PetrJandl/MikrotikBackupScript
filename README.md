# MikrotikBackupScript
Script pro automatické zálohování více zařízení Mikrotik
## Funkčnost ##
1) Využívám připojení na RB pomocí SSH a klíčů uložených ve složce keys/* (klíče je třeba nejprve vygenerovat a umístit na zařízeních)
2) Spustí se příkazy zobrazující informace, které zjistí verze software a firmware a % bad blocks :
  * /system resource print
  * /system routerboard print
3) Spustí se textová (rsc) i binární (backup) záloha RB
4) Pomocí SCP se soubory se zálohami přenesou do složky zalohy/* (dle zadaného názvu)
5) Pokud je jméno zařízení "TheDue______" spustí se také /dude export-db ...
6) Bohužel přes SCP nešlo přenést i všechny ostatní soubory, tedy jsem použil wget se zadaným jménem a heslem. Což přenese veškeré ostatní soubory.

## Spouštění ##
Spouští pomocí cron, každý 1 a 15 den v měsíci ve 2:22 
<code>22 2 1,15 * *    root cd /root/ScriptsCheck/mkb/; ./run.sh</code>
Email příjde i když je vše OK

