# reverse dns scanner bash/powershell scripts
### Usage
#### bash

*help*
```
Usage: ./reversednsscan.sh <ipaddress> <mask> [OPTIONS]
Options:
 -h --help      Display this help message
 -d --dns       Specify a dns server address
 -o --output    Save output to file

For example:
./reversednsscan.sh 10.10.10.10 30
./reversednsscan.sh 192.168.1.0 24 -d 192.168.1.1 -f output.txt
```

#### powershell
```powershell
.\reversednsscan.ps1 -ip "10.10.10.10" -mask 23 -server "10.10.10.1"
```

---
### TODO 
* сделать проверку что утилита host доступна если нет выход с сообщением как пофиксить 
* сделать параметры по умолчанию для bash и для powershell скрипта (по умолчанию dns сервер и адрес и сеть одного из интерфейсов)
* сделать вывод в файл для powerxhell
* сделать обработчик ошибок для параметорв в powershell
